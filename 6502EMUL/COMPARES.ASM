        .model  small
        .code

;                  --------------------------------------
;                 |  C  O  M  P  A  R  E  S  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; comparison operations on the Accumulator and Index Registers.
;
; These instructions include:
;
;       CMP - Compare Memory and Accumulator
;       CPX - Compare Memory and Index X
;       CPY - Compare Memory and Index Y
;
; Upon entry, the following register conventions apply:
;
;       ch - Accumulator
;       dh - Index Register X
;       dl - Index Register Y
;       SI - Program Counter
;       BP - Stack Pointer
;       cl - Processor Status Register

include equates.def

extrn   FlagSZC:abs

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @   @ @@@@  |
;                          | @     @@ @@ @   @ |
;                          | @     @ @ @ @@@@  |
;                          | @     @   @ @     |
;                          |  @@@@ @   @ @     |
;                           -------------------


CMP_2   proc    near            ;______/ Mode 2: immediate addressing \______

        inc     si              ; Advance program counter
        cmp     ch,ds:[si - 1]  ; Compare with data at previous location
        mov     bl,2            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,4            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     ah,4            ; Set instruction cycle time
        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     ah              ; Add one clock cycle for boundary crossing

@@:     cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,ah           ; BL = instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     ah,4            ; Set instruction cycle time
        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     ah              ; Add one clock cycle for boundary crossing

@@:     cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,ah           ; BL = instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,3            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,4            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,2            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,6            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CMP_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     ah,5            ; Set instruction cycle time
        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     ah              ; Add one cycle for boundary crossing

@@:     cmp     ch,ds:[bx]      ; Compare with data at specified location
        mov     bl,ah           ; BL = instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CMP_F   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@  @   @ |
;                          | @     @   @  @ @  |
;                          | @     @@@@    @   |
;                          | @     @      @ @  |
;                          |  @@@@ @     @   @ |
;                           -------------------


CPX_2   proc    near            ;______/ Mode 2: immediate addressing \______

        inc     si              ; Advance program counter
        cmp     dh,ds:[si - 1]  ; Compare with data at previous location
        mov     bl,2            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CPX_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CPX_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        cmp     dh,ds:[bx]      ; Compare with data at specified location
        mov     bl,4            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CPX_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CPX_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        cmp     dh,ds:[bx]      ; Compare with data at specified location
        mov     bl,3            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CPX_7   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@  @   @ |
;                          | @     @   @  @ @  |
;                          | @     @@@@    @   |
;                          | @     @       @   |
;                          |  @@@@ @       @   |
;                           -------------------


CPY_2   proc    near            ;______/ Mode 2: immediate addressing \______

        inc     si              ; Advance program counter
        cmp     dl,ds:[si - 1]  ; Compare with data at previous location
        mov     bl,2            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CPY_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CPY_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        cmp     dl,ds:[bx]      ; Compare with data at specified location
        mov     bl,4            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CPY_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CPY_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        cmp     dl,ds:[bx]      ; Compare with data at specified location
        mov     bl,3            ; Set instruction cycle time
        jmp     FlagSZC         ; Merge flags to complete the cycle

CPY_7   endp
        end
