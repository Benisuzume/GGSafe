#include "stdafx.h"

HANDLE hClientData = NULL;
ClientData *pClientData = NULL;

HANDLE hProxyData = NULL;
ProxyData *pProxyData = NULL;

HANDLE hSystemMessage = NULL;
LPWSTR pSystemMessage = NULL;

BOOL APIENTRY DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	UNREFERENCED_PARAMETER(lpReserved);

	if (dwReason == DLL_PROCESS_ATTACH)
	{
		if (!IsSignedFile())
			return FALSE;

		HANDLE hMutex = OpenMutex(SYNCHRONIZE, FALSE, "GGSafe: Running");
		if (hMutex == NULL)
			return FALSE;

		CloseHandle(hMutex);

		hClientData = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(ClientData), "GGSafe: ClientData");
		if (hClientData == NULL)
			return FALSE;

		pClientData = (ClientData *)MapViewOfFile(hClientData, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(ClientData));
		if (pClientData == NULL)
		{
			CloseHandle(hClientData);
			return FALSE;
		}

		hProxyData = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(ProxyData), "GGSafe: ProxyData");
		if (hProxyData == NULL)
		{
			UnmapViewOfFile(pClientData);
			CloseHandle(hClientData);
			return FALSE;
		}

		pProxyData = (ProxyData *)MapViewOfFile(hProxyData, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(ProxyData));
		if (pProxyData == NULL)
		{
			CloseHandle(hProxyData);
			UnmapViewOfFile(pClientData);
			CloseHandle(hClientData);
			return FALSE;
		}

		hSystemMessage = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, 4096, "GGSafe: Message");
		if (hSystemMessage == NULL)
		{
			UnmapViewOfFile(pProxyData);
			CloseHandle(hProxyData);
			UnmapViewOfFile(pClientData);
			CloseHandle(hClientData);
			return FALSE;
		}

		pSystemMessage = (LPWSTR)MapViewOfFile(hSystemMessage, FILE_MAP_ALL_ACCESS, 0, 0, 4096);
		if (pSystemMessage == NULL)
		{
			CloseHandle(hSystemMessage);
			UnmapViewOfFile(pProxyData);
			CloseHandle(hProxyData);
			UnmapViewOfFile(pClientData);
			CloseHandle(hClientData);
			return FALSE;
		}

		ZeroMemory(pClientData, sizeof(ClientData));
		ZeroMemory(pProxyData, sizeof(ProxyData));
		ZeroMemory(pSystemMessage, 4096);

		DisableThreadLibraryCalls(hModule);
	}
	else if (dwReason == DLL_PROCESS_DETACH)
	{
		UnmapViewOfFile(pSystemMessage);
		CloseHandle(hSystemMessage);
		UnmapViewOfFile(pProxyData);
		CloseHandle(hProxyData);
		UnmapViewOfFile(pClientData);
		CloseHandle(hClientData);
	}

	return TRUE;
}