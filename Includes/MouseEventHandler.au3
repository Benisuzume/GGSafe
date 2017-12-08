#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include <WinAPI.au3>
#include <WinAPIvkeysConstants.au3>
#include <WindowsConstants.au3>

Global $mMouseEvents[]
$mMouseEvents['Click'] = CreateDummyMap()
$mMouseEvents['Down'] = CreateDummyMap()
$mMouseEvents['Enter'] = CreateDummyMap()
$mMouseEvents['Leave'] = CreateDummyMap()
$mMouseEvents['Up'] = CreateDummyMap()

AdlibRegister(MouseEventHandler, 50)

; #FUNCTION# ====================================================================================================================
; Name ..........: GUICtrlSetMouseClick
; Description ...: Occurs when the control is clicked by the primary mouse button.
; Syntax ........: GUICtrlSetMouseClick($vControl[, $fuFunction = Null[, $vParam = Null]])
; Parameters ....: $vControl            - A variant value.
;                  $fuFunction          - [optional] A boolean value. Default is Null.
;                  $vParam              - [optional] A variant value. Default is Null.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUICtrlSetMouseClick($vControl, $fuFunction = Null, $vParam = Null)
	Return GUICtrlSetMouseEvent('Click', $vControl, $fuFunction, $vParam)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GUICtrlSetMouseDown
; Description ...: Occurs when the mouse pointer is over the control and the primary mouse button is pressed.
; Syntax ........: GUICtrlSetMouseDown($vControl[, $fuFunction = Null[, $vParam = Null]])
; Parameters ....: $vControl            - A variant value.
;                  $fuFunction          - [optional] A boolean value. Default is Null.
;                  $vParam              - [optional] A variant value. Default is Null.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUICtrlSetMouseDown($vControl, $fuFunction = Null, $vParam = Null)
	Return GUICtrlSetMouseEvent('Down', $vControl, $fuFunction, $vParam)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GUICtrlSetMouseEnter
; Description ...: Occurs when the mouse pointer enters the visible part of the control.
; Syntax ........: GUICtrlSetMouseEnter($vControl[, $fuFunction = Null[, $vParam = Null]])
; Parameters ....: $vControl            - A variant value.
;                  $fuFunction          - [optional] A boolean value. Default is Null.
;                  $vParam              - [optional] A variant value. Default is Null.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUICtrlSetMouseEnter($vControl, $fuFunction = Null, $vParam = Null)
	Return GUICtrlSetMouseEvent('Enter', $vControl, $fuFunction, $vParam)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GUICtrlSetMouseLeave
; Description ...: Occurs when the mouse pointer leaves the visible part of the control.
; Syntax ........: GUICtrlSetMouseLeave($vControl[, $fuFunction = Null[, $vParam = Null]])
; Parameters ....: $vControl            - A variant value.
;                  $fuFunction          - [optional] A boolean value. Default is Null.
;                  $vParam              - [optional] A variant value. Default is Null.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUICtrlSetMouseLeave($vControl, $fuFunction = Null, $vParam = Null)
	Return GUICtrlSetMouseEvent('Leave', $vControl, $fuFunction, $vParam)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GUICtrlSetMouseUp
; Description ...: Occurs when the mouse pointer is over the control and the primary mouse button is released.
; Syntax ........: GUICtrlSetMouseUp($vControl[, $fuFunction = Null[, $vParam = Null]])
; Parameters ....: $vControl            - A variant value.
;                  $fuFunction          - [optional] A boolean value. Default is Null.
;                  $vParam              - [optional] A variant value. Default is Null.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUICtrlSetMouseUp($vControl, $fuFunction = Null, $vParam = Null)
	Return GUICtrlSetMouseEvent('Up', $vControl, $fuFunction, $vParam)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GUICtrlUnsetMouseEvents
; Description ...:
; Syntax ........: GUICtrlUnsetMouseEvents($vControl)
; Parameters ....: $vControl            - A variant value.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUICtrlUnsetMouseEvents($vControl)
	Local $hCtrl = Ptr(0)
	If IsHWnd($vControl) Then
		$hCtrl = $vControl
	Else
		$hCtrl = GUICtrlGetHandle($vControl)
		If $hCtrl Then
			; --- Nothing to do
		Else
			Return False
		EndIf
	EndIf

	Local $hWnd = _WinAPI_GetAncestor($hCtrl, $GA_ROOT)
	If $hWnd Then
		; --- Nothing to do
	Else
		Return False
	EndIf

	Local $bReturn = False
	For $sMouseEvent In MapKeys($mMouseEvents)
		If MapExists($mMouseEvents[$sMouseEvent], $hWnd) Then
			If MapRemove($mMouseEvents[$sMouseEvent][$hWnd], $hCtrl) Then
				If UBound($mMouseEvents[$sMouseEvent][$hWnd]) Then
					; --- Nothing to do
				Else
					MapRemove($mMouseEvents[$sMouseEvent], $hWnd)
				EndIf

				$bReturn = True
			EndIf
		EndIf
	Next
	Return $bReturn
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: GUIUnsetMouseEvents
; Description ...:
; Syntax ........: GUIUnsetMouseEvents($hWnd)
; Parameters ....: $hWnd                - A handle value.
; Return values .: None
; Author ........: FaridAgl
; Remarks .......:
; Related .......:
; Example .......: No
; ===============================================================================================================================
Func GUIUnsetMouseEvents($hWnd)
	Local $bReturn = False
	For $sMouseEvent In MapKeys($mMouseEvents)
		If MapRemove($mMouseEvents[$sMouseEvent], $hWnd) Then
			$bReturn = True
		EndIf
	Next
	Return $bReturn
