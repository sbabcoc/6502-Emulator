        .model  small
        .code

;                  --------------------------------------
;                 |  T  R  A  N  S  F  E  R  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that transfer
; the contents of one register to another register
;
; These instructions include:
;
;       TXA - Transfer Index Register X to Accumulator
;       TAX - Transfer Accumulator to Index Register X
;       TYA - Transfer Index Register Y to Accumulator
;       TAY - Transfer Accumulator to Index Register Y
;       TXS - Transfer Index Register X to Stack Pointer
;       TSX - Transfer Stack Pointer to Index Register X
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
;                          | @@@@@ @   @   @   |
;                          |   @    @ @   @ @  |
;                          |   @     @   @   @ |
;                          |   @    @ @  @@@@@ |
;                          |   @   @   @ @   @ |
;                           -------------------


TXA_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     ch,dh           ; Move index register X to Accumulator
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

TXA_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@   @   @   @ |
;                          |   @    @ @   @ @  |
;                          |   @   @   @   @   |
;                          |   @   @@@@@  @ @  |
;                          |   @   @   @ @   @ |
;                           -------------------


TAX_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     dh,ch           ; Move Accumulator to index register X
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

TAX_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@ @   @   @   |
;                          |   @    @ @   @ @  |
;                          |   @     @   @   @ |
;                          |   @     @   @@@@@ |
;                          |   @     @   @   @ |
;                           -------------------


TYA_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     ch,dl           ; Move index register Y to Accumulator
        test    ch,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

TYA_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@   @   @   @ |
;                          |   @    @ @   @ @  |
;                          |   @   @   @   @   |
;                          |   @   @@@@@   @   |
;                          |   @   @   @   @   |
;                           -------------------


TAY_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     dl,ch           ; Move Accumulator to index register Y
        test    dl,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

TAY_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@ @   @  @@@@ |
;                          |   @    @ @  @     |
;                          |   @     @    @@@  |
;                          |   @    @ @      @ |
;                          |   @   @   @ @@@@  |
;                           -------------------


TXS_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     al,dh           ; Get copy of index register X
        mov     ah,01           ; Convert to stack pointer format 
        mov     bp,ax           ; Transfer resultant offset to stack pointer

        jmp     Fetch6502Opcode ; Procede to the next opcode

TXS_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@  @@@@ @   @ |
;                          |   @   @      @ @  |
;                          |   @    @@@    @   |
;                          |   @       @  @ @  |
;                          |   @   @@@@  @   @ |
;                           -------------------


TSX_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     ax,bp           ; Get copy of stack pointer
        mov     dh,al           ; Transfer low byte to index register X
        test    dh,-1           ; Set Sign and Zero flags
        jmp     FlagSZ          ; Merge flags to complete the cycle

TSX_0   endp
        end
