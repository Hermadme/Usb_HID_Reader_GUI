Declare Function print_device_descriptor(descr as libusb_device_descriptor, suppress as UByte) as long
Declare Function print_config_descriptor(D_config as libusb_config_descriptor ptr, suppress as UByte) as long
Declare Function print_vendor_info(handle as libusb_device_handle ptr, descr as libusb_device_descriptor, suppress as UByte) as long
Declare Function print_interface_descriptor(inter_desc as const libusb_interface_descriptor Ptr, suppress as UByte) as long
Declare Function print_interface_info(handle as libusb_device_handle ptr, inter_descr as const libusb_interface_descriptor Ptr, suppress as UByte) as long
Declare Function print_endpoint_descriptor(ep_desc as Const libusb_endpoint_descriptor Ptr, suppress as UByte) as long

Function print_device_descriptor(descr as libusb_device_descriptor, suppress as UByte) as long

		pr(!"\n")
		pr(!"  ********\tdevice_descriptor\t********" + !"\n", "italic", "blue_fg")
		pr(!"  bcdUSB\t\t\t\t\t" + "0x" + Str(Hex(descr.bcdUSB, 4)) + !"\n")
		pr(!"  idVendor\t\t\t\t\t" + "0x" + Str(Hex(descr.idVendor, 4)) + !"\n")
		pr(!"  idProduct\t\t\t\t\t" + "0x" + Str(Hex(descr.idProduct, 4)) + !"\n")
		pr(!"  bcdDevice\t\t\t\t\t" + Str("0x" + Hex(descr.bcdDevice, 4)) + !"\n")
		pr(!"  bNumConfigurations\t\t" + Str(descr.bNumConfigurations) + !"\n")

	If (suppress = 0) then
		?
		? "******** device_descriptor ********"
		? "bLength            "; descr.bLength
		? "bdescriptor type   "; "0x"; Hex(descr.bDescriptorType, 2)
		? "bcdUSB             "; "0x"; Hex(descr.bcdUSB, 4)
		? "bDeviceClass       "; "0x"; Hex(descr.bDeviceClass, 4)
		? "bDeviceSubClass    "; "0x"; Hex(descr.bDeviceSubClass, 2)
		? "bDeviceProtocol    "; "0x"; Hex(descr.bDeviceProtocol, 2)
		? "bMaxPacketSize0    "; descr.bMaxPacketSize0
		? "idVendor           "; "0x"; Hex(descr.idVendor, 4)
		? "idProduct          "; "0x"; Hex(descr.idProduct, 4)
		? "bcdDevice          "; "0x"; Hex(descr.bcdDevice, 4)
		? "iManufacturer      "; descr.iManufacturer
		? "iProduct           "; descr.iProduct
		? "iSerialNumber      "; descr.iSerialNumber
		? "bNumConfigurations "; descr.bNumConfigurations
		?
    End If
    return 0
End Function

Function print_config_descriptor(D_config as libusb_config_descriptor ptr, suppress as UByte) as long

		pr(!"  ********\tconfig_descriptor\t********" + !"\n", "italic", "blue_fg")
		pr(!"  bNumInterfaces:\t\t\t" + Str(D_config->bNumInterfaces) + !"\n")
		pr(!"  MaxPower:\t\t\t\t\t" + Str(D_config->MaxPower) + "mA"  + !"\n")

	If (suppress = 0) then
		?
		? "******** config_descriptor ********"
		? "bLength:             "; D_config->bLength
		? "bDescriptorType:     "; D_config->bDescriptorType
		? "wTotalLength:        "; D_config->wTotalLength
		? "bNumInterfaces:      "; D_config->bNumInterfaces
		? "bConfigurationValue: "; D_config->bConfigurationValue
		? "iConfiguration:      "; D_config->iConfiguration
		? "bmAttributes:        "; D_config->bmAttributes
		? "MaxPower:            "; D_config->MaxPower; "mA"
		?
	End If
    return 0
End Function

