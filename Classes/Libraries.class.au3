#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include '..\Header.au3'

Func Libraries()
	;---------------------------------------------------------------------------
	;
	Local $sLibrariesDll = @ScriptDir & '\Libraries\Libraries.dll'
	Local $sGarenaRoomDll = @ScriptDir & '\Libraries\Garena Room.dll'
	Local $sWarcraftDll = @ScriptDir & '\Libraries\Warcraft.dll'

	If FileExists($sLibrariesDll) And FileExists($sGarenaRoomDll) Then
		; --- Nothing to do
	Else
		Debug('Libraries.class | FileExists() failed.', @ScriptLineNumber)
		Return SetError(1, 0, Null)
	EndIf

	If FileExists($sWarcraftDll) Then
		EnvSet('WarcraftDllPath', $sWarcraftDll)
	Else
		EnvSet('WarcraftDllPath', '')
	EndIf

	Local $hLibraries = DllOpen($sLibrariesDll)
	If $hLibraries = -1 Then
		Debug('Libraries.class | DllOpen() failed.', @ScriptLineNumber)
		Return SetError(2, 0, Null)
	EndIf

	Local $tagClientData = 'HWND hWnd;'
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	Local $oClass = AutoItObject_Class()
	With $oClass
		; --- Destructor
		.AddDestructor('Libraries_Destructor')

		; --- Properties | Private
		.AddProperty('Libraries', $ELSCOPE_PRIVATE, $hLibraries)
		.AddProperty('GarenaRoomDll', $ELSCOPE_PRIVATE, $sGarenaRoomDll)
		.AddProperty('tagClientData', $ELSCOPE_PRIVATE, $tagClientData)

		; --- Methods | Public
		.AddMethod('Initialize', 'Libraries_Initialize', False)
		.AddMethod('GarenaRoom', 'Libraries_GarenaRoom', False)
		.AddMethod('MD5', 'Libraries_MD5', False)
	EndWith
	Return $oClass.Object
	;
	;---------------------------------------------------------------------------
EndFunc

Func Libraries_Destructor($this)
	DllClose($this.Libraries)
EndFunc

Func Libraries_Initialize($this, $sLanGameIp, $sIpAddress, $uPort, $sIpLookingUp, $sMessage)
	If IsString($sIpAddress) And IsInt($uPort) Then
		; --- Nothing to do
	Else
		Debug('Libraries.class | IsString() or IsInt() failed.', @ScriptLineNumber)
		Return SetError(1, 0, '')
	EndIf

	DllCall($this.Libraries, 'NONE:cdecl', 'Initialize', _
			'STR', $sLanGameIp, _
			'STR', $sIpAddress, _
			'USHORT', $uPort, _
			'STR', $sIpLookingUp, _
			'WSTR', $sMessage)
EndFunc

Func Libraries_GarenaRoom($this, $sUsername, $sPassword)
	;---------------------------------------------------------------------------
	;
	Local $sCurrentDirectory = GarenaPlusPath() & '\Room'
	Local $sApplicationName = $sCurrentDirectory & '\garena_room.exe'
	Local $sCommandLine = StringFormat('--u%s,--p%s,', $sUsername, $sPassword)

	Local $tClientData = DllStructCreate($this.tagClientData)
	If @error Then
		Debug('Libraries.class | DllStructCreate() failed.', @ScriptLineNumber)
		Return SetError(1, 0, Null)
	EndIf

	DllStructSetData($tClientData, 'hWnd', Null)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	Local $avResult = DllCall($this.Libraries, 'HWND:cdecl', 'GarenaRoom2', _
			'STR', $sApplicationName, _
			'STR', $sCommandLine, _
			'STR', $sCurrentDirectory, _
			'STR', $this.GarenaRoomDll, _
			'STRUCT*', $tClientData)
	If @error Then
		Debug('Libraries.class | GarenaRoom() failed.', @ScriptLineNumber)
		Return SetError(2, 0, Null)
	EndIf

	Return $avResult[0]
	;
	;---------------------------------------------------------------------------
EndFunc

Func Libraries_MD5($this, $sInput)
	If IsString($sInput) And StringLen($sInput) Then
		; --- Nothing to do
	Else
		Debug('Libraries.class | IsString() or StringLen() failed.', @ScriptLineNumber)
		Return SetError(1, 0, '')
	EndIf

	Local $tBuffer = DllStructCreate('BYTE[16]')
	If @error Then
		Debug('Libraries.class | DllStructCreate() failed.', @ScriptLineNumber)
		Return SetError(2, 0, '')
	EndIf

	Local $avResult = DllCall($this.Libraries, 'BOOL:cdecl', '_MD5', _
			'STR', $sInput, _
			'STRUCT*', $tBuffer)
	If @error Or Not $avResult[0] Then
		Debug('Libraries.class | DllCall() failed.', @ScriptLineNumber)
		Return SetError(3, 0, '')
	EndIf

	Local $dResult = DllStructGetData($tBuffer, 1)
	Local $sResult = StringLower(StringTrimLeft($dResult, 2))

	Return $sResult
EndFunc