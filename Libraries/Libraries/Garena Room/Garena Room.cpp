#include "stdafx.h"
#pragma warning(disable: 4127)
#pragma warning(disable: 4740)

LPCSTR szWarcraftDllMd5 = "7bcaa25fd1f819075560623d55d5eb74";

extern HWND lblRoomTitle, btnClearChat, btnLeaveRoom, btnRoom, btnSend, txtChat, lvwRoomUsers, txtSearch;

extern HANDLE hProxyData;
extern ProxyData *pProxyData;
extern FARPROC pConnect;
extern BYTE bJumpInstruction[6], bJumpInstructionOriginal[6];

extern FARPROC pSendTo;
extern BYTE bSendToJumpInstruction[6], bSendToJumpInstructionOriginal[6];

HANDLE hClientData;
ClientData *pClientData, cd;

HANDLE hSystemMessage;
LPWSTR pSystemMessage;

LPWSTR szWelcomeMessage[4096];
DWORD dwAlterWelcomeMessageRet, dwShowSystemMessage, dwSkipSystemMessage;
DWORD dwJoinedRoomRet;
BOOL fIsWelcomeMessageShown = FALSE;

LPSTR *blocks = NULL;
INT nBound = 0;

DWORD dwParentProcessId = NULL;
HANDLE hParentProcessHandle = NULL;

DWORD dwLeaveRoomBypassAddress = NULL;

