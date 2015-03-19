;Reversi_main
;Author: wangningchen, wangchengpeng
;Create: 2015/3/18
;Last modify: 2015/3/18
;Main logic entry

;--------------------------------------------------------------------------
include \masm32\include\masm32rt.inc

.data


;--------------------------------------------------------------------------
.code
start:
	call main
	exit

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

Test1 PROC USES esi edi edx,
	x:DWORD, y:DWORD, pmap:PTR DWORD, pturn:DWORD
;by the direction vector (1, 0)
;current turn is pturn
;if it is valid step, ebx = 1;else ebx = 0
	local opposite:DWORD
	local xystate:DWORD

	mov ebx, 3
	sub ebx, pturn
	mov opposite, ebx

	INVOKE JudgeInGrid, x, y
	.IF (eax == 0)
		mov ebx, 0
		ret
	.ENDIF
	 
	INVOKE GetMapAddress, x, y, pmap
	mov esi, pmap
	add esi, eax
	push ebx
	mov ebx, [esi]
	mov xystate, ebx
	pop ebx
	
	.IF (xystate != 0 || x == 7 || x == 6)
		mov ebx, 0
		ret
	.ENDIF

	mov esi, x
	add esi, 1
	mov edi, y
	push esi
	push edi
	INVOKE GetMapAddress, esi, edi, pmap
	mov esi, pmap
	add esi, eax
	push ebx
	mov ebx, [esi]
	mov xystate, ebx
	pop ebx
	pop edi
	pop esi

	.IF (xystate == turn || xystate == 0)
		mov ebx, 0
		ret
	.ENDIF

	mov esi, x
	mov edi, y
	mov eax, 1
	mov edx, 1
	add esi, 1
	.WHILE (eax == 1 && edx == 1)
		push esi
		push edi
		INVOKE GetMapAddress, esi, edi, pmap
		mov esi, pmap
		add esi, eax
		push ebx
		mov ebx, [esi]
		mov xystate, ebx
		pop ebx
		pop edi
		pop esi
		
		.IF (xystate == opposite)
			mov edx, 1
		.ELSEIF
			mov edx, 0
		.ENDIF

		add esi, 1
		INVOKE JudgeInGrid, esi, edi
	.ENDW

	.IF (edx == 0 && xystate == pturn)
		mov ebx, 1
	.ELSE
		mov ebx, 0
	.ENDIF
	ret
TEST1 ENDP


	
	

;--------------------------------------------------------------------------------------------

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

main PROC
	local turn:DWORD 
	local map[64]:DWORD
	local black_count:DWORD
	local white_count:DWORD
	local ad:DWORD

	INVOKE InitMap, addr turn, addr map, addr black_count, addr white_count
	INVOKE GetMapAddress, 4, 4, addr map
	
	mov ad, eax
	INVOKE GetXYAddress, ad, addr map

	INVOKE Test1, 2, 4, addr map, 1 

	ret
main ENDP
END main


