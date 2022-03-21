#Ifndef LIBUSB_H
   #define LIBUSB_H
      
   #Inclib "usb-1.0"
         
   #Include Once "crt/stdint.bi"
   #Include Once "crt/sys/types.bi"
    #If Defined(__FB_LINUX__ ) Or Defined(__FB_CYGWIN__)
      Type timeval
         tv_sec As Long
         tv_usec As Long
      End Type
   #EndIf

   #Include Once "crt/limits.bi"
   
   #If Defined(__FB_WIN32__) Or Defined(__FB_CYGWIN__)   
      #Include Once "windows.bi"
      #If Defined(interface)
         #Undef interface
      #EndIf
      #If Not Defined(__FB_CYGWIN__)
         #Include Once "win/winsock.bi"
      #EndIf
   #EndIf
      
   #If Defined(__FB_LINUX__)
      #Include Once "crt/sys/socket.bi"
   #EndIf
   
Dim As ULong libusb_device = 0

#define LIBUSB_API_VERSION &h01000105

/'' The following is kept for compatibility, but will be deprecated in the future ''/
#define LIBUSBX_API_VERSION LIBUSB_API_VERSION

#If Defined(__FB_WIN32__)
   #Define LIBUSB_CALL WINAPI
   Extern "Windows-MS"
#Else
   #Define LIBUSB_CALL
   Extern "C"
#EndIf

Function libusb_cpu_to_le16(x As Const uint16_t) As uint16_t

   Union _tmp
      As uint8_t b8(1)
      As uint16_t b16
   End Union
   Dim _tmp As _tmp
   
   _tmp.b8(1) = Cast(uint8_t, (x Shr 8))
   _tmp.b8(0) = Cast(uint8_t, (x And &hff))
   Return _tmp.b16
End Function

#define libusb_le16_to_cpu libusb_cpu_to_le16

Enum libusb_class_code
   LIBUSB_CLASS_PER_INTERFACE = 0

   /''* Audio class ''/
   LIBUSB_CLASS_AUDIO = 1

   /''* Communications class ''/
   LIBUSB_CLASS_COMM = 2

   /''* Human Interface Device class ''/
   LIBUSB_CLASS_HID = 3

   /''* Physical ''/
   LIBUSB_CLASS_PHYSICAL = 5

   /''* Printer class ''/
   LIBUSB_CLASS_PRINTER = 7

   /''* Image class ''/
   LIBUSB_CLASS_PTP = 6, /'' legacy name from libusb-0.1 usb.h ''/
   LIBUSB_CLASS_IMAGE = 6

   /''* Mass storage class ''/
   LIBUSB_CLASS_MASS_STORAGE = 8

   /''* Hub class ''/
   LIBUSB_CLASS_HUB = 9

   /''* Data class ''/
   LIBUSB_CLASS_DATA = 10

   /''* Smart Card ''/
   LIBUSB_CLASS_SMART_CARD = &h0b

   /''* Content Security ''/
   LIBUSB_CLASS_CONTENT_SECURITY = &h0d

   /''* Video ''/
   LIBUSB_CLASS_VIDEO = &h0e,

   /''* Personal Healthcare ''/
   LIBUSB_CLASS_PERSONAL_HEALTHCARE = &h0f

   /''* Diagnostic Device ''/
   LIBUSB_CLASS_DIAGNOSTIC_DEVICE = &hdc

   /''* Wireless class ''/
   LIBUSB_CLASS_WIRELESS = &he0

   /''* Application class ''/
   LIBUSB_CLASS_APPLICATION = &hfe

   /''* Class is vendor-specific ''/
   LIBUSB_CLASS_VENDOR_SPEC = &hff
End Enum

/''* \ingroup libusb_desc
 * Descriptor types as defined by the USB specification. ''/
Enum libusb_descriptor_type
   /''* Device descriptor. See libusb_device_descriptor. ''/
   LIBUSB_DT_DEVICE = &h01

   /''* Configuration descriptor. See libusb_config_descriptor. ''/
   LIBUSB_DT_CONFIG = &h02

   /''* String descriptor ''/
   LIBUSB_DT_STRING = &h03

   /''* Interface descriptor. See libusb_interface_descriptor. ''/
   LIBUSB_DT_INTERFACE = &h04

   /''* Endpoint descriptor. See libusb_endpoint_descriptor. ''/
   LIBUSB_DT_ENDPOINT = &h05

   /''* BOS descriptor ''/
   LIBUSB_DT_BOS = &h0f

   /''* Device Capability descriptor ''/
   LIBUSB_DT_DEVICE_CAPABILITY = &h10

   /''* HID descriptor ''/
   LIBUSB_DT_HID = &h21

   /''* HID report descriptor ''/
   LIBUSB_DT_REPORT = &h22

   /''* Physical descriptor ''/
   LIBUSB_DT_PHYSICAL = &h23

   /''* Hub descriptor ''/
   LIBUSB_DT_HUB = &h29

   /''* SuperSpeed Hub descriptor ''/
   LIBUSB_DT_SUPERSPEED_HUB = &h2a

   /''* SuperSpeed Endpoint Companion descriptor ''/
   LIBUSB_DT_SS_ENDPOINT_COMPANION = &h30
End Enum

/'' Descriptor sizes per descriptor type ''/
#define LIBUSB_DT_DEVICE_SIZE         18
#define LIBUSB_DT_CONFIG_SIZE         9
#define LIBUSB_DT_INTERFACE_SIZE      9
#define LIBUSB_DT_ENDPOINT_SIZE         7
#define LIBUSB_DT_ENDPOINT_AUDIO_SIZE      9   /'' Audio extension ''/
#define LIBUSB_DT_HUB_NONVAR_SIZE      7
#define LIBUSB_DT_SS_ENDPOINT_COMPANION_SIZE   6
#define LIBUSB_DT_BOS_SIZE         5
#define LIBUSB_DT_DEVICE_CAPABILITY_SIZE   3

/'' BOS descriptor sizes ''/
#define LIBUSB_BT_USB_2_0_EXTENSION_SIZE   7
#define LIBUSB_BT_SS_USB_DEVICE_CAPABILITY_SIZE   10
#define LIBUSB_BT_CONTAINER_ID_SIZE      20

