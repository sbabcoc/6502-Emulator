	.model	small
	.data

;                   -----------------------------------
;                  |  M  O  D  E  T  A  B  .  A  S  M  |
;                   -----------------------------------
;
; The following is a table describing the attributes of the entire 6502
; instruction set.  Each byte represents an opcode in the following way:
;
;           [xxxx....]  Base instruction execution cycles
;           [....xxxx]  Addressing mode:
;                         0 - Implied
;                         1 - Accumulator
;                         2 - Immediate
;                         3 - Relative
;                         4 - Absolute
;                         5 - Absolute Indexed with X
;                         6 - Absolute Indexed with Y
;                         7 - Zero Page
;                         8 - Zero Page Indexed with X
;                         9 - Zero Page Indexed with Y
;                         A - Absolute Indirect
;                         B - Absolute Indirect, Pre-indexed with X
;                         C - Absolute Indirect, Post-indexed with Y
;                         D - Zero Page Indirect
;                         E - Zero Page Indirect, Pre-indexed with X
;                         F - Zero Page Indirect, Post-indexed with Y
;
; NOTES: Mode 'C' is defined only to fill a gap in the sequence.  There is
;        currently no 6502 instruction that uses this mode.
;
;        Some instructions have additional execution cycles if an indexing
;        operation crosses a page boundary or if a conditional branch is
;        taken.  Base execution cycles do not account for this fact.
;
;        Addressing mode implies instruction length, so this information
;        is omitted.

ModeTab	label	byte

;        0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
;-----------------------------------------------------------------------,
db	70h,6Eh,20h,20h,20h,37h,57h,20h,30h,22h,21h,20h,20h,44h,64h,20h	; 0
db	23h,5Fh,20h,20h,20h,48h,68h,20h,20h,46h,20h,20h,20h,45h,75h,20h	; 1
db	64h,6Eh,20h,20h,37h,37h,57h,20h,40h,22h,21h,20h,44h,44h,64h,20h	; 2
db	23h,5Fh,20h,20h,20h,48h,68h,20h,20h,46h,20h,20h,20h,45h,75h,20h	; 3
db	60h,6Eh,20h,20h,20h,37h,57h,20h,30h,22h,21h,20h,34h,44h,64h,20h	; 4
db	23h,5Fh,20h,20h,20h,48h,68h,20h,20h,46h,20h,20h,20h,45h,75h,20h	; 5
db	60h,6Eh,20h,20h,20h,37h,57h,20h,40h,22h,21h,20h,5Ah,44h,64h,20h	; 6
db	23h,5Fh,20h,20h,20h,48h,68h,20h,20h,46h,20h,20h,20h,45h,75h,20h	; 7
db	20h,6Eh,20h,20h,37h,37h,37h,20h,20h,20h,20h,20h,44h,44h,44h,20h	; 8
db	23h,6Fh,20h,20h,48h,48h,49h,20h,20h,56h,20h,20h,20h,56h,20h,20h	; 9
db	22h,6Eh,22h,20h,37h,37h,37h,20h,20h,22h,20h,20h,44h,44h,44h,20h	; A
db	23h,5Fh,20h,20h,48h,48h,49h,20h,20h,46h,20h,20h,45h,45h,46h,20h	; B
db	22h,6Eh,20h,20h,37h,37h,57h,20h,20h,22h,20h,20h,44h,44h,64h,20h	; C
db	23h,5Fh,20h,20h,20h,48h,68h,20h,20h,46h,20h,20h,20h,45h,75h,20h	; D
db	22h,6Eh,20h,20h,37h,37h,57h,20h,20h,22h,20h,20h,44h,44h,64h,20h	; E
db	23h,5Fh,20h,20h,20h,48h,68h,20h,20h,46h,20h,20h,20h,45h,45h,20h	; F

end
