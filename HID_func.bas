
sub fillcombo()

	Dim As integer cnt = 0

	cnt = libusb_get_device_list(NULL, @ppList)
	If (cnt < 0) then
    End cnt
	End if

	gtk_combo_box_text_remove_all(GTK_COMBO_BOX_TEXT(combo))
	for i as integer = 0 to cnt-1
		returnvalue = libusb_get_device_descriptor(ppList[i], @desc) 
		gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT(combo),_
			Hex(desc.idVendor,4) & ":" & Hex(desc.idProduct,4))
	next i
	gtk_combo_box_set_active(GTK_COMBO_BOX(combo), 0)

End sub

Function btn2_clicked() as gboolean
	
	fillcombo()
	
	return TRUE
      
End Function 

Function btn4_clicked() as gboolean
	
	stop_read = 0
	
	return TRUE
      
End Function 

Function btn5_clicked() as gboolean
	
	stop_read = 1
	
	return TRUE
      
End Function 

Function btn3_clicked() as gboolean
	
	stop_read = 0

	/'Dim As uinteger countbytes = 0
	Dim As multireturn returnvalues
	Dim As Ubyte counter = 1
	Dim As uinteger size = 2048
	Dim As Ubyte databuffer(size)
	Dim As Ubyte databuffer_oud1 = 0
	Dim As Ubyte databuffer_oud2 = 0
	Dim As Ubyte databuffer_oud3 = 0
	Dim As Ubyte databuffer_oud4 = 0
	Dim As Ubyte ptr dbuf = @databuffer(0)
	Dim As String key


	Do
	
		returnvalues = bulk_tranfer(DHandle(counter-1), in_endpoint(0), dbuf, in_packsize(0), 1, 0)
		If (returnvalues.B = -4) then 
			Exit Do
		End If
		If (returnvalues.B <> -7) then
			If (returnvalues.A>0) then
				pro(Str(returnvalues.A) + !" bytes received\n")
				pro("aantal * " + Str(returnvalues.A) + (" = ") + Str(countbytes) + !"\n")
				countbytes = countbytes + returnvalues.A
				For ii as integer = 0 To returnvalues.A - 1 Step 4
					'if (databuffer(ii) <> databuffer_oud1) or (databuffer(ii+1) <> databuffer_oud2) or (databuffer(ii+2) <> databuffer_oud3) or (databuffer(ii+3) <> databuffer_oud4 )then 
						? databuffer(ii); ", "; databuffer(ii+1); ", "; databuffer(ii+2); ", "; databuffer(ii+3); ", " 
					'End If
					'databuffer_oud1 = databuffer(ii)
					'databuffer_oud2 = databuffer(ii+1)
					'databuffer_oud3 = databuffer(ii+2)
					'databuffer_oud4 = databuffer(ii+3)
				Next ii
			'?
			'? "packet nr."; 256*databuffer(62)+databuffer(63)
			End If
		End If
		key = Inkey
		If (key <> "") then
			? countbytes
		'	? "key pressed: "; asc(key)
		'	databuffer(0) = asc(key)
		'	returnvalues = transfer_data(DHandle(counter-1), out_endpoint(0), dbuf, out_packsize(0), 100, 100)
		End If

	Loop Until key = chr$(27)'/
	
	return TRUE
      
End Function 

