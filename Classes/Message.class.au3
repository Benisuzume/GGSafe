#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include '..\Header.au3'

Func Message()
	Local $oClass = AutoItObject_Class()
	With $oClass
		; --- Methods | Public
		.AddMethod('Error', 'Message_Error', False)
		.AddMethod('Information', 'Message_Information', False)
		.AddMethod('Warning', 'Message_Warning', False)

		; --- Methods | Private
		.AddMethod('GetParent', 'Message_GetParent', True)
	EndWith
	Return $oClass.Object
EndFunc

Func Message_Error($this, $sText, $frmParent = 0)
	MsgBox(BitOR($MB_OK, $MB_ICONERROR), _
			$APP_NAME, _
			$sText, _
			0, _
			$this.GetParent($frmParent))
EndFunc

Func Message_Information($this, $sText, $frmParent = 0)
	MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), _
			$APP_NAME, _
			$sText, _
			0, _
			$this.GetParent($frmParent))
EndFunc

Func Message_Warning($this, $sText, $frmParent = 0)
	MsgBox(BitOR($MB_OK, $MB_ICONWARNING), _
			$APP_NAME, _
			$sText, _
			0, _
			$this.GetParent($frmParent))
EndFunc

Func Message_GetParent($this, $frmParent)
	#forceref $this

	Return IsObj($frmParent) ? $frmParent.Handle : 0
EndFunc