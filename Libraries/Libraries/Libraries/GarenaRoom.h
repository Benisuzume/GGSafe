#pragma once

extern "C" __declspec(dllexport) HWND GarenaRoom2(LPCTSTR, LPSTR, LPCSTR, LPCSTR, ClientData *);
BOOL CALLBACK GarenaRoomMainWindowProc(HWND, LPARAM);
VOID UpdateResources(LPCSTR);