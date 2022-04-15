        .model  small
        .code

;                  --------------------------------------
;                 |  M  A  T  H  E  M  A  T  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; mathematical operations whose operands are the Accumulator and memory.
;
; These instructions include:
;
;       ADC - Add with Carry
;       SBC - Subtract with Carry
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

include equates.def

extrn   Fetch6502Opcode:abs
extrn   FlagSVZC:abs

;----------------------------------------------------------------------------

AddProc dw      ADC_Bin,0,0,0,ADC_Dec

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |   @   @@@@   @@@@ |
;                          |  @ @  @   @ @     |
;                          | @   @ @   @ @     |
;                          | @@@@@ @   @ @     |
;                          | @   @ @@@@   @@@@ |
;                           -------------------


ADC_2   proc    near            ;______/ Mode 2: immediate addressing \______

        mov     al,ds:[si]      ; AL = immediate data at program counter
        inc     si              ; Advance program counter
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        and     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ADC_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     AddProc[bx]

ADC_F   endp

;----------------------------------------------------------------------------

ADC_Bin proc    near            ; Binary-mode add

        assume  ds:_TEXT

        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        adc     ch,al
        jmp     FlagSVZC        ; Merge flags to complete the cycle

ADC_Bin endp

;----------------------------------------------------------------------------

ADC_Dec proc    near                    ; Decimal-mode add

        assume  ds:_TEXT

        push    di                      ; Preserve the DI register

        ;  --------------------------------
        ; | Create decimal result modifier |
        ;  --------------------------------

        mov     ah,ch                   ; AH = .A
        mov     bl,al                   ; BL = parameter
        and     ax,0000111100001111b    ; Retain low nybbles only
        ror     cl,1                    ;/ Get carry state from \
        rol     cl,1                    ;\ flags register image /
        adc     al,ah                   ; Add nybbles with carry
        cbw                             ; Sign-extend result
        mov     di,ax                   ; DI = decimal modifier index

        ;  -----------------------------------------
        ; | Compute result of decimal-mode addition |
        ;  -----------------------------------------

        mov     al,ch                   ; AL = .A
        shr     cl,1                    ; Get carry state from flags image
        adc     al,bl                   ; Add parameters with carry
        lahf                            ; Preserve processor status flags
        sub     al,DeciAdj[di]          ; Apply modifier to addition result
        sahf                            ; Restore processor status flags
        daa                             ; Decimal-adjust addition result
        rcl     cl,1                    ; Put carry state into flags image

IFNDEF  NoDecimalFlags  ;-------------------------------------------------------,
                                                                                ;
        ;  -----------------------------------------                            ;
        ; | Clear flags affected by ADC instruction |                           ;
        ;  -----------------------------------------                            ;
                                                                                ;
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ; SF, ZF and OF         ;
                                                                                ;
        ;  ---------------------                                                ;
        ; | Get zero flag state |                                               ;
        ;  ---------------------                                                ;
                                                                                ;
        and     ah,ZF_8086              ;/ Apply ZF to flags \                  ;
        or      cl,ah                   ;\  register image   /                  ;
        mov     ah,bl                   ; AH = parameter                        ;
                                                                                ;
        ;  ---------------------                                                ;
        ; | Get sign flag state |                                               ;
        ;  ---------------------                                                ;
                                                                                ;
        mov     bl,al                   ; BL = result                           ;
        mov     bh,cl                   ; BH = flags image                      ;
        and     bh,CF_8086              ; Mask off all but carry flag           ;
        shr     bx,4                    ; Create sign table index               ;
        or      cl,SignFlag[bx]         ; Apply sign to flags image             ;
                                                                                ;
        ;  --------------------------                                           ;
        ; | Determine overflow state |                                          ;
        ;  --------------------------                                           ;
                                                                                ;
        ;                ------------                                           ;
        ;               | DERIVATION |                                          ;
        ;  ---------------------------------------                              ;
        ; | O: operation produced an overflow     |                             ;
        ; | P: both parameters have the same sign |                             ;
        ; | S: sign flag matches parameter signs  |                             ;
        ; |                                       |                             ;
        ; | ------------------------------------- |                             ;
        ; |                                       |                             ;
        ; |              O = P * ~S               |                             ;
        ; |                                       |                             ;
        ;  ---------------------------------------                              ;
                                                                                ;
        xor     ch,ah                   ; CH(msb) = ~P                          ;
        not     ch                      ; CH(msb) = P                           ;
        xor     ah,cl                   ; AH(msb) = ~S                          ;
        and     ah,ch                   ; AH(msb) = P * ~S                      ;
                                                                                ;
        rol     ah,2                    ;/ Apply overflow \                     ;
        and     ah,OF_8086              ;| to flags image |                     ;
        or      cl,ah                   ;\                /                     ;
                                                                                ;
ENDIF   ;-----------------------------------------------------------------------'

        ;  -----------------------------------------------------
        ; | Copy result of decimal mode addition to destination |
        ;  -----------------------------------------------------

        mov     ch,al           ; .A = result

        pop     di              ; Restore the DI register
        jmp     Fetch6502Opcode ; Procede to the next opcode

;----------------------------------------------------------------------------

DeciAdj         db      26 dup (0), 6 dup (10h)

IFNDEF  NoDecimalFlags  ;-------------------------------------------------------,
                                                                                ;
