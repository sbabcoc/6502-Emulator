        .model  small
        .code

;                  --------------------------------------
;                 |  L  O  A  D  S  T  O  R  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that either
; load or store values in reference to a specific register.
;
; These instructions include:
;
;       LDA - Load Accumulator
;       LDX - Load Index Register X
;       LDY - Load Index Register Y
;       STA - Store Accumulator
;       STX - Store Index Register X
;       STY - Store Index Register Y
;       STZ - Store Zero
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
include proc_abs.def

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @     @@@@    @   |
;                          | @     @   @  @ @  |
;                          | @     @   @ @   @ |
;                          | @     @   @ @@@@@ |
;                          | @@@@@ @@@@  @   @ |
;                           -------------------


LDA_2   proc    near            ;______/ Mode 2: immediate addressing \______

        mov     ch,ds:[si]      ; Load immediate data at program counter
        inc     si              ; Advance program counter
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDA_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDA_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDA_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDA_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDA_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDA_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDA_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDA_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDA_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        mov     ch,ds:[bx]      ; Load data at specified location
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDA_F   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @     @@@@  @   @ |
;                          | @     @   @  @ @  |
;                          | @     @   @   @   |
;                          | @     @   @  @ @  |
;                          | @@@@@ @@@@  @   @ |
;                           -------------------


LDX_2   proc    near            ;______/ Mode 2: immediate addressing \______

        mov     dh,ds:[si]      ; Load immediate data at program counter
        inc     si              ; Advance program counter
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDX_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDX_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     dh,ds:[bx]      ; Load data at specified location
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDX_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDX_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     dh,ds:[bx]      ; Load data at specified location
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDX_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDX_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     dh,ds:[bx]      ; Load data at specified location
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDX_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDX_9   proc    near            ;____/ Mode 9: zero page indexed with Y \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dl           ; Add index register Y
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     dh,ds:[bx]      ; Load data at specified location
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDX_9   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @     @@@@  @   @ |
;                          | @     @   @  @ @  |
;                          | @     @   @   @   |
;                          | @     @   @   @   |
;                          | @@@@@ @@@@    @   |
;                           -------------------


LDY_2   proc    near            ;______/ Mode 2: immediate addressing \______

        mov     dl,ds:[si]      ; Load immediate data at program counter
        inc     si              ; Advance program counter
        test    dl,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDY_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDY_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     dl,ds:[bx]      ; Load data at specified location
        test    dl,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

LDY_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDY_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     dl,ds:[bx]      ; Load data at specified location
        test    dl,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDY_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDY_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     dl,ds:[bx]      ; Load data at specified location
        test    dl,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDY_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LDY_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     dl,ds:[bx]      ; Load data at specified location
        test    dl,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete cycle

LDY_8   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@@   @   |
;                          | @       @    @ @  |
;                          |  @@@    @   @   @ |
;                          |     @   @   @@@@@ |
;                          | @@@@    @   @   @ |
;                           -------------------


STA_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_6   proc    near            ;____/ Mode 6: absolute indexed with Y \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_6   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_8   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_D   proc    near            ;_______/ Mode D: zero page indirect \_______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_D   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_E   proc    near            ;______/ Mode E: pre-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load effective address
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_E   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STA_F   proc    near            ;_____/ Mode F: post-indexed indirect \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     bx,ds:[bx]      ; Load base for effective address
        adc     bl,dl           ; Add index register Y
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one cycle for boundary crossing

@@:
        mov     ds:[bx],ch      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STA_F   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@@ @   @ |
;                          | @       @    @ @  |
;                          |  @@@    @     @   |
;                          |     @   @    @ @  |
;                          | @@@@    @   @   @ |
;                           -------------------


STX_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     ds:[bx],dh      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STX_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STX_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ds:[bx],dh      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STX_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STX_9   proc    near            ;____/ Mode 9: zero page indexed with Y \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dl           ; Add index register Y
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ds:[bx],dh      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STX_9   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@@ @   @ |
;                          | @       @    @ @  |
;                          |  @@@    @     @   |
;                          |     @   @     @   |
;                          | @@@@    @     @   |
;                           -------------------


STY_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     ds:[bx],dl      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STY_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STY_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ds:[bx],dl      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STY_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STY_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     ds:[bx],dl      ; Store data at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STY_8   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@@ @@@@@ |
;                          | @       @      @  |
;                          |  @@@    @     @   |
;                          |     @   @    @    |
;                          | @@@@    @   @@@@@ |
;                           -------------------


STZ_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     .B ds:[bx],0    ; Store zero at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STZ_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STZ_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     _@              ; Add one clock cycle for boundary crossing

@@:
        mov     .B ds:[bx],0    ; Store zero at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STZ_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STZ_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     .B ds:[bx],0    ; Store zero at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STZ_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STZ_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     .B ds:[bx],0    ; Store zero at specified location

        jmp     Fetch6502Opcode ; Procede to the next opcode

STZ_8   endp
        end
