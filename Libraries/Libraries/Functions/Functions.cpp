#include "Functions.h"

BOOL CalcMd5Hash(LPCSTR filename, LPCSTR desired)
{
	DWORD dwStatus = 0;
	BOOL bResult = FALSE;
	HCRYPTPROV hProv = 0;
	HCRYPTHASH hHash = 0;
	HANDLE hFile = NULL;
	BYTE rgbFile[1024];
	DWORD cbRead = 0;
	BYTE rgbHash[16];
	DWORD cbHash = 0;
	CHAR rgbDigits[] = "0123456789abcdef";

	hFile = CreateFile(filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL);
	if (INVALID_HANDLE_VALUE == hFile)
		return FALSE;

	if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT))
	{
		CloseHandle(hFile);
		return FALSE;
	}

	if (!CryptCreateHash(hProv, CALG_MD5, 0, 0, &hHash))
	{
		CloseHandle(hFile);
		CryptReleaseContext(hProv, 0);
		return FALSE;
	}

	while (bResult = ReadFile(hFile, rgbFile, 1024, &cbRead, NULL))
	{
		if (cbRead == 0)
			break;

		if (!CryptHashData(hHash, rgbFile, cbRead, 0))
		{
			CryptReleaseContext(hProv, 0);
			CryptDestroyHash(hHash);
			CloseHandle(hFile);
			return FALSE;
		}
	}

	if (!bResult)
	{
		CryptReleaseContext(hProv, 0);
		CryptDestroyHash(hHash);
		CloseHandle(hFile);
		return FALSE;
	}

	cbHash = 16;
	char foo[33] = { NULL };
	int j = 0;
	if (CryptGetHashParam(hHash, HP_HASHVAL, rgbHash, &cbHash, 0))
	{
		for (DWORD i = 0; i < cbHash; i++)
		{
			foo[j] = rgbDigits[rgbHash[i] >> 4];
			foo[j + 1] = rgbDigits[rgbHash[i] & 0xf];

			if (desired[j] != foo[j] || desired[j + 1] != foo[j + 1])
				return FALSE;

			j += 2;
		}
	}
	else
	{
		CryptDestroyHash(hHash);
		CryptReleaseContext(hProv, 0);
		CloseHandle(hFile);
		return FALSE;
	}

	CryptDestroyHash(hHash);
	CryptReleaseContext(hProv, 0);
	CloseHandle(hFile);

	return TRUE;
}

/* ---------------------------------------------------------------------------------------------------- */

BOOL IsSignedFile()
{
	CHAR szFilePath[MAX_PATH];
	GetModuleFileName(NULL, szFilePath, MAX_PATH);
	
	FILE *hFile;
    if (fopen_s(&hFile, szFilePath, "rb") != NO_ERROR)
        return FALSE;

    if (fseek(hFile, -8192, SEEK_END) != NO_ERROR)
    {
        fclose(hFile);
        return FALSE;
    }

	LPSTR szBuffer = (LPSTR)VirtualAlloc(NULL, 128, MEM_COMMIT, PAGE_READWRITE);
	if (fread(szBuffer, 1, 128, hFile) != 128)
    {
		VirtualFree(szBuffer, NULL, MEM_RELEASE);
        fclose(hFile);
        return FALSE;
    }

    fclose(hFile);

	CHAR szSignature[] = 
		"\xF6\xFD\x5E\x61\x3D\x22\x43\x7F\xAB\x12\x5B\x65\x18\x36\xDF\x12"
		"\xD1\x12\x1D\x25\xD2\x5A\x48\xC6\xBF\xA3\xC2\x20\x34\x7B\x16\x6B"
		"\x1D\x44\xD9\xAB\x6D\xD6\x42\x7F\x94\x3B\x07\x91\x84\x1D\xCA\x21"
		"\x71\xE4\xF1\xCB\x6B\xA7\x49\xF7\x8F\xAA\x72\xB5\xD5\x78\x6D\xC4"
		"\x4C\x63\x85\x8D\x3C\xF7\x42\xF6\xA0\x7A\x9A\x38\xA9\xD8\x7B\x89"
		"\x5B\xF5\x40\x89\xF9\x83\x42\xD0\xA0\xAE\x9F\xD2\x23\x25\xEE\x37"
		"\x5E\x13\x37\x75\xE0\xCE\x47\x6C\x85\x33\xBE\x4C\xC6\x64\x95\x6F"
		"\x19\x9C\x5A\x9C\xCD\xAA\x4F\x44\xBE\xC8\xFF\x9C\x1B\xE0\xEF\xAF";

	for (int i = 0; i < 128; i++)
	{
		if (szSignature[i] != szBuffer[i])
		{
			VirtualFree(szBuffer, NULL, MEM_RELEASE);
			return FALSE;
		}
	}

	VirtualFree(szBuffer, NULL, MEM_RELEASE);
    return TRUE;
}

