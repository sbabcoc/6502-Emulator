        .model  small
        .code

;                  --------------------------------------
;                 |  S  T  A  K  P  R  O  C  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that "stack"
; and "unstack" the Accumulator and Processor Status register
;
; These instructions include:
;
;       PHA - Push Accumulator to Stack
;       PLA - Pull Accumulator from Stack
;       PHP - Push Processor Status to Stack
;       PLP - Pull Processor Status from Stack
;       PHX - Push Index Register X to Stack
;       PLX - Pull Index Register X from Stack
;       PHY - Push Index Register Y to Stack
;       PLY - Pull Index Register Y from Stack
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

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @   @   |
;                          | @   @ @   @  @ @  |
;                          | @@@@  @@@@@ @   @ |
;                          | @     @   @ @@@@@ |
;                          | @     @   @ @   @ |
;                           -------------------


PHA_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     ds:[bp],ch      ; Store Accumulator at stack pointer
        dec     bp              ; Decrement stack pointer
        or      bp,0100h        ; Ensure stack remains on Page 1

        mov     bl,3            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PHA_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @       @   |
;                          | @   @ @      @ @  |
;                          | @@@@  @     @   @ |
;                          | @     @     @@@@@ |
;                          | @     @@@@@ @   @ |
;                           -------------------


PLA_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     bx,bp           ; BX = current stack pointer
        inc     bl              ; Increment stack pointer
        mov     bp,bx           ; Update stack pointer
        mov     ch,ds:[bp]      ; Load Accumulator at stack pointer

        mov     bl,4            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PLA_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @ @@@@  |
;                          | @   @ @   @ @   @ |
;                          | @@@@  @@@@@ @@@@  |
;                          | @     @   @ @     |
;                          | @     @   @ @     |
;                           -------------------


PHP_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     al,cl                   ; Get copy of Processor Status
        test    al,ZF_8086 or OF_8086   ; Test swapped flag states
        jpe     @F                      ; States are identical - do nothing

        xor     al,ZF_8086 or OF_8086   ; Invert status flag states to swap

@@:     mov     ds:[bp],al      ; Store Processor Status at stack pointer
        dec     bp              ; Decrement stack pointer
        or      bp,0100h        ; Ensure stack remains on Page 1

        mov     bl,3            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PHP_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @     @@@@  |
;                          | @   @ @     @   @ |
;                          | @@@@  @     @@@@  |
;                          | @     @     @     |
;                          | @     @@@@@ @     |
;                           -------------------


PLP_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     bx,bp           ; BX = current stack pointer
        inc     bl              ; Increment stack pointer
        mov     bp,bx           ; Update stack pointer
        mov     cl,ds:[bp]      ; Load Processor Status at stack pointer

        test    cl,ZF_8086 or OF_8086   ; Test swapped flag states
        jpe     @F                      ; States are identical - do nothing

        xor     cl,ZF_8086 or OF_8086   ; Invert status flag states to swap

@@:     mov     bl,4            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PLP_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @ @   @ |
;                          | @   @ @   @  @ @  |
;                          | @@@@  @@@@@   @   |
;                          | @     @   @  @ @  |
;                          | @     @   @ @   @ |
;                           -------------------


PHX_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     ds:[bp],dh      ; Store Index Register X at stack pointer
        dec     bp              ; Decrement stack pointer
        or      bp,0100h        ; Ensure stack remains on Page 1

        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PHX_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @     @   @ |
;                          | @   @ @      @ @  |
;                          | @@@@  @       @   |
;                          | @     @      @ @  |
;                          | @     @@@@@ @   @ |
;                           -------------------


PLX_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     bx,bp           ; BX = current stack pointer
        inc     bl              ; Increment stack pointer
        mov     bp,bx           ; Update stack pointer
        mov     dh,ds:[bp]      ; Load Index Register X at stack pointer

        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PLX_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @   @ @   @ |
;                          | @   @ @   @  @ @  |
;                          | @@@@  @@@@@   @   |
;                          | @     @   @   @   |
;                          | @     @   @   @   |
;                           -------------------


PHY_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     ds:[bp],dl      ; Store Index Register Y at stack pointer
        dec     bp              ; Decrement stack pointer
        or      bp,0100h        ; Ensure stack remains on Page 1

        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PHY_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @     @   @ |
;                          | @   @ @      @ @  |
;                          | @@@@  @       @   |
;                          | @     @       @   |
;                          | @     @@@@@   @   |
;                           -------------------


PLY_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     bx,bp           ; BX = current stack pointer
        inc     bl              ; Increment stack pointer
        mov     bp,bx           ; Update stack pointer
        mov     dl,ds:[bp]      ; Load Index Register Y at stack pointer

        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

PLY_0   endp
        end