Function btn1_clicked() as gboolean

	Dim As integer i
	Dim As Ubyte counter
	Dim As Ubyte sup_out = 0
	Dim AS libusb_device ptr pDevice
	Dim As libusb_config_descriptor ptr Dconfig
	Dim As Const libusb_interface Ptr inter
	Dim As Const libusb_interface_descriptor Ptr interdesc
	Dim As Ubyte in_cnt = 0
	Dim As Ubyte out_cnt = 0
	Dim As uinteger out_packsize(10)

	Erase in_endpoint
	Erase out_endpoint
	Erase in_packsize

	counter = 0
	
	clearbuf(textbuffer, iter)
	clearbuf(infobuffer, iterinfo)
	
	i = gtk_combo_box_get_active(GTK_COMBO_BOX(combo))
	pDevice = ppList[i]
	returnvalue = libusb_get_device_descriptor(pDevice, @desc)
	'pr (Hex(desc.idVendor,4)+":"+Hex(desc.idProduct,4)+!"\n")
	
  	'pr(!"\n")
	?(!"Found the device\t\t\t" + Str(pDevice) + !"\n")
	'? pDevice
	DHandle(counter) = open_device(pDevice)
	
	If (DHandle(counter) = 0) Then
		Exit Function
	End If
		
	returnvalue = print_device_descriptor(desc, sup_out)
	returnvalue = print_vendor_info(DHandle(counter), desc, 0)
		
	returnvalue = libusb_get_config_descriptor(pDevice, 0, @Dconfig)
 
		If returnvalue = 0 Then
			returnvalue = print_config_descriptor(Dconfig, sup_out)			
		    For ii as integer = 0 To Dconfig->bNumInterfaces - 1
				inter = @Dconfig->interface[ii]
				pr(!"  Number of alternate settings:" + Str(inter->num_altsetting) + !"\n")
				For j as integer = 0 To inter->num_altsetting - 1
					interdesc = @inter->altsetting[j]
					returnvalue = print_interface_descriptor(interdesc, sup_out)
					returnvalue = print_interface_info(DHandle(counter), interdesc, sup_out)
					pr(!"  number of endpoints:\t\t" + Str(interdesc->bNumEndpoints) + !"\n")
					For k as integer = 0 To interdesc->bNumEndpoints - 1
						epdesc = @interdesc->endpoint[k]
						returnvalue = print_endpoint_descriptor(epdesc, sup_out)
						if (sup_out = 0) then 
							? ii;" ";j;" ";k
						End If
						If (epdesc->bEndpointAddress >= 128) then
							in_endpoint(in_cnt) = epdesc->bEndpointAddress
							in_packsize(in_cnt) = epdesc->wMaxPacketSize
							in_cnt = in_cnt + 1
						End if
						If (epdesc->bEndpointAddress < 128) then
							out_endpoint(out_cnt) = epdesc->bEndpointAddress
							out_packsize(out_cnt) = epdesc->wMaxPacketSize
							out_cnt = out_cnt + 1
						End if
						If (sup_out = 0) then
							? "ep address "; epdesc->bEndpointAddress
							? "in "; in_endpoint(in_cnt)
							? "out "; out_endpoint(out_cnt)
						End If
					Next k
				Next j
			Next ii			
		Else
			pr(!"Error getting config descriptor" + !"\n")
			End returnvalue
		End IF
	
	pr(!"\n")	
	pr(!"  in endpoint 0:\t" + Str(in_endpoint(0)) + !"\n")
	pr(!"  in endpoint 1:\t" + Str(in_endpoint(1)) + !"\n")
	pr(!"  out endpoint 0:\t" + Str(out_endpoint(0)) + !"\n")
	pr(!"  out endpoint 1:\t" + Str(out_endpoint(1)) + !"\n")


	return TRUE
      
End Function 

Function check_scroll_changed Cdecl(Byval widget As GtkWidget Ptr, BYVAL u_data as gpointer) as gboolean

	'g_print ("checkbox event: %s\n", u_data)

	scroll_on = gtk_toggle_button_get_active(GTK_BUTTON(check_scroll))
	
	? scroll_on
	
	return TRUE
    
End Function

Function combo_changed Cdecl(Byval widget As GtkWidget Ptr) as gboolean

	'Dim As gchar Ptr text

	'text =  gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(widget))
	'gtk_entry_set_text(GTK_ENTRY(test_Entry), text)
	'g_free(text)

	return TRUE
    
End Function

Function timer1000_active Cdecl(BYVAL u_data as gpointer) as gboolean

	Var pdata1000 = Cast(timer_1000 Ptr, u_data)
	'? *pdata1000->teller

    return TRUE
    
End Function

Function timer100_active Cdecl(BYVAL u_data as gpointer) as gboolean

	Var pdata100 = Cast(timer_1000 Ptr, u_data)
	'? *pdata100->teller

    return TRUE
    
End Function

Function timer10_active Cdecl(BYVAL u_data as gpointer) as gboolean

