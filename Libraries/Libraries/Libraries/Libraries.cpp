#include "stdafx.h"

extern ProxyData *pProxyData;
extern LPWSTR pSystemMessage;

BOOL fInitialize = false;

VOID Initialize(LPSTR sLanGameIp, LPSTR sIpAddress, USHORT nPort, LPSTR sIpLookingUp, LPWSTR szMessage)
{
	if (fInitialize)
		return;

	strcpy_s(pProxyData->szLanGameIp, sLanGameIp);
	pProxyData->uAddress = inet_addr(sIpAddress);
	pProxyData->uPort = htons(nPort);
	pProxyData->uIpLookingUp = inet_addr(sIpLookingUp);
	lstrcpyW(pSystemMessage, szMessage);
	fInitialize = true;
}

BOOL _MD5(LPSTR szInput, LPVOID lpBuffer)
{
	return MD5(szInput, lpBuffer);
}