EndFunc

Func GUICtrlSetMouseEvent($sMouseEvent, $vControl, $fuFunction, $vParam)
	Local $hCtrl = Ptr(0)
	Local $iCtrlId = 0

	If IsHWnd($vControl) Then
		$hCtrl = $vControl
		$iCtrlId = _WinAPI_GetDlgCtrlID($hCtrl)
		If $iCtrlId Then
			; --- Nothing to do
		Else
			Return False
		EndIf
	Else
		$hCtrl = GUICtrlGetHandle($vControl)
		If $hCtrl Then
			$iCtrlId = $vControl
			If $iCtrlId = -1 Then
				$iCtrlId = _WinAPI_GetDlgCtrlID($hCtrl)
				If $iCtrlId Then
					; --- Nothing to do
				Else
					Return False
				EndIf
			EndIf
		Else
			Return False
		EndIf
	EndIf

	Local $hWnd = _WinAPI_GetAncestor($hCtrl, $GA_ROOT)
	If $hWnd Then
		; --- Nothing to do
	Else
		Return False
	EndIf

	If $fuFunction = Null And $vParam = Null Then
		If MapExists($mMouseEvents[$sMouseEvent], $hWnd) Then
			If MapRemove($mMouseEvents[$sMouseEvent][$hWnd], $hCtrl) Then

				If UBound($mMouseEvents[$sMouseEvent][$hWnd]) Then
					; --- Nothing to do
				Else
					MapRemove($mMouseEvents[$sMouseEvent], $hWnd)
				EndIf

				Return True
			Else
				Return False
			EndIf
		Else
			Return False
		EndIf
	ElseIf $vParam = Default Then
		If MapExists($mMouseEvents[$sMouseEvent], $hWnd) Then
			If MapExists($mMouseEvents[$sMouseEvent][$hWnd], $hCtrl) Then
				$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['Function'] = $fuFunction

				Return True
			Else
				Return False
			EndIf
		Else
			Return False
		EndIf
	ElseIf $fuFunction = Default Then
		If MapExists($mMouseEvents[$sMouseEvent], $hWnd) Then
			If MapExists($mMouseEvents[$sMouseEvent][$hWnd], $hCtrl) Then
				$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['Param'] = $vParam

				Return True
			Else
				Return False
			EndIf
		Else
			Return False
		EndIf
	EndIf

	If IsFunc($fuFunction) Then
		If MapExists($mMouseEvents[$sMouseEvent], $hWnd) Then
			; --- Nothing to do
		Else
			$mMouseEvents[$sMouseEvent][$hWnd] = CreateDummyMap()
		EndIf

		$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl] = CreateDummyMap()
		$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['Function'] = $fuFunction
		$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['Id'] = $iCtrlId
		$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['Handle'] = $hCtrl
		$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['hWnd'] = $hWnd
		$mMouseEvents[$sMouseEvent][$hWnd][$hCtrl]['Param'] = $vParam

		Return True
	EndIf

	Return False
EndFunc