/'' We unwrap the BOS => define its max size ''/
#define LIBUSB_DT_BOS_MAX_SIZE   ((LIBUSB_DT_BOS_SIZE) + _
                                      (LIBUSB_BT_USB_2_0_EXTENSION_SIZE) + _
                                      (LIBUSB_BT_SS_USB_DEVICE_CAPABILITY_SIZE) + _
                                      (LIBUSB_BT_CONTAINER_ID_SIZE))

#define LIBUSB_ENDPOINT_ADDRESS_MASK   &h0f    /'' in bEndpointAddress ''/
#define LIBUSB_ENDPOINT_DIR_MASK      &h80

Enum libusb_endpoint_direction
   /''* In: device-to-host ''/
   LIBUSB_ENDPOINT_IN = &h80

   /''* Out: host-to-device ''/
   LIBUSB_ENDPOINT_OUT = &h00
End Enum

#define LIBUSB_TRANSFER_TYPE_MASK         &h03    /'' in bmAttributes ''/

Enum libusb_transfer_type
   /''* Control endpoint ''/
   LIBUSB_TRANSFER_TYPE_CONTROL = 0

   /''* Isochronous endpoint ''/
   LIBUSB_TRANSFER_TYPE_ISOCHRONOUS = 1

   /''* Bulk endpoint ''/
   LIBUSB_TRANSFER_TYPE_BULK = 2

   /''* Interrupt endpoint ''/
   LIBUSB_TRANSFER_TYPE_INTERRUPT = 3

   /''* Stream endpoint ''/
   LIBUSB_TRANSFER_TYPE_BULK_STREAM = 4
End Enum

/''* \ingroup libusb_misc
 * Standard requests, as defined in table 9-5 of the USB 3.0 specifications ''/
Enum libusb_standard_request
   /''* Request status of the specific recipient ''/
   LIBUSB_REQUEST_GET_STATUS = &h00

   /''* Clear or disable a specific feature ''/
   LIBUSB_REQUEST_CLEAR_FEATURE = &h01

   /'' &h02 is reserved ''/

   /''* Set or enable a specific feature ''/
   LIBUSB_REQUEST_SET_FEATURE = &h03

   /'' &h04 is reserved ''/

   /''* Set device address for all future accesses ''/
   LIBUSB_REQUEST_SET_ADDRESS = &h05

   /''* Get the specified descriptor ''/
   LIBUSB_REQUEST_GET_DESCRIPTOR = &h06

   /''* Used to update existing descriptors or add new descriptors ''/
   LIBUSB_REQUEST_SET_DESCRIPTOR = &h07

   /''* Get the current device configuration value ''/
   LIBUSB_REQUEST_GET_CONFIGURATION = &h08

   /''* Set device configuration ''/
   LIBUSB_REQUEST_SET_CONFIGURATION = &h09

   /''* Return the selected alternate setting for the specified interface ''/
   LIBUSB_REQUEST_GET_INTERFACE = &h0A

   /''* Select an alternate interface for the specified interface ''/
   LIBUSB_REQUEST_SET_INTERFACE = &h0B

   '' Set then report an endpoint''s synchronization frame ''/
   LIBUSB_REQUEST_SYNCH_FRAME = &h0C

   /''* Sets both the U1 and U2 Exit Latency ''/
   LIBUSB_REQUEST_SET_SEL = &h30

   /''* Delay from the time a host transmits a packet to the time it is
     * received by the device. ''/
   LIBUSB_SET_ISOCH_DELAY = &h31
End Enum

Enum libusb_request_type
   /''* Standard ''/
   LIBUSB_REQUEST_TYPE_STANDARD = (&h00 Shl 5)

   /''* Class ''/
   LIBUSB_REQUEST_TYPE_CLASS = (&h01 Shl 5)

   /''* Vendor ''/
   LIBUSB_REQUEST_TYPE_VENDOR = (&h02 Shl 5)

   /''* Reserved ''/
   LIBUSB_REQUEST_TYPE_RESERVED = (&h03 Shl 5)
End Enum

Enum libusb_request_recipient
   /''* Device ''/
   LIBUSB_RECIPIENT_DEVICE = &h00

   /''* Interface ''/
   LIBUSB_RECIPIENT_INTERFACE = &h01

   /''* Endpoint ''/
   LIBUSB_RECIPIENT_ENDPOINT = &h02

   /''* Other ''/
   LIBUSB_RECIPIENT_OTHER = &h03
End Enum

#define LIBUSB_ISO_SYNC_TYPE_MASK      &h0C

Enum libusb_iso_sync_type
   /''* No synchronization ''/
   LIBUSB_ISO_SYNC_TYPE_NONE = 0

   /''* Asynchronous ''/
   LIBUSB_ISO_SYNC_TYPE_ASYNC = 1

   /''* Adaptive ''/
   LIBUSB_ISO_SYNC_TYPE_ADAPTIVE = 2

   /''* Synchronous ''/
   LIBUSB_ISO_SYNC_TYPE_SYNC = 3
End Enum

#define LIBUSB_ISO_USAGE_TYPE_MASK &h30

Enum libusb_iso_usage_type
   /''* Data endpoint ''/
   LIBUSB_ISO_USAGE_TYPE_DATA = 0

   /''* Feedback endpoint ''/
   LIBUSB_ISO_USAGE_TYPE_FEEDBACK = 1

   /''* Implicit feedback Data endpoint ''/
   LIBUSB_ISO_USAGE_TYPE_IMPLICIT = 2
End Enum

Type libusb_device_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   As uint16_t bcdUSB

   /''* USB-IF class code for the device. See \ref libusb_class_code. ''/
   As uint8_t  bDeviceClass

   /''* USB-IF subclass code for the device, qualified by the bDeviceClass
    * value ''/
   As uint8_t  bDeviceSubClass

   /''* USB-IF protocol code for the device, qualified by the bDeviceClass and
    * bDeviceSubClass values ''/
   As uint8_t  bDeviceProtocol

   /''* Maximum packet size for endpoint 0 ''/
   As uint8_t  bMaxPacketSize0

   /''* USB-IF vendor ID ''/
   As uint16_t idVendor

   /''* USB-IF product ID ''/
   As uint16_t idProduct

   /''* Device release number in binary-coded decimal ''/
   As uint16_t bcdDevice

   /''* Index of string descriptor describing manufacturer ''/
   As uint8_t  iManufacturer

   /''* Index of string descriptor describing product ''/
   As uint8_t  iProduct

   /''* Index of string descriptor containing device serial number ''/
   As uint8_t  iSerialNumber

   /''* Number of possible configurations ''/
   As uint8_t  bNumConfigurations