VOID GarenaRoom()
{
	dwParentProcessId = GetParentPid();
	hParentProcessHandle = OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, dwParentProcessId);
	if (hParentProcessHandle == NULL)
		ExitProcess(0);
	OutputDebugString("1");

	HANDLE hMutex = OpenMutex(SYNCHRONIZE, FALSE, "GGSafe: Running");
	if (hMutex == NULL)
		ExitProcess(0);

	CloseHandle(hMutex);

	hClientData = OpenFileMapping(FILE_MAP_READ, FALSE, "GGSafe: ClientData");
	if (hClientData == NULL)
		ExitProcess(0);

	pClientData = (ClientData *)MapViewOfFile(hClientData, FILE_MAP_READ, 0, 0, sizeof(ClientData));
	if (pClientData == NULL)
	{
		CloseHandle(hClientData);
		ExitProcess(0);
	}

	hProxyData = OpenFileMapping(FILE_MAP_READ, FALSE, "GGSafe: ProxyData");
	if (hProxyData == NULL)
	{
		UnmapViewOfFile(pClientData);
		CloseHandle(hClientData);
		ExitProcess(0);
	}

	pProxyData = (ProxyData *)MapViewOfFile(hProxyData, FILE_MAP_READ, 0, 0, sizeof(ProxyData));
	if (pClientData == NULL)
	{
		CloseHandle(hProxyData);
		UnmapViewOfFile(pClientData);
		CloseHandle(hClientData);
		ExitProcess(0);
	}

	hSystemMessage = OpenFileMapping(FILE_MAP_READ, FALSE, "GGSafe: Message");
	if (hSystemMessage == NULL)
	{
		UnmapViewOfFile(pProxyData);
		CloseHandle(hProxyData);
		UnmapViewOfFile(pClientData);
		CloseHandle(hClientData);
		ExitProcess(0);
	}

	pSystemMessage = (LPWSTR)MapViewOfFile(hSystemMessage, FILE_MAP_READ, 0, 0, 4096);
	if (pSystemMessage == NULL)
	{
		CloseHandle(hSystemMessage);
		UnmapViewOfFile(pProxyData);
		CloseHandle(hProxyData);
		UnmapViewOfFile(pClientData);
		CloseHandle(hClientData);
		ExitProcess(0);
	}

	CopyMemory(szWelcomeMessage, pSystemMessage, 4096);

	DWORD dwBaseAddress = 0, dwSize = 0;
	GetCurrentProcessMainModuleInfo(&dwBaseAddress, &dwSize);

	DWORD dwAddress = 0;

	// Remove memory protection
	dwAddress = FindPattern((LPBYTE)"\x74\x63\x8B\x4D\xCC\x8B\x11\x8B\x4D\xCC\x8B\x02", "xxxxxxxxxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, "\xEB", 1);

	// Please log in to Garena Plus to launch LAN Game.
	dwAddress = FindPattern((LPBYTE)"\x0F\xB6\xC0\x85\xC0\x74\x37\xE8", "xxxxxxxx", dwBaseAddress, dwSize, 5);
	CopyMemoryEx(dwAddress, "\x90\x90", 2);

	// Alter welcome message
	dwAddress = FindPattern((LPBYTE)"\xE8\x21\x94\xF8\xFF\x50\x8D\x55\xB4\x52\xE8", "x????xxxxxx", dwBaseAddress, dwSize, 0);
	dwAlterWelcomeMessageRet = dwAddress + 5;
	SetJumpHook((LPVOID)dwAddress, (DWORD)AlterWelcomeMessage);

	// Block admin message
	dwAddress = FindPattern((LPBYTE)"\x00\x2E\x8B\x45\x08\x50\x8D\x4D\xD8", "?xxxxxxxx", dwBaseAddress, dwSize, 0);
	dwShowSystemMessage = dwAddress + 5;
	dwSkipSystemMessage = dwAddress + 0x30;
	SetJumpHook((LPVOID)dwAddress, (DWORD)BlockAdminMessage);

	// http://ad.garenanow.com/showzone?name=im_room_home
	dwAddress = FindPattern((LPBYTE)"\x68\x8C\x10\x00\x00\x8D\x45", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x01\x00", 2);

	// http://ad.garenanow.com/showzone?name=im_room_full
	dwAddress = FindPattern((LPBYTE)"\x68\xC6\x13\x00\x00\x8D\x55", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x02\x00", 2);

	// http://ad.garenanow.com/showzone?name=im_room_rbottom
	dwAddress = FindPattern((LPBYTE)"\x68\xE2\x13\x00\x00\x8D\x8D", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x03\x00", 2);

	// http://ad.garenanow.com/showzone?name=im_room_top
	dwAddress = FindPattern((LPBYTE)"\x68\xE3\x13\x00\x00\x8D\x8D", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x04\x00", 2);

	// http://ad.garenanow.com/showzone?name=im_room_menu
	dwAddress = FindPattern((LPBYTE)"\x68\xE7\x13\x00\x00\x8D\x55", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x05\x00", 2);

	// Remove reconnect timeout
	dwAddress = FindPattern((LPBYTE)"\x52\xFF\x15\x00\x00\x00\x00\x6A\x01\x8B\x45\xF8", "xxx????xxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, "\x90\x90", 2);

	// You are sending out messages too fast. Why not visit www.garena.com and take a good rest :)
	dwAddress = FindPattern((LPBYTE)"\x68\xDA\x10\x00\x00\x8D\x8D", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x07\x00", 2);

	// Sorry, this room is full. \nOnly Gold Members can join full Rooms. Buy Gold membership now!
	dwAddress = FindPattern((LPBYTE)"\x68\x32\x75\x00\x00\x8D\x95", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x08\x00", 2);

	// Hide Proxy IP Address - MOV DWORD PTR DS:[EAX+1C],ECX
	dwAddress = FindPattern((LPBYTE)"\x8B\x55\x08\x8B\x4A\x1C\x89\x48\x1C\x8B\x4D\xFC\x83\xC1\x04", "xxxxxxxxxxxxxxx", dwBaseAddress, dwSize, 6);
	CopyMemoryEx(dwAddress, "\x90\x90\x90", 3);

	// Don't change Garena Messenger status (Gaming, etc)
	dwAddress = FindPattern((LPBYTE)"\x8B\xC8\xE8\xD7\x0B", "xxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, "\x90\x90\x90\x90\x90", 5);

	// You are still in room, leave room now?
	dwLeaveRoomBypassAddress = FindPattern((LPBYTE)"\x68\x2D\x11\x00\x00\x8D\x85\x00\x00\x00\x00\x50", "xxxxxxx????x", dwBaseAddress, dwSize, -5);

	// Room%s.dat -> Roomtw.dat
	dwAddress = FindPattern((LPBYTE)"\x52\x00\x6F\x00\x6F\x00\x6D\x00\x25\x00\x73\x00\x2E\x00\x64\x00\x61\x00\x74\x00", "xxxxxxxxxxxxxxxxxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, "\x52\x00\x6F\x00\x6F\x00\x6D\x00\x74\x00\x77\x00", 12);

	// Setting server
	dwAddress = FindPattern((LPBYTE)"\x6C\x61\x6E\x67\x61\x6D\x65\x2E\x61\x75\x74\x68\x2E\x67\x61\x72\x65\x6E\x61\x6E\x6F\x77\x2E\x63\x6F\x6D", "xxxxxxxxxxxxxxxxxxxxxxxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, pProxyData->szLanGameIp, 26);

	// <%s> has entered this room
	dwAddress = FindPattern((LPBYTE)"\x75\x1B\x8B\x45\x8C\x50", "xxxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, "\xEB", 1);

	dwAddress = FindPattern((LPBYTE)"\x50\x8D\x8D\x3C\xFF\xFF\xFF\xE8\x00\x00\x00\x00\xC6\x45\xFC\x05", "xxxxxxxx????xxxx", dwBaseAddress, dwSize, 0);
	dwJoinedRoomRet = dwAddress + 0xFA;
	SetJumpHook((LPVOID)dwAddress, (DWORD)JoinedRoomMessage);


	/*
	// http://forum.garena.com/
	dwAddress = FindPattern((LPBYTE)"\x68\xDF\x13\x00\x00\x8D\x45", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x06\x00", 2);

	// http://forum.garena.com/
	dwAddress = FindPattern((LPBYTE)"\x68\xDF\x13\x00\x00\x8D\x45", "xxxxxxx", dwBaseAddress, dwSize, 1);
	CopyMemoryEx(dwAddress, "\x06\x00", 2);

	// Cannot find the user to tunnel.
	dwAddress = FindPattern((LPBYTE)"\x75\x61\x68\x4C\x10\x00\x00\x8D\x55\xBC", "xxxxxxxxxx", dwBaseAddress, dwSize, 0);
	CopyMemoryEx(dwAddress, "\xEB", 1);
	*/

	// Setting Proxy
	{
		CopyMemory(bJumpInstruction, "\xE9\x90\x90\x90\x90\xC3", 6);

		pConnect = GetProcAddress(GetModuleHandle("ws2_32.dll"), "connect");
		DWORD dwJumpSize = (DWORD)_connect - (DWORD)pConnect - 5;

		DWORD dwOldProtection = NULL;
		VirtualProtect(pConnect, 6, PAGE_EXECUTE_READWRITE, &dwOldProtection);
		CopyMemory(bJumpInstructionOriginal, pConnect, 6);
		CopyMemory(&bJumpInstruction[1], &dwJumpSize, 4);
		CopyMemory(pConnect, bJumpInstruction, 6);
		VirtualProtect(pConnect, 6, dwOldProtection, &dwOldProtection);
	}

/*
	// Setting Proxy
	{
		CopyMemory(bSendToJumpInstruction, "\xE9\x90\x90\x90\x90\xC3", 6);

		pSendTo = GetProcAddress(GetModuleHandle("ws2_32.dll"), "sendto");
		DWORD dwJumpSize = (DWORD)_sendto - (DWORD)pSendTo - 5;

		DWORD dwOldProtection = NULL;
		VirtualProtect(pSendTo, 6, PAGE_EXECUTE_READWRITE, &dwOldProtection);
		CopyMemory(bSendToJumpInstructionOriginal, pSendTo, 6);
		CopyMemory(&bSendToJumpInstruction[1], &dwJumpSize, 4);
		CopyMemory(pSendTo, bSendToJumpInstruction, 6);
		VirtualProtect(pSendTo, 6, dwOldProtection, &dwOldProtection);
	}
*/
	// Initialize thread
	HANDLE hThread = CreateThread(NULL, 0, GarenaRoomInitialize, NULL, 0, NULL);
	if (hThread == NULL)
		ExitProcess(0);

	CloseHandle(hThread);
}

DWORD WINAPI GarenaRoomInitialize(LPVOID lpParam)
{
	UNREFERENCED_PARAMETER(lpParam);

	DWORD dwExitCode = NULL;
	while (pClientData->hWnd == NULL)
	{
		if (GetExitCodeProcess(hParentProcessHandle, &dwExitCode))
		{
			if (dwExitCode != STILL_ACTIVE)
			{
				OutputDebugString("2");
				ExitProcess(0);
			}
		}
		else
		{
			OutputDebugString("3");
			ExitProcess(0);
		}

		Sleep(500);
	}

	CopyMemory(&cd, pClientData, sizeof(ClientData));
	UnmapViewOfFile(pClientData);
	CloseHandle(hClientData);

	HWND hRoomDialog = NULL;
	EnumChildWindows(cd.hWnd, GetRoomDialogHandleProc, (LPARAM)&hRoomDialog);

	lvwRoomUsers = NULL;
	EnumChildWindows(hRoomDialog, GetRoomUsersHandleProc, (LPARAM)&lvwRoomUsers);

	lblRoomTitle = GetDlgItem(cd.hWnd, 1135);
	btnRoom = GetDlgItem(cd.hWnd, 1152);
	txtChat = GetDlgItem(hRoomDialog, 1154);
	btnClearChat = GetDlgItem(hRoomDialog, 1155);
	btnLeaveRoom = GetDlgItem(hRoomDialog, 1171);
	btnSend = GetDlgItem(hRoomDialog, 1161);
	txtSearch = GetDlgItem(hRoomDialog, 1170);

	while (!IsLoggedIn())
		Sleep(1000);

	CloseAuthSocket();

	SeDebugPrivilege();

	CHAR szDllPath[MAX_PATH] = {NULL};
	GetEnvironmentVariable("WarcraftDllPath", szDllPath, MAX_PATH);

	if (!CalcMd5Hash(szDllPath, szWarcraftDllMd5))
		ExitProcess(0);

	DWORD dwLastProcessId = NULL;
	while (true)
	{
		Sleep(5000);

		HWND hWnd = FindWindow("Warcraft III", "Warcraft III");
		if (hWnd == NULL)
			continue;

		DWORD dwProcessId = 0;
		GetWindowThreadProcessId(hWnd, &dwProcessId);
		if (dwProcessId == 0)
			continue;

		HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwProcessId);
		if (hProcess == NULL)
			continue;

		if (dwLastProcessId != dwProcessId)
		{
			if (strlen(szDllPath) > 0)
			{
				dwLastProcessId = dwProcessId;

				HMODULE hKernel32 = GetModuleHandleA("kernel32.dll");
				FARPROC lpLoadLibraryA = GetProcAddress(hKernel32, "LoadLibraryA");

				LPVOID lpDllPath = VirtualAllocEx(hProcess, NULL, strlen(szDllPath) + 1, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
				WriteProcessMemory(hProcess, lpDllPath, szDllPath, strlen(szDllPath), NULL);

				HANDLE hThread = CreateRemoteThread(hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)lpLoadLibraryA, lpDllPath, 0, NULL);
				CloseHandle(hThread);
			}
			else
				ExitProcess(0);
		}

		HMODULE hModules[128];
		DWORD dwNeeded;
		CHAR szModuleName[64];
		DWORD dwBaseAddress = 0;

		if (EnumProcessModules(hProcess, hModules, sizeof(hModules), &dwNeeded))
		{
			for (DWORD i = 0; i < dwNeeded / sizeof(HMODULE); i++)
			{
				if (GetModuleBaseName(hProcess, hModules[i], szModuleName, 64))
				{
					if (_stricmp(szModuleName, "game.dll") == 0)
					{
						dwBaseAddress = (DWORD)hModules[i];
					}

					if (_stricmp(szModuleName, "Mp3enc.asi") == 0)
					{
						goto MapHacker;
					}
				}
			}
		}

		if (dwBaseAddress == 0)
			goto MapHacker;

		// Remove FOG on Main Map
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x74C9F1, (LPBYTE)"\x8B\x54\x24\x28\x52", 5))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x3564B8, (LPBYTE)"\x66\x23\xC2", 3))
			goto MapHacker;

		// Enable Enable Trade / Resource View
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x34DDA2, (LPBYTE)"\x8B\x87\x6C\x01\x00\x00", 6))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x34DDAA, (LPBYTE)"\x8B\x87\x68\x01\x00\x00", 6))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x35FA4A, (LPBYTE)"\xEB\x08", 2))
			goto MapHacker;

		// Make Units Clickable
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x2851B2, (LPBYTE)"\x75", 1))
			goto MapHacker;

		// Reveal Illusions
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x282A5C, (LPBYTE)"\xC3\xCC", 2))
			goto MapHacker;

		// Reveal Invisibles
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x399A98, (LPBYTE)"\x74", 1))
			goto MapHacker;

		// Reveal Units on Main Map
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x3A159B, (LPBYTE)"\x23\xCA", 2))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x361176, (LPBYTE)"\x75", 1))
			goto MapHacker;

		// Reveal Units on Mini Map
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x36143C, (LPBYTE)"\x01", 1))
			goto MapHacker;

		// Show Enemies Ping Signals
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x43EE96, (LPBYTE)"\x85", 1))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x43EE99, (LPBYTE)"\x84", 1))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x43EEA9, (LPBYTE)"\x85", 1))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x43EEAC, (LPBYTE)"\x84", 1))
			goto MapHacker;

		// Show Runes
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x3A14DB, (LPBYTE)"\x75", 1))
			goto MapHacker;

		// Show Skills / Cooldowns
		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x2026DC, (LPBYTE)"\x0F\x84\x5F\x01\x00\x00", 6))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x0C838D, (LPBYTE)"\x84", 1))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x28E1DE, (LPBYTE)"\x75", 1))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x34F2A8, (LPBYTE)"\x74\x08", 2))
			goto MapHacker;

		if (IsUsingMapHack(hProcess, dwBaseAddress, 0x34F2E9, (LPBYTE)"\x08", 1))
			goto MapHacker;

		CloseHandle(hProcess);
		continue;

	MapHacker:
		TerminateProcess(hProcess, 0);
		CloseHandle(hProcess);

		HANDLE hThread = CreateThread(NULL, 0, MessageBoxThread, NULL, 0, NULL);
		CloseHandle(hThread);
	}

	return 0;
}