if stop_read = 1 then

	databuffer_oud1 = 0
	databuffer_oud2 = 0
	databuffer_oud3 = 0
	databuffer_oud4 = 0
	
End If

if stop_read = 0 then
	
	Dim As uinteger countbytes = 0
	Dim As multireturn returnvalues
	Dim As Ubyte counter = 1
	Dim As uinteger size = 2048
	Dim As Ubyte databuffer(size)
	'Dim As Ubyte databuffer_oud1 = 0
	'Dim As Ubyte databuffer_oud2 = 0
	'Dim As Ubyte databuffer_oud3 = 0
	'Dim As Ubyte databuffer_oud4 = 0
	Dim As Ubyte ptr dbuf = @databuffer(0)
	Dim As String key


		returnvalues = bulk_tranfer(DHandle(counter-1), in_endpoint(0), dbuf, in_packsize(0), 1, 0)
		If (returnvalues.B = -4) then 
			Exit Function
		End If
		If (returnvalues.B <> -7) then
			If (returnvalues.A>0) then
				'pro(Str(returnvalues.A) + !" bytes received\n")
				'pro("aantal * " + Str(returnvalues.A) + (" = ") + Str(countbytes) + !"\n")
				countbytes = countbytes + returnvalues.A
				For ii as integer = 0 To returnvalues.A - 1 Step 4
					if (databuffer(ii) <> databuffer_oud1) or (databuffer(ii+1) <> databuffer_oud2) or (databuffer(ii+2) <> databuffer_oud3) or (databuffer(ii+3) <> databuffer_oud4 )then 
						pro(Str(databuffer(ii)) + ", "_
						+ Str(databuffer(ii+1)) + ", "_
						+ Str(databuffer(ii+2)) + ", "_
						+ Str(databuffer(ii+3)) + ", "_
						+ !"\n") 
					End If
					databuffer_oud1 = databuffer(ii)
					databuffer_oud2 = databuffer(ii+1)
					databuffer_oud3 = databuffer(ii+2)
					databuffer_oud4 = databuffer(ii+3)
				Next ii
			'?
			'? "packet nr."; 256*databuffer(62)+databuffer(63)
			End If
		End If
		key = Inkey
		If (key <> "") then
			? countbytes
		'	? "key pressed: "; asc(key)
		'	databuffer(0) = asc(key)
		'	returnvalues = transfer_data(DHandle(counter-1), out_endpoint(0), dbuf, out_packsize(0), 100, 100)
		End If

	Var pdata10 = Cast(timer_10 Ptr, u_data)
	'? *pdata10->teller

	'? dialog_m.d_response

End If

return TRUE


    
End Function

sub dialog_message()

	Dim As gint resp

	Dim As GtkWidget ptr dialog
	Dim As GtkWidget ptr label
	Dim As GtkWidget ptr content_area
	
	Dim As GtkDialogFlags flags
	
	flags = GTK_DIALOG_DESTROY_WITH_PARENT
	
	if (*dialog_m.d_but2 = "") then
		dialog = gtk_dialog_new_with_buttons (*dialog_m.d_name,_
			GTK_WINDOW(t_window), flags,_
			*dialog_m.d_but1, 20, NULL)
	else
		dialog = gtk_dialog_new_with_buttons (*dialog_m.d_name,_
			GTK_WINDOW(t_window), flags,_
			*dialog_m.d_but1, 20, *dialog_m.d_but2, 30, NULL)
	End IF
	
 	gtk_widget_set_size_request(dialog, 350, 75)
 	
 	content_area = gtk_dialog_get_content_area (GTK_DIALOG(dialog))
	label = gtk_label_new("")	
	gtk_label_set_line_wrap(GTK_LABEL(label), True)
	gtk_label_set_text(GTK_LABEL(label),_
		*dialog_m.d_text)
	
	gtk_container_add (GTK_CONTAINER (content_area), label)
	gtk_widget_show_all (dialog)
	
	resp = gtk_dialog_run(GTK_DIALOG(dialog))
	
	if (resp = 20) then
		? "ok button"
		gtk_widget_destroy(dialog)
	elseif (resp = 30) then		
		? "other button"
		gtk_widget_destroy(dialog)
	End If
	  
	'g_signal_connect_swapped (dialog, "response",_
		'G_CALLBACK(@gtk_widget_destroy), dialog)
		
	dialog_m.d_response = resp