VOID HideModule(HMODULE hModule)
{
	DWORD PEB_LDR_DATA;

	__asm
	{
		pushad;
		pushfd;
		mov eax, fs:[30h]
		mov eax, [eax+0Ch]
		mov PEB_LDR_DATA, eax

		// InLoadOrderModuleList
			mov esi, [eax+0Ch]
			mov edx, [eax+10h]

		LoopInLoadOrderModuleList:
			lodsd
			mov esi, eax
			mov ecx, [eax+18h]
			cmp ecx, hModule
			jne SkipA
			mov ebx, [eax]
			mov ecx, [eax+4]
			mov [ecx], ebx
			mov [ebx+4], ecx
			jmp InMemoryOrderModuleList

		SkipA:
			cmp edx, esi
			jne LoopInLoadOrderModuleList

		InMemoryOrderModuleList:
			mov eax, PEB_LDR_DATA
			mov esi, [eax+14h]
			mov edx, [eax+18h]

		LoopInMemoryOrderModuleList:
			lodsd
			mov esi, eax
			mov ecx, [eax+10h]
			cmp ecx, hModule
			jne SkipB
			mov ebx, [eax]
			mov ecx, [eax+4]
			mov [ecx], ebx
			mov [ebx+4], ecx
			jmp InInitializationOrderModuleList

		SkipB:
			cmp edx, esi
			jne LoopInMemoryOrderModuleList

		InInitializationOrderModuleList:
			mov eax, PEB_LDR_DATA
			mov esi, [eax+1Ch]
			mov edx, [eax+20h]

		LoopInInitializationOrderModuleList:
			lodsd
			mov esi, eax
			mov ecx, [eax+08h]
			cmp ecx, hModule
			jne SkipC
			mov ebx, [eax]
			mov ecx, [eax+4]
			mov [ecx], ebx
			mov [ebx+4], ecx
			jmp Finished

		SkipC:
			cmp edx, esi
			jne LoopInInitializationOrderModuleList

		Finished:
			popfd;
			popad;
	}
}

/* ---------------------------------------------------------------------------------------------------- */

BOOL MD5(LPSTR szInput, LPVOID lpBuffer)
{
	HCRYPTPROV hProv;
	if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT))
		 return FALSE;

	HCRYPTHASH hHash;
	if (!CryptCreateHash(hProv, CALG_MD5, NULL, 0, &hHash))
	{
		CryptReleaseContext(hProv, 0);
		return FALSE;
	}

	if (!CryptHashData(hHash, (LPBYTE)szInput, strlen(szInput), 0))
	{
		CryptDestroyHash(hHash);
		CryptReleaseContext(hProv, 0);
		return FALSE;
	}

	DWORD dwLength = 16;
	if (!CryptGetHashParam(hHash, HP_HASHVAL, (LPBYTE)lpBuffer, &dwLength, 0))
	{
		CryptDestroyHash(hHash);
		CryptReleaseContext(hProv, 0);
		return FALSE;
	}

	CryptDestroyHash(hHash);
	CryptReleaseContext(hProv, 0);

	return TRUE;
}

/* ---------------------------------------------------------------------------------------------------- */