End Type

Type libusb_endpoint_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   As uint8_t  bEndpointAddress

   As uint8_t  bmAttributes

   /''* Maximum packet size this endpoint is capable of sending/receiving. ''/
   As uint16_t wMaxPacketSize

   /''* Interval for polling endpoint for data transfers. ''/
   As uint8_t  bInterval

   /''* For audio devices only: the rate at which synchronization feedback
    * is provided. ''/
   As uint8_t  bRefresh

   /''* For audio devices only: the address if the synch endpoint ''/
   As uint8_t  bSynchAddress

   /''* Extra descriptors. If libusb encounters unknown endpoint descriptors,
    * it will store them here, should you wish to parse them. ''/
   As  UByte Ptr extra

   /''* Length of the extra descriptors, in bytes. ''/
   As Long extra_length
End Type

Type libusb_interface_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   /''* Number of this interface ''/
   As uint8_t  bInterfaceNumber

   /''* Value used to select this alternate setting for this interface ''/
   As uint8_t  bAlternateSetting

   /''* Number of endpoints used by this interface (excluding the control
    * endpoint). ''/
   As uint8_t  bNumEndpoints

   /''* USB-IF class code for this interface. See \ref libusb_class_code. ''/
   As uint8_t  bInterfaceClass

   /''* USB-IF subclass code for this interface, qualified by the
    * bInterfaceClass value ''/
   As uint8_t  bInterfaceSubClass

   /''* USB-IF protocol code for this interface, qualified by the
    * bInterfaceClass and bInterfaceSubClass values ''/
   As uint8_t  bInterfaceProtocol

   /''* Index of string descriptor describing this interface ''/
   As uint8_t  iInterface

   As  libusb_endpoint_descriptor Ptr endpoint

   As  UByte Ptr extra

   /''* Length of the extra descriptors, in bytes. ''/
   As Long extra_length
End Type

Type libusb_interface
   As Const libusb_interface_descriptor Ptr altsetting
   
   As Long num_altsetting
End Type

Type libusb_config_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   /''* Total length of data returned for this configuration ''/
   As uint16_t wTotalLength

   /''* Number of interfaces supported by this configuration ''/
   As uint8_t  bNumInterfaces

   /''* Identifier value for this configuration ''/
   As uint8_t  bConfigurationValue

   /''* Index of string descriptor describing this configuration ''/
   As uint8_t  iConfiguration

   /''* Configuration characteristics ''/
   As uint8_t  bmAttributes

   As uint8_t  MaxPower

   As Const libusb_interface Ptr interface
   As  UByte Ptr extra

   /''* Length of the extra descriptors, in bytes. ''/
   As Long extra_length
End Type

Type libusb_ss_endpoint_companion_descriptor
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   As uint8_t  bMaxBurst

   As uint8_t  bmAttributes

   As uint16_t wBytesPerInterval
End Type

#If Defined(__STDC_VERSION__)
   #If (__STDC_VERSION__ >= 199901)
      #Define __STDC_VERSION_DEF__
   #EndIf
#EndIf

Type libusb_bos_dev_capability_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t bLength
   As uint8_t bDescriptorType
   /''* Device Capability type ''/
   As uint8_t bDevCapabilityType
   /''* Device Capability data (bLength - 3 bytes) ''/
   #If Defined(__STDC_VERSION_DEF__)
      As uint8_t dev_capability_data(Any) /'' valid C99 code ''/
   #Else
      As uint8_t dev_capability_data(0) /'' non-standard, but usually working code ''/
   #EndIf
End Type

Type libusb_bos_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   /''* Length of this descriptor and all of its sub descriptors ''/
   As uint16_t wTotalLength

   /''* The number of separate device capability descriptors in
    * the BOS ''/
   As uint8_t  bNumDeviceCaps

   /''* bNumDeviceCap Device Capability Descriptors ''/
   #If Defined(__STDC_VERSION_DEF__)
      As libusb_bos_dev_capability_descriptor Ptr dev_capability(Any) /'' valid C99 code ''/
   #Else
      As libusb_bos_dev_capability_descriptor Ptr dev_capability(0) /'' non-standard, but usually working code ''/
   #EndIf
End Type

Type libusb_usb_2_0_extension_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   As uint8_t  bDevCapabilityType

   As uint32_t  bmAttributes
End Type

Type libusb_ss_usb_device_capability_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   As uint8_t  bDevCapabilityType

   As uint8_t  bmAttributes

   As uint16_t wSpeedSupported

   As uint8_t  bFunctionalitySupport

   /''* U1 Device Exit Latency. ''/
   As uint8_t  bU1DevExitLat

   /''* U2 Device Exit Latency. ''/
   As uint16_t bU2DevExitLat
End Type

Type  libusb_container_id_descriptor
   /''* Size of this descriptor (in bytes) ''/
   As uint8_t  bLength

   As uint8_t  bDescriptorType

   As uint8_t  bDevCapabilityType

   /''* Reserved field ''/
   As uint8_t bReserved

   /''* 128 bit UUID ''/
   As uint8_t  ContainerID(16)
End Type

Type libusb_control_setup
   As uint8_t  bmRequestType

   As uint8_t  bRequest

   /''* Value. Varies according to request ''/
   As uint16_t wValue

   /''* Index. Varies according to request, typically used to pass an index
    * or offset ''/
   As uint16_t wIndex

   /''* Number of bytes to transfer ''/
   As uint16_t wLength
End Type
Dim Shared libusb_control_setup As libusb_control_setup

#define LIBUSB_CONTROL_SETUP_SIZE (SizeOf(libusb_control_setup))

/'' libusb ''/
Type libusb_context As libusb_context
Type libusb_device As libusb_device
Type libusb_device_handle As libusb_device_handle

/''* \ingroup libusb_lib
 * Structure providing the version of the libusb runtime
 ''/