End sub

Function create_menubar() as integer

	dialog_m.d_name = @"HID reader"
	dialog_m.d_text = @"HID reader for Linux - Version 1.0"
	dialog_m.d_but1 = @"OK"
	dialog_m.d_but2 = @"Show details"


	Dim As GtkWidget ptr menubar
	Dim As GtkWidget ptr fileMenu
	Dim As GtkWidget ptr helpMenu
	Dim As GtkWidget ptr fileMi
	Dim As GtkWidget ptr helpMi
	Dim As GtkWidget ptr quitMi
	Dim As GtkWidget ptr aboutMi

	Dim As GtkWidget ptr sep
	
	menubar = gtk_menu_bar_new()
	gtk_fixed_put(GTK_FIXED(fixed), menubar, 20, 0)

	fileMenu = gtk_menu_new()
	helpMenu = gtk_menu_new()
  
	fileMi = gtk_menu_item_new_with_mnemonic("_File")
	helpMi = gtk_menu_item_new_with_mnemonic("_Help")
	'sep = gtk_separator_menu_item_new()
	quitMi = gtk_image_menu_item_new_from_stock(GTK_STOCK_QUIT, _
	  accel_group)
	aboutMi = gtk_image_menu_item_new_from_stock(GTK_STOCK_ABOUT, _
	  accel_group)

	gtk_widget_add_accelerator(quitMi, "activate", accel_group, _
	  GDK_KEY_Q, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE) 

	gtk_menu_item_set_submenu(GTK_MENU_ITEM(fileMi), fileMenu)
	gtk_menu_shell_append(GTK_MENU_SHELL(fileMenu), quitMi)
	gtk_menu_shell_append(GTK_MENU_SHELL(menubar), fileMi)
	
	gtk_widget_add_accelerator(aboutMi, "activate", accel_group, _
	  GDK_KEY_H, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE) 

	gtk_menu_item_set_submenu(GTK_MENU_ITEM(helpMi), helpMenu)
	gtk_menu_shell_append(GTK_MENU_SHELL(helpMenu), aboutMi)
	gtk_menu_shell_append(GTK_MENU_SHELL(menubar), helpMi)

	g_signal_connect(G_OBJECT(quitMi), "activate", _
        G_CALLBACK(@gtk_main_quit), NULL)
        
	g_signal_connect(G_OBJECT(aboutMi), "activate", _ 						' connect button to function signup_button_clicked
        G_CALLBACK(@dialog_message), cast (gpointer, NULL))

	return 0
	
End Function

Function create_window() as integer

	t_window = gtk_window_new(GTK_WINDOW_TOPLEVEL)
	gtk_widget_modify_font(t_window, wpfd)
	gtk_container_set_border_width (GTK_CONTAINER (t_window), 0)			' create top level window
	gtk_window_set_title(GTK_WINDOW(t_window), "HID reader")
	gtk_window_set_default_size(GTK_WINDOW(t_window), 880, 660)
	gtk_window_set_position(GTK_WINDOW(t_window), GTK_WIN_POS_CENTER)

	fixed = gtk_fixed_new()
	gtk_container_add(GTK_CONTAINER(t_window), fixed)
    gtk_window_set_resizable(GTK_WINDOW(t_window),FALSE)

	g_signal_connect(t_window, "destroy", _
      G_CALLBACK(@gtk_main_quit), NULL)  

	accel_group = gtk_accel_group_new()
	gtk_window_add_accel_group(GTK_WINDOW(t_window), accel_group)

	return 0

End Function

