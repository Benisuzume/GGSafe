#include "stdafx.h"

BOOL APIENTRY DllMain(HMODULE hModule, DWORD dwReason, LPVOID lpReserved)
{
	UNREFERENCED_PARAMETER(lpReserved);

	if (dwReason == DLL_PROCESS_ATTACH)
	{
		DisableThreadLibraryCalls(hModule);
		HideModule(hModule);
		GarenaRoom();
	}
	else if (dwReason == DLL_PROCESS_DETACH)
		ExitProcess(0);

	return TRUE;
}