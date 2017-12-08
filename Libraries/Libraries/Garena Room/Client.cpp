#include "stdafx.h"

HWND lblRoomTitle, btnClearChat, btnLeaveRoom, btnRoom, btnSend, txtChat, lvwRoomUsers, txtSearch;

VOID ChatClear()
{
	SendMessage(btnClearChat, BM_CLICK, 0, 0);
}

BOOL ChatSend(LPCSTR szMessage)
{
	if (strlen(szMessage) == 0)
		return FALSE;

	static DWORD dwCounter = 0;

	CHAR szBuffer[141] = {0};
	sprintf_s(szBuffer, "[%d] %s", dwCounter++, szMessage);

	if (dwCounter > 9999999)
		dwCounter = 0;

	SendMessage(txtChat, WM_SETTEXT, 0, (LPARAM)szBuffer);
	SendMessage(btnSend, BM_CLICK, 0, 0);

	return TRUE;
}

BOOL IsInRoom()
{
	return IsWindowEnabled(btnRoom);
}

BOOL IsLoggedIn()
{
	return IsWindowVisible(btnRoom);
}

BOOL CALLBACK GetRoomDialogHandleProc(HWND hWnd, LPARAM lParam)
{
	LPSTR szClassName = (LPSTR)VirtualAlloc(NULL, 7, MEM_COMMIT, PAGE_READWRITE);
	GetClassName(hWnd, szClassName, 7);

	static int iIndex = 0;
	if (strcmp(szClassName, "#32770") == 0 && ++iIndex == 3)
	{
		*(HWND *)lParam = hWnd;
		VirtualFree(szClassName, NULL, MEM_RELEASE);
		return FALSE;
	}

	VirtualFree(szClassName, NULL, MEM_RELEASE);
	return TRUE;
}

BOOL CALLBACK GetRoomUsersHandleProc(HWND hWnd, LPARAM lParam)
{
	LPSTR szClassName = (LPSTR)VirtualAlloc(NULL, 7, MEM_COMMIT, PAGE_READWRITE);
	GetClassName(hWnd, szClassName, 13);

	if (strcmp(szClassName, "WTL_LISTVIEW") == 0)
	{
		*(HWND *)lParam = hWnd;
		VirtualFree(szClassName, NULL, MEM_RELEASE);
		return FALSE;
	}

	VirtualFree(szClassName, NULL, MEM_RELEASE);
	return TRUE;
}