#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

Global Enum $ELSCOPE_PUBLIC, $ELSCOPE_READONLY, $ELSCOPE_PRIVATE

Global $hAutoItObjectDll = -1

Func AutoItObject_Startup($sDllPath)
	If $hAutoItObjectDll = -1 Then
		$hAutoItObjectDll = DllOpen($sDllPath)
		If $hAutoItObjectDll = -1 Then
			Return SetError(1, 0, False)
		EndIf

		Local $hFunctionProxy = DllCallbackRegister(AutoItObject_FunctionProxy, 'INT', 'WSTR;idispatch')

		DllCall($hAutoItObjectDll, 'PTR', 'Initialize', _
				'PTR', DllCallbackGetPtr($hFunctionProxy), _
				'PTR', Null)
		If @error Then
			DllCallbackFree($hFunctionProxy)
			DllClose($hAutoItObjectDll)
			$hAutoItObjectDll = -1
			Return SetError(2, 0, False)
		EndIf
	EndIf

	Return True
EndFunc

Func AutoItObject_Class()
	If $hAutoItObjectDll = -1 Then
		Return Null
	EndIf

	Return DllCall($hAutoItObjectDll, 'idispatch', 'CreateAutoItObjectClass')[0]
EndFunc

Func AutoItObject_FunctionProxy($sFunction, $this)
	Local $avArguments = $this.__params__
	If IsArray($avArguments) Then
		Local $vResult = Call($sFunction, $avArguments)
		If @error = 0xDEAD And @extended = 0xBEEF Then
			Return 0
		EndIf

		$this.__error__ = @error
		$this.__result__ = $vResult
		Return 1
	EndIf

	Return 0
EndFunc