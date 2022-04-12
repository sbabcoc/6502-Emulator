	.model	small
	.code

;                   -----------------------------------
;                  |  D  E  C  &  I  N  C  .  A  S  M  |
;                   -----------------------------------
;
; This module contains code which emulates the 6502 instructions that either
; increment or decrement the contents of memory or the Index Registers.
;
; These instructions include:
;
;       DEA - Decrement Accumulator
;       DEC - Decrement Memory
;       DEX - Decrement Index Register X
;       DEY - Decrement Index Register Y
;       INA - Increment Accumulator
;       INC - Increment Memory
;       INX - Increment Index Register X
;       INY - Increment Index Register Y
;
; Upon entry, the following register conventions apply:
;
;       ch - Accumulator
;       dh - Index Register X
;       dl - Index Register Y
;       SI - Program Counter
;       BP - Stack Pointer
;       cl - Processor Status Register
;
;       _@ - Base execution cycles for instruction (from TIMETAB.ASM)

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@@   @   |
;                          | @   @ @      @ @  |
;                          | @   @ @@@@  @   @ |
;                          | @   @ @     @@@@@ |
;                          | @@@@  @@@@@ @   @ |
;                           -------------------


DEA_1	proc	near		;_____/ Mode 1: accumulator addressing \_____                             

	dec	ch		; Decrement Accumulator
	jmp	FlagSZ		; Merge flags to complete the cycle

DEA_1	endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@@  @@@@ |
;                          | @   @ @     @     |
;                          | @   @ @@@@  @     |
;                          | @   @ @     @     |
;                          | @@@@  @@@@@  @@@@ |
;                           -------------------


DEC_4	proc	near		;______/ Mode 4: absolute addressing \_______                                    

	mov	bx,ds:[si]	; Get pointer to specified location
	add	si,2		; Advance program counter
	dec	ds:[bx]		; Decrement data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

DEC_4	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DEC_5	proc	near		;____/ Mode 5: absolute indexed with X \_____                                           

	mov	bx,ds:[si]	; Get pointer to specified location
	add	si,2		; Advance program counter
	add	bl,dh		; Add index register X
	jnc	@F		; Jump if index did not exceed page boundary

	inc	bh		; Increment page number
	inc	_@		; Add one clock cycle for boundary crossing

@@:
	dec	ds:[bx]		; Decrement data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

DEC_5	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DEC_7	proc	near		;______/ Mode 7: zero page addressing \______

	mov	bl,ds:[si]	; Get pointer to specified location
	inc	si		; Advance program counter
	xor	bh,bh		; Ensure that MSB equals zero
	dec	ds:[bx]		; Decrement data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

DEC_7	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DEC_8	proc	near		;____/ Mode 8: zero page indexed with X \____

	mov	bl,ds:[si]	; Get pointer to specified location
	inc	si		; Advance program counter
	add	bl,dh		; Add index register X
	xor	bh,bh		; Ensure that MSB equals zero
	dec	ds:[bx]		; Decrement data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

DEC_8	endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@@ @   @ |
;                          | @   @ @      @ @  |
;                          | @   @ @@@@    @   |
;                          | @   @ @      @ @  |
;                          | @@@@  @@@@@ @   @ |
;                           -------------------


DEX_0	proc	near		;_______/ Mode 0: implied addressing \_______

	dec	dh		; Decrement Index Register X
	jmp	FlagSZ		; Merge flags to complete the cycle

DEX_0	endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@@ @   @ |
;                          | @   @ @      @ @  |
;                          | @   @ @@@@    @   |
;                          | @   @ @       @   |
;                          | @@@@  @@@@@   @   |
;                           -------------------


DEY_0	proc	near		;_______/ Mode 0: implied addressing \_______                           

	dec	dl		; Decrement Index Register Y
	jmp	FlagSZ		; Merge flags to complete the cycle

DEY_0	endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@ @   @   @   |
;                           |  @  @@  @  @ @  |
;                           |  @  @ @ @ @   @ |
;                           |  @  @  @@ @@@@@ |
;                           | @@@ @   @ @   @ |
;                            -----------------


INA_1	proc	near		;_____/ Mode 1: accumulator addressing \_____

	inc	ch		; Increment Accumulator
	jmp	FlagSZ		; Merge flags to complete the cycle

INA_1	endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@ @   @  @@@@ |
;                           |  @  @@  @ @     |
;                           |  @  @ @ @ @     |
;                           |  @  @  @@ @     |
;                           | @@@ @   @  @@@@ |
;                            -----------------


INC_4	proc	near		;______/ Mode 4: absolute addressing \_______   

	mov	bx,ds:[si]	; Get pointer to specified location
	add	si,2		; Advance program counter
	inc	ds:[bx]		; Increment data at specified locatio
	jmp	FlagSZ		; Merge flags to complete the cycle

INC_4	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

INC_5	proc	near		;____/ Mode 5: absolute indexed with X \_____

	mov	bx,ds:[si]	; Get pointer to specified location
	add	si,2		; Advance program counter
	add	bl,dh		; Add index register X
	jnc	@F		; Jump if index did not exceed page boundary

	inc	bh		; Increment page number
	inc	_@		; Add one clock cycle for boundary crossing

@@:
	inc	ds:[bx]		; Increment data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

INC_5	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

INC_7	proc	near		;______/ Mode 7: zero page addressing \______

	mov	bl,ds:[si]	; Get pointer to specified location
	inc	si		; Advance program counter
	xor	bh,bh		; Ensure that MSB equals zero
	inc	ds:[bx]		; Increment data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

INC_7	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

INC_8	proc	near		;____/ Mode 8: zero page indexed with X \____

	mov	bl,ds:[si]	; Get pointer to specified location
	inc	si		; Advance program counter
	add	bl,dh		; Add index register X
	xor	bh,bh		; Ensure that MSB equals zero
	inc	ds:[bx]		; Increment data at specified location
	jmp	FlagSZ		; Merge flags to complete the cycle

INC_8	endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@ @   @ @   @ |
;                           |  @  @@  @  @ @  |
;                           |  @  @ @ @   @   |
;                           |  @  @  @@  @ @  |
;                           | @@@ @   @ @   @ |
;                            -----------------


INX_0	proc	near		;_______/ Mode 0: implied addressing \_______

	inc	dh		; Increment Index Register X
	jmp	FlagSZ		; Merge flags to complete the cycle

INX_0	endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@ @   @ @   @ |
;                           |  @  @@  @  @ @  |
;                           |  @  @ @ @   @   |
;                           |  @  @  @@   @   |
;                           | @@@ @   @   @   |
;                            -----------------


INY_0	proc	near		;_______/ Mode 0: implied addressing \_______

	inc	dl		; Increment Index Register Y
	jmp	FlagSZ		; Merge flags to complete the cycle

INY_0	endp
	end
