;Reversi_main

;--------------------------------------------------------------------------
include \masm32\include\masm32rt.inc
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\winmm.lib
include logic.inc


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
DrawWindow proto

IDB_MAIN   equ 1
IDB_BITMAP1 equ 101	;background
IDB_BITMAP2 equ 102 ;Black
IDB_BITMAP3 equ 103 ;White
IDB_BITMAP4 equ 104 ;Empty
IDB_BITMAP5 equ 108 ;Number

IDB_BLACK1  equ  110
IDB_BLACK2  equ  111
IDB_WHITE1  equ  112
IDB_WHITE2  equ  113

IDI_ICON equ 106
IDR_MENU equ 105
IDD_DIALOG equ 109

ID_MODE1   equ 40001
ID_MODE2   equ 40002
ID_MODE3   equ 40003
ID_SOUND   equ 40004
ID_MUSIC   equ 40005
ID_STORY   equ 40006
ID_RULE    equ 40007
ID_CONTACT equ 40008

.data
;last time map
preMap DWORD 64 DUP(0)
;current time map
curMap DWORD 64 DUP(0)
black_count DWORD 0
white_count DWORD 0
bcountDigit1 WORD 0
bcountDigit2 WORD 0
wcountDigit1 WORD 0
wcountDigit2 WORD 0
turn DWORD 2
;choice_mode 1:vs computer,man first
;choice_mode 2:vs computer,computer first
;choice_mode 3:man vs man
choice_mode DWORD 1
hLog DWORD ?
updateLog BYTE "Update map", 0Dh, 0Ah, 0
paintLog BYTE "Paint dialog", 0Dh, 0Ah, 0
aiLog BYTE "AI Step", 0Dh, 0Ah, 0
mouseEventLog BYTE "LButtonDown", 0Dh, 0Ah, 0
updateLogLength DWORD 12
paintLogLength DWORD 14
aiLogLength DWORD 9
mouseEventLogLength DWORD 13
music BYTE "test", 0

ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "男女男 女男女 木其",0
intX db 0
intY db 0

szStoryTitle     db	  '故事背景',0
szStoryContent   db	  '    22世纪，同性恋逐渐变成了主流。',0dh,0ah,
'    然而，只要存在可一一配对的男女必须强制结婚，某一性别人数过剩才允许该性别同性结婚。',0dh,0ah,
'    随着医学突飞猛进，变性手术日臻成熟，因此人类社会被分为男女两方阵营，互相想要把对方阵营拉拢到自己阵营，使得本阵营性别过剩。',0
szRuleTitle      db   '游戏规则',0
szRuleContent    db	  '您不会下黑白棋吗？',0dh,0ah,'如有疑问，请拨打客服专线18201116235',0
szContactTitle   db   '关于我们',0
szContactContent db	  '如果您觉得该游戏不错，请汇款children19930928@yeah.net',0

.data?
hInstance HINSTANCE ?
hMenu dd ?
CommandLine LPSTR ?
hBitmap1 dd ?
hBitmap2 dd ?
hBitmap3 dd ?
hBitmap4 dd ?
hBitmap5 dd ?
hIcon    dd ?

hBitmapBlack1 dd ?
hBitmapBlack2 dd ?
hBitmapWhite1 dd ?
hBitmapWhite2 dd ?

;--------------------------------------------------------------------------
.code
start:
	invoke DrawWindow
	exit

_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
			invoke	LoadIcon,hInstance,IDI_ICON
			invoke	SendMessage,hWnd,WM_SETICON,IDI_ICON,eax
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax == IDOK
				invoke	EndDialog,hWnd,NULL
				invoke InitMap, addr turn, addr curMap, addr black_count, addr white_count, choice_mode, addr preMap
 		        ;invoke SendMessage, hWnd, WM_PAINT, 0, 0
			.else
				invoke	EndDialog,hWnd,NULL
			.endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret
_ProcDlgMain	endp

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
	invoke LoadIcon,hInstance,IDI_ICON
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke LoadMenu, hInstance, IDR_MENU

	mov hMenu,eax
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW  and  not WS_MAXIMIZEBOX and not WS_THICKFRAME,CW_USEDEFAULT,\ ;CW_USEDEFAULT,\
           CW_USEDEFAULT,700,540,NULL,hMenu,\
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

	  .if x < 50 || y < 50 || x > 48*8+50 || y > 48*8+50
		ret
	  .else
		sub x, 50
		sub y, 50	    
	  .endif

	  mov esi, 0
	  .while x > 48
		sub x, 48
		inc esi
	  .endw
	  
	  mov edi, 0
	  .while y > 48
		sub y, 48
		inc edi
	  .endw

	  sub edi, 7
	  neg edi

	  ret

PosToCoord ENDP

;get two digit of black_count and white_count
;return to the bcount1, bcount2, wcount1, wcount2
getScoreDigit PROC
	mov dx, 0
	mov eax, black_count
	mov ebx, 10
	div bx
	mov bcountDigit1, ax
	mov bcountDigit2, dx

	mov dx, 0
	mov eax, white_count
	mov ebx, 10
	div bx
	mov wcountDigit1, ax
	mov wcountDigit2, dx
	ret
getScoreDigit ENDP

; draw one piece of chess
DrawOnePiece PROC USES eax, color:DWORD, x:DWORD, y:DWORD, ps:PAINTSTRUCT, hdc:HDC, hMemDC:HDC, rect:RECT, hWnd:HWND

   sub y, 7
   neg y

   mov eax, 48
   mul x
   mov x, eax
  
   mov eax, 48
   mul y
   mov y, eax
  
   add x, 50
   add  y, 50

   inc x
   inc y ;edge

   invoke GetClientRect,hWnd,addr rect
   ;invoke InvalidateRect, hWnd, NULL, 0

   ;invoke BeginPaint,hWnd,addr ps
   ;mov hdc,eax
   ;invoke CreateCompatibleDC,hdc
   ;mov hMemDC,eax
   

   invoke SelectObject,hMemDC,hBitmap4
   invoke BitBlt,hdc,x,y,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
   .if color == 1
	  invoke SelectObject,hMemDC,hBitmap2
	  invoke BitBlt,hdc,x,y,rect.right,rect.bottom,hMemDC,0,0,SRCAND
   .elseif color == 2
      invoke SelectObject,hMemDC,hBitmap3
	  invoke BitBlt,hdc,x,y,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
   .endif

   ;invoke DeleteDC,hMemDC

   ret