Function create_elements() as integer

	'test_Entry = gtk_entry_new() 	
	'gtk_fixed_put(GTK_FIXED(fixed), test_Entry, 115, 10)
	'gtk_widget_set_size_request(test_Entry, 90, 30)

	btn1 = gtk_button_new_with_label("Open device")
	gtk_fixed_put(GTK_FIXED(fixed), btn1, 150, 60)
	gtk_widget_set_size_request(btn1, 120, 30)

	btn2 = gtk_button_new_with_label("Reload devices")			' create new button
	gtk_fixed_put(GTK_FIXED(fixed), btn2, 150, 20)
	gtk_widget_set_size_request(btn2, 120, 30)

	btn3 = gtk_button_new_with_label("Bulk read")
	gtk_fixed_put(GTK_FIXED(fixed), btn3, 280, 20)
	gtk_widget_set_size_request(btn3, 120, 30)

	btn4 = gtk_button_new_with_label("Interupt read")
	gtk_fixed_put(GTK_FIXED(fixed), btn4, 410, 20)
	gtk_widget_set_size_request(btn4, 120, 30)

	btn5 = gtk_button_new_with_label("Stop read")
	gtk_fixed_put(GTK_FIXED(fixed), btn5, 410, 60)
	gtk_widget_set_size_request(btn5, 120, 30)

	label1 = gtk_label_new("List of devices") 							' create new label
	gtk_misc_set_alignment(GTK_MISC(label1), 0, 0.5)
	gtk_fixed_put(GTK_FIXED(fixed), label1, 20, 35)
	gtk_widget_set_size_request(label1, 200, 30)

	label2 = gtk_label_new("Label 2") 	
	'gtk_fixed_put(GTK_FIXED(fixed), label2, 340, 10)
	'gtk_widget_set_size_request(label2, 90, 30)
	
	'check_scroll = gtk_toggle_button_new_with_label("auto scroll")
	
	check_scroll = gtk_check_button_new_with_label("auto scroll")
	gtk_fixed_put(GTK_FIXED(fixed), check_scroll, 280, 60)
	gtk_widget_set_size_request(check_scroll, 90, 30)

	combo = gtk_combo_box_text_new() 	
	gtk_fixed_put(GTK_FIXED(fixed), combo, 20, 60)
	gtk_widget_set_size_request(combo, 120, 30)

	textview = gtk_text_view_new()	
	gtk_widget_override_background_color(textview,_
		GTK_STATE_FLAG_NORMAL, @backgrcol)
	gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(textview),_
		GTK_WRAP_WORD_CHAR)

	scrtextwin = gtk_scrolled_window_new(NULL, NULL)
	
	gtk_container_set_border_width (GTK_CONTAINER (scrtextwin), 0)
	gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrtextwin),_
		GTK_POLICY_AUTOMATIC, GTK_POLICY_ALWAYS)
	gtk_container_add(GTK_CONTAINER(scrtextwin), textview)
	gtk_fixed_put(GTK_FIXED(fixed), scrtextwin, 20, 100)
	gtk_widget_set_size_request(scrtextwin, 250, 540)
	gtk_widget_modify_font(scrtextwin, pfd)
	
	outputview = gtk_text_view_new()
	gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(outputview),_
		GTK_WRAP_WORD_CHAR)
	
	scroutputwin = gtk_scrolled_window_new(NULL, NULL)
	
	gtk_container_set_border_width (GTK_CONTAINER (scroutputwin), 0)
	gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroutputwin),_
		GTK_POLICY_AUTOMATIC, GTK_POLICY_ALWAYS)
	gtk_container_add(GTK_CONTAINER(scroutputwin), outputview)
	gtk_fixed_put(GTK_FIXED(fixed), scroutputwin, 280, 100)
	gtk_widget_set_size_request(scroutputwin, 580, 540)
	gtk_widget_modify_font(scroutputwin, pfd)
	
	infoview = gtk_text_view_new()
	gtk_fixed_put(GTK_FIXED(fixed), infoview, 540, 20)
	gtk_widget_set_size_request(infoview, 320, 70)

	textbuffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(textview))
	outputbuffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(outputview))
	infobuffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(infoview))

	gtk_text_buffer_get_end_iter(outputbuffer, @end_i)
	text_mark_end = gtk_text_buffer_create_mark(outputbuffer,_
		NULL, @end_i, FALSE)

	gtk_text_buffer_create_tag(textbuffer, "gap",_
        "pixels_above_lines", 8, NULL)
	gtk_text_buffer_create_tag(textbuffer, "lmarg",_
		"left_margin", 5, NULL)
	gtk_text_buffer_create_tag(textbuffer, "blue_fg",_
		"foreground", "blue", NULL) 
	gtk_text_buffer_create_tag(textbuffer, "gray_bg",_
		"background", "gray", NULL) 
	gtk_text_buffer_create_tag(textbuffer, "italic", _
		"style", PANGO_STYLE_ITALIC, NULL)
	gtk_text_buffer_create_tag(textbuffer, "bold",_
		"weight", PANGO_WEIGHT_BOLD, NULL)

	gtk_text_buffer_create_tag(outputbuffer, "gap",_
        "pixels_above_lines", 8, NULL)
	gtk_text_buffer_create_tag(outputbuffer, "lmarg",_
		"left_margin", 5, NULL)
	gtk_text_buffer_create_tag(outputbuffer, "blue_fg",_
		"foreground", "blue", NULL) 
	gtk_text_buffer_create_tag(outputbuffer, "gray_bg",_
		"background", "gray", NULL) 
	gtk_text_buffer_create_tag(outputbuffer, "italic", _
		"style", PANGO_STYLE_ITALIC, NULL)
	gtk_text_buffer_create_tag(outputbuffer, "bold",_
		"weight", PANGO_WEIGHT_BOLD, NULL)

	gtk_text_buffer_create_tag(infobuffer, "gap",_
        "pixels_above_lines", 8, NULL)
	gtk_text_buffer_create_tag(infobuffer, "lmarg",_
		"left_margin", 5, NULL)
	gtk_text_buffer_create_tag(infobuffer, "blue_fg",_
		"foreground", "blue", NULL) 
	gtk_text_buffer_create_tag(infobuffer, "gray_bg",_
		"background", "gray", NULL) 
	gtk_text_buffer_create_tag(infobuffer, "italic", _
		"style", PANGO_STYLE_ITALIC, NULL)
	gtk_text_buffer_create_tag(infobuffer, "bold",_
		"weight", PANGO_WEIGHT_BOLD, NULL)
		
	gtk_text_buffer_get_iter_at_offset(textbuffer, @iter, 0)
	gtk_text_buffer_get_iter_at_offset(outputbuffer, @iteroutput, 0)
	gtk_text_buffer_get_iter_at_offset(infobuffer, @iterinfo, 0)

	g_signal_connect(btn1,"clicked", _ 						' connect button to function signup_button_clicked
        G_CALLBACK(@btn1_clicked),NULL)
	
	g_signal_connect(btn2,"clicked", _ 						' connect button to function signup_button_clicked
        G_CALLBACK(@btn2_clicked),NULL)
	
	g_signal_connect(btn3,"clicked", _ 						' connect button to function signup_button_clicked
        G_CALLBACK(@btn3_clicked),NULL)

	g_signal_connect(btn4,"clicked", _ 						' connect button to function signup_button_clicked
        G_CALLBACK(@btn4_clicked),NULL)

	g_signal_connect(btn5,"clicked", _ 						' connect button to function signup_button_clicked
        G_CALLBACK(@btn5_clicked),NULL)

	g_signal_connect(G_OBJECT(combo), "changed",_
		G_CALLBACK(@combo_changed), NULL)		

	'g_signal_connect(G_OBJECT(check_scroll), "clicked",_
		'G_CALLBACK(@check_scroll_changed), NULL)		
		
		
		
	'g_signal_connect (G_OBJECT (check_scroll), "toggled",_
			'G_CALLBACK (@check_scroll_changed), @"check 3 toggled")
    'g_signal_connect (G_OBJECT (check_scroll), "pressed",_
			'G_CALLBACK (@check_scroll_changed), @"check 3 pressed")
    'g_signal_connect (G_OBJECT (check_scroll), "released",_
			'G_CALLBACK (@check_scroll_changed), @"check 3 released")
    g_signal_connect (G_OBJECT (check_scroll), "clicked",_
			G_CALLBACK (@check_scroll_changed), @"check 3 clicked")
    'g_signal_connect (G_OBJECT (check_scroll), "enter",_
			'G_CALLBACK (@check_scroll_changed), @"check 3 enter")
   ' g_signal_connect (G_OBJECT (check_scroll), "leave",_
			'G_CALLBACK (@check_scroll_changed), @"check 3 leave")

		
	return 0

End Function



