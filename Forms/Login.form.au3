#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include '..\Header.au3'

Func Login($sGarenaUsername, $sGarenaPassword)
	;---------------------------------------------------------------------------
	;
	Local $WIDTH = 350
	Local $HEIGHT = 300
	Local $LEFT = 1
	Local $TOP = 27

	Local $hWnd = GUICreate(StringFormat('%s %.1f', $APP_NAME, $APP_VERSION), $WIDTH + 2, $HEIGHT + 51, -1, -1, BitOR($WS_POPUP, $WS_MINIMIZEBOX))
	GUISetBkColor(0xEFEFF2, $hWnd)
	GUISetFont(8.5, $FW_NORMAL, 0, 'Tahoma', $hWnd, $DEFAULT_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, Login_btnClose_MouseClick, $hWnd)

	GUICtrlCreateLabel('', 0, 0, $WIDTH + 2, 1)
	GUICtrlSetBkColor(-1, 0x76C2AF)

	GUICtrlCreateLabel('', $WIDTH + 1, 1, 1, $HEIGHT + 26)
	GUICtrlSetBkColor(-1, 0x76C2AF)

	GUICtrlCreateLabel('', 0, $HEIGHT + 27, $WIDTH + 2, 24)
	GUICtrlSetBkColor(-1, 0x76C2AF)

	GUICtrlCreateLabel('', 0, 1, 1, $HEIGHT + 26)
	GUICtrlSetBkColor(-1, 0x76C2AF)

	GUICtrlCreatePicEx('ICON_PNG', 8, 8, 20, 16)

	GUICtrlCreateLabel(StringFormat('%s %.1f', $APP_NAME, $APP_VERSION), 35, 1, $WIDTH - 109, 26 + 3, $SS_CENTERIMAGE, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetColor(-1, 0x717171)
	GUICtrlSetFont(-1, 12)

	GUICtrlCreateLabel('', $WIDTH - 33, 1, 34, 26)
	GUICtrlSetTip(-1, 'Close')
	GUICtrlSetMouseClick(-1, Login_btnClose_MouseClick)
	GUICtrlSetMouseDown(-1, Login_Button_MouseDown)
	GUICtrlSetMouseEnter(-1, Login_Button_MouseEnter)
	GUICtrlSetMouseLeave(-1, Login_Button_MouseLeave)
	GUICtrlSetMouseUp(-1, Login_Button_MouseUp)
	GUICtrlCreatePicEx('CLOSE_PNG', $WIDTH - 33, 1, 34, 26)

	GUICtrlCreateLabel('', $WIDTH - 67, 1, 34, 26)
	GUICtrlSetTip(-1, 'Minimize')
	GUICtrlSetMouseClick(-1, Login_btnMinimize_Click)
	GUICtrlSetMouseDown(-1, Login_Button_MouseDown)
	GUICtrlSetMouseEnter(-1, Login_Button_MouseEnter)
	GUICtrlSetMouseLeave(-1, Login_Button_MouseLeave)
	GUICtrlSetMouseUp(-1, Login_Button_MouseUp)
	GUICtrlCreatePicEx('MINIMIZE_PNG', $WIDTH - 67, 1, 34, 26)

	Local $lblStatusBar = GUICtrlCreateLabel('Ready', 11, $HEIGHT + 28, $WIDTH - 20, 22, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, 0x76C2AF)
	GUICtrlSetColor(-1, 0xFFFFFF)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	GUICtrlCreateLabel('Garena Username:', $LEFT + 50, $TOP + 50, -1, 15)

	Local $txtUsername = GUICtrlCreateCombo($sGarenaUsername, $LEFT + 50, $TOP + 70, 225, 20)
	GUICtrlSetLimit(-1, 15)
	GUICtrlSetOnEvent(-1, Login_txtUsername_Changed)

	GUICtrlCreateButton('X', $LEFT + 279, $TOP + 69, 22, 23, $BS_VCENTER)
	GUICtrlSetOnEvent(-1, Login_btnDeleteAccount_Click)

	GUICtrlCreateLabel('Garena Password:', $LEFT + 50, $TOP + 100, -1, 15)

	Local $txtPassword = GUICtrlCreateInput($sGarenaPassword, $LEFT + 50, $TOP + 120, 250, 20, BitOR($ES_LEFT, $ES_PASSWORD))
	GUICtrlSetLimit(-1, 31)

	Local $chkRememberMe = GUICtrlCreateCheckbox('Remember Me', $LEFT + 50, $TOP + 160, -1, 15)

	Local $btnLogin = GUICtrlCreateButton('Login', $LEFT + 125, $TOP + 195, 100, 25, $BS_DEFPUSHBUTTON)
	GUICtrlSetOnEvent(-1, Login_btnLogin_MouseClick)

	GUICtrlCreateLabel('»—«Ì œ—Ì«›  ¬Œ—Ì‰ «Œ»«— »Â ò«‰«·  ·ê—«„ „« »ÅÌÊ‰œÌœ', $LEFT + 50, $TOP + 240, 250, 15, $SS_CENTER)
	GUICtrlSetColor(-1, 0x52A590)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetMouseClick(-1, Login_lnkTelegram_MouseClick)
	GUICtrlSetMouseEnter(-1, LinkLabel_MouseEnter)
	GUICtrlSetMouseLeave(-1, LinkLabel_MouseLeave)

	GUICtrlCreateLabel('ÅÌ‘‰Â«œ«  Ê ”Ê«·«  ŒÊœ —« œ— ›—Ê„ „ÿ—Õ ò‰Ìœ', $LEFT + 50, $TOP + 265, 250, 15, $SS_CENTER)
	GUICtrlSetColor(-1, 0x52A590)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetMouseClick(-1, Login_lnkForum_MouseClick)
	GUICtrlSetMouseEnter(-1, LinkLabel_MouseEnter)
	GUICtrlSetMouseLeave(-1, LinkLabel_MouseLeave)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	If $sGarenaUsername And $sGarenaPassword Then
		GUICtrlSetState($chkRememberMe, $GUI_CHECKED)
	Else
		Local $asAccounts = IniReadSectionNames(@LocalAppDataDir & '\GGSafe.dat')
		If Not @error Then
			Local $sAccounts = ''

			For $i = 1 To $asAccounts[0]
				If $asAccounts[$i] = 'Config' Then
					ContinueLoop
				EndIf

				$sAccounts &= $asAccounts[$i]

				If $i < $asAccounts[0] Then
					$sAccounts &= '&'
				EndIf
			Next

			Local $sCurrentAccount = IniRead(@LocalAppDataDir & '\GGSafe.dat', 'Config', 'Current', '')
			Local $sCurrentPassword = GetAccountPassword($sCurrentAccount)

			GUICtrlSetData($txtUsername, $sAccounts, $sCurrentAccount)
			GUICtrlSetData($txtPassword, $sCurrentPassword)

			If $sCurrentPassword Then
				GUICtrlSetState($chkRememberMe, $GUI_CHECKED)
				GUICtrlSetState($btnLogin, $GUI_FOCUS)
			EndIf
		EndIf
	EndIf

	GUISetState(@SW_SHOW, $hWnd)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	Local $oClass = AutoItObject_Class()
	With $oClass
		; --- Destructor
		.AddDestructor('Login_Destructor')

		; --- Properties | Read-only
		.AddProperty('Handle', $ELSCOPE_READONLY, $hWnd)
		.AddProperty('lblStatusBar', $ELSCOPE_READONLY, $lblStatusBar)
		.AddProperty('txtUsername', $ELSCOPE_READONLY, $txtUsername)
		.AddProperty('txtPassword', $ELSCOPE_READONLY, $txtPassword)
		.AddProperty('chkRememberMe', $ELSCOPE_READONLY, $chkRememberMe)

		; --- Methods | Public
		.AddMethod('Status', 'Login_Status', False)
	EndWith
	$frmLogin = $oClass.Object
	;
	;---------------------------------------------------------------------------

	If $sGarenaUsername And $sGarenaPassword Then
		Login_btnLogin_MouseClick()
	EndIf
EndFunc

Func Login_Destructor($this)
	GUIUnsetMouseEvents($this.Handle)
	GUIDelete($this.Handle)
EndFunc

Func Login_Button_MouseDown($mParam)
	GUICtrlSetBkColor($mParam['Id'], 0x76C2AF)
EndFunc

Func Login_Button_MouseEnter($mParam)
	GUICtrlSetBkColor($mParam['Id'], 0xFEFEFE)
EndFunc

Func Login_Button_MouseLeave($mParam)
	GUICtrlSetBkColor($mParam['Id'], 0xEFEFF2)
EndFunc

Func Login_Button_MouseUp($mParam)
	GUICtrlSetBkColor($mParam['Id'], 0xFEFEFE)
EndFunc

Func Login_btnClose_MouseClick()
	$frmLogin = Null
	Exit
EndFunc

Func Login_btnMinimize_Click()
	GUISetState(@SW_MINIMIZE, $frmLogin.Handle)
EndFunc

Func Login_txtUsername_Changed()
	Local $sUsername = GUICtrlRead($frmLogin.txtUsername)
	Local $sPassword = GetAccountPassword($sUsername)

	If $sPassword Then
		GUICtrlSetData($frmLogin.txtPassword, $sPassword)
		GUICtrlSetState($frmLogin.chkRememberMe, $GUI_CHECKED)
	Else
		GUICtrlSetData($frmLogin.txtPassword, '')
		GUICtrlSetState($frmLogin.chkRememberMe, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Login_btnDeleteAccount_Click()
	Local $sUsername = GUICtrlRead($frmLogin.txtUsername)
	If $sUsername Then
		IniDelete(@LocalAppDataDir & '\GGSafe.dat', $sUsername)

		Local $hUsername = GUICtrlGetHandle($frmLogin.txtUsername)
		Local $iIndex = _GUICtrlComboBox_GetCurSel($hUsername)
		_GUICtrlComboBox_DeleteString($hUsername, $iIndex)

		GUICtrlSetData($frmLogin.txtPassword, '')
		GUICtrlSetState($frmLogin.chkRememberMe, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Login_btnLogin_MouseClick()
	If IsObj($frmLogin) Then
		; --- Nothing to do
	Else
		Return
	EndIf

	Local $sUsername = GUICtrlRead($frmLogin.txtUsername)
	Local $sPassword = GUICtrlRead($frmLogin.txtPassword)

	$sUsername = StringStripWS($sUsername, $STR_STRIPALL)

	If $sUsername And $sPassword Then
		; --- Nothing to do
	Else
		$oMessage.Warning('Please enter both username and password.', $frmLogin)
		GUICtrlSetState($sUsername ? $frmLogin.txtPassword : $frmLogin.txtUsername, $GUI_FOCUS)
		Return
	EndIf

	If StringLen($sPassword) <> 32 Then
		$sPassword = $oLibraries.MD5($sPassword)
		If @error Then
			Debug('Login.form | MD5() failed.', @ScriptLineNumber)
			Return
		EndIf
	EndIf

	If GUICtrlRead($frmLogin.chkRememberMe) = $GUI_CHECKED Then
		SaveAccount($sUsername, $sPassword)
	Else
		SaveAccount($sUsername)
	EndIf

	SetCurrentAccount($sUsername)

	$frmLogin.Status('Initializing Garena Room...')

	Switch $oServer.Login($sUsername)
		Case $oServer.Result['Success']
			If $oServer.LatestVersion > $APP_VERSION Then
				$frmLogin.Status('Ready')
				$oMessage.Information('A new version of ' & $APP_NAME & ' is now available.' & @CRLF & 'Click OK to download it now.', $frmLogin)

				ShellExecute($oServer.LatestUrl)
				Login_btnClose_MouseClick()
				Return
			EndIf

			$frmLogin.Status('Launching Garena Room...')

			Local $avProcesses = ProcessList('garena_room.exe')
			For $i = 1 To $avProcesses[0][0]
				ProcessClose($avProcesses[$i][1])
			Next

			$oLibraries.GarenaRoom($sUsername, $sPassword)

			Login_btnClose_MouseClick()
			Return

		Case $oServer.Result['Disabled']
			$frmLogin.Status('Ready')
			$oMessage.Warning($APP_NAME & ' is currently disabled.' & @CRLF & 'Please try again later.', $frmLogin)

		Case $oServer.Result['Banned']
			$frmLogin.Status('Ready')
			$oMessage.Warning('Sorry, you have been banned from ' & $APP_NAME & '.', $frmLogin)

		Case Else
			$frmLogin.Status('Ready')
			$oMessage.Warning('Unable to connect to server.' & @CRLF & 'Check your internet connection and try again.', $frmLogin)
	EndSwitch
EndFunc

Func Login_Status($this, $sStatus)
	GUICtrlSetData($this.lblStatusBar, $sStatus)
EndFunc

Func Login_lnkTelegram_MouseClick()
	ShellExecute('https://telegram.me/GGSafe')
EndFunc

Func Login_lnkForum_MouseClick()
	ShellExecute('http://forum.ggsafe.ir/')
EndFunc

Func LinkLabel_MouseEnter($mParam)
	GUICtrlSetFont($mParam['Id'], 8.5, $FW_NORMAL, $GUI_FONTUNDER)
EndFunc

Func LinkLabel_MouseLeave($mParam)
	GUICtrlSetFont($mParam['Id'], 8.5, $FW_NORMAL, 0)
EndFunc

Func SaveAccount($sUsername, $sPassword = '')
	IniWrite(@LocalAppDataDir & '\GGSafe.dat', $sUsername, 'Password', $sPassword)
EndFunc

Func GetAccountPassword($sUsername)
	Return IniRead(@LocalAppDataDir & '\GGSafe.dat', $sUsername, 'Password', '')
EndFunc

Func SetCurrentAccount($sUsername)
	IniWrite(@LocalAppDataDir & '\GGSafe.dat', 'Config', 'Current', $sUsername)
EndFunc