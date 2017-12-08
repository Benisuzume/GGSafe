#pragma once

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#include <Psapi.h>
#pragma comment(lib, "psapi.lib")

#include <WinSock.h>
#pragma comment(lib, "ws2_32.lib")

#include <stdio.h>
#include <WinCrypt.h>

/* ---------------------------------------------------------------------------------------------------- */

struct ProxyData {
	CHAR szLanGameIp[26];
	u_long uAddress;
	u_short uPort;
	u_long uIpLookingUp;
};

struct ClientData {
	HWND hWnd;
};

/* ---------------------------------------------------------------------------------------------------- */

BOOL CalcMd5Hash(LPCSTR, LPCSTR);
BOOL IsSignedFile();
VOID HideModule(HMODULE);

/* ---------------------------------------------------------------------------------------------------- */

BOOL MD5(LPSTR, LPVOID);

/* ---------------------------------------------------------------------------------------------------- */

BOOL InjectDll(HANDLE, HANDLE, LPCSTR);
VOID LoadLibraryAndJumpBack();
VOID AfterLoadLibraryAndJumpBack();

/* ---------------------------------------------------------------------------------------------------- */

VOID GetCurrentProcessMainModuleInfo(LPDWORD, LPDWORD);
DWORD FindPattern(LPBYTE, LPCSTR, DWORD, DWORD, INT);
BOOL Compare(LPBYTE, LPBYTE, LPCSTR);
VOID CopyMemoryEx(DWORD, LPSTR, size_t);
VOID SetJumpHook(LPVOID, DWORD);
VOID SeDebugPrivilege();
BOOL IsUsingMapHack(HANDLE, DWORD, DWORD, LPBYTE, DWORD);