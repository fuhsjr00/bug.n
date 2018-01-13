/**
 * Intended to be built with MinGW.
 *
 */

#include <windows.h>


char *AppTitle="Win1"; 
LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam);


int WinMain(HINSTANCE hInst,HINSTANCE,LPSTR,int nCmdShow)
{
  WNDCLASS wc;
  HWND hwnd;
  MSG msg;

  wc.style=CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc=WindowProc;
  wc.cbClsExtra=0;
  wc.cbWndExtra=0;
  wc.hInstance=hInst;
  wc.hIcon=LoadIcon(NULL,IDI_WINLOGO);
  wc.hCursor=LoadCursor(NULL,IDC_ARROW);
  wc.hbrBackground=(HBRUSH)COLOR_WINDOWFRAME;
  wc.lpszMenuName=NULL;
  wc.lpszClassName=AppTitle;

  if (!RegisterClass(&wc))
    return 0;

  hwnd = CreateWindow(AppTitle,AppTitle,
		      WS_OVERLAPPEDWINDOW,
		      CW_USEDEFAULT,CW_USEDEFAULT,100,100,
		      NULL,NULL,hInst,NULL);

  if (!hwnd)
    return 0;

  ShowWindow(hwnd,nCmdShow);
  UpdateWindow(hwnd);

  while (GetMessage(&msg,NULL,0,0) > 0)
    {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    } 
} 


int maintain_bomb = 60;
int activate_bomb = 5;

LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
  switch (msg)
    {
    case WM_PAINT:
      {
	PAINTSTRUCT ps;
	HDC dc;
	RECT r;
	GetClientRect(hwnd,&r);
	dc=BeginPaint(hwnd,&ps);
	DrawText(dc,"This window intentionally hangs",-1,&r,DT_SINGLELINE|DT_CENTER|DT_VCENTER);
	EndPaint(hwnd,&ps);
	break;
      }

    case WM_DESTROY:
      PostQuitMessage(0);
      break;
    case WM_SHOWWINDOW:
    case WM_ACTIVATE:
      if(activate_bomb == 0)
	while(maintain_bomb) {
	  Sleep(1000);
	  maintain_bomb--;
	}
      activate_bomb--;

    default:
     return DefWindowProc(hwnd, msg, wparam, lparam);
    }
  return 0;
} 