DrawOnePiece ENDP


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   LOCAL hImgDC:HDC
   LOCAL rect:RECT
   LOCAL pos:POINT
   LOCAL coordX:DWORD
   LOCAL coordY:DWORD
   LOCAL hImg:HBITMAP



   mov coordX, 0
   mov coordY, 0

   .if uMsg==WM_CREATE
	  ; load bitmap
	  invoke InitLog
	  mov hLog, eax
	  invoke LoadIcon, hInstance, IDI_ICON
	  mov hIcon, eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP1
      mov hBitmap1,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP2
      mov hBitmap2,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP3
      mov hBitmap3,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP4
      mov hBitmap4,eax
	  invoke LoadBitmap,hInstance,IDB_BITMAP5
      mov hBitmap5,eax
	  invoke LoadBitmap,hInstance,IDB_BLACK1
      mov hBitmapBlack1,eax
	  invoke LoadBitmap,hInstance,IDB_BLACK1
      mov hBitmapBlack2,eax
	  invoke LoadBitmap,hInstance,IDB_WHITE1
      mov hBitmapWhite1,eax
	  invoke LoadBitmap,hInstance,IDB_WHITE2
      mov hBitmapWhite2,eax

	  ;INVOKE SetTimer, hWnd, 1, 200, NULL
	  invoke InitMap, addr turn, addr curMap, addr black_count, addr white_count, choice_mode, addr preMap


   .elseif uMsg == WM_TIMER
	  mov eax, wParam
	  .if (eax == 2)
		invoke KillTimer, hWnd, 2
	  loop3:
		invoke CheckEnd, addr curMap, addr black_count, addr white_count
		.if (eax == 1)
			invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
			invoke SendMessage, hWnd, WM_PAINT, 0, 0
		.endif
		invoke CopyMap, addr curMap, addr preMap
		invoke AIStep, addr curMap, turn, addr black_count, addr white_count
		invoke AppendLog, hLog, addr aiLog, aiLogLength
		mov coordX, eax
		mov coordY, edx
		invoke UpdateMap, coordX, coordY, addr curMap, turn, addr black_count, addr white_count
		invoke AppendLog, hLog, addr updateLog, updateLogLength
		invoke AppendMapLog, hLog, addr curMap, coordX, coordY, turn
		invoke SendMessage, hWnd, WM_PAINT, 0, 0
		invoke CheckEnd, addr curMap, addr black_count, addr white_count
		.if (eax == 1)
			invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
			invoke SendMessage, hWnd, WM_PAINT, 0, 0
			ret
		.endif
		invoke CheckTurnEnd, addr curMap, 2
		.if (eax == 1)
			mov turn, 1
		.elseif (eax == 0)
			;showMessage2
			jmp loop3
		.endif

	  .else
		ret
	  .endif

      ;invoke SendMessage, hWnd, WM_PAINT, 0, 0
   .elseif uMsg==WM_COMMAND
      .if wParam == ID_MODE1
	      mov eax, 1
		  mov choice_mode, eax
		  invoke InitMap, addr turn, addr curMap, addr black_count, addr white_count, choice_mode, addr preMap
		  invoke SendMessage, hWnd, WM_PAINT, 0, 0
	  .elseif wParam == ID_MODE2
	      mov eax, 2
		  mov choice_mode, eax
		  invoke InitMap, addr turn, addr curMap, addr black_count, addr white_count, choice_mode, addr preMap
		  invoke SendMessage, hWnd, WM_PAINT, 0, 0
	  .elseif wParam == ID_MODE3
	  	  mov eax, 3
		  mov choice_mode, eax
		  invoke InitMap, addr turn, addr curMap, addr black_count, addr white_count, choice_mode, addr preMap
		  invoke SendMessage, hWnd, WM_PAINT, 0, 0
	  .elseif wParam == ID_MUSIC
	  	  ;music
		  invoke PlaySound, addr music, NULL, SND_FILENAME
	  .elseif wParam == ID_SOUND
	      ;sound	
		  invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK	
		  invoke SendMessage, hWnd, WM_PAINT, 0, 0  
	  .elseif wParam == ID_STORY
		  invoke MessageBox,hWnd,offset szStoryContent, offset szStoryTitle, MB_OK
	  .elseif wParam == ID_RULE
	      invoke MessageBox,hWnd, offset szRuleContent,offset szRuleTitle, NULL
	  .elseif wParam == ID_CONTACT
	      invoke MessageBox,hWnd, offset szContactContent, offset szContactTitle, NULL
	  .endif
   .elseif uMsg==WM_PAINT

   	  invoke GetClientRect,hWnd,addr rect
      invoke InvalidateRect, hWnd, NULL, 0
      invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
	  invoke CreateCompatibleDC,hdc
	  mov hImgDC,eax
	  invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
	  mov hImg, eax
	  invoke SelectObject, hMemDC, hImg

	  ;invoke CreateCompatibleDC,hdc
	  ;mov hImgDC,eax

	  ;;;;Draw Background
      invoke SelectObject,hImgDC,hBitmap1
      invoke GetClientRect,hWnd,addr rect
      invoke BitBlt,hMemDC,0,0,rect.right,rect.bottom,hImgDC,0,0,SRCCOPY
	  
	  ;;;; Draw Chess
	  L1:
	  	.if coordY > 7
			jmp L2
		.endif
	  
		invoke GetMapAddress, coordX, coordY, addr curMap
		mov ebx, [eax]
		invoke GetMapAddress, coordX, coordY, addr preMap
		mov ecx, [eax]

		invoke DrawOnePiece, ebx, coordX, coordY, ps, hMemDC, hImgDC, rect, hWnd

		;.if ebx != ecx
		;	invoke DrawOnePiece, ebx, coordX, coordY, ps, hMemDC, hImgDC, rect, hWnd
		;.endif
		
		inc coordX
		.if coordX > 7
		    mov coordX, 0
		    inc coordY
		.endif
		jmp L1
	  L2:

	  ;;;;;;;;;;;;;;;;;;;;;;;;;;
	  ;Draw Score
	  ;;;;;;;;;;;;;;;;;;;;;;;;;;

	  ;invoke SelectObject,hImgDC,hBitmap2
	  ;invoke BitBlt,hMemDC,460 ,160,rect.right,rect.bottom,hImgDC,0,0,SRCAND
      ;invoke SelectObject,hImgDC,hBitmap3
	  ;invoke BitBlt,hMemDC,460,270,rect.right,rect.bottom,hImgDC,0,0,SRCPAINT

	  invoke SelectObject,hImgDC,hBitmapBlack1
	  invoke BitBlt,hMemDC,460 ,160,rect.right,rect.bottom,hImgDC,0,0,SRCAND
	  invoke SelectObject,hImgDC,hBitmapWhite1
	  invoke BitBlt,hMemDC,460,270,rect.right,rect.bottom,hImgDC,0,0,SRCPAINT
	  
	  invoke getScoreDigit

	  invoke SelectObject,hImgDC,hBitmap5

	  mov ax, bcountDigit1
	  mov bx, 60
	  mul bx
	  invoke BitBlt,hMemDC,520,150,60,70,hImgDC,ax,0,SRCAND
	 
	  mov ax, wcountDigit1
	  mov bx, 60
	  mul bx
	  invoke BitBlt,hMemDC,520,150+100,60,70,hImgDC,ax,100,SRCPAINT

	  mov ax, bcountDigit2
	  mov bx, 60
	  mul bx
	  invoke BitBlt,hMemDC,520+45,150,60,70,hImgDC,ax,0,SRCAND

	  mov ax, wcountDigit2
	  mov bx, 60
	  mul bx
	  invoke BitBlt,hMemDC,520+45,150+100,60,70,hImgDC,ax,100,SRCPAINT

	  invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hMemDC, 0 ,0, SRCCOPY

	  invoke DeleteObject, hImg

      invoke DeleteDC,hMemDC
	  invoke DeleteDC,hImgDC
	  invoke EndPaint, hWnd, addr ps
	  invoke AppendLog, hLog, addr paintLog, paintLogLength

	.elseif uMsg == WM_LBUTTONDOWN
		invoke AppendLog, hLog, addr mouseEventLog, mouseEventLogLength
		.if (choice_mode == 1 || choice_mode == 2)
			.if (turn == 2)
				ret
			.endif

			 loop1:
			   invoke CheckEnd, addr curMap, addr black_count, addr white_count
			   .if (eax == 1)
					invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
					invoke SendMessage, hWnd, WM_PAINT, 0, 0
					ret
			   .endif
			   ;invoke GetCursorPos,addr pos
			   ;invoke ScreenToClient,hWnd,addr pos
			   push eax
			   mov eax, lParam
			   and eax, 0FFFFh
			   mov pos.x, eax
			   mov eax, lParam
			   shr eax, 16
			   and eax, 0FFFFh
			   mov pos.y, eax
			   pop eax
			   invoke PosToCoord, pos.x, pos.y
			   mov coordX, esi
			   mov coordY, edi

			   invoke TryStep, coordX, coordY, addr curMap, turn

			  .if (ebx == 1)
				invoke CopyMap, addr curMap, addr preMap
				invoke UpdateMap, coordX, coordY, addr curMap, turn, addr black_count, addr white_count
				invoke AppendLog, hLog, addr updateLog, updateLogLength
				invoke AppendMapLog, hLog, addr curMap, coordX, coordY, turn
				invoke SendMessage, hWnd, WM_PAINT, 0, 0
			    invoke CheckEnd, addr curMap, addr black_count, addr white_count
			    .if (eax == 1)
					invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
					invoke SendMessage, hWnd, WM_PAINT, 0, 0
					ret
			    .endif
				invoke CheckTurnEnd, addr curMap, 1
				.if (eax == 1)
					mov turn, 2
				.elseif (eax == 0)
					;showMessage1
					jmp loop1
				.endif
			  .elseif (ebx == 0)
				ret
			  .endif

			  invoke SetTimer, hWnd, 2, 500, NULL
			  ret

		  loop2:
			invoke CheckEnd, addr curMap, addr black_count, addr white_count
			.if (eax == 1)
				invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
				invoke SendMessage, hWnd, WM_PAINT, 0, 0
				ret
			.endif
			invoke CopyMap, addr curMap, addr preMap
			invoke AIStep, addr curMap, turn, addr black_count, addr white_count
			mov coordX, eax
			mov coordY, edx
			invoke UpdateMap, coordX, coordY, addr curMap, turn, addr black_count, addr white_count
			invoke AppendMapLog, hLog, addr curMap, coordX, coordY, turn
			invoke SendMessage, hWnd, WM_PAINT, 0, 0
			invoke CheckEnd, addr curMap, addr black_count, addr white_count
			.if (eax == 1)
				invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
				invoke SendMessage, hWnd, WM_PAINT, 0, 0
				ret
			.endif
			invoke CheckTurnEnd, addr curMap, 2
			.if (eax == 1)
				mov turn, 1
			.elseif (eax == 0)
				;showMessage2
				jmp loop2
			.endif
		.elseif (choice_mode == 3)
			loop4:
			   invoke CheckEnd, addr curMap, addr black_count, addr white_count
			   .if (eax == 1)
					invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
					invoke SendMessage, hWnd, WM_PAINT, 0, 0
					ret
			   .endif
			   ;invoke GetCursorPos,addr pos
			   ;invoke ScreenToClient,hWnd,addr pos
			   push eax
			   mov eax, lParam
			   and eax, 0FFFFh
			   mov pos.x, eax
			   mov eax, lParam
			   shr eax, 16
			   and eax, 0FFFFh
			   mov pos.y, eax
			   pop eax
			   invoke PosToCoord, pos.x, pos.y
			   mov coordX, esi
			   mov coordY, edi

			   invoke TryStep, coordX, coordY, addr curMap, turn

			  .if (ebx == 1)
				invoke CopyMap, addr curMap, addr preMap
				invoke UpdateMap, coordX, coordY, addr curMap, turn, addr black_count, addr white_count
				invoke AppendMapLog, hLog, addr curMap, coordX, coordY, turn
				invoke SendMessage, hWnd, WM_PAINT, 0, 0
			    invoke CheckEnd, addr curMap, addr black_count, addr white_count
			    .if (eax == 1)
					invoke DialogBoxParam, hInstance, IDD_DIALOG, hWnd, _ProcDlgMain, MB_OK
					invoke SendMessage, hWnd, WM_PAINT, 0, 0
					ret
			    .endif
				invoke CheckTurnEnd, addr curMap, turn
				.if (eax == 1)
					mov ebx, 3
					sub ebx, turn
					mov turn, ebx
				.elseif (eax == 0)
					;showMessage3
					jmp loop4
				.endif
			  .elseif (ebx == 0)
				ret
			  .endif

			  ret
		.endif
	.elseif uMsg==WM_DESTROY
	  invoke CloseHandle, hLog
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