BOOL InjectDll(HANDLE hProcess, HANDLE hThread, LPCSTR szDllPath)
{
	DWORD dwAttributes = GetFileAttributes(szDllPath);
	if (dwAttributes == INVALID_FILE_ATTRIBUTES || dwAttributes & FILE_ATTRIBUTE_DIRECTORY)
		return FALSE;

	CONTEXT ctx;
	ZeroMemory(&ctx, sizeof(CONTEXT));
	ctx.ContextFlags = CONTEXT_CONTROL;

	GetThreadContext(hThread, &ctx);

	DWORD dwLength = (DWORD)AfterLoadLibraryAndJumpBack - (DWORD)LoadLibraryAndJumpBack;
	LPBYTE pLocalFunction = (LPBYTE)VirtualAlloc(NULL, dwLength, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	CopyMemory(pLocalFunction, LoadLibraryAndJumpBack, dwLength);

	LPBYTE pRemoteFunction = (LPBYTE)VirtualAllocEx(
		hProcess,
		NULL,
		dwLength + strlen(szDllPath) + 1, 
		MEM_COMMIT,
		PAGE_EXECUTE_READWRITE);

	*(LPDWORD)&pLocalFunction[2] = (DWORD)GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryA");
	*(LPDWORD)&pLocalFunction[7] = (DWORD)pRemoteFunction + dwLength;
	*(LPDWORD)&pLocalFunction[15] = ctx.Eip - (DWORD)&pRemoteFunction[19];

	WriteProcessMemory(hProcess, pRemoteFunction, pLocalFunction, dwLength, NULL);
	WriteProcessMemory(hProcess, pRemoteFunction + dwLength, szDllPath, strlen(szDllPath), NULL);

	ctx.Eip = (DWORD)pRemoteFunction;
	SetThreadContext(hThread, &ctx);

	VirtualFree(pLocalFunction, NULL, MEM_RELEASE);

	return TRUE;
}

__declspec(naked) VOID LoadLibraryAndJumpBack()
{
	__asm
	{
		PUSHAD

		MOV EAX, 0xDEADBEEF

		PUSH 0xDEADBEEF
		CALL EAX

		POPAD

		__emit 0xE9
		__emit 0xDE
		__emit 0xAD
		__emit 0xBE
		__emit 0xEF
	}
}

__declspec(naked) VOID AfterLoadLibraryAndJumpBack()
{
}

/* ---------------------------------------------------------------------------------------------------- */

VOID GetCurrentProcessMainModuleInfo(LPDWORD dwBaseAddress, LPDWORD dwSize)
{
	MODULEINFO mi;
	ZeroMemory(&mi, sizeof(MODULEINFO));

	GetModuleInformation(GetCurrentProcess(), GetModuleHandle(NULL), &mi, sizeof(MODULEINFO));

	*dwBaseAddress = (DWORD)mi.lpBaseOfDll;
	*dwSize = mi.SizeOfImage;
}

DWORD FindPattern(LPBYTE bMask, LPCSTR szMask, DWORD dwStartAddress, DWORD dwSize, INT nOffset)
{
	for (DWORD i = 0; i < dwSize; i++)
	{
		if (Compare((LPBYTE)dwStartAddress + i, bMask, szMask))
			return dwStartAddress + i + nOffset;
	}

	return NULL;
}

BOOL Compare(LPBYTE bData, LPBYTE bMask, LPCSTR szMask)
{
	while (*szMask)
	{
		bData++;
		bMask++;
		szMask++;

		if (*szMask == 'x' && *bData != *bMask)
			return FALSE;
	}

	return *szMask == NULL;
}

VOID CopyMemoryEx(DWORD dwBaseAddress, LPSTR szData, size_t dwSize)
{
	DWORD dwOldProtection;
	VirtualProtect((LPVOID)dwBaseAddress, dwSize, PAGE_READWRITE, &dwOldProtection);
	CopyMemory((LPVOID)dwBaseAddress, szData, dwSize);
	VirtualProtect((LPVOID)dwBaseAddress, dwSize, dwOldProtection, &dwOldProtection);
}

VOID SetJumpHook(LPVOID lpHookAddress, DWORD dwJumpTo)
{
	BYTE bJump[5];
	CopyMemory(bJump, "\xE9\x90\x90\x90\x90", 5);

	DWORD dwJumpSize = dwJumpTo - (DWORD)lpHookAddress - 5;

	DWORD dwOldProtection = NULL;
	VirtualProtect(lpHookAddress, 5, PAGE_EXECUTE_READWRITE, &dwOldProtection);
	CopyMemory(&bJump[1], &dwJumpSize, 4);
	CopyMemory(lpHookAddress, bJump, 5);
	VirtualProtect(lpHookAddress, 5, dwOldProtection, &dwOldProtection);
}

VOID SeDebugPrivilege()
{
	HANDLE hToken;
	if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken))
		return;

	LUID Luid;
	if (!LookupPrivilegeValue(NULL, SE_DEBUG_NAME, &Luid))
		return;

	TOKEN_PRIVILEGES tp;
	tp.PrivilegeCount = 1;
	tp.Privileges[0].Luid = Luid;
	tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

	if (!AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL))
		return;

	CloseHandle(hToken);
}

BOOL IsUsingMapHack(HANDLE hProcess, DWORD dwBaseAdress, DWORD dwAddress, LPBYTE lpOriginalBytes, DWORD dwSize)
{
	BYTE lpBuffer[32];
	ZeroMemory(lpBuffer, dwSize);

	dwAddress += dwBaseAdress;
	ReadProcessMemory(hProcess, (LPVOID)dwAddress, lpBuffer, dwSize, NULL);
	if (memcmp(lpOriginalBytes, lpBuffer, dwSize) == 0)
		return FALSE;

	return TRUE;
}