;Reversi_main
;Author: wangningchen, wangchengpeng
;Create: 2015/3/18
;Last modify: 2015/3/18
;Main logic entry

;--------------------------------------------------------------------------
include \masm32\include\masm32rt.inc
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
include logic.inc


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
DrawWindow proto

IDB_MAIN   equ 1
IDB_BITMAP1 equ 101	;background
IDB_BITMAP2 equ 102 ;Black
IDB_BITMAP3 equ 103 ;White

.data
weightMatrix DWORD 8, 1, 6, 5, 5, 6, 1, 8
             DWORD 1, 1, 5, 4, 4, 5, 1, 1
			 DWORD 6, 5, 3, 2, 2, 3, 5, 6
			 DWORD 5, 4, 2, 1, 1, 2, 4, 5
			 DWORD 5, 4, 2, 1, 1, 2, 4, 5
			 DWORD 6, 5, 3, 2, 2, 3, 5, 6
			 DWORD 1, 1, 5, 4, 4, 5, 1, 1
			 DWORD 8, 1, 6, 5, 5, 6, 1, 8 
ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "男女男 女男女 木其",0
intX db 0
intY db 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hBitmap1 dd ?
hBitmap2 dd ?
hBitmap3 dd ?

gridLen dd 50		;the length of grid
gridOffsetX dd 50	;offset x to window
gridOffsetY dd 50	;offset y to window

;--------------------------------------------------------------------------
.code
start:
	invoke DrawWindow
	exit

	
DrawWindow PROC

	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

	ret
DrawWindow ENDP


; draw the window
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND

	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW  and  not WS_MAXIMIZEBOX and not WS_THICKFRAME,50,\ ;CW_USEDEFAULT,\
           50,670,489,NULL,NULL,\
           hInst,NULL

	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov     eax,msg.wParam
	ret
WinMain endp

; change the pos of window to coord of grid
; return the answer x,y to esi, edi
PosToCoord PROC , x:DWORD, y:DWORD

	  .if x < 50 || y < 50 || x > 46*8+50 || y > 46*8+50
		ret
	  .else
		sub x, 50
		sub y, 50	    
	  .endif

	  mov esi, 0
	  .while x > 46
		sub x, 46
		inc esi
	  .endw
	  
	  mov edi, 0
	  .while y > 46
		sub y, 46
		inc edi
	  .endw

	  ret

PosToCoord ENDP

; draw one piece of chess
DrawOnePiece PROC USES eax, color:DWORD, x:DWORD, y:DWORD, ps:PAINTSTRUCT, hdc:HDC, hMemDC:HDC, rect:RECT, hWnd:HWND

   mov eax, 46
   mul x
   mov x, eax
  
   mov eax, 46
   mul y
   mov y, eax
  
   add x, 50
   add  y, 50

   invoke GetClientRect,hWnd,addr rect
   invoke InvalidateRect, hWnd, addr rect, 0

   invoke BeginPaint,hWnd,addr ps
   mov hdc,eax
   invoke CreateCompatibleDC,hdc
   mov hMemDC,eax

   .if color == 0
	  invoke SelectObject,hMemDC,hBitmap2
	  invoke BitBlt,hdc,x,y,rect.right,rect.bottom,hMemDC,0,0,SRCAND
   .elseif color == 1
      invoke SelectObject,hMemDC,hBitmap3
	  invoke BitBlt,hdc,x,y,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
   .endif

   
   invoke DeleteDC,hMemDC

   ret
DrawOnePiece ENDP


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   LOCAL rect:RECT
   LOCAL pos:POINT

   .if uMsg==WM_CREATE
	  ; load bitmap
	  invoke LoadBitmap,hInstance,IDB_BITMAP1
      mov hBitmap1,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP2
      mov hBitmap2,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP3
      mov hBitmap3,eax
	  
   .elseif uMsg==WM_PAINT
      invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
      invoke SelectObject,hMemDC,hBitmap1
      invoke GetClientRect,hWnd,addr rect
      invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY


      ;invoke BitBlt,hdc,100,100,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
	  ;invoke BitBlt,hdc,150,100,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
	  ;invoke BitBlt,hdc,200,100,rect.right,rect.bottom,hMemDC,0,0,SRCAND
	  ;
	  ;invoke SelectObject,hMemDC,hBitmap3
      ;invoke GetClientRect,hWnd,addr rect
      ;invoke BitBlt,hdc,250,100,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
	  ;invoke BitBlt,hdc,300,100,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
	  ;invoke BitBlt,hdc,350,100,rect.right,rect.bottom,hMemDC,0,0,SRCAND
      invoke DeleteDC,hMemDC

	.elseif uMsg == WM_LBUTTONDOWN

	  invoke GetCursorPos,addr pos
	  invoke ScreenToClient,hWnd,addr pos
	  invoke PosToCoord, pos.x, pos.y
	  ; pos is the coord(0-7)
	  mov pos.x, esi
	  mov pos.y, edi

	  invoke DrawOnePiece, 0, pos.x, pos.y, ps, hdc, hMemDC, rect, hWnd

   .elseif uMsg == WM_RBUTTONDOWN

	  invoke GetCursorPos,addr pos
	  invoke ScreenToClient,hWnd,addr pos
	  invoke PosToCoord, pos.x, pos.y
	  ; pos is the coord(0-7)
	  mov pos.x, esi
	  mov pos.y, edi

	  invoke DrawOnePiece, 1, pos.x, pos.y, ps, hdc, hMemDC, rect, hWnd

	.elseif uMsg==WM_DESTROY
      invoke DeleteObject,hBitmap1
		invoke PostQuitMessage,NULL
	  invoke DeleteObject,hBitmap2
		invoke PostQuitMessage,NULL
	  invoke DeleteObject,hBitmap3
		invoke PostQuitMessage,NULL
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp

end start
