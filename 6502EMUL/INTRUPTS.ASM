	.model	small
	.code

;                  --------------------------------------
;                 |  I  N  T  R  U  P  T  S  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; interrupt service operations.
;
; These instructions include:
;
;       BRK - Force Break
;       RTI - Return from Interrupt
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
;                          | @@@@  @@@@  @   @ |
;                          | @   @ @   @ @  @  |
;                          | @@@@  @@@@  @@@   |
;                          | @   @ @  @  @  @  |
;                          | @@@@  @   @ @   @ |
;                           -------------------

BRK_0	proc	near		;_______/ Mode 0: implied addressing \_______

	mov	bx,bp		; BX = current stack pointer
	mov	ax,si		; AX = current program counter
	inc	ax		; Increment copy of program counter
	mov	ds:[bx],ah	; Store MSB of return address at stack pointer
	dec	bl		; Decrement stack pointer
	mov	ds:[bx],al	; Store LSB of return address at stack pointer
	dec	bl		; Decrement stack pointer

	;------ Set status flags: ------,
	or	cl,B_6502 or I_6502	; Break and Interrupt Disable

	mov	al,cl			; Get copy of Processor Status
	test	al,ZF_8086 or OF_8086	; Test swapped flag states
	jpe	@F			; States are identical - do nothing

	xor	al,ZF_8086 or OF_8086	; Invert status flag states to swap

@@:	mov	ds:[bx],al	; Store Processor Status at stack pointer
	dec	bl		; Decrement stack pointer
	mov	bp,bx		; Update stack pointer
	mov	si,irqVector	; Load Program Counter with IRQ Vector
	jmp	Fetch6502Opcode	; Procede to the next opcode

BRK_0	endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@@  @@@@@ @@@ |
;                           | @   @   @    @  |
;                           | @@@@    @    @  |
;                           | @  @    @    @  |
;                           | @   @   @   @@@ |
;                            -----------------

RTI_0	proc	near		;_______/ Mode 0: implied addressing \_______

	mov	bx,bp		; BX = current stack pointer
	inc	bl		; Increment stack pointer
	mov	cl,ds:[bx]	; Load Processor Status at stack pointer

	test	cl,ZF_8086 or OF_8086	; Test swapped flag states
	jpe	@F			; States are identical - do nothing

	xor	cl,ZF_8086 or OF_8086	; Invert status flag states to swap

@@:	inc	bl		; Increment stack pointer
	mov	al,ds:[bx]	; Load LSB of return address at stack pointer
	inc	bl		; Increment stack pointer
	mov	ah,ds:[bx]	; Load MSB of return address at stack pointer
	mov	bp,bx		; Update stack pointer
	mov	si,ax		; Load Program counter with return address
	jmp	Fetch6502Opcode	; Procede to the next opcode

RTI_0	endp
	end

