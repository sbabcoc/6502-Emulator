	.model	small
	.code

;                      -----------------------------
;                     |  J  U  M  P  S  .  A  S  M  |
;                      -----------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; control transfer operations.
;
; These instructions include:
;
;       JMP - Jump
;       JSR - Jump to Subroutine
;       RTS - Return from Subroutine
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
;                          |     @ @   @ @@@@  |
;                          |     @ @@ @@ @   @ |
;                          |     @ @ @ @ @@@@  |
;                          | @   @ @   @ @     |
;                          |  @@@  @   @ @     |
;                           -------------------


JMP_4	proc	near		;______/ Mode 4: absolute addressing \_______

	mov	si,ds:[si]	; Load Program Counter with destination address
	jmp	Fetch6502Opcode	; Procede to the next opcode

JMP_4	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

JMP_A	proc	near		;__/ Mode A: absolute indirect addressing \__

	mov	bx,ds:[si]	; Get pointer to specified location
	mov	si,ds:[bx]	; Load Program Counter with destination address
	jmp	Fetch6502Opcode	; Procede to the next opcode

JMP_A	endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

JMP_B	proc	near		;_/ Mode B: absolute pre-indexed indirect \__

	mov	bx,ds:[si]	; Get pointer to specified location
	add	bl,dh		;/ Add index register X \
	adc	bh,0		;\                      /
	mov	si,ds:[bx]	; Load Program Counter with destination address
	jmp	Fetch6502Opcode	; Procede to the next opcode

JMP_B	endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |     @  @@@@ @@@@  |
;                          |     @ @     @   @ |
;                          |     @  @@@  @@@@  |
;                          | @   @     @ @  @  |
;                          |  @@@  @@@@  @   @ |
;                           -------------------


JSR_4	proc	near		;______/ Mode 4: absolute addressing \_______

	mov	bx,bp		; BX = current stack pointer
	mov	ax,si		; AX = current program counter
	inc	ax		; Increment copy of program counter
	mov	ds:[bx],ah	; Store MSB of return address at stack pointer
	dec	bl		; Decrement stack pointer
	mov	ds:[bx],al	; Store LSB of return address at stack pointer
	dec	bl		; Decrement stack pointer
	mov	bp,bx		; Update stack pointer
	mov	si,ds:[si]	; Load Program Counter with subroutine address
	jmp	Fetch6502Opcode	; Procede to the next opcode

JSR_4	endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@@  @@@@ |
;                          | @   @   @   @     |
;                          | @@@@    @    @@@  |
;                          | @  @    @       @ |
;                          | @   @   @   @@@@  |
;                           -------------------


RTS_0	proc	near		;_______/ Mode 0: implied addressing \_______

	mov	bx,bp		; BX = current stack pointer
	inc	bl		; Increment stack pointer
	mov	al,ds:[bx]	; Load LSB of return address at stack pointer
	inc	bl		; Increment stack pointer
	mov	ah,ds:[bx]	; Load MSB of return address at stack pointer
	inc	ax		; Increment return address
	mov	bp,bx		; Update stack pointer
	mov	si,ax		; Load Program counter with return address
	jmp	Fetch6502Opcode	; Procede to the next opcode

RTS_0	endp
	end
