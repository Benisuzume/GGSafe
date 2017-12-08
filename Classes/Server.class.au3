#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include '..\Header.au3'

Func Server()
	;---------------------------------------------------------------------------
	;
	Local $pCurl = Curl_Easy_Init()
	If $pCurl Then
		; --- Nothing to do
	Else
		Debug('Server.class | Curl_Easy_Init() failed.', @ScriptLineNumber)
		Return SetError(1, 0, Null)
	EndIf

	Curl_Easy_Setopt($pCurl, $CURLOPT_URL, 'http://ggsafe.ir/server/')
	Curl_Easy_Setopt($pCurl, $CURLOPT_SSL_VERIFYPEER, 0)
	Curl_Easy_Setopt($pCurl, $CURLOPT_FORBID_REUSE, 1)
	Curl_Easy_Setopt($pCurl, $CURLOPT_WRITEFUNCTION, Curl_DataWriteCallback())
	Curl_Easy_Setopt($pCurl, $CURLOPT_WRITEDATA, $pCurl)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	Local $mResult[]
	$mResult['Success'] = 1
	$mResult['Disabled'] = 2
	$mResult['Banned'] = 3
	$mResult['InternetError'] = 4

	Local $mRequest[]
	$mRequest['Login'] = 1
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	Local $oClass = AutoItObject_Class()
	With $oClass
		; --- Destructor
		.AddDestructor('Server_Destructor')

		; --- Properties | Private
		.AddProperty('Curl', $ELSCOPE_PRIVATE, $pCurl)

		; --- Properties | Read-only
		.AddProperty('Result', $ELSCOPE_READONLY, $mResult)
		.AddProperty('Request', $ELSCOPE_READONLY, $mRequest)
		.AddProperty('LatestVersion', $ELSCOPE_READONLY, 0.0)
		.AddProperty('LatestUrl', $ELSCOPE_READONLY, '')
		.AddProperty('IpAddress', $ELSCOPE_READONLY, '')

		; --- Methods | Public
		.AddMethod('Login', 'Server_Login', False)

		; --- Methods | Private
		.AddMethod('MachineId', 'Server_MachineId', True)
	EndWith
	Return $oClass.Object
	;
	;---------------------------------------------------------------------------
EndFunc

Func Server_Destructor($this)
	#forceref $this

	; Curl_Easy_Cleanup($this.Curl)
EndFunc

