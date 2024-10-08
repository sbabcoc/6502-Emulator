        .model  small
        .code

;                  --------------------------------------
;                 |  B  I  T  T  E  S  T  S  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; bit-level test operations on the contents of memory.
;
; These instructions include:
;
;       BIT - Test Memory Bits with Accumulator
;       TRB - Test and Reset Memory Bits with Accumulator
;       TSB - Test and Set Memory Bits with Accumulator
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
;                            -----------------
;                           | @@@@  @@@ @@@@@ |
;                           | @   @  @    @   |
;                           | @@@@   @    @   |
;                           | @   @  @    @   |
;                           | @@@@  @@@   @   |
;                            -----------------


BIT_2   proc    near            ;______/ Mode 2: immediate addressing \______

        mov     al,ds:[si]      ; AL = immediate data at program counter
        inc     si              ; Advance program counter
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BIT_2   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BIT_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        mov     bl,4            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BIT_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BIT_5   proc    near            ;____/ Mode 5: absolute indexed with X \_____

        mov     ah,2            ; Set instruction cycle time
        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        add     bl,dh           ; Add index register X
        jnc     @F              ; Jump if index did not exceed page boundary

        inc     bh              ; Increment page number
        inc     ah              ; Add one clock cycle for boundary crossing

@@:     mov     al,ds:[bx]      ; AL = data at specified location
        mov     bl,ah           ; BL = instruction cycle time
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        jmp     Fetch6502Opcode ; Procede to the next opcode

BIT_5   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BIT_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        mov     bl,3            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BIT_7   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BIT_8   proc    near            ;____/ Mode 8: zero page indexed with X \____

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        add     bl,dh           ; Add index register X
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

BIT_8   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@ @@@@  @@@@  |
;                          |   @   @   @ @   @ |
;                          |   @   @@@@  @@@@  |
;                          |   @   @  @  @   @ |
;                          |   @   @   @ @@@@  |
;                           -------------------


TRB_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        or      ds:[bx],ch      ;/ Reset memory bits \
        xor     ds:[bx],ch      ;\ with Accumulator  /
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

TRB_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

TRB_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        or      ds:[bx],ch      ;/ Reset memory bits \
        xor     ds:[bx],ch      ;\ with Accumulator  /
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

TRB_7   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@@  @@@@ @@@@  |
;                          |   @   @     @   @ |
;                          |   @    @@@  @@@@  |
;                          |   @       @ @   @ |
;                          |   @   @@@@  @@@@  |
;                           -------------------


TSB_4   proc    near            ;______/ Mode 4: absolute addressing \_______

        mov     bx,ds:[si]      ; Get pointer to specified location
        add     si,2            ; Advance program counter
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        or      ds:[bx],ch      ; Set memory bits with Accumulator
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

TSB_4   endp

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

TSB_7   proc    near            ;______/ Mode 7: zero page addressing \______

        mov     bl,ds:[si]      ; Get pointer to specified location
        inc     si              ; Advance program counter
        xor     bh,bh           ; Ensure that MSB equals zero
        mov     al,ds:[bx]      ; AL = data at specified location
        test    ch,al           ; Test memory bits with Accumulator

        lahf                                            ; AH = results of test
        and     ah,ZF_8086                              ; AH = [_z______]

                                                        ; AL = [so......]
        sar     al,5                                    ;      [s---->o.]
        and     al,SF_8086 or OF_8086                   ;      [s_____o_]

        or      ah,al                                   ; AH = [sz____o_]
        and     cl,not (SF_8086 or ZF_8086 or OF_8086)  ;/ Merge result into \
        or      cl,al                                   ;\ 6502 status image /

        or      ds:[bx],ch      ; Set memory bits with Accumulator
        mov     bl,2            ; Set instruction cycle time
        jmp     Fetch6502Opcode ; Procede to the next opcode

TSB_7   endp
        end
