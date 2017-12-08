#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include 'BinaryCall.au3'

Global Const $JSON_UNESCAPED_UNICODE = 1 ; Encode multibyte Unicode characters literally
Global Const $JSON_UNESCAPED_SLASHES = 2 ; Don't escape /
Global Const $JSON_HEX_TAG = 4 ; All < and > are converted to \u003C and \u003E
Global Const $JSON_HEX_AMP = 8 ; All &s are converted to \u0026
Global Const $JSON_HEX_APOS = 16 ; All ' are converted to \u0027
Global Const $JSON_HEX_QUOT = 32 ; All " are converted to \u0022
Global Const $JSON_UNESCAPED_ASCII = 64 ; Don't escape ascii charcters between chr(1) ~ chr(0x1f)
Global Const $JSON_STRICT_PRINT = 256 ; Make sure returned JSON string is RFC4627 compliant

Global Const $JSMN_ERROR_NOMEM = -1 ; Not enough tokens were provided
Global Const $JSMN_ERROR_INVAL = -2 ; Invalid character inside JSON string
Global Const $JSMN_ERROR_PART = -3 ; The string is not a full JSON packet, more bytes expected

Func Json_Decode($Json, $InitTokenCount = 1000)
	Static $Jsmn_Init = _Jsmn_RuntimeLoader('jsmn_init'), $Jsmn_Parse = _Jsmn_RuntimeLoader('jsmn_parse')
	If $Json = '' Then $Json = '""'
	Local $TokenList, $Ret
	Local $Parser = DllStructCreate('uint pos;int toknext;int toksuper')
	Do
		DllCallAddress('none:cdecl', $Jsmn_Init, 'ptr', DllStructGetPtr($Parser))
		$TokenList = DllStructCreate('byte[' & ($InitTokenCount * 20) & ']')
		$Ret = DllCallAddress('int:cdecl', $Jsmn_Parse, 'ptr', DllStructGetPtr($Parser), 'wstr', $Json, 'ptr', DllStructGetPtr($TokenList), 'uint', $InitTokenCount)
		$InitTokenCount *= 2
	Until $Ret[0] <> $JSMN_ERROR_NOMEM

	Local $Next = 0
	Return SetError($Ret[0], 0, _Json_Token($Json, DllStructGetPtr($TokenList), $Next))
EndFunc

Func Json_Encode($Data, $Option = 0)
	Local $Json = ''
	Select
		Case IsString($Data)
			Return '"' & _Json_StringEncode($Data, $Option) & '"'

		Case IsNumber($Data)
			Return $Data

		Case IsArray($Data) And UBound($Data, 0) = 1
			$Json = '['
			For $i = 0 To UBound($Data) - 1
				$Json &= Json_Encode($Data[$i], $Option) & ','
			Next
			If StringRight($Json, 1) = ',' Then $Json = StringTrimRight($Json, 1)
			Return $Json & ']'

		Case _Json_IsObject($Data)
			$Json = '{'
			Local $Keys = $Data.Keys()
			For $i = 0 To UBound($Keys) - 1
				$Json &= '"' & _Json_StringEncode($Keys[$i], $Option) & '":' & Json_Encode($Data.Item($Keys[$i]), $Option) & ','
			Next
			If StringRight($Json, 1) = ',' Then $Json = StringTrimRight($Json, 1)
			Return $Json & '}'

		Case IsBool($Data)
			Return StringLower($Data)

		Case IsPtr($Data)
			Return Number($Data)

		Case IsBinary($Data)
			Return '"' & _Json_StringEncode(BinaryToString($Data, 4), $Option) & '"'

		Case Else
			Return 'null'
	EndSelect
EndFunc

Func _Json_IsObject(ByRef $Object)
	Return (IsObj($Object) And ObjName($Object) = 'Dictionary')
EndFunc

