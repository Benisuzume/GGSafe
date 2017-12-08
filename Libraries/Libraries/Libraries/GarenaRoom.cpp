#include "stdafx.h"

extern ClientData *pClientData;
extern BOOL fInitialize;

LPCSTR szGarenaRoomDllMd5 = "0bbbdb8b1452a712fa914cfff787aaec";

HWND GarenaRoom2(LPCTSTR lpApplicationName, LPSTR lpCommandLine, LPCSTR szCurrentDirectory, LPCSTR szDllPath, ClientData *cd)
{
	if (!fInitialize)
		return NULL;

	if (!CalcMd5Hash(szDllPath, szGarenaRoomDllMd5))
		return NULL;

	UpdateResources(lpApplicationName);

	STARTUPINFO si;
	ZeroMemory(&si, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);

	PROCESS_INFORMATION pi;
	ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));

	if (!CreateProcess(lpApplicationName,
		lpCommandLine,
		NULL,
		NULL,
		FALSE,
		CREATE_SUSPENDED,
		NULL,
		szCurrentDirectory,
		&si,
		&pi)
		)
	{
		return NULL;
	}

	ZeroMemory(pClientData, sizeof(ClientData));
	CopyMemory(pClientData, cd, sizeof(ClientData));
	pClientData->hWnd = NULL;

	if (!InjectDll(pi.hProcess, pi.hThread, szDllPath))
	{
		TerminateProcess(pi.hProcess, 0);
		CloseHandle(pi.hThread);
		CloseHandle(pi.hProcess);
		return NULL;
	}

	ResumeThread(pi.hThread);
	CloseHandle(pi.hThread);

	WaitForInputIdle(pi.hProcess, INFINITE);

	EnumWindows(GarenaRoomMainWindowProc, (LPARAM)pi.dwProcessId);
	if (pClientData->hWnd == NULL)
	{
		TerminateProcess(pi.hProcess, 0);
		CloseHandle(pi.hProcess);
		return NULL;
	}

	CloseHandle(pi.hProcess);
	return pClientData->hWnd;
}

BOOL CALLBACK GarenaRoomMainWindowProc(HWND hWnd, LPARAM lParam)
{
	DWORD dwProcessId = 0;
	GetWindowThreadProcessId(hWnd, &dwProcessId);

	if (dwProcessId == (DWORD)lParam)
	{
		LPSTR szString = (LPSTR)VirtualAlloc(NULL, 16, MEM_COMMIT, PAGE_READWRITE);
		GetWindowText(hWnd, szString, 16);

		BOOL bResult = strcmp(szString, "Garena LAN Game") == 0;
		VirtualFree(szString, NULL, MEM_RELEASE);

		if (bResult)
		{
			pClientData->hWnd = hWnd;
			return FALSE;
		}
	}

	return TRUE;
}

VOID UpdateResources(LPCSTR szFilePath)
{
	HANDLE hRes = BeginUpdateResource(szFilePath, FALSE);
	if (hRes != NULL) {
		std::wstring data[] = { L"",
			L"http://ggsafe.ir/ads/im_room_home/",
			L"http://ggsafe.ir/ads/im_room_full/",
			L"http://ggsafe.ir/ads/im_room_rbottom/",
			L"http://ggsafe.ir/ads/im_room_top/",
			L"http://ggsafe.ir/ads/im_room_menu/",
			L"http://forum.ggsafe.ir/",
			L"You are sending out messages too fast. Why not visit www.ggsafe.ir and take a good rest :)",
			L"Sorry, this room is full. \nOnly VIP Members can join full Rooms. Buy VIP membership now!",
			L"", L"", L"", L"", L"", L"", L""
		};

		std::vector < WORD > buffer;
		for (size_t index = 0; index < sizeof(data) / sizeof(data[0]); ++index)
		{
			size_t pos = buffer.size();
			buffer.resize(pos + data[index].size() + 1);
			buffer[pos++] = static_cast< WORD >(data[index].size());
			copy(data[index].begin(), data[index].end(),
			buffer.begin() + pos);
		}

		UpdateResource(hRes,
			RT_STRING,
			MAKEINTRESOURCE(1),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL),
			reinterpret_cast< void* >(&buffer[0]),
			buffer.size() * sizeof(WORD));

		EndUpdateResource(hRes, FALSE);
	}
}