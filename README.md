# 6502-Emulator
This repository contains Intel x86 code to emulate the instruction set of the 6502 processor. In its current state, this repository lacks the implementation to fetch, decode, and process each instruction.

The source is compatible with Microsoft Macro-Assembler 5.1

> NOTE: The locations of the Zero and Overflow flags are swapped in the 6502
>       status register image maintained in the _F register.  This is done so
>       that the process of merging the 8086 flag states into the 6502 status
>       register image will be as efficient as possible.
>
>       The procedures for the PHP (Push processor status on stack) and PLP
>       (Pull processor status from stack) instructions need to accommodate
>       the transposition of the Zero and Overflow flags from their defined
>       6502 positions when storing to or loading from the 6502 stack.
>
>                      ---------------------------
>                     | TO SWAP ZERO AND OVERFLOW |
>                ---------------------------------------
>               |       test    cl,ZF_8086 or OF_8086   |
>               |       jpe     @F                      |
>               |                                       |
>               |       xor     cl,ZF_8086 or OF_8086   |
>               |                                       |
>               |@@:                                    |
>                ---------------------------------------