Func _Json_StringDecode($String)
	Static $Json_StringDecode = _Jsmn_RuntimeLoader('json_string_decode')
	Local $Length = StringLen($String) + 1
	Local $Buffer = DllStructCreate('wchar[' & $Length & ']')
	Local $Ret = DllCallAddress('int:cdecl', $Json_StringDecode, 'wstr', $String, 'ptr', DllStructGetPtr($Buffer), 'uint', $Length)
	Return SetError($Ret[0], 0, DllStructGetData($Buffer, 1))
EndFunc

Func _Json_StringEncode($String, $Option = 0)
	Static $Json_StringEncode = _Jsmn_RuntimeLoader('json_string_encode')
	Local $Length = StringLen($String) * 6 + 1
	Local $Buffer = DllStructCreate('wchar[' & $Length & ']')
	Local $Ret = DllCallAddress('int:cdecl', $Json_StringEncode, 'wstr', $String, 'ptr', DllStructGetPtr($Buffer), 'uint', $Length, 'int', $Option)
	Return SetError($Ret[0], 0, DllStructGetData($Buffer, 1))
EndFunc

Func _Json_Token(ByRef $Json, $Ptr, ByRef $Next)
	If $Next = -1 Then Return Null

	Local $Token = DllStructCreate('int;int;int;int', $Ptr + ($Next * 20))
	Local $Type = DllStructGetData($Token, 1)
	Local $Start = DllStructGetData($Token, 2)
	Local $End = DllStructGetData($Token, 3)
	Local $Size = DllStructGetData($Token, 4)
	$Next += 1

	If $Type = 0 And $Start = 0 And $End = 0 And $Size = 0 Then
		$Next = -1
		Return Null
	EndIf

	Switch $Type
		Case 0
			Local $Primitive = StringMid($Json, $Start + 1, $End - $Start)
			Switch $Primitive
				Case 'true'
					Return True
				Case 'false'
					Return False
				Case 'null'
					Return Null
				Case Else
					If StringRegExp($Primitive, '^[+\-0-9]') Then
						Return Number($Primitive)
					Else
						Return _Json_StringDecode($Primitive)
					EndIf
			EndSwitch

		Case 1
			Local $Object = ObjCreate('Scripting.Dictionary')
			$Object.CompareMode = 0

			For $i = 0 To $Size - 1 Step 2
				Local $Key = _Json_Token($Json, $Ptr, $Next)
				Local $Value = _Json_Token($Json, $Ptr, $Next)
				If Not IsString($Key) Then $Key = Json_Encode($Key)

				If $Object.Exists($Key) Then $Object.Remove($Key)
				$Object.Add($Key, $Value)
			Next
			Return $Object

		Case 2
			Local $Array[$Size]
			For $i = 0 To $Size - 1
				$Array[$i] = _Json_Token($Json, $Ptr, $Next)
			Next
			Return $Array

		Case 3
			Return _Json_StringDecode(StringMid($Json, $Start + 1, $End - $Start))
	EndSwitch
EndFunc

