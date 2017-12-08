#pragma once

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdlib.h>
#include <stdio.h>

const HWND  hWnd      = FindWindow("Warcraft III", NULL);
const DWORD dwGameDll = (DWORD)GetModuleHandle("Game.dll");

#include "Functions.h"
#include "HotKeys.h"

#include "Jass Natives.h"

#include "States.h"
#include "Camera Distance Hack.h"
#include "Damage Notifier.h"
#include "Dream UI.h"
#include "Game Start Notifier.h"
#include "Mana Bar.h"
#include "Warcraft Functions.h"