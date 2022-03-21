Declare Function open_device(device as libusb_device ptr) as libusb_device_handle ptr
Declare Function close_device(handle as libusb_device_handle ptr) as long
Declare Function exit_prog(ppList as libusb_device ptr ptr) as long
Declare Function transfer_data(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn
Declare Function bulk_tranfer(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn

Function open_device(device as libusb_device ptr) as libusb_device_handle ptr
    Dim As long returnvalue
    Dim As libusb_device_handle ptr Handle
    
    returnvalue = libusb_open(device, @Handle)
    ?(!"dev_handle\t\t\t\t\t" + Str(Handle) + !"\n")
    ?(!"Error Detail\t\t\t\t\t"+ Str(returnvalue) + !"\n") 
    if (returnvalue < 0) then 
		exit function
	End if

    ?(Str(*(libusb_error_name(returnvalue))) + !"\n")
        
    returnvalue = libusb_reset_device(Handle)
    ?(!"Error Reset Device\t\t\t" + Str(returnvalue) +  !"\n")
        
    If Handle > 0 Then
        returnvalue = libusb_kernel_driver_active(Handle, 0)          ''check if kernel has attached a driver
        ?(!"Check attached\t\t\t\t" + Str(returnvalue) + !"\n")
        If returnvalue > 0 Then                                        ''if so
            returnvalue = libusb_detach_kernel_driver(Handle, 0)      ''detach it
            ?(!"Detached\t\t\t\t\t" + Str(returnvalue) + !"\n")
        End If
        returnvalue = libusb_claim_interface(Handle, 0)               ''now we can claim the interface
        ?(!"Claim\t\t\t\t\t\t" + Str(returnvalue) + !"\n")
        ?(!"\n")
    End If
    return Handle
End Function

Function close_device(handle as libusb_device_handle ptr) as long
    Dim As long returnvalue
    
    returnvalue = libusb_release_interface(handle, 0)
    ?
    ? "release :"; returnvalue
    libusb_close(handle)
    return returnvalue
End Function

Function exit_prog(ppList as libusb_device ptr ptr) as long
? "ok"
libusb_free_device_list(ppList, 1)
libusb_exit(NULL)
? "end"
return 1
End Function

Function print_info()as long
return 1
End Function

Function transfer_data(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn
    Dim As multireturn returnvalues
    Dim As long returnvalue
    Dim As long length = 0

	returnvalue =  libusb_interrupt_transfer(handle, endp, databuf, number, @length, timeout)
	
	If (suppress = 0) then
	?
	? "returnvalue "; returnvalue
	? *(libusb_error_name(returnvalue))
	End if
	
	returnvalues.A = length
	returnvalues.B = returnvalue
		
	return returnvalues
End Function



Function bulk_tranfer(handle as libusb_device_handle ptr, endp as UByte, databuf As UByte Ptr, number as long, timeout As ULong, suppress as UByte) as multireturn

    Dim As multireturn returnvalues
    Dim As long returnvalue
    Dim As long length = 0

	returnvalue =  libusb_bulk_transfer(handle, endp, databuf, number, @length, timeout)
	
	If (suppress = 0) then
	'?
	'? "returnvalue "; returnvalue
	'? *(libusb_error_name(returnvalue))
	End if
	
	returnvalues.A = length
	returnvalues.B = returnvalue
		
	return returnvalues
End Function
