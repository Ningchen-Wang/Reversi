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


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
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
	

	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

	call main

	exit



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

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   LOCAL rect:RECT
   LOCAL pos:POINT

   .if uMsg==WM_CREATE
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

	  ;invoke SelectObject,hMemDC,hBitmap2
      ;invoke GetClientRect,hWnd,addr rect
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

	  invoke GetClientRect,hWnd,addr rect
	  invoke InvalidateRect, hWnd, addr rect, 0

	  invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
	  invoke SelectObject,hMemDC,hBitmap2

	  invoke GetCursorPos,addr pos
	  invoke ScreenToClient,hWnd,addr pos


	  .if pos.x > 50 && pos.y > 50
		sub pos.x, 50
		sub pos.y, 50
	  .else
	    ret
	  .endif

	  push eax
	  mov eax, 0
	  .while pos.x > 46
		sub pos.x, 46
		inc eax
	  .endw
	  
	  push ebx
	  mov ebx, 0
	  .while pos.y > 46
		sub pos.y, 46
		inc ebx
	  .endw
	  
	  mov pos.x, eax
	  mov pos.y, ebx
	  
	  pop eax
	  pop ebx
	  
	  mov eax, 46
	  mul pos.x
	  mov pos.x, eax
	  
	  mov eax, 46
	  mul pos.y
	  mov pos.y, eax
	  
	  add pos.x, 46
	  add pos.y, 46
	  


	  

      invoke BitBlt,hdc,pos.x,pos.y,rect.right,rect.bottom,hMemDC,0,0,SRCAND
      invoke DeleteDC,hMemDC

   .elseif uMsg == WM_RBUTTONDOWN

	  invoke GetClientRect,hWnd,addr rect
	  invoke InvalidateRect, hWnd, addr rect, 0

	  invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax
	  invoke SelectObject,hMemDC,hBitmap3

	  invoke GetCursorPos,addr pos
	  invoke ScreenToClient,hWnd,addr pos

      invoke BitBlt,hdc,pos.x,pos.y,rect.right,rect.bottom,hMemDC,0,0,SRCPAINT
      invoke DeleteDC,hMemDC

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

;----------------------------------------------------
JudgeInGrid PROC,
	x:DWORD, y:DWORD
;judge if (x, y) is in the grid
;if yes, eax = 1;
;else, eax = 0
	.IF (x < 0 || x > 7 || y < 0 || y > 7)
		mov eax, 0
	.ELSE
		mov eax, 1
	.ENDIF
	ret
JudgeInGrid ENDP

;----------------------------------------------------
GetMapAddress PROC, 
	x:DWORD, y:DWORD, pmap:PTR DWORD
;calculate the address of (x, y) in map
;the beginning address of map is pmap 
;return the result in eax
	push esi
	.IF (x < 0 || x > 7 || y < 0 || y > 7)
		mov eax, pmap
	.ELSE
		mov eax, 8
		mul x
		add eax, y
		mov esi, 4
		mul esi
		add eax, pmap
	.ENDIF
	pop esi
	ret
GetMapAddress ENDP

;----------------------------------------------------
GetXYAddress PROC,
	mapAddress:DWORD, pmap:PTR DWORD
;calculate the (x ,y) address of the point whose map address is mapAddress
;store x in eax, and y in edx
	mov eax, mapAddress
	sub eax, pmap
	.IF (eax < 0 || eax > 252)
		mov eax, 0
		mov edx, 0
		ret
	.ELSE
		mov edx, 0
		push esi 
		mov esi, 4
		div esi
		
		mov esi, 8
		mov edx, 0
		div esi
		pop esi
		ret
	.ENDIF
GetXYAddress ENDP

;--------------------------------------------------------------------------------------------
;this block is used to check whether the step is valid, whose turn is equal to var turn
;we will check in eight directions, which respond to eight checking functions
;1-direction vector(1, 0)  2-direction vector(-1, 0)
;3-direction vector(0, 1)  4-direction vector(0, -1)
;5-direction vector(1, 1)  6-direction vector(-1, 1)
;7-direction vector(1, -1)  8-direction vector(-1, -1)

TryStep PROC USES esi edi edx ecx,
	x:DWORD, y:DWORD, pmap:PTR DWORD, turn:DWORD