Function print_interface_descriptor(inter_desc as const libusb_interface_descriptor Ptr, suppress as UByte) as long
		
		pr(!"  ********\tinterface_descriptor\t********" + !"\n", "italic", "blue_fg")
		pr(!"  bNumEndpoints:\t\t\t" + STR(inter_desc->bNumEndpoints) + !"\n")
		
	If (suppress = 0) then
		?
		? "******** interface_descriptor ********"
		? "bLength:            "; inter_desc->bLength
		? "bDescriptorType:    "; inter_desc->bDescriptorType
		? "bInterfaceNumber:   "; inter_desc->bInterfaceNumber
		? "bAlternateSetting:  "; inter_desc->bAlternateSetting
		? "bNumEndpoints:      "; inter_desc->bNumEndpoints
		? "bInterfaceClass:    "; inter_desc->bInterfaceClass
		? "bInterfaceSubClass: "; inter_desc->bInterfaceSubClass
		? "bInterfaceProtocol: "; inter_desc->bInterfaceProtocol
		? "iInterface:         "; inter_desc->iInterface
	End If
    return 0
End Function

Function print_endpoint_descriptor(ep_desc as Const libusb_endpoint_descriptor Ptr, suppress as UByte) as long

		pr(!"  ********\tendpoint descriptor\t********" + !"\n", "italic", "blue_fg")
		pr(!"  bEndpointAddress:\t\t\t" + "0x" + Str(Hex(ep_desc->bEndpointAddress)) + !"\n")
		pr(!"  wMaxPacketSize:\t\t\t" + Str(ep_desc->wMaxPacketSize) + !"\n")
		
	If (suppress = 0) then
		?
		? "******** endpoint descriptor ********"
		? "bLength:          "; ep_desc->bLength
		? "bDescriptorType:  "; ep_desc->bDescriptorType
		? "bEndpointAddress: "; "0x"; Hex(ep_desc->bEndpointAddress)
		? "bmAttributes:     "; ep_desc->bmAttributes
		? "wMaxPacketSize:   "; ep_desc->wMaxPacketSize
		? "bInterval:        "; ep_desc->bInterval
		? "bRefresh:         "; ep_desc->bRefresh
		? "bSynchAddress:    "; ep_desc->bSynchAddress
	End If
    return 0
End Function

Function print_vendor_info(handle as libusb_device_handle ptr, descr as libusb_device_descriptor, suppress as UByte) as long
    Dim As long returnvalue
    Dim As ubyte device_info(64)
	If (suppress = 0) then
    
		'pr("******** Vendor information ********" + !"\n")
	
		returnvalue = libusb_get_string_descriptor_ascii(handle, descr.iProduct, @device_info(0), 64)
		If returnvalue > 0 Then
			pri(!"  Product\t\t\t", "gap")
			For i as integer = 0 to returnvalue - 1
				pri(chr(device_info(i)))
			Next
		End If
		pri(!"\n")

		returnvalue = libusb_get_string_descriptor_ascii(handle, descr.iManufacturer, @device_info(0), 64)
		If returnvalue > 0 Then
			pri(!"  Manufacturer\t")
			For i as integer = 0 to returnvalue - 1
				pri(chr(device_info(i)))
			Next
		End If
		pri(!"\n")

		returnvalue = libusb_get_string_descriptor_ascii(handle, descr.iSerialNumber, @device_info(0), 64)
		If returnvalue > 0 Then
			pri(!"  SerialNumber\t")
			For i as integer = 0 to returnvalue - 1
				pri(chr(device_info(i)))
			Next
		End If
	End If
    return 0
End Function

Function print_interface_info(handle as libusb_device_handle ptr, inter_descr as const libusb_interface_descriptor Ptr, suppress as UByte) as long
    Dim As long returnvalue
    Dim As ubyte device_info(64)
    
	If (suppress = 0) then
		?
		? "******** Interface information ********"
	
		returnvalue = libusb_get_string_descriptor_ascii(handle, inter_descr->iInterface, @device_info(0), 64)
		If returnvalue > 0 Then
			? "Interface          ";
			For i as integer = 0 to returnvalue - 1
				? chr(device_info(i));
			Next
		Else
			? returnvalue
		End If
		?
		?
    End If
    return 0
End Function
