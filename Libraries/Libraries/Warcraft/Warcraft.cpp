#include "Warcraft.h"

BOOL WINAPI DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	if (dwReason == DLL_PROCESS_ATTACH)
	{
		DisableThreadLibraryCalls(hModule);

		CHAR szWarcraftDllPath[MAX_PATH] = { NULL };
		GetEnvironmentVariable("WarcraftDllPath", szWarcraftDllPath, MAX_PATH);

		if (strlen(szWarcraftDllPath) == 0)
		{
			return FALSE;
		}

		if (WarcraftVersion() == 6401)
		{
			JassNativesInit();

			DamageNotifierInit();
			DreamUiInit();
			GameStartNotifierInit();
			ManaBarInit();

			HANDLE hThread = CreateThread(NULL, NULL, (LPTHREAD_START_ROUTINE)HotKeys, NULL, NULL, NULL);
			CloseHandle(hThread);

			return TRUE;
		}

		return FALSE;
	}

	return TRUE;
}