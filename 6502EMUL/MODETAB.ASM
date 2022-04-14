        .model  small
        .data

;                   -----------------------------------
;                  |  M  O  D  E  T  A  B  .  A  S  M  |
;                   -----------------------------------
;
; The following is a table that defines the addressing mode of each opcode in
; the entire 6502 instruction set.
;
;       Addressing mode:
;         0 - Implied
;         1 - Accumulator
;         2 - Immediate
;         3 - Relative
;         4 - Absolute
;         5 - Absolute Indexed with X
;         6 - Absolute Indexed with Y
;         7 - Zero Page
;         8 - Zero Page Indexed with X
;         9 - Zero Page Indexed with Y
;         A - Absolute Indirect
;         B - Absolute Indirect, Pre-indexed with X
;         C - Absolute Indirect, Post-indexed with Y
;         D - Zero Page Indirect
;         E - Zero Page Indirect, Pre-indexed with X
;         F - Zero Page Indirect, Post-indexed with Y
;
; NOTES: Mode 'C' is defined only to fill a gap in the sequence.  There is
;        currently no 6502 instruction that uses this mode.
;
;        Addressing mode implies instruction length, so this information
;        is omitted.

ModeTab label   byte

;-----------------------------------------------------------------------,
;        0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F  ;
;-----------------------------------------------------------------------;---,
db      00h,0Eh,00h,00h,00h,07h,07h,00h,00h,02h,01h,00h,00h,04h,04h,00h ; 0 ;
db      03h,0Fh,00h,00h,00h,08h,08h,00h,00h,06h,00h,00h,00h,05h,05h,00h ; 1 ;
db      04h,0Eh,00h,00h,07h,07h,07h,00h,00h,02h,01h,00h,04h,04h,04h,00h ; 2 ;
db      03h,0Fh,00h,00h,00h,08h,08h,00h,00h,06h,00h,00h,00h,05h,05h,00h ; 3 ;
db      00h,0Eh,00h,00h,00h,07h,07h,00h,00h,02h,01h,00h,04h,04h,04h,00h ; 4 ;
db      03h,0Fh,00h,00h,00h,08h,08h,00h,00h,06h,00h,00h,00h,05h,05h,00h ; 5 ;
db      00h,0Eh,00h,00h,00h,07h,07h,00h,00h,02h,01h,00h,0Ah,04h,04h,00h ; 6 ;
db      03h,0Fh,00h,00h,00h,08h,08h,00h,00h,06h,00h,00h,00h,05h,05h,00h ; 7 ;
db      00h,0Eh,00h,00h,07h,07h,07h,00h,00h,00h,00h,00h,04h,04h,04h,00h ; 8 ;
db      03h,0Fh,00h,00h,08h,08h,09h,00h,00h,06h,00h,00h,00h,05h,00h,00h ; 9 ;
db      02h,0Eh,02h,00h,07h,07h,07h,00h,00h,02h,00h,00h,04h,04h,04h,00h ; A ;
db      03h,0Fh,00h,00h,08h,08h,09h,00h,00h,06h,00h,00h,05h,05h,06h,00h ; B ;
db      02h,0Eh,00h,00h,07h,07h,07h,00h,00h,02h,00h,00h,04h,04h,04h,00h ; C ;
db      03h,0Fh,00h,00h,00h,08h,08h,00h,00h,06h,00h,00h,00h,05h,05h,00h ; D ;
db      02h,0Eh,00h,00h,07h,07h,07h,00h,00h,02h,00h,00h,04h,04h,04h,00h ; E ;
db      03h,0Fh,00h,00h,00h,08h,08h,00h,00h,06h,00h,00h,00h,05h,05h,00h ; F ;
;-----------------------------------------------------------------------'---'

end
