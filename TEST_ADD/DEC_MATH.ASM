	page	60,132

	.model	small
	.code
	.386

	public	_ADC_10
	include	equates.def

_ADC_10	proc	near

	push	bp
	mov	bp,sp

	push	ds
	push	di
	mov	di,cs
	mov	ds,di
	mov	dl,byte ptr [bp+4]
	mov	ch,byte ptr [bp+6]
	mov	dh,byte ptr [bp+8]
	call	ADC_Dec
	mov	ax,dx
	pop	di
	pop	ds
	pop	bp
	ret

_ADC_10	endp

ADC_Dec	proc	near			; Decimal-mode add

	assume	ds:_TEXT

	mov	di,bx			; Preserve the BX register

	;  --------------------------------
	; | Create decimal result modifier |
	;  --------------------------------

	mov	bl,dl			; BL = .A
	mov	bh,ch			; BH = parameter
	and	bx,0000111100001111b	; Retain low nybbles only
	ror	dh,1			;/ Get carry state from \
	rol	dh,1			;\ flags register image /
	adc	bl,bh			; Add nybbles with carry
	xor	bh,bh			; Extend to 16 bits for indexing

	;  -----------------------------------------
	; | Compute result of decimal-mode addition |
	;  -----------------------------------------

	mov	al,dl			; AL = .A
	shr	dh,1			; Get carry state from flags image
	adc	al,ch			; Add parameters with carry
	lahf				; Preserve processor status flags
	sub	al,DeciAdj[bx]		; Apply modifier to addition result
	sahf				; Restore processor status flags
	daa				; Decimal-adjust addition result
	rcl	dh,1			; Put carry state into flags image

IFNDEF	NoDecimalFlags	;-------------------------------------------------------,
										;
	;  -----------------------------------------				;
	; | Clear flags affected by ADC instruction |				;
	;  -----------------------------------------				;
										;
	and	dh,not (SF_8086 or ZF_8086 or OF_8086)	; SF, ZF and OF		;
										;
	;  ---------------------						;
	; | Get zero flag state |						;
	;  ---------------------						;
										;
	and	ah,ZF_8086		;/ Apply ZF to flags \			;
	or	dh,ah			;\  register image   /			;
										;
 	;  ---------------------						;
	; | Get sign flag state |						;
 	;  ---------------------						;
										;
	mov	bl,al			; BL = result				;
	mov	bh,dh			; BH = flags image			;
	and	bh,CF_8086		; Mask off all but carry flag		;
	shr	bx,4			; Create sign table index		;
	or	dh,SignFlag[bx]		; Apply sign to flags image		;
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
	; |              O = P * ~S               |				;
	; |                                       |				;
	;  ---------------------------------------				;
										;
	xor	ch,dl			; CH(msb) = ~P				;
	not	ch			; CH(msb) = P				;
	xor	dl,dh			; DL(msb) = ~S				;
	and	ch,dl			; CH(msb) = P * ~S			;
										;
	rol	ch,1			;/ Apply overflow \			;
	rol	ch,1			;| to flags image |			;
	and	ch,OF_8086		;|                |			;
	or	dh,ch			;\                /			;
										;
ENDIF	;-----------------------------------------------------------------------'

	;  -----------------------------------------------------
	; | Copy result of decimal mode addition to destination |
	;  -----------------------------------------------------

	mov	dl,al		; .A = result
	mov	bx,di		; Restore the BX register
	ret			; Return to caller

;----------------------------------------------------------------------------

DeciAdj		db	26 dup (0), 6 dup (10h)

IFNDEF	NoDecimalFlags	;-------------------------------------------------------,
										;
SignFlag	db	8 dup (PL)						;
		db	2 dup (MI)						;
		db	6 dup (?)						;
		db	6 dup (MI)						;
		db	8 dup (PL)						;
		db	2 dup (MI)						;
										;
ENDIF	;-----------------------------------------------------------------------'

ADC_Dec	endp
	end
