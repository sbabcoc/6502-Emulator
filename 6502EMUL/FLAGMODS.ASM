        .model  small
        .code

;                  --------------------------------------
;                 |  F  L  A  G  M  O  D  S  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that process
; opcodes that modify flags in the processor status register.
;
; These instructions include:
;
;       CLC - Clear the Carry Flag
;       CLD - Clear the Decimal Mode Flag
;       CLI - Clear the Interrupt Disable Flag
;       CLV - Clear the Overflow Flag
;       SEC - Set the Carry Flag
;       SED - Set the Decimal Mode Flag
;       SEI - Set the Interrupt Disable Flag
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
;                          |  @@@@ @      @@@@ |
;                          | @     @     @     |
;                          | @     @     @     |
;                          | @     @     @     |
;                          |  @@@@ @@@@@  @@@@ |
;                           -------------------


CLC_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        and     cl,not C_6502   ; Clear the Carry Flag
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

CLC_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @     @@@@  |
;                          | @     @     @   @ |
;                          | @     @     @   @ |
;                          | @     @     @   @ |
;                          |  @@@@ @@@@@ @@@@  |
;                           -------------------


CLD_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        and     cl,not D_6502   ; Clear the Decimal Mode Flag
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

CLD_0   endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           |  @@@@ @     @@@ |
;                           | @     @      @  |
;                           | @     @      @  |
;                           | @     @      @  |
;                           |  @@@@ @@@@@ @@@ |
;                            -----------------


CLI_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        and     cl,not I_6502   ; Clear the Interrupt Disable Flag
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

CLI_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @     @   @ |
;                          | @     @     @   @ |
;                          | @     @     @   @ |
;                          | @     @      @ @  |
;                          |  @@@@ @@@@@   @   |
;                           -------------------


CLV_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        and     cl,not OF_8086  ; Use 8086 Overflow Flag definition
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

CLV_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@@  @@@@ |
;                          | @     @     @     |
;                          |  @@@  @@@@  @     |
;                          |     @ @     @     |
;                          | @@@@  @@@@@  @@@@ |
;                           -------------------


SEC_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        or      cl,C_6502       ; Set the Carry Flag
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

SEC_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          |  @@@@ @@@@@ @@@@  |
;                          | @     @     @   @ |
;                          |  @@@  @@@@  @   @ |
;                          |     @ @     @   @ |
;                          | @@@@  @@@@@ @@@@  |
;                           -------------------


SED_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        or      cl,D_6502       ; Set the Decimal Mode Flag
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

SED_0   endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           |  @@@@ @@@@@ @@@ |
;                           | @     @      @  |
;                           |  @@@  @@@@   @  |
;                           |     @ @      @  |
;                           | @@@@  @@@@@ @@@ |
;                            -----------------


SEI_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        or      cl,I_6502       ; Set the Interrupt Disable Flag
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

SEI_0   endp
        end
