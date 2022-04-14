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
;       _@ - Base execution cycles for instruction (from TIMETAB.ASM)

include equates.def
include proc_abs.def

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
        jmp     Fetch6502Opcode ; Procede to the next opcode

SEI_0   endp
        end
