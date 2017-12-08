#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include <GDIPlus.au3>
#include <Memory.au3>
#include <WinAPIRes.au3>
#include <StaticConstants.au3>

Func Debug($sOutput, $iScriptLineNumber)
	Local $sDateTime = StringFormat('%04u-%02u-%02u %02u:%02u:%02u', @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
	Local $sError = StringFormat('[%s] %u: %s\r\n', $sDateTime, $iScriptLineNumber, $sOutput)

	If @Compiled Then
		Local $hFile = FileOpen(@ScriptDir & '\Errors.txt', $FO_APPEND)
		FileWrite($hFile, $sError)
		FileClose($hFile)
	Else
		ConsoleWrite('!' & $sError)
	EndIf
EndFunc

Func GarenaPlusPath()
	Local $sGarenaMessenger = '\GarenaMessenger.exe'
	Local $sGarenaRoom = '\Room\garena_room.exe'

	Local $sPath = RegRead('HKCU\Software\GGSafe', 'Garena Plus Path')
	If $sPath Then
		If FileExists($sPath & $sGarenaMessenger) And FileExists($sPath & $sGarenaRoom) Then
			Return $sPath
		EndIf
	EndIf

	$sPath = @ProgramFilesDir & '\Garena Plus'
	If FileExists($sPath & $sGarenaMessenger) And FileExists($sPath & $sGarenaRoom) Then
		RegWrite('HKCU\Software\GGSafe', 'Garena Plus Path', 'REG_SZ', $sPath)
		Return $sPath
	EndIf

	$sPath = RegRead('HKLM\SOFTWARE\Garena\im', 'Path')
	If $sPath Then
		If FileExists($sPath & $sGarenaMessenger) And FileExists($sPath & $sGarenaRoom) Then
			RegWrite('HKCU\Software\GGSafe', 'Garena Plus Path', 'REG_SZ', $sPath)
			Return $sPath
		EndIf
	EndIf

	$sPath = FileSelectFolder('Select Garena Plus folder...', '')
	If $sPath Then
		Local $iPos = StringInStr($sPath, '\Room')
		If $iPos Then
			$sPath = StringTrimRight($sPath, StringLen($sPath) - $iPos + 1)
		EndIf

		If FileExists($sPath & $sGarenaMessenger) And FileExists($sPath & $sGarenaRoom) Then
			RegWrite('HKCU\Software\GGSafe', 'Garena Plus Path', 'REG_SZ', $sPath)
			Return $sPath
		EndIf
	EndIf

	RegWrite('HKCU\Software\GGSafe', 'Garena Plus Path', 'REG_SZ', '')
	Return ''
EndFunc

Func GUICtrlCreatePicEx($sResourceName, $iX, $iY, $iWidth, $iHeight, $iStyle = -1, $iExStyle = -1)
	Local $hBitmap = 0, $hPreviousBitmap = 0
	Local $iCtrlId = 0

	If @Compiled Then
		Local $hModule = _WinAPI_GetModuleHandle(Null)
		If $hModule Then
			; --- Nothing to do
		Else
			Return SetError(1, 0, 0)
		EndIf

		Local $hResourceInfo = _WinAPI_FindResource($hModule, $RT_RCDATA, $sResourceName)
		If $hResourceInfo Then
			; --- Nothing to do
		Else
			Return SetError(2, 0, 0)
		EndIf

		Local $hResourceData = _WinAPI_LoadResource($hModule, $hResourceInfo)
		If $hResourceData Then
			; --- Nothing to do
		Else
			Return SetError(3, 0, 0)
		EndIf

		Local $pResourceData = _WinAPI_LockResource($hResourceData)
		If $pResourceData Then
			; --- Nothing to do
		Else
			Return SetError(4, 0, 0)
		EndIf

		Local $iResourceSize = _WinAPI_SizeOfResource($hModule, $hResourceInfo)
		If $iResourceSize Then
			; --- Nothing to do
		Else
			Return SetError(5, 0, 0)
		EndIf

		Local $hMemory = _MemGlobalAlloc($iResourceSize, $GMEM_MOVEABLE)
		If $hMemory Then
			; --- Nothing to do
		Else
			Return SetError(6, 0, 0)
		EndIf

		Local $pMemory = _MemGlobalLock($hMemory)
		If $pMemory Then
			; --- Nothing to do
		Else
			_MemGlobalFree($hMemory)
			Return SetError(7, 0, 0)
		EndIf

		_MemMoveMemory($pResourceData, $pMemory, $iResourceSize)
		If @error Then
			_MemGlobalUnlock($hMemory)
			_MemGlobalFree($hMemory)
			Return SetError(8, 0, 0)
		EndIf

		_MemGlobalUnlock($hMemory)

		Local $pStream = _WinAPI_CreateStreamOnHGlobal($hMemory)
		If $pStream Then
			; --- Nothing to do
		Else
			_MemGlobalFree($hMemory)
			Return SetError(9, 0, 0)
		EndIf

		Local $hBitmapFromStream = _GDIPlus_BitmapCreateFromStream($pStream)
		If $hBitmapFromStream Then
			; --- Nothing to do
		Else
			_WinAPI_ReleaseStream($pStream)
			_MemGlobalFree($hMemory)
			Return SetError(10, 0, 0)
		EndIf

		$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmapFromStream)
		If $hBitmap Then
			; --- Nothing to do
		Else
			_GDIPlus_BitmapDispose($hBitmapFromStream)
			_WinAPI_ReleaseStream($pStream)
			_MemGlobalFree($hMemory)
			Return SetError(11, 0, 0)
		EndIf

		$iCtrlId = GUICtrlCreatePic('', $iX, $iY, $iWidth, $iHeight, $iStyle, $iExStyle)
		If $iCtrlId Then
			; --- Nothing to do
		Else
			_WinAPI_DeleteObject($hBitmap)
			_GDIPlus_BitmapDispose($hBitmapFromStream)
			_WinAPI_ReleaseStream($pStream)
			_MemGlobalFree($hMemory)
		EndIf

		$hPreviousBitmap = GUICtrlSendMsg($iCtrlId, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
		If $hPreviousBitmap Then
			_WinAPI_DeleteObject($hPreviousBitmap)
		EndIf

		_WinAPI_DeleteObject($hBitmap)
		_GDIPlus_BitmapDispose($hBitmapFromStream)
		_WinAPI_ReleaseStream($pStream)
		_MemGlobalFree($hMemory)

		Return $iCtrlId
	Else
		Local $hImage = _GDIPlus_ImageLoadFromFile('Resources\' & $sResourceName & '.png')
		If @error Then
			Return SetError(1, 0, 0)
		EndIf

		$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
		If @error Then
			_GDIPlus_ImageDispose($hImage)
			Return SetError(2, 0, 0)
		EndIf

		_GDIPlus_ImageDispose($hImage)

		$iCtrlId = GUICtrlCreatePic('', $iX, $iY, $iWidth, $iHeight, $iStyle, $iExStyle)

		$hPreviousBitmap = GUICtrlSendMsg($iCtrlId, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
		If $hPreviousBitmap Then
			_WinAPI_DeleteObject($hPreviousBitmap)
		EndIf

		_WinAPI_DeleteObject($hBitmap)

		Return $iCtrlId
	EndIf
EndFunc