Type libusb_version
   /''* Library major version. ''/
   As  uint16_t major

   /''* Library minor version. ''/
   ''As Const uint16_t minor
   As  uint16_t minor

   /''* Library micro version. ''/
   ''As Const uint16_t micro
   As  uint16_t micro

   /''* Library nano version. ''/
   ''As Const uint16_t nano
   As  uint16_t nano

   /''* Library release candidate suffix string, e.g. "-rc4". ''/
   ''As Const UByte Ptr rc
   As  UByte Ptr rc

   /''* For ABI compatibility only. ''/
   As  UByte Ptr describe
End Type

Type libusb_context As libusb_context

Type libusb_device As libusb_device


Type libusb_device_handle As libusb_device_handle

Enum libusb_speed
   ''* The OS doesn''t report or know the device speed. ''/
   LIBUSB_SPEED_UNKNOWN = 0

   /''* The device is operating at low speed (1.5MBit/s). ''/
   LIBUSB_SPEED_LOW = 1

   /''* The device is operating at full speed (12MBit/s). ''/
   LIBUSB_SPEED_FULL = 2

   /''* The device is operating at high speed (480MBit/s). ''/
   LIBUSB_SPEED_HIGH = 3

   /''* The device is operating at super speed (5000MBit/s). ''/
   LIBUSB_SPEED_SUPER = 4
End Enum

Enum libusb_supported_speed
   /''* Low speed operation supported (1.5MBit/s). ''/
   LIBUSB_LOW_SPEED_OPERATION   = 1

   /''* Full speed operation supported (12MBit/s). ''/
   LIBUSB_FULL_SPEED_OPERATION  = 2

   /''* High speed operation supported (480MBit/s). ''/
   LIBUSB_HIGH_SPEED_OPERATION  = 4

   /''* Superspeed operation supported (5000MBit/s). ''/
   LIBUSB_SUPER_SPEED_OPERATION = 8
End Enum

Enum libusb_usb_2_0_extension_attributes
   /''* Supports Link Power Management (LPM) ''/
   LIBUSB_BM_LPM_SUPPORT = 2
End Enum

Enum libusb_ss_usb_device_capability_attributes
   /''* Supports Latency Tolerance Messages (LTM) ''/
   LIBUSB_BM_LTM_SUPPORT = 2
End Enum

/''* \ingroup libusb_dev
 * USB capability types
 ''/
Enum libusb_bos_type
   /''* Wireless USB device capability ''/
   LIBUSB_BT_WIRELESS_USB_DEVICE_CAPABILITY   = 1

   /''* USB 2.0 extensions ''/
   LIBUSB_BT_USB_2_0_EXTENSION         = 2

   /''* SuperSpeed USB device capability ''/
   LIBUSB_BT_SS_USB_DEVICE_CAPABILITY      = 3

   /''* Container ID type ''/
   LIBUSB_BT_CONTAINER_ID            = 4
End Enum

Enum libusb_error
   /''* Success (no error) ''/
   LIBUSB_SUCCESS = 0

   /''* Input/output error ''/
   LIBUSB_ERROR_IO = -1

   /''* Invalid parameter ''/
   LIBUSB_ERROR_INVALID_PARAM = -2

   /''* Access denied (insufficient permissions) ''/
   LIBUSB_ERROR_ACCESS = -3

   /''* No such device (it may have been disconnected) ''/
   LIBUSB_ERROR_NO_DEVICE = -4

   /''* Entity not found ''/
   LIBUSB_ERROR_NOT_FOUND = -5

   /''* Resource busy ''/
   LIBUSB_ERROR_BUSY = -6

   /''* Operation timed out ''/
   LIBUSB_ERROR_TIMEOUT = -7

   /''* Overflow ''/
   LIBUSB_ERROR_OVERFLOW = -8

   /''* Pipe error ''/
   LIBUSB_ERROR_PIPE = -9

   /''* System call interrupted (perhaps due to signal) ''/
   LIBUSB_ERROR_INTERRUPTED = -10

   /''* Insufficient memory ''/
   LIBUSB_ERROR_NO_MEM = -11

   /''* Operation not supported or unimplemented on this platform ''/
   LIBUSB_ERROR_NOT_SUPPORTED = -12

   /'' NB: Remember to update LIBUSB_ERROR_COUNT below as well as the
      message strings in strerror.c when adding new error codes here. ''/

   /''* Other error ''/
   LIBUSB_ERROR_OTHER = -99
End Enum

/'' Total number of error codes in enum libusb_error ''/
#define LIBUSB_ERROR_COUNT 14

/''* \ingroup libusb_asyncio
 * Transfer status codes ''/
Enum libusb_transfer_status
   /''* Transfer completed without error. Note that this does not indicate
    * that the entire amount of requested data was transferred. ''/
   LIBUSB_TRANSFER_COMPLETED

   /''* Transfer failed ''/
   LIBUSB_TRANSFER_ERROR

   /''* Transfer timed out ''/
   LIBUSB_TRANSFER_TIMED_OUT

   /''* Transfer was cancelled ''/
   LIBUSB_TRANSFER_CANCELLED

   /''* For bulk/interrupt endpoints: halt condition detected (endpoint
    * stalled). For control endpoints: control request not supported. ''/
   LIBUSB_TRANSFER_STALL

   /''* Device was disconnected ''/
   LIBUSB_TRANSFER_NO_DEVICE

   /''* Device sent more data than requested ''/
   LIBUSB_TRANSFER_OVERFLOW

   /'' NB! Remember to update libusb_error_name()
      when adding new status codes here. ''/
End Enum

/''* \ingroup libusb_asyncio
 * libusb_transfer.flags values ''/
Enum libusb_transfer_flags
   /''* Report short frames as errors ''/
   LIBUSB_TRANSFER_SHORT_NOT_OK = 1 Shl 0

   LIBUSB_TRANSFER_FREE_BUFFER = 1 Shl 1

   LIBUSB_TRANSFER_FREE_TRANSFER = 1 Shl 2

   LIBUSB_TRANSFER_ADD_ZERO_PACKET = 1 Shl 3,
End Enum

/''* \ingroup libusb_asyncio
 * Isochronous packet descriptor. ''/