;whether (x,y) is a valid position in this turn
;if it is valid step, ebx = 1;else ebx = 0
	local opposite:DWORD
	local xystate:DWORD
	local delta_x:SDWORD
	local delta_y:SDWORD

	mov ebx, 3
	sub ebx, turn
	mov opposite, ebx

	INVOKE JudgeInGrid, x, y
	.IF (eax == 0)
		mov ebx, 0
		ret
	.ENDIF
	 
	INVOKE GetMapAddress, x, y, pmap
	mov esi, eax
	push ebx
	mov ebx, [esi]
	mov xystate, ebx
	pop ebx
	
	.IF (xystate != 0)
		mov ebx, 0
		ret
	.ENDIF
	
	mov delta_x, -2
direction_loop_x:
	add delta_x, 1	
	.IF (delta_x == 2)
		mov ebx, 0
		ret
	.ENDIF
	mov delta_y, -2
direction_loop_y:
	add delta_y, 1	
	.IF (delta_y == 2)
		jmp direction_loop_x
	.ENDIF
	.IF (delta_x == 0 && delta_y == 0)
		jmp direction_loop_y
	.ENDIF
	mov esi, x
	add esi, delta_x
	mov edi, y
	add edi, delta_y
	push esi
	push edi
	INVOKE GetMapAddress, esi, edi, pmap
	mov esi, eax
	push ebx
	mov ebx, [esi]
	mov xystate, ebx
	pop ebx
	pop edi
	pop esi

	
	mov ecx, xystate
	.IF (ecx == turn || xystate == 0)
		jmp direction_loop_y
	.ENDIF

	mov esi, x
	mov edi, y
	mov eax, 1
	mov edx, 1
	add esi, delta_x
	add edi, delta_y
	.WHILE (edx == 1)
		INVOKE JudgeInGrid, esi, edi
		.IF (eax == 0)
			jmp direction_loop_y
		.ENDIF
		push esi
		push edi
		INVOKE GetMapAddress, esi, edi, pmap
		mov esi, eax
		push ebx
		mov ebx, [esi]
		mov xystate, ebx
		pop ebx
		pop edi
		pop esi
		
		mov ecx, xystate
		.IF (ecx == opposite)
			mov edx, 1
		.ELSEIF
			mov edx, 0
		.ENDIF

		add esi, delta_x
		add edi, delta_y
	.ENDW

	mov ecx, xystate
	.IF (edx == 0 && ecx == turn)
		mov ebx, 1
		ret
	.ENDIF
	jmp direction_loop_y
TryStep ENDP

;----------------------------------------------------
InitMap PROC, pturn:PTR DWORD, pmap:PTR DWORD, pblack_count:PTR DWORD, pwhite_count:PTR DWORD
;initilize the var in main
	pushad

	mov eax, pturn
	mov ebx, 1
	mov [eax], ebx

	mov eax, pblack_count
	mov ebx, 2
	mov [eax], ebx

	mov eax, pwhite_count
	mov ebx, 2
	mov [eax], ebx

	mov ecx, 64
	mov esi, 0
	mov ebx, 0
	L1:
		mov eax, pmap
		add eax, esi
		mov [eax], ebx
		add esi, 4
		loop L1

	mov eax, pmap
	mov esi, 108
	add eax, esi
	mov ebx, 1
	mov [eax], ebx

	mov eax, pmap
	mov esi, 144
	add eax, esi
	mov ebx, 1
	mov [eax], ebx

	mov eax, pmap
	mov esi, 112
	add eax, esi
	mov ebx, 2
	mov [eax], ebx

	mov eax, pmap
	mov esi, 140
	add eax, esi
	mov ebx, 2
	mov [eax], ebx

	popad

	;call GUI function

	ret
InitMap ENDP

CheckEnd PROC USES ebx ecx edx esi, 
	pmap:PTR DWORD, black_count: DWORD, white_count: DWORD
;check if the game is finished, retval in eax, 0 means not finished, 1 means finished
	mov ebx, black_count
	add ebx, white_count
	.IF (ebx == 64)
		mov eax, 1
		ret
	.ENDIF
	mov esi, pmap
	mov ecx, 64
check_loop:
	INVOKE GetXYAddress, esi, pmap
	INVOKE TryStep, eax, edx, pmap, 1
	.IF (ebx == 1)
		mov eax, 0
		ret
	.ENDIF
	INVOKE TryStep, eax, esi, pmap, 2
	.IF (ebx == 1)
		mov eax, 0
		ret
	.ENDIF
	add esi, 4
	loop check_loop
	mov eax, 1
	ret
CheckEnd ENDP

UpdateMap PROC,
	x:DWORD, y:DWORD, pmap:PTR DWORD, turn:DWORD, pblack_count:PTR DWORD, pwhite_count:PTR DWORD