Func _Jsmn_RuntimeLoader($ProcName = '')
	Static $SymbolList
	If Not IsDllStruct($SymbolList) Then
		Local $Code = 'AwAAAASFBwAAAAAAAAA1HbEvgTNrvX54gCiqsa1mt5v7RCdoAFjCfVE40DZbE5UfabA9UKuHrjqOMbvjSoB2zBJTEYEQejBREnPrXL3VwpVOW+L9SSfo0rTfA8U2W+Veqo1uy0dOsPhl7vAHbBHrvJNfEUe8TT0q2eaTX2LeWpyrFEm4I3mhDJY/E9cpWf0A78e+y4c7NxewvcVvAakIHE8Xb8fgtqCTVQj3Q1eso7n1fKQj5YsQ20A86Gy9fz8dky78raeZnhYayn0b1riSUKxGVnWja2i02OvAVM3tCCvXwcbSkHTRjuIAbMu2mXF1UpKci3i/GzPmbxo9n/3aX/jpR6UvxMZuaEDEij4yzfZv7EyK9WCNBXxMmtTp3Uv6MZsK+nopXO3C0xFzZA/zQObwP3zhJ4sdatzMhFi9GAM70R4kgMzsxQDNArueXj+UFzbCCFZ89zXs22F7Ixi0FyFTk3jhH56dBaN65S+gtPztNGzEUmtk4M8IanhQSw8xCXr0x0MPDpDFDZs3aN5TtTPYmyk3psk7OrmofCQGG5cRcqEt9902qtxQDOHumfuCPMvU+oMjzLzBVEDnBbj+tY3y1jvgGbmEJguAgfB04tSeAt/2618ksnJJK+dbBkDLxjB4xrFr3uIFFadJQWUckl5vfh4MVXbsFA1hG49lqWDa7uSuPCnOhv8Yql376I4U4gfcF8LcgorkxS+64urv2nMUq6AkBEMQ8bdkI64oKLFfO7fGxh5iMNZuLoutDn2ll3nq4rPi4kOyAtfhW0UPyjvqNtXJ/h0Wik5Mi8z7BVxaURTDk81TP8y9+tzjySB/uGfHFAzjF8DUY1vqJCgn0GQ8ANtiiElX/+Wnc9HWi2bEEXItbm4yv97QrEPvJG9nPRBKWGiAQsIA5J+WryX5NrfEfRPk0QQwyl16lpHlw6l0UMuk7S21xjQgyWo0MywfzoBWW7+t4HH9sqavvP4dYAw81BxXqVHQhefUOS23en4bFUPWE98pAN6bul+kS767vDK34yTC3lA2a8wLrBEilmFhdB74fxbAl+db91PivhwF/CR4Igxr35uLdof7+jAYyACopQzmsbHpvAAwT2lapLix8H03nztAC3fBqFSPBVdIv12lsrrDw4dfhJEzq7AbL/Y7L/nIcBsQ/3UyVnZk4kZP1KzyPCBLLIQNpCVgOLJzQuyaQ6k2QCBy0eJ0ppUyfp54LjwVg0X7bwncYbAomG4ZcFwTQnC2AX3oYG5n6Bz4SLLjxrFsY+v/SVa+GqH8uePBh1TPkHVNmzjXXymEf5jROlnd+EjfQdRyitkjPrg2HiQxxDcVhCh5J2L5+6CY9eIaYgrbd8zJnzAD8KnowHwh2bi4JLgmt7ktJ1XGizox7cWf3/Dod56KAcaIrSVw9XzYybdJCf0YRA6yrwPWXbwnzc/4+UDkmegi+AoCEMoue+cC7vnYVdmlbq/YLE/DWJX383oz2Ryq8anFrZ8jYvdoh8WI+dIugYL2SwRjmBoSwn56XIaot/QpMo3pYJIa4o8aZIZrjvB7BXO5aCDeMuZdUMT6AXGAGF1AeAWxFd2XIo1coR+OplMNDuYia8YAtnSTJ9JwGYWi2dJz3xrxsTQpBONf3yn8LVf8eH+o5eXc7lzCtHlDB+YyI8V9PyMsUPOeyvpB3rr9fDfNy263Zx33zTi5jldgP2OetUqGfbwl+0+zNYnrg64bluyIN/Awt1doDCQkCKpKXxuPaem/SyCHrKjg'
		Local $Symbol[] = ['jsmn_parse', 'jsmn_init', 'json_string_decode', 'json_string_encode']
		Local $CodeBase = _BinaryCall_Create($Code)
		If @error Then Exit MsgBox(16, 'Json', 'Startup Failure!')

		$SymbolList = _BinaryCall_SymbolList($CodeBase, $Symbol)
		If @error Then Exit MsgBox(16, 'Json', 'Startup Failure!')
	EndIf
	If $ProcName Then Return DllStructGetData($SymbolList, $ProcName)
EndFunc