Type libusb_iso_packet_descriptor
   /''* Length of data to request in this packet ''/
   As ULong length

   /''* Amount of data that was actually transferred ''/
   As ULong actual_length

   /''* Status code for this packet ''/
   As libusb_transfer_status status
End Type

Type fw_libusb_transfer As libusb_transfer

Type libusb_transfer_cb_fn As Sub(transfer As fw_libusb_transfer Ptr)

Type libusb_transfer
   /''* Handle of the device that this transfer will be submitted to ''/
   As libusb_device_handle Ptr dev_handle

   /''* A bitwise OR combination of \ref libusb_transfer_flags. ''/
   As uint8_t flags

   /''* Address of the endpoint where this transfer will be sent. ''/
   As UByte endpoint

   /''* Type of the endpoint from \ref libusb_transfer_type ''/
   As UByte Type

   /''* Timeout for this transfer in millseconds. A value of 0 indicates no
    * timeout. ''/
   As ULong timeout

   As libusb_transfer_status status

   /''* Length of the data buffer ''/
   As Long length

   As Long actual_length

   As libusb_transfer_cb_fn callback

   /''* User context data to pass to the callback function. ''/
   As Any Ptr user_data

   /''* Data buffer ''/
   As UByte Ptr buffer

   /''* Number of isochronous packets. Only used for I/O with isochronous
    * endpoints. ''/
   As Long num_iso_packets

   /''* Isochronous packet descriptors, for isochronous transfers only. ''/
   #If Defined(__STDC_VERSION_DEF__)
      As libusb_iso_packet_descriptor iso_packet_desc(Any) /'' valid C99 code ''/
   #Else
      As libusb_iso_packet_descriptor iso_packet_desc(0) /'' non-standard, but usually working code ''/
   #EndIf
End Type

Enum libusb_capability
   /''* The libusb_has_capability() API is available. ''/
   LIBUSB_CAP_HAS_CAPABILITY = &h0000
   /''* Hotplug support is available on this platform. ''/
   LIBUSB_CAP_HAS_HOTPLUG = &h0001
   /''* The library can access HID devices without requiring user intervention.
    * Note that before being able to actually access an HID device, you may
    * still have to call additional libusb functions such as
    * \ref libusb_detach_kernel_driver(). ''/
   LIBUSB_CAP_HAS_HID_ACCESS = &h0100
   /''* The library supports detaching of the default USB driver, using
    * \ref libusb_detach_kernel_driver(), if one is set by the OS kernel ''/
   LIBUSB_CAP_SUPPORTS_DETACH_KERNEL_DRIVER = &h0101
End Enum

Enum libusb_log_level
   LIBUSB_LOG_LEVEL_NONE = 0
   LIBUSB_LOG_LEVEL_ERROR
   LIBUSB_LOG_LEVEL_WARNING
   LIBUSB_LOG_LEVEL_INFO
   LIBUSB_LOG_LEVEL_DEBUG
End Enum

Declare Function libusb_init(ctx As libusb_context Ptr Ptr) As Long
Declare Sub libusb_exit(ctx As libusb_context Ptr)
Declare Sub libusb_set_debug(ctx As libusb_context Ptr, level As Long)
Declare Function libusb_get_version() As Const libusb_version Ptr
Declare Function libusb_has_capability(capability As uint32_t) As Long
Declare Function libusb_error_name(errcode As Long) As Const ZString Ptr
Declare Function libusb_setlocale(locale As  UByte Ptr) As Long
Declare Function libusb_strerror(errcode As Long) As Const ZString Ptr

Declare Function libusb_get_device_list(ctx As libusb_context Ptr, list As libusb_device Ptr Ptr Ptr) As ssize_t
Declare Sub libusb_free_device_list(list As libusb_device Ptr Ptr, unref_devices As Long)
Declare Function libusb_ref_device(dev As libusb_device Ptr) As libusb_device Ptr
Declare Sub libusb_unref_device(dev As libusb_device Ptr)

Declare Function libusb_get_configuration( _
                        dev As libusb_device_handle Ptr, _
                        config As Long Ptr) As Long
Declare Function libusb_get_device_descriptor( _
                        dev As libusb_device Ptr, _
                        desc As libusb_device_descriptor Ptr) As Long
Declare Function libusb_get_active_config_descriptor( _
                        dev As libusb_device Ptr, _
                        config As libusb_config_descriptor Ptr Ptr) As Long
Declare Function libusb_get_config_descriptor( _
                        dev As libusb_device Ptr, _
                        config_index As uint8_t, _
                        config As libusb_config_descriptor Ptr Ptr) As Long
Declare Function libusb_get_config_descriptor_by_value( _
                        dev As libusb_device Ptr, _
                        bConfigurationValue As uint8_t, _
                        config As libusb_config_descriptor Ptr Ptr) As Long
Declare Sub libusb_free_config_descriptor(config As libusb_config_descriptor Ptr)
Declare Function libusb_get_ss_endpoint_companion_descriptor( _
                        ctx As libusb_context Ptr, _
                        endpoint As Const libusb_endpoint_descriptor Ptr, _
                        ep_comp As libusb_ss_endpoint_companion_descriptor Ptr Ptr) As Long
Declare Sub libusb_free_ss_endpoint_companion_descriptor( _
                        ep_comp As libusb_ss_endpoint_companion_descriptor Ptr)
                       
Declare Function libusb_get_bos_descriptor( _
                        dev_handle As libusb_device_handle Ptr, _
                        bos As libusb_bos_descriptor Ptr Ptr) As Long
Declare Sub libusb_free_bos_descriptor(bos As libusb_bos_descriptor Ptr)
Declare Function libusb_get_usb_2_0_extension_descriptor( _
                        ctx As libusb_context Ptr, _
                        dev_cap As libusb_bos_dev_capability_descriptor Ptr, _
                        usb_2_0_extension As libusb_usb_2_0_extension_descriptor Ptr Ptr) As Long
Declare Sub libusb_free_usb_2_0_extension_descriptor(usb_2_0_extension As libusb_usb_2_0_extension_descriptor Ptr)
Declare Function libusb_get_ss_usb_device_capability_descriptor( _
                        ctx As libusb_context Ptr, _
                        dev_cap As libusb_bos_dev_capability_descriptor Ptr, _
                        ss_usb_device_cap As libusb_ss_usb_device_capability_descriptor Ptr Ptr) As Long