;Update map when a player decide to choice (x,y) in this turn
;(x,y) must be a valid position
;Update counters too
	local opposite:DWORD
	local delta_x:SDWORD
	local delta_y:SDWORD
	local delta_black: SDWORD
	local delta_white: SDWORD

	pushad
	mov ebx, 3
	sub ebx, turn
	mov opposite, ebx

	.IF (turn == 1)
		mov delta_black, 1
		mov delta_white, -1
	.ELSE
		mov delta_black, -1
		mov delta_white, 1
	.ENDIF

	INVOKE GetMapAddress, x, y, pmap
	mov esi, eax
	mov eax, turn
	mov [esi], eax
	.IF (turn == 1)
		mov eax, pblack_count
	.ELSE
		mov eax, pwhite_count
	.ENDIF
	push ebx
	mov ebx, [eax]
	add ebx, 1
	mov [eax], ebx
	pop ebx	

	
	mov delta_x, -2
direction_loop_x:
	add delta_x, 1	
	.IF (delta_x == 2)
		popad
		ret
	.ENDIF
	mov delta_y, -2
direction_loop_y:
	add delta_y, 1	
	.IF (delta_y == 2)
		jmp direction_loop_x
	.ENDIF
	.IF (delta_x == 0 && delta_y == 0)
		jmp direction_loop_y
	.ENDIF
	mov esi, x
	add esi, delta_x
	mov edi, y
	add edi, delta_y
	INVOKE JudgeInGrid, esi, edi
	.IF (eax == 0)
		jmp direction_loop_y
	.ENDIF
	push esi
	push edi
	INVOKE GetMapAddress, esi, edi, pmap
	mov esi, eax
	push ebx
	mov ebx, [esi]
	mov ecx, ebx
	pop ebx
	pop edi
	pop esi

	.IF (ecx == turn || ecx == 0)
		jmp direction_loop_y
	.ENDIF

	mov esi, x
	mov edi, y
	mov eax, 1
	mov edx, 1
	add esi, delta_x
	add edi, delta_y
	.WHILE (edx == 1)
		INVOKE JudgeInGrid, esi, edi
		.IF (eax == 0)
			jmp direction_loop_y
		.ENDIF
		push esi
		push edi
		INVOKE GetMapAddress, esi, edi, pmap
		mov esi, eax
		push ebx
		mov ebx, [esi]
		mov ecx, ebx
		pop ebx
		pop edi
		pop esi
		
		.IF (ecx == opposite)
			mov edx, 1
		.ELSEIF
			mov edx, 0
		.ENDIF

		add esi, delta_x
		add edi, delta_y
	.ENDW

	.IF (edx == 0 && ecx == turn)
		mov esi, x
		mov edi, y
		add esi, delta_x
		add edi, delta_y
		mov edx, 1
		.WHILE (edx == 1)
			push esi
			push edi
			INVOKE GetMapAddress, esi, edi, pmap
			mov esi, eax
			push ebx
			mov ebx, [esi]
			.IF (ebx == opposite)
				mov edx, 1
				mov eax, turn
				mov [esi], eax
				mov eax, pblack_count
				mov ebx, [eax]
				add ebx, delta_black
				mov [eax], ebx
				mov eax, pwhite_count
				mov ebx, [eax]
				add ebx, delta_white
				mov [eax], ebx
				;need update map here
			.ELSEIF
				mov edx, 0
			.ENDIF

			pop ebx
			pop edi
			pop esi

			add esi, delta_x
			add edi, delta_y
		.ENDW
		
	.ENDIF
	jmp direction_loop_y
UpdateMap ENDP

CopyMap PROC USES eax ebx ecx edx,
	pmap:PTR DWORD, pmap_copy:PTR DWORD
;pmap is a pointer to map in main logic procedure
;This procedure try to copy it to pmap_copy address
;This procedure will not allocate memory for copy, it need procedure who call this to allocate enough memory
	mov ecx, 64
copy_map_loop:
	mov eax, pmap
	mov ebx, ecx
	shl ebx, 2
	add eax, ebx
	sub eax, 4
	mov eax, [eax]
	mov edx, pmap_copy
	add edx, ebx
	sub edx, 4
	mov [edx], eax
	loop copy_map_loop
	ret
CopyMap ENDP

;------------------------------------------------------------------------------------------
;AI Functions Part