DWORD WINAPI MessageBoxThread(LPVOID lpParam)
{
	UNREFERENCED_PARAMETER(lpParam);

	MessageBox(NULL, "You are using Map Hacks, please remove it and run Warcraft again.", "GGSafe", MB_OK | MB_ICONERROR);

	return 0;
}

VOID Threadasd(LPVOID lpParam)
{
	Sleep(1000);

	SendMessage(txtSearch, WM_SETTEXT, 0, (LPARAM)lpParam);

	INT nCount = ListView_GetItemCount(lvwRoomUsers);
	if (nCount != 0)
	{
		SendMessage(lvwRoomUsers, WM_KEYDOWN, VK_LCONTROL, 0);
		SendMessage(lvwRoomUsers, WM_KEYDOWN, VK_HOME, 0);
		SendMessage(lvwRoomUsers, WM_KEYUP, VK_HOME, 0);
		SendMessage(lvwRoomUsers, WM_KEYUP, VK_LCONTROL, 0);

		SendMessage(lvwRoomUsers, WM_COMMAND, 4245, 0);
	}

	SendMessage(txtSearch, WM_SETTEXT, 0, (LPARAM)"");
	delete lpParam;
}

VOID BlockSpammer(LPCSTR szUsername)
{
	CHAR szBlockedUsernames[1024] = { NULL };
	GetEnvironmentVariable("BlockedUsernames", szBlockedUsernames, 1024);
	blocks = StringToCsv(szBlockedUsernames, &nBound);

	for (int i = 0; i < nBound; ++i)
	{
		if (strcmp(blocks[i], szUsername) == 0)
		{
			CHAR *foo;
			foo = new CHAR[32];
			ZeroMemory(foo, 32);
			strcpy_s(foo, 32, szUsername);

			HANDLE hThread;
			hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Threadasd, foo, 0, NULL);
			CloseHandle(hThread);
		}
	}

	SendMessage(txtSearch, WM_SETTEXT, 0, (LPARAM)"");
}