Declare Sub libusb_free_ss_usb_device_capability_descriptor(ss_usb_device_cap As libusb_ss_usb_device_capability_descriptor Ptr)
Declare Function libusb_get_container_id_descriptor( _
                        ctx As libusb_context Ptr, _
                        dev_cap As libusb_bos_dev_capability_descriptor Ptr, _
                        container_id As libusb_container_id_descriptor Ptr Ptr) As Long
Declare Sub libusb_free_container_id_descriptor( _
                        container_id As libusb_container_id_descriptor Ptr)
Declare Function libusb_get_bus_number(dev As libusb_device Ptr) As uint8_t
Declare Function libusb_get_port_number(dev As libusb_device Ptr) As uint8_t
Declare Function libusb_get_port_numbers( _
                        dev As libusb_device Ptr, _
                        port_numbers As uint8_t Ptr, _
                        port_numbers_len As Long) As Long
''LIBUSB_DEPRECATED_FOR(libusb_get_port_numbers)
Declare Function libusb_get_port_path( _
                        ctx As libusb_context Ptr, _
                        dev As libusb_device Ptr, _
                        path As ZString Ptr, _
                        path_length As uint8_t) As Long
Declare Function libusb_get_parent(dev As libusb_device Ptr) As libusb_device Ptr
Declare Function libusb_get_device_address(dev As libusb_device Ptr) As uint8_t
Declare Function libusb_get_device_speed(dev As libusb_device Ptr) As Long
Declare Function libusb_get_max_packet_size( _
                        dev As libusb_device Ptr, _
                        endpoint As UByte) As Long
Declare Function libusb_get_max_iso_packet_size(dev As libusb_device Ptr, endpoint As UByte) As Long

Declare Function libusb_open(dev As libusb_device Ptr, dev_handle As libusb_device_handle Ptr Ptr) As Long
Declare Sub libusb_close(dev_handle As libusb_device_handle Ptr)
Declare Function libusb_get_device(dev_handle As libusb_device_handle Ptr) As libusb_device Ptr

Declare Function libusb_set_configuration( _
                        dev_handle As libusb_device_handle Ptr, _
                        configuration As Long) As Long
Declare Function libusb_claim_interface( _
                        dev_handle As libusb_device_handle Ptr, _
                        interface_number As Long) As Long
Declare Function libusb_release_interface( _
                        dev_handle As libusb_device_handle Ptr, _
                        interface_number As Long) As Long

Declare Function libusb_open_device_with_vid_pid( _
                        ctx As libusb_context Ptr, _
                        vendor_id As uint16_t, _
                        product_id As uint16_t) As libusb_device_handle Ptr

Declare Function libusb_set_interface_alt_setting( _
                        dev_handle As libusb_device_handle Ptr, _
                        interface_number As Long, _
                        alternate_setting As Long) As Long
Declare Function libusb_clear_halt( _
                        dev_handle As libusb_device_handle Ptr, _
                        endpoint As UByte) As Long
Declare Function libusb_reset_device(dev_handle As libusb_device_handle Ptr)As Long

Declare Function libusb_alloc_streams( _
                        dev_handle As libusb_device_handle Ptr, _
                        num_streams As uint32_t, _
                        endpoints As UByte Ptr, _
                        num_endpoints As Long) As Long
Declare Function libusb_free_streams( _
                        dev_handle As libusb_device_handle Ptr, _
                        endpoints As UByte Ptr, _
                        num_endpoints As Long) As Long

Declare Function libusb_dev_mem_alloc( _
                        dev_handle As libusb_device_handle Ptr, _
                        length As size_t) As UByte Ptr
Declare Function libusb_dev_mem_free( _
                        dev_handle As libusb_device_handle Ptr, _
                        buffer As UByte Ptr, _
                        length As size_t) As Long

Declare Function libusb_kernel_driver_active( _
                        dev_handle As libusb_device_handle Ptr, _
                        interface_number As Long) As Long
Declare Function libusb_detach_kernel_driver( _
                        dev_handle As libusb_device_handle Ptr, _
                        interface_number As Long) As Long
Declare Function libusb_attach_kernel_driver( _
                        dev_handle As libusb_device_handle Ptr, _
                        interface_number As Long) As Long
Declare Function libusb_set_auto_detach_kernel_driver( _
                        dev_handle As libusb_device_handle Ptr, _
                        enable As Long) As Long

Function libusb_control_transfer_get_data(transfer As libusb_transfer Ptr) As ZString Ptr
   Return transfer->buffer + LIBUSB_CONTROL_SETUP_SIZE
End Function

Function libusb_control_transfer_get_setup(transfer As libusb_transfer Ptr) As libusb_control_setup Ptr
   Return Cast(libusb_control_setup Ptr, transfer->buffer)
End Function
 
Sub libusb_fill_control_setup( _
           buffer As UByte Ptr, _
           bmRequestType As uint8_t, _
           bRequest As uint8_t, _
           wValue As uint16_t, _
           wIndex As uint16_t, _
           wLength As uint16_t)
   Dim As libusb_control_setup Ptr setup
   setup = Cast(libusb_control_setup Ptr, buffer)
   setup->bmRequestType = bmRequestType
   setup->bRequest = bRequest
   setup->wValue = libusb_cpu_to_le16(wValue)
   setup->wIndex = libusb_cpu_to_le16(wIndex)
   setup->wLength = libusb_cpu_to_le16(wLength)       
End Sub
             
Declare Function libusb_alloc_transfer(iso_packets As Long) As libusb_transfer Ptr
Declare Function libusb_submit_transfer(transfer As libusb_transfer Ptr) As Long
Declare Function libusb_cancel_transfer(transfer As libusb_transfer Ptr) As Long
Declare Sub libusb_free_transfer(transfer As libusb_transfer Ptr)
Declare Sub libusb_transfer_set_stream_id( _
                   transfer As libusb_transfer Ptr, _
                   stream_id As uint32_t)
Declare Function libusb_transfer_get_stream_id(transfer As libusb_transfer Ptr) As uint32_t

