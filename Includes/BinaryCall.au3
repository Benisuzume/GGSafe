#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include <Memory.au3>
#include <WinAPI.au3>
#include <WinAPIMisc.au3>

Global $__BinaryCall_Kernel32dll = DllOpen('kernel32.dll')
Global $__BinaryCall_Msvcrtdll = DllOpen('msvcrt.dll')
Global $__BinaryCall_LastError = ''

Func _BinaryCall_Alloc($Code, $Padding = 0)
	Local $Length = BinaryLen($Code) + $Padding
	Local $Ret = _MemVirtualAlloc(0, $Length, $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
	If Not $Ret Then Return SetError(1, @error, 0)
	If BinaryLen($Code) Then
		Local $Buffer = DllStructCreate('byte[' & $Length & ']', $Ret)
		DllStructSetData($Buffer, 1, $Code)
	EndIf
	Return $Ret
EndFunc

Func _BinaryCall_RegionSize($Ptr)
	Local $Buffer = DllStructCreate('ptr;ptr;dword;uint_ptr;dword;dword;dword')
	Local $Ret = DllCall($__BinaryCall_Kernel32dll, 'int', 'VirtualQuery', 'ptr', $Ptr, 'ptr', DllStructGetPtr($Buffer), 'uint_ptr', DllStructGetSize($Buffer))
	If @error Or $Ret[0] = 0 Then Return SetError(1, @error, 0)
	Return DllStructGetData($Buffer, 4)
EndFunc

Func _BinaryCall_Free($Ptr)
	Local $Ret = _MemVirtualFree($Ptr, 0, $MEM_RELEASE)
	If Not $Ret Then
		$Ret = _MemGlobalFree($Ptr)
		If $Ret Then Return SetError(1, @error, False)
	EndIf
	Return True
EndFunc

Func _BinaryCall_Release($CodeBase)
	Local $Ret = _BinaryCall_Free($CodeBase)
	Return SetError(@error, @extended, $Ret)
EndFunc

Func _BinaryCall_MemorySearch($Ptr, $Length, $Binary)
	Static $CodeBase
	If Not $CodeBase Then
		$CodeBase = _BinaryCall_Create('0x5589E58B4D14578B4508568B550C538B7D1085C9742139CA721B29CA8D341031D2EB054239CA740F8A1C17381C1074F34039F076EA31C05B5E5F5DC3', '', 0, True, False)
		If Not $CodeBase Then Return SetError(1, 0, 0)
	EndIf

	$Binary = Binary($Binary)
	Local $Buffer = DllStructCreate('byte[' & BinaryLen($Binary) & ']')
	DllStructSetData($Buffer, 1, $Binary)

	Local $Ret = DllCallAddress('ptr:cdecl', $CodeBase, 'ptr', $Ptr, 'uint', $Length, 'ptr', DllStructGetPtr($Buffer), 'uint', DllStructGetSize($Buffer))
	Return $Ret[0]
EndFunc

Func _BinaryCall_Base64Decode($Src)
	Static $CodeBase
	If Not $CodeBase Then
		$CodeBase = _BinaryCall_Create('0x55B9FF00000089E531C05756E8F10000005381EC0C0100008B55088DBDF5FEFFFFF3A4E9C00000003B45140F8FC20000000FB65C0A028A9C1DF5FEFFFF889DF3FEFFFF0FB65C0A038A9C1DF5FEFFFF889DF2FEFFFF0FB65C0A018985E8FEFFFF0FB69C1DF5FEFFFF899DECFEFFFF0FB63C0A89DE83E630C1FE040FB6BC3DF5FEFFFFC1E70209FE8B7D1089F3881C074080BDF3FEFFFF63745C0FB6B5F3FEFFFF8BBDECFEFFFF8B9DE8FEFFFF89F083E03CC1E704C1F80209F88B7D1088441F0189D883C00280BDF2FEFFFF6374278A85F2FEFFFFC1E60683C10483E03F09F088441F0289D883C0033B4D0C0F8C37FFFFFFEB0231C081C40C0100005B5E5F5DC35EC3E8F9FFFFFF000000000000000000000000000000000000000000000000000000000000000000000000000000000000003E0000003F3435363738393A3B3C3D00000063000000000102030405060708090A0B0C0D0E0F101112131415161718190000000000001A1B1C1D1E1F202122232425262728292A2B2C2D2E2F30313233', '', 132, True, False)
		If Not $CodeBase Then Return SetError(1, 0, Binary(''))
	EndIf

	$Src = String($Src)
	Local $SrcLen = StringLen($Src)
	Local $SrcBuf = DllStructCreate('char[' & $SrcLen & ']')
	DllStructSetData($SrcBuf, 1, $Src)

	Local $DstLen = Int(($SrcLen + 2) / 4) * 3 + 1
	Local $DstBuf = DllStructCreate('byte[' & $DstLen & ']')

	Local $Ret = DllCallAddress('uint:cdecl', $CodeBase, 'ptr', DllStructGetPtr($SrcBuf), 'uint', $SrcLen, 'ptr', DllStructGetPtr($DstBuf), 'uint', $DstLen)
	If $Ret[0] = 0 Then Return SetError(2, 0, Binary(''))
	Return BinaryMid(DllStructGetData($DstBuf, 1), 1, $Ret[0])
EndFunc

Func _BinaryCall_LzmaDecompress($Src)
	Static $CodeBase
	If Not $CodeBase Then
		$CodeBase = _BinaryCall_Create(_BinaryCall_Base64Decode('VYnlVzH/VlOD7EyLXQiKC4D54A+HxQAAADHA6wWD6S2I0ID5LI1QAXfziEXmMcDrBYPpCYjQgPkIjVABd/OIReWLRRSITeSLUwkPtsmLcwWJEA+2ReUBwbgAAwAA0+CNhABwDgAAiQQk6EcEAACJNCSJRdToPAQAAItV1InHi0Xkhf+JArgBAAAAdDaF9nQyi0UQg8MNiRQkiXQkFIl8JBCJRCQYjUXgiUQkDItFDIlcJASD6A2JRCQI6CkAAACLVdSJRdSJFCToAQQAAItF1IXAdAqJPCQx/+jwAwAAg8RMifhbXl9dw1dWU1WJ5YtFJAFFKFD8i3UYAXUcVot1FK2SUopO/oPI/9Pg99BQiPGDyP/T4PfQUADRifeD7AwpwEBQUFBQUFcp9laDy/+4AAMAANPgjYg2BwAAuAAEAATR6fOragVZ6MoCAADi+Yt9/ItF8Ct9JCH4iUXosADoywIAAA+FhQAAAIpN9CN97NPngOkI9tnT7lgB916NPH/B5wg8B1qNjH5sDgAAUVa+AAEAAFCwAXI0i338K33cD7Y/i23M0eeJ8SH+AfGNbE0A6JgCAACJwcHuCIPhATnOvgABAAB1DjnwctfrDIttzOh5AgAAOfBy9FqD+gSJ0XIJg/oKsQNyArEGKcpS60mwwOhJAgAAdRRYX1pZWln/NCRRUrpkBgAAsQDrb7DM6CwCAAB1LLDw6BMCAAB1U1g8B7AJcgKwC1CLdfwrddw7dSQPgs8BAACsi338qumOAQAAsNjo9wEAAIt12HQbsOTo6wEAAIt11HQJi3XQi03UiU3Qi03YiU3Ui03ciU3YiXXcWF9ZumgKAACxCAH6Ulc8B4jIcgIEA1CLbczovAEAAHUUi0Xoi33MweADKclqCF6NfEcE6zWLbcyDxQLomwEAAHUYi0Xoi33MweADaghZaghejbxHBAEAAOsQvwQCAAADfcxqEFm+AAEAAIlN5CnAQIn96GYBAACJwSnxcvMBTeSDfcQED4OwAAAAg0XEB4tN5IP5BHIDagNZi33IweEGKcBAakBejbxPYAMAAIn96CoBAACJwSnxcvOJTeiJTdyD+QRyc4nOg2XcAdHug03cAk6D+Q5zGbivAgAAKciJ8dJl3ANF3NHgA0XIiUXM6y2D7gToowAAANHr0WXcOV3gcgb/RdwpXeBOdei4RAYAAANFyIlFzMFl3ARqBF4p/0eJ+IttzOi0AAAAqAF0Awl93NHnTnXs6wD/RdyLTeSDwQKLffyJ+CtFJDlF3HdIif4rddyLVSisqjnXcwNJdfeJffwPtvA7fSgPgnH9///oKAAAACnAjWwkPItVIIt1+Ct1GIkyi1Usi338K30kiTrJW15fw15YKcBA69qB+wAAAAFyAcPB4whWi3X4O3Ucc+SLReDB4AisiUXgiXX4XsOLTcQPtsDB4QQDRegByOsGD7bAA0XEi23IjWxFACnAjWxFAIH7AAAAAXMci0wkOMFkJCAIO0wkXHOcihH/RCQ4weMIiFQkIInZD7dVAMHpCw+vyjlMJCBzF4nLuQAIAAAp0cHpBWYBTQABwI1sJEDDweoFKUwkICnLZilVAAHAg8ABjWwkQMO4///////gbXN2Y3J0LmRsbHxtYWxsb2MAuP//////4GZyZWUA'))
		If Not $CodeBase Then Return SetError(1, 0, Binary(''))
	EndIf

	$Src = Binary($Src)
	Local $SrcLen = BinaryLen($Src)
	Local $SrcBuf = DllStructCreate('byte[' & $SrcLen & ']')
	DllStructSetData($SrcBuf, 1, $Src)

	Local $Ret = DllCallAddress('ptr:cdecl', $CodeBase, 'ptr', DllStructGetPtr($SrcBuf), 'uint_ptr', $SrcLen, 'uint_ptr*', 0, 'uint*', 0)
	If $Ret[0] Then
		Local $DstBuf = DllStructCreate('byte[' & $Ret[3] & ']', $Ret[0])
		Local $Output = DllStructGetData($DstBuf, 1)
		DllCall($__BinaryCall_Msvcrtdll, 'none:cdecl', 'free', 'ptr', $Ret[0])

		Return $Output
	EndIf
	Return SetError(2, 0, Binary(''))
EndFunc

Func _BinaryCall_Relocation($Base, $Reloc)
	Local $Size = Int(BinaryMid($Reloc, 1, 2))

	For $i = 3 To BinaryLen($Reloc) Step $Size
		Local $Offset = Int(BinaryMid($Reloc, $i, $Size))
		Local $Ptr = $Base + $Offset
		DllStructSetData(DllStructCreate('ptr', $Ptr), 1, DllStructGetData(DllStructCreate('ptr', $Ptr), 1) + $Base)
	Next
EndFunc

Func _BinaryCall_ImportLibrary($Base, $Length)
	Local $JmpBin, $JmpOff, $JmpLen, $DllName, $ProcName
	$JmpBin = Binary('0xB8FFFFFFFFFFE0')
	$JmpOff = 1
	$JmpLen = BinaryLen($JmpBin)

	Do
		Local $Ptr = _BinaryCall_MemorySearch($Base, $Length, $JmpBin)
		If $Ptr = 0 Then ExitLoop

		Local $StringPtr = $Ptr + $JmpLen
		Local $StringLen = _WinAPI_StrLen($StringPtr, False)
		Local $String = DllStructGetData(DllStructCreate('char[' & $StringLen & ']', $StringPtr), 1)
		Local $Split = StringSplit($String, '|')

		If $Split[0] = 1 Then
			$ProcName = $Split[1]
		ElseIf $Split[0] = 2 Then
			If $Split[1] Then $DllName = $Split[1]
			$ProcName = $Split[2]
		EndIf

		If $DllName And $ProcName Then
			Local $Handle = _WinAPI_LoadLibrary($DllName)
			If Not $Handle Then
				$__BinaryCall_LastError = 'LoadLibrary fail on ' & $DllName
				Return SetError(1, 0, False)
			EndIf

			Local $Proc = _WinAPI_GetProcAddress($Handle, $ProcName)
			If Not $Proc Then
				$__BinaryCall_LastError = 'GetProcAddress failed on ' & $ProcName
				Return SetError(2, 0, False)
			EndIf

			DllStructSetData(DllStructCreate('ptr', $Ptr + $JmpOff), 1, $Proc)
		EndIf

		Local $Diff = Int($Ptr - $Base + $JmpLen + $StringLen + 1)
		$Base += $Diff
		$Length -= $Diff

	Until $Length <= $JmpLen
	Return True
EndFunc

Func _BinaryCall_CodePrepare($Code)
	If Not $Code Then Return ''
	If IsBinary($Code) Then Return $Code

	$Code = String($Code)
	If StringLeft($Code, 2) = '0x' Then Return Binary($Code)
	If StringIsXDigit($Code) Then Return Binary('0x' & $Code)

	Return _BinaryCall_LzmaDecompress(_BinaryCall_Base64Decode($Code))
EndFunc

Func _BinaryCall_SymbolFind($CodeBase, $Identify, $Length = Default)
	$Identify = Binary($Identify)

	If IsKeyword($Length) Then
		$Length = _BinaryCall_RegionSize($CodeBase)
	EndIf

	Local $Ptr = _BinaryCall_MemorySearch($CodeBase, $Length, $Identify)
	If $Ptr = 0 Then Return SetError(1, 0, 0)

	Return $Ptr + BinaryLen($Identify)
EndFunc

Func _BinaryCall_SymbolList($CodeBase, $Symbol)
	If Not IsArray($Symbol) Or $CodeBase = 0 Then Return SetError(1, 0, 0)

	Local $Tag = ''
	For $i = 0 To UBound($Symbol) - 1
		$Tag &= 'ptr ' & $Symbol[$i] & ';'
	Next

	Local $SymbolList = DllStructCreate($Tag)
	If @error Then Return SetError(1, 0, 0)

	For $i = 0 To UBound($Symbol) - 1
		$CodeBase = _BinaryCall_SymbolFind($CodeBase, $Symbol[$i])
		DllStructSetData($SymbolList, $Symbol[$i], $CodeBase)
	Next
	Return $SymbolList
EndFunc

Func _BinaryCall_Create($Code, $Reloc = '', $Padding = 0, $ReleaseOnExit = True, $LibraryImport = True)
	Local $BinaryCode = _BinaryCall_CodePrepare($Code)
	If Not $BinaryCode Then Return SetError(1, 0, 0)

	Local $BinaryCodeLen = BinaryLen($BinaryCode)
	Local $TotalCodeLen = $BinaryCodeLen + $Padding

	Local $CodeBase = _BinaryCall_Alloc($BinaryCode, $Padding)
	If Not $CodeBase Then Return SetError(2, 0, 0)

	If $Reloc Then
		$Reloc = _BinaryCall_CodePrepare($Reloc)
		If Not $Reloc Then Return SetError(3, 0, 0)
		_BinaryCall_Relocation($CodeBase, $Reloc)
	EndIf

	If $LibraryImport Then
		If Not _BinaryCall_ImportLibrary($CodeBase, $BinaryCodeLen) Then
			_BinaryCall_Free($CodeBase)
			Return SetError(4, 0, 0)
		EndIf
	EndIf

	If $ReleaseOnExit Then
		_BinaryCall_ReleaseOnExit($CodeBase)
	EndIf

	Return SetError(0, $TotalCodeLen, $CodeBase)
EndFunc

Func _BinaryCall_ReleaseOnExit($Ptr)
	OnAutoItExitRegister('__BinaryCall_DoRelease')
	__BinaryCall_ReleaseOnExit_Handle($Ptr)
EndFunc

Func __BinaryCall_DoRelease()
	__BinaryCall_ReleaseOnExit_Handle()
EndFunc

Func __BinaryCall_ReleaseOnExit_Handle($Ptr = Default)
	Static $PtrList

	If @NumParams = 0 Then
		If IsArray($PtrList) Then
			For $i = 1 To $PtrList[0]
				_BinaryCall_Free($PtrList[$i])
			Next
		EndIf
	Else
		If Not IsArray($PtrList) Then
			Local $InitArray[1] = [0]
			$PtrList = $InitArray
		EndIf

		If IsPtr($Ptr) Then
			Local $Array = $PtrList
			Local $Size = UBound($Array)
			ReDim $Array[$Size + 1]
			$Array[$Size] = $Ptr
			$Array[0] += 1
			$PtrList = $Array
		EndIf
	EndIf
EndFunc