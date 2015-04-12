include logic.inc
.MODEL Flat,StdCall
OPTION CaseMap:None
.data
weightMatrix DWORD 8, 1, 6, 5, 5, 6, 1, 8
             DWORD 1, 1, 5, 4, 4, 5, 1, 1
			 DWORD 6, 5, 3, 2, 2, 3, 5, 6
			 DWORD 5, 4, 2, 1, 1, 2, 4, 5
			 DWORD 5, 4, 2, 1, 1, 2, 4, 5
			 DWORD 6, 5, 3, 2, 2, 3, 5, 6
			 DWORD 1, 1, 5, 4, 4, 5, 1, 1
			 DWORD 8, 1, 6, 5, 5, 6, 1, 8 
.code

logic:
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
	x:DWORD, y:DWORD, pmap:DWORD
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
	mapAddress:DWORD, pmap:DWORD
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
	x:DWORD, y:DWORD, pmap:DWORD, turn:DWORD
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
InitMap PROC, pturn:DWORD, pmap:DWORD, pblack_count:DWORD, pwhite_count:DWORD, choice_mode:DWORD
;initilize the var in main
	local x:DWORD
	local y:DWORD

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

;	mov ebx, 1
;	L1:
;		mov eax, pmap
;		add eax, esi
;		mov [eax], ebx
;		add esi, 4
;		loop L1
;
;	mov eax, pmap
;	mov esi, 60
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 92
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 88
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 120
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 116
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 148
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 200
;	add eax, esi
;	mov ebx, 0
;	mov [eax], ebx
;
;	mov eax, pmap
;	mov esi, 204
;	add eax, esi
;	mov ebx, 2
;	mov [eax], ebx

	.if (choice_mode == 2)
		invoke AIStep, pmap, 2, pblack_count, pwhite_count
		mov x, eax
		mov y, edx
		invoke UpdateMap, x, y, pmap, 2, pblack_count, pwhite_count
		mov esi, pblack_count
		mov edi, [esi]
		mov eax, 1
		mov esi, pturn
		mov [esi], eax
	.endif

	;call GUI function
	popad

	ret
InitMap ENDP

CheckTurnEnd PROC, pmap: DWORD, turn: DWORD
;Check if the next player have a valid grid to place his chessman, retval in eax, 0 means not have a valid grid, 1 means have
	local next_turn: DWORD
	pushad
	mov eax, turn
	mov ebx, 3
	sub ebx, eax
	mov next_turn, ebx
	mov esi, pmap
	mov ecx, 64
check_loop:
	INVOKE GetXYAddress, esi, pmap
	INVOKE TryStep, eax, edx, pmap, next_turn
	.IF (ebx == 1)
		mov eax, 1
		ret
	.ENDIF
	add esi, 4
	loop check_loop
	popad
	mov eax, 0
	ret
CheckTurnEnd ENDP

CheckEnd PROC USES ebx ecx edx esi, 
	pmap: DWORD, black_count: DWORD, white_count: DWORD
;check if the game is finished, retval in eax, 0 means not finished, 1 means finished
	mov ebx, black_count
	add ebx, white_count
	.IF (ebx == 64)
		mov eax, 1
		ret
	.ENDIF
	INVOKE CheckTurnEnd, pmap, 1
	.IF (eax == 1)
		mov eax, 0
		ret
	.ENDIF
	INVOKE CheckTurnEnd, pmap, 2
	.IF (eax == 1)
		mov eax, 0
		ret
	.ENDIF
	mov eax, 1
	ret
CheckEnd ENDP

UpdateMap PROC,
	x:DWORD, y:DWORD, pmap:DWORD, turn:DWORD, pblack_count:DWORD, pwhite_count:DWORD
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
	pmap:DWORD, pmap_copy:DWORD
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
	pValue:DWORD, count:DWORD

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
	pmap:DWORD, turn:DWORD

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
	pmap:DWORD, turn:DWORD, pblack_count:DWORD, pwhite_count:DWORD
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

;------------------------------------------------------------------

logicTest PROC
	local turn:DWORD 
	local map[64]:DWORD
	local black_count:DWORD
	local white_count:DWORD
	local map_copy[64]:DWORD
	local AI_x:DWORD
	local AI_y:DWORD

	INVOKE InitMap, addr turn, addr map, addr black_count, addr white_count, 0

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

		jmp main_logic_loop
		
	ret
logicTest ENDP

END logic
