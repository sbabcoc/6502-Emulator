        .model  small
        .code

;                  --------------------------------------
;                 |  I  N  T  R  U  P  T  S  .  A  S  M  |
;                  --------------------------------------
;
; This module contains code which emulates the 6502 instructions that perform
; interrupt service operations.
;
; These instructions include:
;
;       BRK - Force Break
;       RTI - Return from Interrupt
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

extrn   Fetch6502Opcode:abs

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @@@@  @@@@@ @@@ |
;                           | @   @   @    @  |
;                           | @@@@    @    @  |
;                           | @  @    @    @  |
;                           | @   @   @   @@@ |
;                            -----------------

RTI_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        mov     bx,bp           ; BX = current stack pointer
        inc     bl              ; Increment stack pointer
        mov     cl,ds:[bx]      ; Load Processor Status at stack pointer
        and     cl,not B_6502   ; Clear "break" indicator

        ;------ Set status flags: ------,
        test    cl,ZF_8086 or OF_8086   ; Test swapped flag states
        jpe     @F                      ; States are identical - do nothing

        xor     cl,ZF_8086 or OF_8086   ; Invert status flag states to swap

@@:     inc     bl              ; Increment stack pointer
        mov     al,ds:[bx]      ; Load LSB of return address at stack pointer
        inc     bl              ; Increment stack pointer
        mov     ah,ds:[bx]      ; Load MSB of return address at stack pointer
        mov     bp,bx           ; Update stack pointer
        mov     si,ax           ; Load Program counter with return address
        jmp     Fetch6502Opcode ; Procede to the next opcode

RTI_0   endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@   @@@@ @@@@@ |
;                          | @   @ @       @   |
;                          | @@@@   @@@    @   |
;                          | @  @      @   @   |
;                          | @   @ @@@@    @   |
;                           -------------------

RST     proc    near

        or      cl,I_6502       ; Set the Interrupt Disable Flag
        mov     si,resetVector  ; Load Program Counter with Reset Vector
        jmp     Fetch6502Opcode ; Procede to the next opcode

RST     endp

;----------------------------------------------------------------------------
;
;                           -------------------
;                          | @@@@  @@@@  @   @ |
;                          | @   @ @   @ @  @  |
;                          | @@@@  @@@@  @@@   |
;                          | @   @ @  @  @  @  |
;                          | @@@@  @   @ @   @ |
;                           -------------------

BRK_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        inc     si              ; Increment program counter
        or      cl,B_6502       ; Set "break" indicator

                                ; Fall thru to nested IRQ proc

IRQ     proc   near

        call    SaveContext
        mov     si,irqVector    ; Load Program Counter with IRQ Vector
        jmp     Fetch6502Opcode ; Procede to the next opcode

IRQ     endp
BRK_0   endp

;----------------------------------------------------------------------------
;
;                            -----------------
;                           | @   @ @   @ @@@ |
;                           | @@  @ @@ @@  @  |
;                           | @ @ @ @ @ @  @  |
;                           | @  @@ @   @  @  |
;                           | @   @ @   @ @@@ |
;                            -----------------

NMI_0   proc    near            ;_______/ Mode 0: implied addressing \_______

        call    SaveContext
        mov     si,nmiVector    ; Load Program Counter with NMI Vector
        jmp     Fetch6502Opcode ; Procede to the next opcode

NMI_0   endp

;----------------------------------------------------------------------------

SaveContext     proc    near

        mov     bx,bp           ; BX = current stack pointer
        mov     ax,si           ; AX = current program counter
        mov     ds:[bx],ah      ; Store MSB of return address at stack pointer
        dec     bl              ; Decrement stack pointer
        mov     ds:[bx],al      ; Store LSB of return address at stack pointer
        dec     bl              ; Decrement stack pointer

        ;------ Set status flags: ------,
        mov     al,cl                   ; Get copy of Processor Status
        test    al,ZF_8086 or OF_8086   ; Test swapped flag states
        jpe     @F                      ; States are identical - do nothing

        xor     al,ZF_8086 or OF_8086   ; Invert status flag states to swap

@@:     mov     ds:[bx],al      ; Store Processor Status at stack pointer
        dec     bl              ; Decrement stack pointer
        mov     bp,bx           ; Update stack pointer

        ; Clear Decimal Mode Flag and "break" indicator
        and     cl,not (D_6502 or B_6502)

        or      cl,I_6502       ; Set the Interrupt Disable Flag
        ret

SaveContext     endp
        end

