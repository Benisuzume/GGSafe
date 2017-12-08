#include "stdafx.h"

HANDLE hProxyData;
ProxyData *pProxyData;
FARPROC pConnect;
BYTE bJumpInstruction[6], bJumpInstructionOriginal[6];

FARPROC pSendTo;
BYTE bSendToJumpInstruction[6], bSendToJumpInstructionOriginal[6];

SOCKET hAuthServer = NULL;
SOCKET hRoomServer = NULL;
BOOL fIsLoggedIn = false;

int __stdcall _connect(SOCKET s, const struct sockaddr *name, int namelen)
{
	int iResult = SOCKET_ERROR;

	DWORD dwOldProtection = NULL;
	VirtualProtect(pConnect, 6, PAGE_EXECUTE_READWRITE, &dwOldProtection);
	CopyMemory(pConnect, bJumpInstructionOriginal, 6);

	u_short uPort = ((sockaddr_in *)name)->sin_port;
	if (uPort == 0x201D) // 7456
	{
		if (!fIsLoggedIn)
		{
			sockaddr_in SocketAddress;
			SocketAddress.sin_family = AF_INET;
			SocketAddress.sin_addr.S_un.S_addr = pProxyData->uAddress;
			SocketAddress.sin_port = pProxyData->uPort;

			hAuthServer = s;
			iResult = SOCKSv5(s, &SocketAddress, (sockaddr_in *)name);
		}
		else
			iResult = connect(s, name, namelen);
	}
	else
		iResult = connect(s, name, namelen);

	CopyMemory(pConnect, bJumpInstruction, 6);
	VirtualProtect(pConnect, 6, dwOldProtection, &dwOldProtection);

	return iResult;
}

VOID CloseAuthSocket()
{
	closesocket(hAuthServer);
	fIsLoggedIn = true;
}

int SOCKSv5(SOCKET s, sockaddr_in *SocksAddress, sockaddr_in *DestinationAddress)
{
	if (connect(s, (sockaddr *)SocksAddress, sizeof(sockaddr)) == SOCKET_ERROR)
		return SOCKET_ERROR;

	/* -------------------------------------------------- */

	{
		char szSend[3];
		szSend[0] = 0x05; // SOCKS version number
		szSend[1] = 0x01; // Number of authentication methods supported
		szSend[2] = 0x00; // No authentication

		if (send(s, szSend, 3, 0) != 3)
			return SOCKET_ERROR;
	}

	/* -------------------------------------------------- */

	{
		char szReceive[2];

		if (recv(s, szReceive, 2, 0) != 2)
			return SOCKET_ERROR;

		if (szReceive[0] != 0x05 || szReceive[1] != 0x00)
			return SOCKET_ERROR;
	}

	/* -------------------------------------------------- */

	{
		char szSend[10];
		szSend[0] = 0x05; // SOCKS version number
		szSend[1] = 0x01; // Establish a TCP/IP stream connection
		szSend[2] = 0x00; // Reserved
		szSend[3] = 0x01; // IPv4 address
		memcpy(           // Destination address
			szSend + 4,
			(const void *)&DestinationAddress->sin_addr.S_un.S_addr,
			4);
		memcpy(           // Destination port
			szSend + 8,
			(const void *)&DestinationAddress->sin_port,
			2);

		if (send(s, szSend, 10, 0) != 10)
			return SOCKET_ERROR;
	}

	/* -------------------------------------------------- */

	{
		char szReceive[10];
		ZeroMemory(szReceive, 10);

		if (recv(s, szReceive, 10, 0) != 10)
			return SOCKET_ERROR;

		if (szReceive[0] != 0x05 || szReceive[1] != 0x00)
			return SOCKET_ERROR;
	}

	/* -------------------------------------------------- */

	return NO_ERROR;
}

int __stdcall _sendto(SOCKET s, const char *buf, int len, int flags, const struct sockaddr *to, int tolen)
{
	int iResult = SOCKET_ERROR;

	DWORD dwOldProtection = NULL;
	VirtualProtect(pSendTo, 6, PAGE_EXECUTE_READWRITE, &dwOldProtection);
	CopyMemory(pSendTo, bSendToJumpInstructionOriginal, 6);

	if (len == 9 && buf[0] == 5)
	{
		((sockaddr_in *)to)->sin_addr.s_addr = pProxyData->uIpLookingUp;

		iResult = sendto(s, buf, len, flags, to, tolen);
	}
	else
		iResult = sendto(s, buf, len, flags, to, tolen);

	CopyMemory(pSendTo, bSendToJumpInstruction, 6);
	VirtualProtect(pSendTo, 6, dwOldProtection, &dwOldProtection);

	return iResult;
}