        .model  small
        .code

;                  --------------------------------------
;                 |  F  L  A  G  P  R  O  C  .  A  S  M  |
;                  --------------------------------------
;
; This module contains procedures to maintain the contents of the 6502 status
; register.  The flags processed here are those affected by arithmetic and
; logical operations: Sign, Overflow, Zero and Carry.  The other three flags
; (Break, Decimal Mode and Interrupt) and direct setting/resetting of Carry
; and Overflow are handled in the corresponding opcode procedures.
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

FlagSZ          proc    near    ; Merge SF & ZF into 6502 status

        lahf                    ; AH = 8086 processor status

        and     ah,SF_8086 or ZF_8086           ;/ Merge 8086 SF & ZF \
        and     cl,not (SF_8086 or ZF_8086)     ;|  into 6502 status  |
        or      cl,ah                           ;\   register image   /

        jmp     Fetch6502Opcode ; Procede to the next opcode

FlagSZ          endp

;----------------------------------------------------------------------------

FlagSZC proc    near            ; Merge SF, ZF & CF into 6502 status

        lahf                    ; AH = 8086 processor status

        and     ah,SF_8086 or ZF_8086 or CF_8086        ;/ Merge SF, ZF & CF \
        and     cl,not (SF_8086 or ZF_8086 or CF_8086)  ;| into 6502 status  |
        or      cl,ah                                   ;\  register image   /

        jmp     Fetch6502Opcode ; Procede to the next opcode

FlagSZC endp

;----------------------------------------------------------------------------

FlagSVZC        proc    near    ; Merge SF, OF, ZF & CF into 6502 status

        lahf                    ; AH = 8086 processor status

        ;---- Load default mask for 8086 flags image ---,
        mov     al,SF_8086 or ZF_8086 or CF_8086        ; AL = default mask
        jno     @F                                      ;/ If no overflow, \
                                                        ;\    merge now    /

        or      ax,OF_8086 shl 8 or OF_8086     ; Set OF in mask and image

        ;-- Merge 8086 SF, OF, ZF & CF into 6502 status register image -,
@@:     and     ah,al                                                   ;
        and     cl,not (SF_8086 or OF_8086 or ZF_8086 or CF_8086)       ;
        or      cl,ah                                                   ;

        jmp     Fetch6502Opcode ; Procede to the next opcode

FlagSVZC        endp
                end
