sub pr Overload (p_text as const gchar ptr,_
	tag1 as const gchar ptr, tag2 as const gchar ptr)


	gtk_text_buffer_insert_with_tags_by_name(textbuffer,_
		@iter, p_text, -1, tag1, tag2, NULL)

End sub

sub pr Overload (p_text as const gchar ptr, tag1 as const gchar ptr)


	gtk_text_buffer_insert_with_tags_by_name(textbuffer,_
		@iter, p_text, -1, tag1, NULL)

 End sub

sub pr Overload (p_text as const gchar ptr)


	gtk_text_buffer_insert(textbuffer, @iter, p_text, -1)

End sub

sub pro Overload (p_text as const gchar ptr,_
	tag1 as const gchar ptr, tag2 as const gchar ptr)


	gtk_text_buffer_insert_with_tags_by_name(outputbuffer,_
		@iteroutput, p_text, -1, tag1, tag2, NULL)

    if scroll_on = 1 then
		gtk_text_view_scroll_to_mark (GTK_TEXT_VIEW (outputview),_
			text_mark_end, 0., TRUE, 1.0, 1.0)
	End If

End sub

sub pro Overload (p_text as const gchar ptr, tag1 as const gchar ptr)


	gtk_text_buffer_insert_with_tags_by_name(outputbuffer,_
		@iteroutput, p_text, -1, tag1, NULL)

    if scroll_on = 1 then
    gtk_text_view_scroll_to_mark (GTK_TEXT_VIEW (outputview),_
		text_mark_end, 0., TRUE, 1.0, 1.0)
	End If

End sub

sub pro Overload (p_text as const gchar ptr)


	gtk_text_buffer_insert(outputbuffer, @iteroutput, p_text, -1)

    if scroll_on = 1 then
    gtk_text_view_scroll_to_mark (GTK_TEXT_VIEW (outputview),_
		text_mark_end, 0., TRUE, 1.0, 1.0)
	End If

End sub

sub pri Overload (p_text as const gchar ptr,_
	tag1 as const gchar ptr, tag2 as const gchar ptr)

	gtk_text_buffer_insert_with_tags_by_name(infobuffer,_
		@iterinfo, p_text, -1, tag1, tag2, NULL)

End sub

sub pri Overload (p_text as const gchar ptr, tag1 as const gchar ptr)

	gtk_text_buffer_insert_with_tags_by_name(infobuffer,_
		@iterinfo, p_text, -1, tag1, NULL)

End sub

sub pri Overload (p_text as const gchar ptr)

	gtk_text_buffer_insert(infobuffer,_
		@iterinfo, p_text, -1)

End sub

sub clearbuf(buf as Gtktextbuffer ptr, b_iter as GtkTextIter)

 	Dim as GtkTextIter start_i
	Dim as GtkTextIter end_i

	gtk_text_buffer_get_bounds(buf, @start_i, @end_i)
	gtk_text_buffer_delete(buf, @start_i, @end_i)
	b_iter = start_i
	
End sub


