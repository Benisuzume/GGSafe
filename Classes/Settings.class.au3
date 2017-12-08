#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include '..\Header.au3'

Func Settings()
	;---------------------------------------------------------------------------
	;
	Local $oClass = AutoItObject_Class()
	With $oClass
		; --- Properties | Private
		.AddProperty('KeyName', $ELSCOPE_PRIVATE, 'HKCU\Software\' & $APP_NAME)

		; --- Methods | Public
		.AddMethod('Username', 'Settings_Username', False)
		.AddMethod('Password', 'Settings_Password', False)
	EndWith
	Return $oClass.Object
	;
	;---------------------------------------------------------------------------
EndFunc

Func Settings_Username($this, $sUsername = '')
	If @NumParams = 2 Then
		RegWrite($this.KeyName, 'Username', 'REG_SZ', $sUsername)
	Else
		Return RegRead($this.KeyName, 'Username')
	EndIf
EndFunc

Func Settings_Password($this, $sPassword = '')
	If @NumParams = 2 Then
		RegWrite($this.KeyName, 'Password', 'REG_SZ', $sPassword)
	Else
		Return RegRead($this.KeyName, 'Password')
	EndIf
EndFunc