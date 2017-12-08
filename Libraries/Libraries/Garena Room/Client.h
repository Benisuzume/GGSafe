#pragma once

VOID ChatClear();
BOOL ChatSend(LPCSTR);
BOOL IsInRoom();
BOOL IsLoggedIn();
BOOL CALLBACK GetRoomDialogHandleProc(HWND, LPARAM);
BOOL CALLBACK GetRoomUsersHandleProc(HWND, LPARAM);