Sub libusb_fill_control_transfer( _
           transfer As libusb_transfer Ptr, _
           dev_handle As libusb_device_handle Ptr, _
           buffer As UByte Ptr, _
           callback As libusb_transfer_cb_fn, _
           user_data As Any Ptr, _
           timeout As ULong)
           
  Dim As libusb_control_setup Ptr setup
  setup = Cast(libusb_control_setup Ptr, buffer)
   transfer->dev_handle = dev_handle
   transfer->endpoint = 0
   transfer->Type = LIBUSB_TRANSFER_TYPE_CONTROL
   transfer->timeout = timeout
   transfer->buffer = buffer
   If setup Then
      transfer->length = Cast(Long, LIBUSB_CONTROL_SETUP_SIZE + libusb_le16_to_cpu(setup->wLength))
   EndIf
   transfer->user_data = user_data
   transfer->callback = callback   
End Sub

Sub libusb_fill_bulk_transfer( _
           transfer As libusb_transfer Ptr, _
           dev_handle As libusb_device_handle Ptr, _
           endpoint As UByte, _
           buffer As UByte Ptr, _
           length As Long, _
           callback As libusb_transfer_cb_fn, _
           user_data As Any Ptr, _
           timeout As ULong)

   transfer->dev_handle = dev_handle
   transfer->endpoint = endpoint
   transfer->Type = LIBUSB_TRANSFER_TYPE_BULK
   transfer->timeout = timeout
   transfer->buffer = buffer
   transfer->length = length
   transfer->user_data = user_data
   transfer->callback = callback
End Sub

Sub libusb_fill_bulk_stream_transfer( _
           transfer As libusb_transfer Ptr, _
           dev_handle As libusb_device_handle Ptr, _
           endpoint As UByte, _
           stream_id As uint32_t, _
           buffer As UByte Ptr, _
           length As Long, _
           callback As libusb_transfer_cb_fn, _
           user_data As Any Ptr, _
           timeout As ULong)

   libusb_fill_bulk_transfer(transfer, dev_handle, endpoint, buffer, _
         length, callback, user_data, timeout)
   transfer->Type = LIBUSB_TRANSFER_TYPE_BULK_STREAM
   libusb_transfer_set_stream_id(transfer, stream_id)
End Sub

Sub libusb_fill_interrupt_transfer( _
           transfer As libusb_transfer Ptr, _
           dev_handle As libusb_device_handle Ptr, _
           endpoint As UByte, _
           buffer As UByte Ptr, _
           length As Long, _
           callback As libusb_transfer_cb_fn, _
           user_data As Any Ptr, _
           timeout As ULong)

   transfer->dev_handle = dev_handle
   transfer->endpoint = endpoint
   transfer->Type = LIBUSB_TRANSFER_TYPE_INTERRUPT
   transfer->timeout = timeout
   transfer->buffer = buffer
   transfer->length = length
   transfer->user_data = user_data
   transfer->callback = callback
End Sub

Sub libusb_fill_iso_transfer( _
           transfer As libusb_transfer Ptr, _
           dev_handle As libusb_device_handle Ptr, _
           endpoint As UByte, _
           buffer As UByte Ptr, _
           length As Long, _
           num_iso_packets As Long, _
           callback As libusb_transfer_cb_fn, _
           user_data As Any Ptr, _
           timeout As ULong)
 
   transfer->dev_handle = dev_handle
   transfer->endpoint = endpoint
   transfer->Type = LIBUSB_TRANSFER_TYPE_ISOCHRONOUS
   transfer->timeout = timeout
   transfer->buffer = buffer
   transfer->length = length
   transfer->num_iso_packets = num_iso_packets
   transfer->user_data = user_data
   transfer->callback = callback
End Sub

Sub libusb_set_iso_packet_lengths( _
           transfer As libusb_transfer Ptr, _
           length As ULong)
   Dim As Long i
   For i = 0 To transfer->num_iso_packets
      transfer->iso_packet_desc(i).length = length
   Next
      
End Sub

Function libusb_get_iso_packet_buffer( _
                transfer As libusb_transfer Ptr, _
                packet As ULong) As UByte Ptr

   Dim As Long i
   Dim As size_t offset = 0
   Dim As Long _packet

   /'' oops..slight bug in the API. packet is an unsigned int, but we use
    * signed integers almost everywhere else. range-check and convert to
    * signed to avoid compiler warnings. FIXME for libusb-2. ''/
   If (packet > INT_MAX) Then
      Return NULL
   EndIf
   _packet = Cast(Long, packet)

   If _packet >= transfer->num_iso_packets Then
      Return NULL
   EndIf

   For i = 0 To _packet
      offset += transfer->iso_packet_desc(i).length
   Next

   Return transfer->buffer + offset
End Function

Function libusb_get_iso_packet_buffer_simple( _
                transfer As libusb_transfer Ptr, _
                packet As Long) As UByte Ptr
 
   Dim As Long _packet

   /'' oops..slight bug in the API. packet is an unsigned int, but we use
    * signed integers almost everywhere else. range-check and convert to
    * signed to avoid compiler warnings. FIXME for libusb-2. ''/
   If (packet > INT_MAX) Then
      Return NULL
   EndIf
   _packet = Cast(Long, packet)

   If _packet >= transfer->num_iso_packets Then
      Return NULL
   EndIf

   Return transfer->buffer + (Cast(Long, transfer->iso_packet_desc(0).length) * _packet)
End Function

/'' sync I/O ''/

Declare Function libusb_control_transfer( _
                        dev_handle As libusb_device_handle Ptr, _
                        request_type As uint8_t, _
                        bRequest As uint8_t, _
                        wValue As uint16_t, _
                        wIndex As uint16_t, _
                        _Data As UByte Ptr, _
                        wLength As uint16_t, _
                        timeout As ULong) As Long

Declare Function libusb_bulk_transfer( _
                        dev_handle As libusb_device_handle Ptr, _
                        endpoint As UByte, _
                        _Data As UByte Ptr, _
                        length As Long, _
                        actual_length As Long Ptr, _
                        timeout As ULong) As Long

Declare Function libusb_interrupt_transfer( _
                        dev_handle As libusb_device_handle Ptr, _
                        endpoint As UByte, _
                        _Data As UByte Ptr, _
                        length As Long, _
                        actual_length As Long Ptr, _
                        timeout As ULong) As Long

