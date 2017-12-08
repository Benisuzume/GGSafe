#include "Warcraft.h"

void GameStartNotifierInit()
{
	PlantDetourJump((BYTE *)dwGameDll + 0x5C0D81, (BYTE *)GameStartNotifier, 5);
}

void GameStartNotifier()
{
	if (GetForegroundWindow() != hWnd)
		ShowWindow(hWnd, SW_RESTORE);
}