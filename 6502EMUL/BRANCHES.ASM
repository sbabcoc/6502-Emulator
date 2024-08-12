        .model  small
        .code

;                  --------------------------------------
;                 |  B  R  A  N  C  H  E  S  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that process
; relative branch opcodes.
;
; These instructions include:
;
;       BRA - Branch Always
;       BCC - Branch on Carry Clear
;       BCS - Branch on Carry Set
;       BEQ - Branch on Result Zero
;       BMI - Branch on Result Minus
;       BNE - Branch on Result Not Zero
;       BPL - Branch on Result Plus
;       BVC - Branch on Overflow Clear
;       BVS - Branch on Overflow Set
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
; NOTE: The locations of the Zero and Overflow flags are swapped in the 6502
;       status register image maintained in the _F register.  This is done so
;       that the process of merging the 8086 flag states into the 6502 status
;       register image will be as efficient as possible.
;
;       The procedures for the PHP (Push processor status on stack) and PLP
;       (Pull processor status from stack) instructions need to accommodate
;       the transposition of the Zero and Overflow flags from their defined
;       6502 positions when storing to or loading from the 6502 stack.
;
;                      ---------------------------
;                     | TO SWAP ZERO AND OVERFLOW |
;                ---------------------------------------
;               |       test    cl,ZF_8086 or OF_8086   |
;               |       jpe     @F                      |
;               |                                       |
;               |       xor     cl,ZF_8086 or OF_8086   |
;               |                                       |
;               |@@:                                    |
;                ---------------------------------------

include equates.def

extrn   Fetch6502Opcode:abs

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@    @   |
;                          | @   @ @   @  @ @  |
;                          | @@@@  @@@@  @   @ |
;                          | @   @ @  @  @@@@@ |
;                          | @@@@  @   @ @   @ |
;                           -------------------


BRA_3   proc    near            ;______/ Mode 3: relative addressing \_______

        mov     bl,3            ; Set instruction cycle time
        mov     al,ds:[si]      ; Load relative offset into AL
        cbw                     ; Sign-extend offset to fill AX
        inc     si              ; Increment the program counter
        xchg    ax,si           ; Move program counter to AX, save offset
        add     si,ax           ; Add program counter to relative offset
        xor     al,al           ; Clear LSB of previous program counter value
        xor     ax,si           ; Did program counter cross a page boundary?
        jz      @F              ; No, procede to the next instruction

        inc     bl              ; Add one cycle for page boundary crossing

@@:     jmp     Fetch6502Opcode ; Procede to the next opcode

BRA_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@   @@@@  @@@@ |
;                          | @   @ @     @     |
;                          | @@@@  @     @     |
;                          | @   @ @     @     |
;                          | @@@@   @@@@  @@@@ |
;                           -------------------


BCC_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,CF_8086      ; Is the carry flag clear?
        jz      BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BCC_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@   @@@@  @@@@ |
;                          | @   @ @     @     |
;                          | @@@@  @      @@@  |
;                          | @   @ @         @ |
;                          | @@@@   @@@@ @@@@  |
;                           -------------------


BCS_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,CF_8086      ; Is the carry flag set?
        jnz     BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BCS_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@@  @@@  |
;                          | @   @ @     @   @ |
;                          | @@@@  @@@@  @   @ |
;                          | @   @ @     @  @  |
;                          | @@@@  @@@@@  @@ @ |
;                           -------------------


BEQ_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,ZF_8086      ; Is the zero flag set?
        jnz     BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BEQ_3   endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@@  @   @ @@@ |
;                           | @   @ @@ @@  @  |
;                           | @@@@  @ @ @  @  |
;                           | @   @ @   @  @  |
;                           | @@@@  @   @ @@@ |
;                            -----------------


BMI_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,SF_8086      ; Is the sign flag set?
        jnz     BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BMI_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @ @@@@@ |
;                          | @   @ @@  @ @     |
;                          | @@@@  @ @ @ @@@@  |
;                          | @   @ @  @@ @     |
;                          | @@@@  @   @ @@@@@ |
;                           -------------------


BNE_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,ZF_8086      ; Is the zero flag clear?
        jz      BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BNE_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@  @     |
;                          | @   @ @   @ @     |
;                          | @@@@  @@@@  @     |
;                          | @   @ @     @     |
;                          | @@@@  @     @@@@@ |
;                           -------------------


BPL_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,SF_8086      ; Is the sign flag clear?
        jz      BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BPL_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @  @@@@ |
;                          | @   @ @   @ @     |
;                          | @@@@  @   @ @     |
;                          | @   @  @ @  @     |
;                          | @@@@    @    @@@@ |
;                           -------------------


BVC_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,OF_8086      ; Is the overflow flag clear?
        jz      BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BVC_3   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @  @@@@ |
;                          | @   @ @   @ @     |
;                          | @@@@  @   @  @@@  |
;                          | @   @  @ @      @ |
;                          | @@@@    @   @@@@  |
;                           -------------------


BVS_3   proc    near            ;______/ Mode 3: relative addressing \_______

        test    cl,OF_8086      ; Is the overflow flag set?
        jnz     BRA_3           ; Yes, perform branch operations

        inc     si              ; Increment the program counter
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BVS_3   endp
        end
