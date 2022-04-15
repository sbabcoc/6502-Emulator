        .model  small
        .code

;                   -----------------------------------
;                  |  B  O  O  L  E  A  N  .  A  S  M  |
;                   -----------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; boolean operations on the Accumulator.
;
; These instructions include:
;
;       AND - "AND" Memory with Accumulator
;       EOR - "Exclusive-OR" Memory with Accumulator
;       ORA - "OR" Memory with Accumulator
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

extrn   FlagSZ:abs

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |   @   @   @ @@@@  |
;                          |  @ @  @@  @ @   @ |
;                          | @   @ @ @ @ @   @ |
;                          | @@@@@ @  @@ @   @ |
;                          | @   @ @   @ @@@@  |
;                           -------------------


AND_2   proc    near            ;______/ Mode 2: immediate addressing \______

        inc     si              ; Advance program counter
        and     ch,ds:[si - 1]  ; "AND" with data at previous location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AND_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        and     ch,ds:[bx]      ; "AND" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

AND_F   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@  @@@  @@@@  |
;                          | @     @   @ @   @ |
;                          | @@@@  @   @ @@@@  |
;                          | @     @   @ @  @  |
;                          | @@@@@  @@@  @   @ |
;                           -------------------


EOR_2   proc    near            ;______/ Mode 2: immediate addressing \______

        inc     si              ; Advance program counter
        xor     ch,ds:[si - 1]  ; "EOR" with data at previous location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EOR_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        xor     ch,ds:[bx]      ; "EOR" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

EOR_F   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@  @@@@    @   |
;                          | @   @ @   @  @ @  |
;                          | @   @ @@@@  @   @ |
;                          | @   @ @  @  @@@@@ |
;                          |  @@@  @   @ @   @ |
;                           -------------------


ORA_2   proc    near            ;______/ Mode 2: immediate addressing \______

        inc     si              ; Advance program counter
        or      ch,ds:[si - 1]  ; "ORA" with data at previous location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ORA_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        or      ch,ds:[bx]      ; "ORA" with data at specified location
        jmp     FlagSZ          ; Merge flags to complete the cycle

ORA_F   endp
        end