__declspec(naked) VOID JoinedRoomMessage()
{
	LPSTR szUsername;

	__asm
	{
		PUSHAD
		MOV szUsername, EAX;
	}

	BlockSpammer(szUsername);

	__asm
	{
		POPAD
		JMP dwJoinedRoomRet
	}
}

__declspec(naked) VOID AlterWelcomeMessage()
{
	__asm
	{
		PUSHAD
	}

	HANDLE hThread;
	hThread = CreateThread(NULL, 0, CheckRoomConditionThread, NULL, 0, NULL);
	CloseHandle(hThread);

	fIsWelcomeMessageShown = TRUE;
	__asm
	{
		POPAD
		LEA EAX, szWelcomeMessage
		JMP dwAlterWelcomeMessageRet
	}
}

__declspec(naked) VOID BlockAdminMessage()
{
	__asm
	{
		PUSHAD
	}

	if (fIsWelcomeMessageShown)
	{
		fIsWelcomeMessageShown = FALSE;
		__asm
		{
			POPAD
			JMP dwSkipSystemMessage
		}
	}

	__asm
	{
		POPAD
		MOV EAX, DWORD PTR[EBP+8]
		JMP dwShowSystemMessage
	}
}

DWORD WINAPI CheckRoomConditionThread(LPVOID lpParam)
{
	UNREFERENCED_PARAMETER(lpParam);

	CHAR szWindowText[64] = { NULL };
	GetWindowText(lblRoomTitle, szWindowText, 64);

	CHAR szRoomName[64] = { NULL };
	for (DWORD i = 0; i < strlen(szWindowText); i++)
	{
		if (szWindowText[i] == '(')
			break;

		szRoomName[i] = szWindowText[i];
	}

	// --------------------------------------------------

	CHAR szIsBanned[96] = { NULL };
	sprintf_s(szIsBanned, 96, "%s IsBanned", szRoomName);
	CHAR szIsBannedResult[8] = { NULL };

	GetEnvironmentVariable(szIsBanned, szIsBannedResult, 8);
	INT nIsBanned = atoi(szIsBannedResult);

	if (nIsBanned == 1)
	{
		LeaveRoom();
		MessageBox(cd.hWnd, "You have been banned to access this room.", "GGSafe", MB_OK | MB_ICONWARNING);
		return 0;
	}


	// --------------------------------------------------

	/*
	CHAR szEntryLevel[96] = { NULL };
	sprintf_s(szEntryLevel, 96, "%s EntryLevel", szRoomName);
	CHAR szEntryLevelResult[8] = { NULL };

	GetEnvironmentVariable(szEntryLevel, szEntryLevelResult, 8);
	INT nEntryLevel = atoi(szEntryLevelResult);

	if (GetCurrentUserLevel() < nEntryLevel)
	{
		LeaveRoom();
		MessageBox(cd.hWnd, "Your level is not sufficient to access this room.", "GGSafe", MB_OK | MB_ICONWARNING);
		return 0;
	}
	*/

	// --------------------------------------------------

	CHAR szMaxUsers[96] = { NULL };
	sprintf_s(szMaxUsers, 96, "%s MaxUsers", szRoomName);
	CHAR szMaxUsersResult[8] = { NULL };

	GetEnvironmentVariable(szMaxUsers, szMaxUsersResult, 8);
	INT nMaxUsers = atoi(szMaxUsersResult);

	if (nMaxUsers > 0 && GetRoomUsersCount() > nMaxUsers)
	{
		LeaveRoom();
		MessageBox(cd.hWnd, "Sorry, this room is full.", "GGSafe", MB_OK | MB_ICONWARNING);
		return 0;
	}

	// --------------------------------------------------

	CHAR szBlockedUsernames[1024] = { NULL };
	GetEnvironmentVariable("BlockedUsernames", szBlockedUsernames, 1024);
	blocks = StringToCsv(szBlockedUsernames, &nBound);

	for (int i = 0; i < nBound; ++i)
	{
		SendMessage(txtSearch, WM_SETTEXT, 0, (LPARAM)blocks[i]);

		INT nCount = ListView_GetItemCount(lvwRoomUsers);
		if (nCount != 0)
		{
			SendMessage(lvwRoomUsers, WM_KEYDOWN, VK_LCONTROL, 0);
			SendMessage(lvwRoomUsers, WM_KEYDOWN, VK_HOME, 0);
			SendMessage(lvwRoomUsers, WM_KEYUP, VK_HOME, 0);
			SendMessage(lvwRoomUsers, WM_KEYUP, VK_LCONTROL, 0);

			SendMessage(lvwRoomUsers, WM_COMMAND, 4245, 0);
		}
	}

	SendMessage(txtSearch, WM_SETTEXT, 0, (LPARAM)"");

	// --------------------------------------------------

	return 0;
}

