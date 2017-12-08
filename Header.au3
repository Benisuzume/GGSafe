#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

;---------------------------------------------------------------------------
;
AutoItSetOption('GUICloseOnESC', 0)
AutoItSetOption('GUIDataSeparatorChar', '&')
AutoItSetOption('GUIOnEventMode', 1)
AutoItSetOption('MustDeclareVars', 1)
AutoItSetOption('TCPTimeout', 10000)
;
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
;
Global Const $APP_NAME = 'GGSafe'
Global Const $APP_VERSION = 1.8
;
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
;
Global $oErrorHandler = Null

Global $oGarenaTalk = Null
Global $oLibraries = Null
Global $oMessage = Null
Global $oServer = Null
Global $oSettings = Null

Global $frmLogin = Null

Global $hMutex = 0
;
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
;
#include <GuiComboBox.au3>
#include <SQLite.au3>
#include <String.au3>
#include <WinAPIProc.au3>

#include <APIErrorsConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>

#include 'Includes\AutoItObject.au3'
#include 'Includes\Curl.au3'
#include 'Includes\Functions.au3'
#include 'Includes\Json.au3'
#include 'Includes\MouseEventHandler.au3'

#include 'Classes\Libraries.class.au3'
#include 'Classes\Message.class.au3'
#include 'Classes\Server.class.au3'
#include 'Classes\Settings.class.au3'

#include 'Forms\Login.form.au3'
;
;---------------------------------------------------------------------------