Func Server_Login($this, $sUsername)
	;---------------------------------------------------------------------------
	;
	Local $sMachineId = $this.MachineId()
	If $sMachineId Then
		; --- Nothing to do
	Else
		Debug('Server.class | MachineId() failed.', @ScriptLineNumber)
		Return $this.Result['InternetError']
	EndIf

	Local $oRequest = ObjCreate('Scripting.Dictionary')
	$oRequest.Add('request', $this.Request['Login'])
	$oRequest.Add('username', $sUsername)
	$oRequest.Add('machine', $sMachineId)

	Local $oJson = Json_Encode($oRequest)
	Curl_Easy_Setopt($this.Curl, $CURLOPT_COPYPOSTFIELDS, $oJson)

	If Curl_Easy_Perform($this.Curl) = $CURLE_OK Then
		; --- Nothing to do
	Else
		Debug('Server.class | Curl_Easy_Perform() failed.', @ScriptLineNumber)
		Return $this.Result['InternetError']
	EndIf

	Local $dResponse = Curl_Data_Get($this.Curl)
	Local $sResponse = BinaryToString($dResponse)

	Curl_Data_Cleanup($this.Curl)
	;
	;---------------------------------------------------------------------------

	;---------------------------------------------------------------------------
	;
	Local $oResponse = Json_Decode($sResponse)
	If IsObj($oResponse) And $oResponse.Exists('Result') Then
		; --- Nothing to do
	Else
		Return $this.Result['InternetError']
	EndIf

	If $oResponse.Item('Result') = $this.Result['Success'] Then
		; --- Nothing to do
	Else
		Switch $oResponse.Item('Result')
			Case $this.Result['Disabled'], $this.Result['Banned']
				Return $oResponse.Item('Result')

			Case Else
				Return $this.Result['InternetError']
		EndSwitch
	EndIf

	$this.LatestVersion = $oResponse.Item('LatestVersion')
	$this.LatestUrl = $oResponse.Item('LatestUrl')
	$this.IpAddress = $oResponse.Item('IpAddress')

	$oLibraries.Initialize($oResponse.Item('LanGameIp'), _
			$oResponse.Item('ProxyIp'), _
			$oResponse.Item('ProxyPort'), _
			$oResponse.Item('IpLookingUp'), _
			$oResponse.Item('Message'))

	Local $sQuery = 'INSERT INTO RoomTab (' & _
			'RoomId, AreaId, GameId, RoomName, ServerId, MaxNormalUsers, MaxUsers, RoomType, EntryLevel, SendWay, DisplayOrder ' & _
			') VALUES (' & _
			"%u, 10010007, 1001, '%s', %u, %u, %u, 1, %u, 0, 0" & _
			');'

	_SQLite_Exec(-1, 'DELETE FROM RoomTab WHERE AreaId=10010007;')

	For $oRoom In $oResponse.Item('Rooms')
		_SQLite_Exec(-1, 'DELETE FROM RoomTab WHERE RoomId=' & $oRoom.Item('RoomId') & ';')

		_SQLite_Exec(-1, StringFormat($sQuery, _
				$oRoom.Item('RoomId'), $oRoom.Item('RoomName'), $oRoom.Item('ServerId'), $oRoom.Item('MaxUsers'), $oRoom.Item('MaxUsers'), $oRoom.Item('EntryLevel')))

		EnvSet($oRoom.Item('RoomName') & ' MaxUsers', $oRoom.Item('MaxUsers'))
		EnvSet($oRoom.Item('RoomName') & ' EntryLevel', $oRoom.Item('EntryLevel'))
		EnvSet($oRoom.Item('RoomName') & ' IsBanned', $oRoom.Item('IsBanned'))
	Next

	Local $sBlockedUsernames = ''
	For $block In $oResponse.Item('Blocks')
		$sBlockedUsernames &= $block & ','
	Next

	$sBlockedUsernames = StringTrimRight($sBlockedUsernames, 1)
	EnvSet('BlockedUsernames', $sBlockedUsernames)

	Return $this.Result['Success']
	;
	;---------------------------------------------------------------------------
EndFunc

Func Server_MachineId($this)
	#forceref $this

	Local $sText = ''

	Local $oService = ObjGet('winmgmts:\\.\root\cimv2')
	If IsObj($oService) Then
		; --- Nothing to do
	Else
		Debug('Server.class | ObjGet() failed.', @ScriptLineNumber)
		Return ''
	EndIf

	Local $oItems = $oService.ExecQuery('SELECT * FROM Win32_ComputerSystemProduct')
	If IsObj($oItems) Then
		For $oProperty In $oItems
			$sText &= $oProperty.IdentifyingNumber
			$sText &= $oProperty.Name
			$sText &= $oProperty.SKUNumber
			$sText &= $oProperty.UUID
			$sText &= $oProperty.Vendor
			$sText &= $oProperty.Version
		Next
	Else
		Debug('Server.class | IsObj() failed.', @ScriptLineNumber)
		Return ''
	EndIf

	$oItems = $oService.ExecQuery('SELECT * FROM Win32_BIOS')
	If IsObj($oItems) Then
		For $oProperty In $oItems
			$sText &= $oProperty.IdentificationCode
			$sText &= $oProperty.Manufacturer
			$sText &= $oProperty.Name
			$sText &= $oProperty.SerialNumber
			$sText &= $oProperty.SMBIOSMajorVersion
			$sText &= $oProperty.SMBIOSMinorVersion
		Next
	Else
		Debug('Server.class | IsObj() failed.', @ScriptLineNumber)
		Return ''
	EndIf

	$sText = StringStripWS($sText, $STR_STRIPALL)
	If $sText Then
		; --- Nothing to do
	Else
		Debug('Server.class | StringStripWS() failed.', @ScriptLineNumber)
		Return ''
	EndIf

	Local $sHash = $oLibraries.MD5($sText)
	If @error Then
		Debug('Server.class | MD5() failed.', @ScriptLineNumber)
		Return ''
	EndIf

	Return $sHash
EndFunc