INT GetRoomUsersCount()
{
	return ListView_GetItemCount(lvwRoomUsers);
}

INT GetCurrentUserLevel()
{
	CHAR szBuffer[8] = { NULL };
	ListView_GetItemText(lvwRoomUsers, 0, 1, szBuffer, 8);

	INT nLevel = atoi(szBuffer);
	return nLevel;
}

VOID LeaveRoom()
{
	CopyMemoryEx(dwLeaveRoomBypassAddress, "\x84", 1);
	SendMessage(btnLeaveRoom, BM_CLICK, 0, 0);
	CopyMemoryEx(dwLeaveRoomBypassAddress, "\x85", 1);
}

LPSTR *StringToCsv(CHAR buf[], int *bnd)
{
	int i = 0, j = 0;

	*bnd = 0;
	while (buf[i] != '\0')
	{
		if (buf[i] == ',')
		{
			buf[i] = '\0';
			*bnd += 1;
		}

		i++;
	}

	*bnd += 1;

	char **szArray = new char *[*bnd];
	for (j = 0, i = 0; j <= *bnd - 1; j++)
	{
		szArray[j] = &buf[i];

		while (buf[i] != '\0')
		{
			i++;

			if (buf[i] == '\0')
			{
				i++;
				break;
			}
		}
	}

	return szArray;
}

DWORD GetParentPid()
{
	HANDLE hSnapshot;
	PROCESSENTRY32 pe32;
	DWORD ppid = 0, pid = GetCurrentProcessId();

	hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	__try {
		if (hSnapshot == INVALID_HANDLE_VALUE) __leave;

		ZeroMemory(&pe32, sizeof(pe32));
		pe32.dwSize = sizeof(pe32);
		if (!Process32First(hSnapshot, &pe32)) __leave;

		do {
			if (pe32.th32ProcessID == pid) {
				ppid = pe32.th32ParentProcessID;
				break;
			}
		} while (Process32Next(hSnapshot, &pe32));

	}
	__finally {
		if (hSnapshot != INVALID_HANDLE_VALUE) CloseHandle(hSnapshot);
	}
	return ppid;
}