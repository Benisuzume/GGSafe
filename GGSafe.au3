#NoTrayIcon
#RequireAdmin
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include 'Header.au3'

;---------------------------------------------------------------------------
;
#pragma compile(Out, Release\GGSafe.exe)
#pragma compile(Icon, Resources\Icon.ico)
#pragma compile(CompanyName, www.GGSafe.ir)
#pragma compile(FileDescription, GGSafe)
#pragma compile(FileVersion, 1.8.0.0)
#pragma compile(InternalName, GGSafe)
#pragma compile(LegalCopyright, Copyright © 2016 GGSafe.ir All rights reserved.)
#pragma compile(OriginalFilename, GGSafe.exe)
#pragma compile(ProductName, GGSafe)
#pragma compile(ProductVersion, 1.8.0.0)

#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf=1 /sv=1 /rm /rsln

#AutoIt3Wrapper_Res_File_Add=Resources\CLOSE_PNG.png, RT_RCDATA, CLOSE_PNG
#AutoIt3Wrapper_Res_File_Add=Resources\ICON_PNG.png, RT_RCDATA, ICON_PNG
#AutoIt3Wrapper_Res_File_Add=Resources\MINIMIZE_PNG.png, RT_RCDATA, MINIMIZE_PNG

#AutoIt3Wrapper_Res_Remove=RT_ICON, 1, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 7, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 8, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 9, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 10, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 11, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 12, 2057
#AutoIt3Wrapper_Res_Remove=RT_STRING, 313, 2057
#AutoIt3Wrapper_Res_Remove=RT_GROUPICON, 169, 2057

#AutoIt3Wrapper_Run_After=Resources\Other\SignTheFile.au3
;
;---------------------------------------------------------------------------

Func EntryPoint()
	;---------------------------------------------------------------------------
	;
	$hMutex = _WinAPI_CreateMutex($APP_NAME & ': Running')

	If _WinAPI_GetLastError() = $ERROR_ALREADY_EXISTS Then
		_WinAPI_CloseHandle($hMutex)
		Exit
	EndIf
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	TCPStartup()
	If @error Then
		_WinAPI_CloseHandle($hMutex)

		Return SetError(2, 0, 'TCPStartup()')
	EndIf

	If  StringInStr(TCPNameToIP('ggsafe.ir'), '127.0.') Then
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(3, 0, 'TCPNameToIP()')
	EndIf

	_GDIPlus_Startup()
	If @error Then
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(4, 0, '_GDIPlus_Startup()')
	EndIf

	AutoItObject_Startup(@ScriptDir & '\Libraries\AutoItObject.dll')
	If @error Then
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(5, 0, 'AutoItObject_Startup()')
	EndIf

	$oErrorHandler = ObjEvent('AutoIt.Error', ComErrorHandler)
	If @error Then
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(6, 0, 'ObjEvent()')
	EndIf
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	$oSettings = Settings()
	$oMessage = Message()

	$oLibraries = Libraries()
	If @error Then
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(7, 0, 'Libraries.class')
	EndIf

	$oServer = Server()
	If @error Then
		$oLibraries = Null
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(8, 0, 'Server.class')
	EndIf

	Local $sGarenaPlusPath = GarenaPlusPath()
	If $sGarenaPlusPath Then
		; --- Nothing to do
	Else
		$oServer = Null
		$oLibraries = Null
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		$oMessage.Error('Unable to find Garena Plus path.' & @CRLF & 'Please download and install Garena Plus.')
		Return SetError(1, 0, 'GarenaPlusPath()')
	EndIf

	_SQLite_Startup($sGarenaPlusPath & '\sqlite3.dll')
	If @error Then
		$oServer = Null
		$oLibraries = Null
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(8, 0, '_SQLite_Startup()')
	EndIf

	FileInstall('Resources\Roomtw.dat', $sGarenaPlusPath & '\Room\Roomtw.dat', $FC_OVERWRITE)

	_SQLite_Open($sGarenaPlusPath & '\Room\Roomtw.dat')
	If @error Then
		_SQLite_Shutdown()
		$oServer = Null
		$oLibraries = Null
		_GDIPlus_Shutdown()
		TCPShutdown()
		_WinAPI_CloseHandle($hMutex)

		Return SetError(8, 0, '_SQLite_Open()')
	EndIf

	OnAutoItExitRegister(ExitPoint)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	Local $sGarenaUsername = ''
	Local $sGarenaPassword = ''

	If $CmdLine[0] Then
		$sGarenaUsername = _StringBetween($CmdLineRaw, '--u', ',')
		If @error Then
			$sGarenaUsername = ''
		Else
			$sGarenaPassword = _StringBetween($CmdLineRaw, '--p', ',')
			If @error Then
				$sGarenaUsername = ''
				$sGarenaPassword = ''
			Else
				$sGarenaUsername = $sGarenaUsername[0]
				$sGarenaPassword = $sGarenaPassword[0]
			EndIf
		EndIf
	EndIf

	Login($sGarenaUsername, $sGarenaPassword)

	While True
		Sleep(1000)
	WEnd
	;
	;---------------------------------------------------------------------------
EndFunc

Func ExitPoint()
	$oServer = Null
	$oLibraries = Null

	_SQLite_Close()
	_SQLite_Shutdown()
	_GDIPlus_Shutdown()
	TCPShutdown()
	_WinAPI_CloseHandle($hMutex)
EndFunc

Func ComErrorHandler()
	MsgBox(BitOR($MB_OK, $MB_ICONERROR), $APP_NAME, 'Unfortunately ' & $APP_NAME & ' has stopped working.' & @CRLF & @CRLF & _
			'Error Number:' & @TAB & '0x' & Hex($oErrorHandler.number, 8) & @CRLF & _
			'Line Number:' & @TAB & $oErrorHandler.scriptline & @CRLF & _
			'Description:' & @TAB & $oErrorHandler.windescription)
	Exit
EndFunc

Global $sEntryPoint = EntryPoint()
If @error Then
	Debug('GGSafe | ' & $sEntryPoint & ' failed.', @ScriptLineNumber)
EndIf