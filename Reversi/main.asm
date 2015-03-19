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

	ret
main ENDP
END main


