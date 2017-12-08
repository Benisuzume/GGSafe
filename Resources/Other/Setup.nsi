;--------------------------------

	!include "MUI2.nsh"

	!define MUI_NAME "GGSafe"
	!define MUI_VERSION "1.8"

;--------------------------------

	Name "${MUI_NAME}"
	OutFile "GGSafe-${MUI_VERSION}-Setup.exe"

	InstallDir "$PROGRAMFILES\${MUI_NAME}"
	InstallDirRegKey HKCU "Software\${MUI_NAME}" "Path"

	RequestExecutionLevel admin

;--------------------------------

	!define MUI_ABORTWARNING

	!define MUI_ICON "C:\Users\farid\Desktop\GGSafe\Resources\Icon.ico"
	!define MUI_UNICON "C:\Users\farid\Desktop\GGSafe\Resources\Icon.ico"

	!define MUI_WELCOMEFINISHPAGE_BITMAP "C:\Users\farid\Desktop\GGSafe\Resources\Wizard.bmp"
	!define MUI_UNWELCOMEFINISHPAGE_BITMAP "C:\Users\farid\Desktop\GGSafe\Resources\Wizard.bmp"

	!define MUI_HEADERIMAGE
	!define MUI_HEADERIMAGE_RIGHT
	!define MUI_HEADERIMAGE_BITMAP "C:\Users\farid\Desktop\GGSafe\Resources\Header.bmp"

	ShowInstDetails "nevershow"
	ShowUninstDetails "nevershow"

	!define MUI_FINISHPAGE_RUN "$INSTDIR\${MUI_NAME}.exe"
	!define MUI_FINISHPAGE_RUN_TEXT "Run ${MUI_NAME}"

;--------------------------------

	!insertmacro MUI_PAGE_WELCOME
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_PAGE_FINISH

	!insertmacro MUI_UNPAGE_WELCOME
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES
	!insertmacro MUI_UNPAGE_FINISH

;--------------------------------

	!insertmacro MUI_LANGUAGE "English"

;--------------------------------

Section
	SetOutPath "$INSTDIR"
	WriteRegStr HKCU "Software\${MUI_NAME}" "Path" $INSTDIR

	File /r "C:\Users\farid\Desktop\GGSafe\Release\*"
	CreateShortCut "$DESKTOP\${MUI_NAME}.lnk" "$INSTDIR\${MUI_NAME}.exe" ""

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_NAME}" "DisplayName" "${MUI_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_NAME}" "DisplayVersion" "${MUI_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_NAME}" "DisplayIcon" "$INSTDIR\${MUI_NAME}.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_NAME}" "Publisher" "www.GGSafe.ir"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"

	WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------

Section "Uninstall"
	Delete "$DESKTOP\${MUI_NAME}.lnk"
	Delete "$INSTDIR\Uninstall.exe"
	RMDir /r "$INSTDIR"

	DeleteRegValue HKCU "Software\${MUI_NAME}" "Path"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_NAME}"
SectionEnd