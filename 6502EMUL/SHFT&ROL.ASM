        .model  small
        .code

;                  --------------------------------------
;                 |  S  H  F  T  &  R  O  L  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; shift and roll operations on the contents of memory or the Accumulator.
;
; These instructions include:
;
;       ASL - Arithmetic Shift Left
;       LSR - Logical Shift Right
;       ROL - Roll Left
;       ROR - Roll Right
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
;                          |   @    @@@@ @     |
;                          |  @ @  @     @     |
;                          | @   @  @@@  @     |
;                          | @@@@@     @ @     |
;                          | @   @ @@@@  @@@@@ |
;                           -------------------


ASL_1   proc    near            ;_____/ Mode 1: accumulator addressing \_____

        sal     ch,1            ; Shift Accumulator left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ASL_1   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ASL_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        sal     ds:[bx],1       ; Shift specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ASL_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ASL_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        sal     ds:[bx],1       ; Shift specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ASL_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ASL_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        sal     ds:[bx],1       ; Shift specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ASL_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ASL_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        sal     ds:[bx],1       ; Shift specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ASL_8   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @      @@@@ @@@@  |
;                          | @     @     @   @ |
;                          | @      @@@  @@@@  |
;                          | @         @ @  @  |
;                          | @@@@@ @@@@  @   @ |
;                           -------------------


LSR_1   proc    near            ;_____/ Mode 1: accumulator addressing \_____

        shr     ch,1            ; Shift Accumulator right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

LSR_1   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LSR_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        shr     ds:[bx],1       ; Shift specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

LSR_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LSR_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        shr     ds:[bx],1       ; Shift specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

LSR_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LSR_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        shr     ds:[bx],1       ; Shift specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

LSR_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LSR_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        shr     ds:[bx],1       ; Shift specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

LSR_8   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@   @@@  @     |
;                          | @   @ @   @ @     |
;                          | @@@@  @   @ @     |
;                          | @  @  @   @ @     |
;                          | @   @  @@@  @@@@@ |
;                           -------------------


ROL_1   proc    near            ;_____/ Mode 1: accumulator addressing \_____

        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcl     ch,1            ; Roll Accumulator left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROL_1   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROL_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcl     ds:[bx],1       ; Roll specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROL_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROL_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcl     ds:[bx],1       ; Roll specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROL_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROL_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcl     ds:[bx],1       ; Roll specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROL_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROL_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcl     ds:[bx],1       ; Roll specified location left one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROL_8   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@   @@@  @@@@  |
;                          | @   @ @   @ @   @ |
;                          | @@@@  @   @ @@@@  |
;                          | @  @  @   @ @  @  |
;                          | @   @  @@@  @   @ |
;                           -------------------


ROR_1   proc    near            ;_____/ Mode 1: accumulator addressing \_____

        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcr     ch,1            ; Roll Accumulator right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROR_1   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROR_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcr     ds:[bx],1       ; Roll specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROR_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROR_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcr     ds:[bx],1       ; Roll specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROR_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROR_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcr     ds:[bx],1       ; Roll specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROR_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ROR_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        ror     cl,1            ; Move 6502 Carry into 8086 Carry
        rol     cl,1            ; Restore processor status
        rcr     ds:[bx],1       ; Roll specified location right one bit
        jmp     FlagSZC         ; Merge flags to complete the cycle

ROR_8   endp
        end
