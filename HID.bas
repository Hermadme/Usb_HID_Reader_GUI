'Free basic Address Event Representation

#DEFINE __USE_GTK3__ 														' GTK-3 Version
#INCLUDE "gtk/gtk.bi" 		
#INCLUDE "gdk/gdk.bi"	
#If Defined(__FB_LINUX__)  
 ? "Linux"
#Else
 ? "Windows"
#EndIf

#include once "libusb-1.0.bi"

Type multireturn
    As long A,B,C
End Type

Type timer_1000
  'As gchar ptr mypointer = @"appeltaart"
  As gchar ptr teller = @"1000"
  As guint my_timer = 1000
End Type

Type timer_100
  'As gchar ptr mypointer = @"appeltaart"
  As gchar ptr teller = @"100"
  As guint my_timer = 100
End Type

Type timer_10
  'As gchar ptr mypointer = @"appeltaart"
  As gchar ptr teller = @"10"
  As guint my_timer = 10
End Type

Type dialog1
  As gchar ptr d_name
  As gchar ptr d_text
  As gchar ptr d_but1
  As gchar ptr d_but2
  As integer d_response

End Type

	Dim shared As libusb_device_handle ptr DHandle(10)
	Dim shared As Ubyte in_endpoint(10)
	Dim shared As Ubyte out_endpoint(10)
	Dim shared As uinteger in_packsize(10)


dim shared as GdkRGBA backgrcol
gdk_rgba_parse(@backgrcol, "rgb(225,250,255)")

dim shared as libusb_device_descriptor desc
'Dim As libusb_transfer_cb_fn call_back 
'Dim As integer conf
dim shared as libusb_device ptr ptr ppList
dim shared as Long returnvalue
Dim As Const libusb_interface_descriptor Ptr interdesc
dim shared as Const libusb_endpoint_descriptor Ptr epdesc
'Dim As libusb_transfer Ptr xfr
'Dim As uinteger size = 2048
'Dim As Ubyte databuffer(size)
Dim shared As Ubyte databuffer_oud1 = 0
Dim shared As Ubyte databuffer_oud2 = 0
Dim shared As Ubyte databuffer_oud3 = 0
Dim shared As Ubyte databuffer_oud4 = 0
Dim shared as integer scroll_on = 0
Dim shared as integer stop_read = 1

Dim shared dialog_m as dialog1
  
? *dialog_m.d_text

Dim shared as GtkWidget ptr btn1
Dim shared as GtkWidget ptr btn2								 			' button
Dim shared as GtkWidget ptr btn3								 			' button
Dim shared as GtkWidget ptr btn4								 			' button
Dim shared as GtkWidget ptr btn5								 			' button
Dim shared as GtkWidget ptr label1											' label
Dim shared as GtkWidget ptr label2											' label
'Dim shared as GtkWidget ptr test_Entry		
Dim shared as GtkWidget ptr combo
Dim shared as GtkWidget ptr textview		
Dim shared as GtkWidget ptr outputview		
Dim shared as GtkWidget ptr infoview		
'Dim shared as GtkWidget ptr hbox
'Dim shared as GtkWidget ptr radio
Dim shared as GTKWidget ptr scrtextwin
Dim shared as GTKWidget ptr scroutputwin


Dim shared as GtkTextIter iter
Dim shared as GtkTextIter iteroutput
Dim shared as GtkTextIter iterinfo
Dim shared as GtkTextIter start_i
Dim shared as GtkTextIter end_i

Dim shared as GtkTextMark ptr text_mark_end

Dim shared as GtkWidget ptr check_scroll


'dim shared tag as GtkTextTag ptr

'Dim shared as GtkAdjustment ptr textadj
'Dim shared as GtkWidget ptr scrolledtext

Dim shared as Gtktextbuffer ptr textbuffer
Dim shared as Gtktextbuffer ptr outputbuffer
Dim shared as Gtktextbuffer ptr infobuffer

'Dim shared as integer returnvalue	
										' function return value
Dim shared as GtkWidget ptr about_dialog										' top level window

Dim shared as GtkWidget ptr t_window										' top level window
Dim shared as GtkWidget ptr fixed

'Dim shared as GtkApplication ptr app

Dim shared as GtkAccelGroup ptr accel_group = NULL

Dim shared as PangoFontDescription ptr pfd
pfd = pango_font_description_from_string("sans 8")
Dim shared as PangoFontDescription ptr wpfd
wpfd = pango_font_description_from_string("sans 10")


'Dim shared as integer count = 0

#include once "HID_commands.bas"
#include once "HID_lib.bas"
#include once "HID_info.bas"
#INCLUDE once "HID_func.bas"												' GTK+library


'For i as integer = 0 To 63
	'databuffer(i) = 100+i
'Next i

returnvalue = libusb_init(NULL)
If returnvalue < 0 Then
   End returnvalue
End If

gtk_init(NULL, NULL)
  
Var pdata1000 = New timer_1000
Var pdata100 = New timer_100
Var pdata10 = New timer_10
	
returnvalue = create_window()	
returnvalue = create_elements()
returnvalue = create_menubar()

gtk_widget_show_all(t_window)												' make the dialog visable

g_timeout_add(pdata1000->my_timer, @timer1000_active, pdata1000)
g_timeout_add(pdata100->my_timer, @timer100_active, pdata100)
g_timeout_add(pdata10->my_timer, @timer10_active, pdata10)

fillcombo()	

	'gtk_entry_set_text(GTK_ENTRY(test_Entry),_
	'gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(combo)))


	'pr(!"test\n")
	'gtk_text_buffer_insert(textbuffer,@iter, !"Dit is een test\n", -1)
	'gtk_text_buffer_insert(textbuffer,@iter, !"Dit is een test", -1)

	'gtk_text_buffer_insert(outputbuffer,@iteroutput, !"Output box\n", -1)
	'gtk_text_buffer_insert_with_tags_by_name(outputbuffer, @iteroutput,_ 
    '    !"Colored Text\n", -1, "blue_fg", "lmarg",  NULL)
	'gtk_text_buffer_insert_with_tags_by_name (outputbuffer, @iteroutput,_ 
    '    !"Text with colored background\n", -1, "lmarg", "gray_bg", NULL)

	'gtk_text_buffer_insert_with_tags_by_name (outputbuffer, @iteroutput,_
    '    !"Text in italics\n", -1, "italic", "lmarg",  NULL)

	'gtk_text_buffer_insert_with_tags_by_name (outputbuffer, @iteroutput,_ 
    '    !"Bold text\n", -1, "bold", "lmarg",  NULL)




gtk_main()
