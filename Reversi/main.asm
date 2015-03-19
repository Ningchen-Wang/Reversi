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
InitMap PROC, pturn:PTR DWORD, pmap:PTR DWORD, pblack_count:PTR DWORD, pwhite_count:PTR DWORD
;initilize the var in main
	;mov eax, [ebp+8]
	;mov ebx, 1
	;mov [eax], ebx
	mov eax, pturn
	mov ebx, 1
	mov [eax], ebx
	mov [pblack_count], 2
	mov [pwhite_count], 2

	mov ecx, 64
	mov esi, 0
	L1:
		mov [pmap + esi], 0
		add esi, 4
		loop L1

	mov [pmap + 108], 1
	mov [pmap + 144], 1
	mov [pmap + 112], 2
	mov [pmap + 140], 2

	;call GUI function

	ret
InitMap ENDP

main PROC
	local turn:DWORD 
	local map[64]:DWORD
	local black_count:DWORD
	local white_count:DWORD

	INVOKE InitMap, addr turn, addr map, addr black_count, addr white_count

	ret
main ENDP
END main