Function libusb_get_descriptor( _
                dev_handle As libusb_device_handle Ptr, _
                desc_type As uint8_t, _
                desc_index As uint8_t, _
                _Data As UByte Ptr, _
                length As Long) As Long

   Return libusb_control_transfer(dev_handle, _
                                  LIBUSB_ENDPOINT_IN, _
                                  LIBUSB_REQUEST_GET_DESCRIPTOR, _
                                  Cast(uint16_t, ((desc_type Shl 8) Or desc_index)), _
                                  0, _
                                  _Data, _
                                  Cast(uint16_t, length), _
                                  1000)
End Function

Function libusb_get_string_descriptor( _
                dev_handle As libusb_device_handle Ptr, _
                desc_index As uint8_t, _
                langid As uint16_t, _
                _Data As UByte Ptr, _
                length As Long) As Long

   Return libusb_control_transfer(dev_handle, _
                                  LIBUSB_ENDPOINT_IN, _
                                   LIBUSB_REQUEST_GET_DESCRIPTOR, _
                                   Cast(uint16_t,((LIBUSB_DT_STRING Shl 8) Or desc_index)), _
                                   langid, _
                                   _Data, _
                                   Cast(uint16_t, length), _
                                   1000)
End Function

Declare Function libusb_get_string_descriptor_ascii( _
                        dev_handle As libusb_device_handle Ptr, _
                        desc_index As uint8_t, _
                        _Data As UByte Ptr, _
                        length As Long) As Long

/'' polling and timeouts ''/

Declare Function libusb_try_lock_events(ctx As libusb_context Ptr) As Long
Declare Sub libusb_lock_events(ctx As libusb_context Ptr)
Declare Sub libusb_unlock_events(ctx As libusb_context Ptr)
Declare Function libusb_event_handling_ok(ctx As libusb_context Ptr) As Long
Declare Function libusb_event_handler_active(ctx As libusb_context Ptr) As Long
Declare Sub libusb_interrupt_event_handler(ctx As libusb_context Ptr)
Declare Sub libusb_lock_event_waiters(ctx As libusb_context Ptr)
Declare Sub libusb_unlock_event_waiters(ctx As libusb_context Ptr)
Declare Function libusb_wait_for_event(ctx As libusb_context Ptr, tv As timeval Ptr) As Long

Declare Function libusb_handle_events_timeout(ctx As libusb_context Ptr, tv As timeval Ptr) As Long
Declare Function libusb_handle_events_timeout_completed( _
                        ctx As libusb_context Ptr, _
                        tv As timeval Ptr, _
                        completed As Long Ptr) As Long
Declare Function libusb_handle_events(ctx As libusb_context Ptr) As Long
Declare Function libusb_handle_events_completed(ctx As libusb_context Ptr, completed As Long Ptr) As Long
Declare Function libusb_handle_events_locked(ctx As libusb_context Ptr, tv As timeval Ptr) As Long
Declare Function libusb_pollfds_handle_timeouts(ctx As libusb_context Ptr) As Long
Declare Function libusb_get_next_timeout(ctx As libusb_context Ptr, tv As timeval Ptr) As Long

/''* \ingroup libusb_poll
 * File descriptor for polling
 ''/
Type libusb_pollfd
   /''* Numeric file descriptor ''/
   As Long fd

   As Short events
End Type

Type libusb_pollfd_added_cb As Sub(fd As Long, events As Short, user_data As Any Ptr)

Type libusb_pollfd_removed_cb As Sub(fd As Long, user_data As Any Ptr)

Declare Function libusb_get_pollfds(ctx As libusb_context Ptr) As Const libusb_pollfd Ptr Ptr
Declare Sub libusb_free_pollfds(pollfds As Const libusb_pollfd Ptr Ptr)
Declare Sub libusb_set_pollfd_notifiers( _
                   ctx As libusb_context Ptr, _
                   added_cb As libusb_pollfd_added_cb, _
                   removed_cb As libusb_pollfd_removed_cb, _
                   user_data As Any Ptr)

Type libusb_hotplug_callback_handle As Long

/''* \ingroup libusb_hotplug
 *
 * Since version 1.0.16, \ref LIBUSB_API_VERSION >= &h01000102
 *
 * Flags for hotplug events ''/

Enum lusb_hpf
   /''* Default value when not using any flags. ''/
   LIBUSB_HOTPLUG_NO_FLAGS = 0

   /''* Arm the callback and fire it for all matching currently attached devices. ''/
   LIBUSB_HOTPLUG_ENUMERATE = 1 Shl 0
End Enum

Type libusb_hotplug_flag As lusb_hpf
   
/''* \ingroup libusb_hotplug
 *
 * Since version 1.0.16, \ref LIBUSB_API_VERSION >= &h01000102
 *
 * Hotplug events ''/
Enum lusb_hpe
   /''* A device has been plugged in and is ready to use ''/
   LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED = &h01

   /''* A device has left and is no longer available.
    * It is the user''s responsibility to call libusb_close on any handle associated with a disconnected device.
    * It is safe to call libusb_get_device_descriptor on a device that has left ''/
   LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT    = &h02
End Enum

Type libusb_hotplug_event As lusb_hpe
   
/''* \ingroup libusb_hotplug
 * Wildcard matching for hotplug events ''/
#define LIBUSB_HOTPLUG_MATCH_ANY -1

Type libusb_hotplug_callback_fn As Function( _
            ctx As libusb_context Ptr, _
                  device As libusb_device Ptr, _
                 event As libusb_hotplug_event, _
                 user_data As Any Ptr) As Long
                
Declare Function libusb_hotplug_register_callback( _
                        ctx As libusb_context Ptr, _
                              events As libusb_hotplug_event, _
                             flags As libusb_hotplug_flag, _
                             vendor_id As Long, _
                             product_id As Long, _
                             dev_class As Long, _
                              cb_fn As libusb_hotplug_callback_fn, _
                             user_data As Any Ptr, _
                              callback_handle As libusb_hotplug_callback_handle Ptr) As Long

Declare Sub libusb_hotplug_deregister_callback( _
                   ctx As libusb_context Ptr, _
                         callback_handle As libusb_hotplug_callback_handle)

End Extern
#EndIf