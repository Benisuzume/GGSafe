#include "Warcraft.h"

extern GAME_ClearTextMessages ClearTextMessages;

void WINAPI HotKeys()
{
	SetTls();

	bool bIsShown  = false;

	while (true)
	{
		if (IsInGame() && !bIsShown)
		{
			TextPrint("|CFFFCD211GGSafe|R has been loaded successfully.\n"
			          "     |CFFFF0000Numpad +|R : Camera Distance Zoom In\n"
			          "     |CFFFF0000Numpad -|R  : Camera Distance Zoom Out\n"
			          "     |CFFFF0000Numpad *|R  : Camera Distance Set to Default\n"
			          "     |CFFFF0000BackSpace|R : Clear Screen", 30.0f);

			bIsShown = true;
		}
		else if (!IsInGame() && bIsShown)
				bIsShown = false;

		else if (HotKeyPressed(VK_ZoomIn))
		{
			CameraDistanceHack(VK_ZoomIn);
			while (HotKeyPressed(VK_ZoomIn))
				Sleep(100);
		}

		else if (HotKeyPressed(VK_ZoomOut))
		{
			CameraDistanceHack(VK_ZoomOut);
			while (HotKeyPressed(VK_ZoomOut))
				Sleep(100);
		}

		else if (HotKeyPressed(VK_Default))
		{
			CameraDistanceHack(VK_Default);
			while (HotKeyPressed(VK_Default))
				Sleep(100);
		}

		else if (HotKeyPressed(VK_ClearScreen))
		{
			if (IsInGame() && !IsChatBoxOpen())
				ClearTextMessages();

			while (HotKeyPressed(VK_ClearScreen))
				Sleep(100);
		}

		Sleep(100);
	}

	return;
}

bool HotKeyPressed(int iKey)
{
	if (GetForegroundWindow() != hWnd)
		return false;

	if (GetAsyncKeyState(iKey))
		return true;

	return false;
}