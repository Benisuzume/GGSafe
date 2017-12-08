#pragma once

int __stdcall _connect(SOCKET, const struct sockaddr *, int);
VOID CloseAuthSocket();
int SOCKSv5(SOCKET, sockaddr_in *, sockaddr_in *);
int __stdcall _sendto(SOCKET, const char *, int, int, const struct sockaddr *, int);