Func MouseEventHandler()
	Local $tPOINT = DllStructCreate($tagPOINT)
	DllStructSetData($tPOINT, 'X', MouseGetPos(0))
	DllStructSetData($tPOINT, 'Y', MouseGetPos(1))

	Local $hCtrl = _WinAPI_WindowFromPoint($tPOINT)
	If $hCtrl Then
		Local $hWnd = _WinAPI_GetAncestor($hCtrl, $GA_ROOT)
		If $hWnd Then
			; --- Nothing to do
		Else
			Return
		EndIf
	Else
		Return
	EndIf

	Local $bIsPrimaryDown = _WinAPI_GetAsyncKeyState(_WinAPI_GetSystemMetrics($SM_SWAPBUTTON) ? $VK_RBUTTON : $VK_LBUTTON) < 0

	Local Static $bWasPrimaryDown = False
	Local Static $hPreviousCtrl = Ptr(0), $hPreviousDownCtrl = Ptr(0)
	Local Static $mPreviousUpEvent[], $mPreviousLeaveEvent[]

	If $hCtrl = $hPreviousCtrl And $bIsPrimaryDown = $bWasPrimaryDown Then
		Return
	EndIf

	If $hCtrl <> $hPreviousDownCtrl And $bIsPrimaryDown Then
		If $bWasPrimaryDown Then
			Return
		EndIf

		$hPreviousDownCtrl = $hCtrl
	EndIf

	Local $mParam[]

	If $hCtrl <> $hPreviousCtrl Then
		If IsMap($mPreviousUpEvent) And $bWasPrimaryDown And Not $bIsPrimaryDown Then
			$mParam = $mPreviousUpEvent
			MapRemove($mParam, 'Function')

			Call($mPreviousUpEvent['Function'], $mParam)
			If @error = 0xDEAD And @extended = 0xBEEF Then
				Call($mPreviousUpEvent['Function'])
			EndIf

			$mPreviousUpEvent = Null
		EndIf

		If IsMap($mPreviousLeaveEvent) Then
			$mParam = $mPreviousLeaveEvent
			MapRemove($mParam, 'Function')

			Call($mPreviousLeaveEvent['Function'], $mParam)
			If @error = 0xDEAD And @extended = 0xBEEF Then
				Call($mPreviousLeaveEvent['Function'])
			EndIf

			$mPreviousLeaveEvent = Null
		EndIf
	EndIf

	If $bIsPrimaryDown Then
		If MapExists($mMouseEvents['Down'], $hWnd) Then
			If MapExists($mMouseEvents['Down'][$hWnd], $hCtrl) Then
				$mParam = $mMouseEvents['Down'][$hWnd][$hCtrl]
				MapRemove($mParam, 'Function')

				Call($mMouseEvents['Down'][$hWnd][$hCtrl]['Function'], $mParam)
				If @error = 0xDEAD And @extended = 0xBEEF Then
					Call($mMouseEvents['Down'][$hWnd][$hCtrl]['Function'])
				EndIf
			EndIf
		EndIf
	Else
		If $hCtrl <> $hPreviousCtrl Or $bWasPrimaryDown Then
			If $hCtrl = $hPreviousDownCtrl And $bWasPrimaryDown Then
				If MapExists($mMouseEvents['Click'], $hWnd) Then
					If MapExists($mMouseEvents['Click'][$hWnd], $hCtrl) Then
						$mParam = $mMouseEvents['Click'][$hWnd][$hCtrl]
						MapRemove($mParam, 'Function')

						Call($mMouseEvents['Click'][$hWnd][$hCtrl]['Function'], $mParam)
						If @error = 0xDEAD And @extended = 0xBEEF Then
							Call($mMouseEvents['Click'][$hWnd][$hCtrl]['Function'])
						EndIf
					EndIf
				EndIf

				If MapExists($mMouseEvents['Up'], $hWnd) Then
					If MapExists($mMouseEvents['Up'][$hWnd], $hCtrl) Then
						$mParam = $mMouseEvents['Up'][$hWnd][$hCtrl]
						MapRemove($mParam, 'Function')

						Call($mMouseEvents['Up'][$hWnd][$hCtrl]['Function'], $mParam)
						If @error = 0xDEAD And @extended = 0xBEEF Then
							Call($mMouseEvents['Up'][$hWnd][$hCtrl]['Function'])
						EndIf
					EndIf
				EndIf
			ElseIf $hCtrl <> $hPreviousCtrl Then
				If MapExists($mMouseEvents['Enter'], $hWnd) Then
					If MapExists($mMouseEvents['Enter'][$hWnd], $hCtrl) Then
						$mParam = $mMouseEvents['Enter'][$hWnd][$hCtrl]
						MapRemove($mParam, 'Function')

						Call($mMouseEvents['Enter'][$hWnd][$hCtrl]['Function'], $mParam)
						If @error = 0xDEAD And @extended = 0xBEEF Then
							Call($mMouseEvents['Enter'][$hWnd][$hCtrl]['Function'])
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If MapExists($mMouseEvents['Up'], $hWnd) Then
		If MapExists($mMouseEvents['Up'][$hWnd], $hCtrl) Then
			$mPreviousUpEvent = $mMouseEvents['Up'][$hWnd][$hCtrl]
		Else
			$mPreviousUpEvent = Null
		EndIf
	Else
		$mPreviousUpEvent = Null
	EndIf

	If MapExists($mMouseEvents['Leave'], $hWnd) Then
		If MapExists($mMouseEvents['Leave'][$hWnd], $hCtrl) Then
			$mPreviousLeaveEvent = $mMouseEvents['Leave'][$hWnd][$hCtrl]
		Else
			$mPreviousLeaveEvent = Null
		EndIf
	Else
		$mPreviousLeaveEvent = Null
	EndIf

	$bWasPrimaryDown = $bIsPrimaryDown
	$hPreviousCtrl = $hCtrl
EndFunc

Func CreateDummyMap()
	Local $mDummy[]
	Return $mDummy
EndFunc