;findMaxValueAddress receives address of array and the length of array
;return the index of the max value in eax
findMaxValueAddress PROC USES esi ecx edx,
	pValue:PTR DWORD, count:DWORD

	local maxValue:DWORD
	local maxValueAddress:DWORD

	mov maxValue, 0
	mov maxValueAddress, 0

	mov ecx, count
	mov esi, pValue
	L1:
		mov edx, [esi]
		.IF (edx > maxValue)
			mov maxValue, edx
			mov maxValueAddress, esi
		.ENDIF
		add esi, 4
		loop L1

	mov eax, maxValueAddress
	ret

findMaxValueAddress ENDP

;getEvaluateValue receives the map and the turn 
;return the evaluate value in eax
getEvaluateValue PROC USES ecx edi ebx edx esi,
	pmap:PTR DWORD, turn:DWORD

	mov ecx, 64
	mov edi, 0
	mov ebx, pmap
	mov edx, OFFSET weightMatrix

	L1:
		mov esi, [ebx]
		.IF (esi == turn)
			add edi, [edx]
		.ENDIF
		add ebx, 4
		add edx, 4
		loop L1
	mov eax, edi
	ret
getEvaluateValue ENDP

;AIStep receives the map and the turn
;return the best position (x, y)
;x stored in eax, y stored in edx
AIStep PROC USES ebx ecx esi edi,
	pmap:PTR DWORD, turn:DWORD, pblack_count:DWORD, pwhite_count:DWORD
	local value[64]:DWORD
	local copy_Map[64]:DWORD
	local lbcount:DWORD
	local lwcount:DWORD

	mov ebx, pblack_count
	mov eax, [ebx]
	mov lbcount, eax

	mov ebx, pwhite_count
	mov eax, [ebx]
	mov lwcount, eax

	mov ecx, 0
	.WHILE (ecx < 8)
		mov edi, 0
		.WHILE (edi < 8)
			INVOKE CopyMap, pmap, addr copy_Map
			INVOKE TryStep, ecx, edi, addr copy_Map, turn
			.IF (ebx == 0)
				INVOKE GetMapAddress, ecx, edi, addr value
				mov esi, 0
				mov [eax], esi
			.ELSE
				INVOKE UpdateMap, ecx, edi, addr copy_Map, turn, addr lbcount, addr lwcount
				INVOKE getEvaluateValue, addr copy_Map, turn
				mov esi, eax
				INVOKE GetMapAddress, ecx, edi, addr value
				mov [eax], esi
			.ENDIF
			add edi, 1
		.ENDW
		add ecx, 1
	.ENDW

	INVOKE findMaxValueAddress, addr value, 64

	mov esi, eax
	INVOKE GetXYAddress, esi, addr value

	;return x in eax and y in edx
	ret
AIStep ENDP

result PROC, 
	pmap:PTR DWORD
	mov eax, 1
	ret
result ENDP

;------------------------------------------------------------------------------------------

main PROC
	local turn:DWORD 
	local map[64]:DWORD
	local black_count:DWORD
	local white_count:DWORD
	local map_copy[64]:DWORD
	local AI_x:DWORD
	local AI_y:DWORD

	INVOKE InitMap, addr turn, addr map, addr black_count, addr white_count

	main_logic_loop:
	black_input:
		INVOKE CopyMap, addr map, addr map_copy	
		INVOKE AIStep, addr map_copy, turn, addr black_count, addr white_count
		mov AI_x, eax
		mov AI_y, edx
		INVOKE TryStep, AI_x, AI_y, addr map, turn
		.IF (ebx == 0)	
			jmp black_input
		.ENDIF 
		INVOKE UpdateMap, AI_x, AI_y, addr map, turn, addr black_count, addr white_count
		INVOKE CheckEnd, addr map, black_count, white_count 
		.IF (eax == 1)
			ret
		.ENDIF
		mov eax, 3
		sub eax, turn
		mov turn, eax
	white_input:
		INVOKE CopyMap, addr map, addr map_copy
		INVOKE AIStep, addr map_copy, turn, addr black_count, addr white_count
		mov AI_x, eax
		mov AI_y, edx
		INVOKE TryStep, AI_x, AI_y, addr map, turn
		.IF (ebx == 0)
			jmp white_input
		.ENDIF 
		INVOKE UpdateMap, AI_x, AI_y, addr map, turn, addr black_count, addr white_count
		INVOKE CheckEnd, addr map, black_count, white_count 
		.IF (eax == 1)
			ret
		.ENDIF
		mov eax, 3
		sub eax, turn
		mov turn, eax

		INVOKE result, addr map
		jmp main_logic_loop
		
	ret
main ENDP
;END main

end start
