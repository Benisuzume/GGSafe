#pragma once

#define VK_ZoomIn       VK_ADD
#define VK_ZoomOut      VK_SUBTRACT
#define VK_Default      VK_MULTIPLY
#define VK_ClearScreen  VK_BACK

void WINAPI HotKeys();
bool HotKeyPressed(int iKey);