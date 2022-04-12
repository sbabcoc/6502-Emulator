	.model	small
	.data

;                   -----------------------------------
;                  |  T  I  M  E  T  A  B  .  A  S  M  |
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

;	0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
;----------------------------------------------------------------------,
db	7 , 6 , 2 , 2 , 2 , 3 , 5 , 2 , 3 , 2 , 2 , 2 , 2 , 4 , 6 , 2  ; 0
db	2 , 5 , 2 , 2 , 2 , 4 , 6 , 2 , 2 , 4 , 2 , 2 , 2 , 4 , 7 , 2  ; 1
db	6 , 6 , 2 , 2 , 3 , 3 , 5 , 2 , 4 , 2 , 2 , 2 , 4 , 4 , 6 , 2  ; 2
db	2 , 5 , 2 , 2 , 2 , 4 , 6 , 2 , 2 , 4 , 2 , 2 , 2 , 4 , 7 , 2  ; 3
db	6 , 6 , 2 , 2 , 2 , 3 , 5 , 2 , 3 , 2 , 2 , 2 , 3 , 4 , 6 , 2  ; 4
db	2 , 5 , 2 , 2 , 2 , 4 , 6 , 2 , 2 , 4 , 2 , 2 , 2 , 4 , 7 , 2  ; 5
db	6 , 6 , 2 , 2 , 2 , 3 , 5 , 2 , 4 , 2 , 2 , 2 , 5 , 4 , 6 , 2  ; 6
db	2 , 5 , 2 , 2 , 2 , 4 , 6 , 2 , 2 , 4 , 2 , 2 , 2 , 4 , 7 , 2  ; 7
db	2 , 6 , 2 , 2 , 3 , 3 , 3 , 2 , 2 , 2 , 2 , 2 , 4 , 4 , 4 , 2  ; 8
db	2 , 6 , 2 , 2 , 4 , 4 , 4 , 2 , 2 , 5 , 2 , 2 , 2 , 5 , 2 , 2  ; 9
db	2 , 6 , 2 , 2 , 3 , 3 , 3 , 2 , 2 , 2 , 2 , 2 , 4 , 4 , 4 , 2  ; A
db	2 , 5 , 2 , 2 , 4 , 4 , 4 , 2 , 2 , 4 , 2 , 2 , 4 , 4 , 4 , 2  ; B
db	2 , 6 , 2 , 2 , 3 , 3 , 5 , 2 , 2 , 2 , 2 , 2 , 4 , 4 , 6 , 2  ; C
db	2 , 5 , 2 , 2 , 2 , 4 , 6 , 2 , 2 , 4 , 2 , 2 , 2 , 4 , 7 , 2  ; D
db	2 , 6 , 2 , 2 , 3 , 3 , 5 , 2 , 2 , 2 , 2 , 2 , 4 , 4 , 6 , 2  ; E
db	2 , 5 , 2 , 2 , 2 , 4 , 6 , 2 , 2 , 4 , 2 , 2 , 2 , 4 , 4 , 2  ; F

end