SignFlag        db      8 dup (PL)                                              ;
                db      2 dup (MI)                                              ;
                db      6 dup (?)                                               ;
                db      6 dup (MI)                                              ;
                db      8 dup (PL)                                              ;
                db      2 dup (MI)                                              ;
                                                                                ;
ENDIF   ;-----------------------------------------------------------------------'

ADC_Dec endp

;----------------------------------------------------------------------------

SubProc dw      SBC_Bin,0,0,0,SBC_Dec

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@   @@@@ |
;                          | @     @   @ @     |
;                          |  @@@  @@@@  @     |
;                          |     @ @   @ @     |
;                          | @@@@  @@@@   @@@@ |
;                           -------------------


SBC_2   proc    near            ;______/ Mode 2: immediate addressing \______

        mov     al,ds:[si]      ; AL = immediate data at program counter
        inc     si              ; Advance program counter
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        and     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SBC_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,cl
        and     bx,D_6502
        jmp     SubProc[bx]

SBC_F   endp

;----------------------------------------------------------------------------

SBC_Bin proc    near            ; Binary-mode subtract

        assume  ds:_TEXT

        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        cmc
        sbb     ch,al
        cmc
        jmp     FlagSVZC        ; Merge flags to complete the cycle

SBC_Bin endp

;----------------------------------------------------------------------------

SBC_Dec proc    near                    ; Decimal-mode subtract

        assume  ds:_TEXT

        push    di                      ; Preserve the DI register

        ;  ----------------------------------------------------
        ; | Invert carry state to accomodate 6502 idiosyncrasy |
        ;  ----------------------------------------------------

        xor     cl,CF_8086              ; Invert carry

        ;  --------------------------------
        ; | Create decimal result modifier |
        ;  --------------------------------

        mov     ah,ch                   ; AH = .A
        mov     bl,al                   ; BL = parameter
        and     ax,0000111100001111b    ; Retain low nybbles only
        ror     cl,1                    ;/ Get carry state from \
        rol     cl,1                    ;\ flags register image /
        sbb     al,ah                   ; Subtract nybbles with borrow
        cbw                             ; Sign-extend result
        mov     di,ax                   ; DI = decimal modifier index

        ;  --------------------------------------------
        ; | Compute result of decimal-mode subtraction |
        ;  --------------------------------------------

        mov     al,ch                   ; AL = .A
        shr     cl,1                    ; Get carry state from flags image
        sbb     al,bl                   ; Subtract parameters with carry
        lahf                            ; Preserve processor status flags
        rcl     cl,1                    ; Put carry state into flags image

        sub     al,MinorAdj[di + 10h]   ; Apply minor decimal adjustment

        mov     di,cx                   ;/ DI = carry state \
        and     di,CF_8086              ;\                  /
        sub     al,MajorAdj[di]         ; Apply major decimal adjustment

IFNDEF  NoDecimalFlags  ;-------------------------------------------------------,
                                                                                ;
        ;  -----------------------------------------                            ;
        ; | Clear flags affected by SBC instruction |                           ;
        ;  -----------------------------------------                            ;
                                                                                ;
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ; SF, ZF and OF         ;
                                                                                ;
        ;  -------------------------------                                      ;
        ; | Get sign and zero flag states |                                     ;
        ;  -------------------------------                                      ;
                                                                                ;
        and     ah,(SF_8086 or ZF_8086) ;/  Apply SF and ZF flags  \            ;
        or      cl,ah                   ;\ to flags register image /            ;
                                                                                ;
        ;  --------------------------                                           ;
        ; | Determine overflow state |                                          ;
        ;  --------------------------                                           ;
                                                                                ;
        ;                ------------                                           ;
        ;               | DERIVATION |                                          ;
        ;  ---------------------------------------                              ;
        ; | O: operation produced an overflow     |                             ;
        ; | P: both parameters have the same sign |                             ;
        ; | S: sign flag matches parameter signs  |                             ;
        ; |                                       |                             ;
        ; | ------------------------------------- |                             ;
        ; |                                       |                             ;
        ; |              O = ~P * ~S              |                             ;
        ; |                                       |                             ;
        ;  ---------------------------------------                              ;
                                                                                ;
        xor     ch,bl                   ; CH(msb) = ~P                          ;
        xor     bl,cl                   ; BL(msb) = ~S                          ;
        and     bl,ch                   ; BL(msb) = ~P * ~S                     ;
                                                                                ;
        rol     bl,2                    ;/ Apply overflow \                     ;
        and     bl,OF_8086              ;| to flags image |                     ;
        or      cl,bl                   ;\                /                     ;
                                                                                ;
ENDIF   ;-----------------------------------------------------------------------'

        ;  -----------------------------------------------------
        ; | Copy result of decimal mode addition to destination |
        ;  -----------------------------------------------------

        mov     ch,al           ; .A = result

        ;  ----------------------------------------------------
        ; | Invert carry state to accomodate 6502 idiosyncrasy |
        ;  ----------------------------------------------------

        xor     cl,CF_8086      ; Invert carry

        pop     di              ; Restore the DI register
        jmp     Fetch6502Opcode ; Procede to the next opcode

;----------------------------------------------------------------------------

MajorAdj        db      00h, 60h
MinorAdj        db      6 dup (-10), 10 dup (6), 16 dup (0)

SBC_Dec endp
        end
