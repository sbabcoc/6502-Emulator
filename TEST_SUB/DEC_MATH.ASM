	page	60,132

	.model	small
	.code
	.386

	public	_SBC_10
	include	equates.def

_SBC_10	proc	near

	push	bp
	mov	bp,sp

	push	ds
	push	di
	mov	di,cs
	mov	ds,di
	mov	dl,byte ptr [bp+4]
	mov	ch,byte ptr [bp+6]
	mov	dh,byte ptr [bp+8]
	call	SBC_Dec
	mov	ax,dx
	pop	di
	pop	ds
	pop	bp
	ret

_SBC_10	endp

SBC_Dec	proc	near			; Decimal-mode subtract

	assume	ds:_TEXT

	mov	di,bx			; Preserve the BX register

	;  ----------------------------------------------------
	; | Invert carry state to accomodate 6502 idiosyncrasy |
	;  ----------------------------------------------------

	xor	dh,C_6502		; Invert carry

	;  --------------------------------
	; | Create decimal result modifier |
	;  --------------------------------

	mov	al,dl			; AL = .A
	mov	ah,ch			; AH = parameter
	and	ax,0000111100001111b	; Retain low nybbles only
	ror	dh,1			;/ Get carry state from \
	rol	dh,1			;\ flags register image /
	sbb	al,ah			; Subtract nybbles with borrow
	cbw				; Sign-extend result
	mov	bx,ax			; BX = decimal modifier index
	mov	al,dl			; AL = .A

	;  --------------------------------------------
	; | Compute result of decimal-mode subtraction |
	;  --------------------------------------------

	shr	dh,1			; Get carry state from flags image
	sbb	dl,ch			; Subtract parameters with carry
	lahf				; Preserve processor status flags
	rcl	dh,1			; Put carry state into flags image

	sub	dl,MinorAdj[bx + 10h]	; Apply minor decimal adjustment

	mov	bl,dh			;/ BX = carry state \
	and	bx,C_6502		;\                  /
	sub	dl,MajorAdj[bx]		; Apply major decimal adjustment

IFNDEF	NoDecimalFlags	;-------------------------------------------------------,
										;
	;  -----------------------------------------				;
	; | Clear flags affected by SBC instruction |				;
	;  -----------------------------------------				;
										;
	and	dh,not (SF_8086 or ZF_8086 or OF_8086)	; SF, ZF and OF		;
										;
	;  -------------------------------					;
	; | Get sign and zero flag states |					;
	;  -------------------------------					;
										;
	and	ah,(SF_8086 or ZF_8086)	;/  Apply SF and ZF flags  \		;
	or	dh,ah			;\ to flags register image /		;
										;
	;  --------------------------						;
	; | Determine overflow state |						;
	;  --------------------------						;
										;
	;                ------------						;
	;               | DERIVATION |						;
	;  ---------------------------------------				;
	; | O: operation produced an overflow     |				;
	; | P: both parameters have the same sign |				;
	; | S: sign flag matches parameter signs  |				;
	; |                                       |				;
	; | ------------------------------------- |				;
	; |                                       |				;
	; |              O = ~P * ~S              |				;
	; |                                       |				;
	;  ---------------------------------------				;
										;
	xor	ch,al			; CH(msb) = ~P				;
	xor	ah,al			; AH(msb) = ~S				;
	and	ah,ch			; AH(msb) = ~P * ~S			;
										;
	rol	ah,1			;/ Apply overflow \			;
	rol	ah,1			;| to flags image |			;
	and	ah,OF_8086		;|                |			;
	or	dh,ah			;\                /			;
										;
ENDIF	;-----------------------------------------------------------------------'

	;  ----------------------------------------------------
	; | Invert carry state to accomodate 6502 idiosyncrasy |
	;  ----------------------------------------------------

	xor	dh,C_6502      	; Invert carry
	mov	bx,di		; Restore the BX register
	ret			; Return to caller

;----------------------------------------------------------------------------

MajorAdj	db	00h, 60h
MinorAdj	db	6 dup (-10), 10 dup (6), 16 dup (0)

SBC_Dec	endp
	end
