#pragma once

VOID GarenaRoom();
DWORD WINAPI GarenaRoomInitialize(LPVOID);
DWORD WINAPI MessageBoxThread(LPVOID);
VOID BlockSpammer(LPCSTR);
DWORD WINAPI CheckRoomConditionThread(LPVOID);
VOID JoinedRoomMessage();
VOID AlterWelcomeMessage();
VOID BlockAdminMessage();
INT GetRoomUsersCount();
INT GetCurrentUserLevel();
VOID LeaveRoom();
LPSTR *StringToCsv(CHAR buf[], int *nBound);
DWORD GetParentPid();