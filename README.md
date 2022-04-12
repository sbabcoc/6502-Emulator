# 6502-Emulator
This repository contains Intel x86 code to emulate the instruction set of the 6502 processor. In its current state, this repository lacks the implementation to fetch, decode, and process each instruction.

The source is compatible with Microsoft Macro-Assembler 5.1

A couple of files in the **6502EMUL** folder are clearly in mid-revision:

* **MODETAB.ASM**: This file contains a table that combined base instruction execution cycles and addressing mode. I'm pretty sure that I intended to mask off the top nybble of each entry, leaving only the addressing mode.
* **TIMETAB.ASM**: This file contains just base instruction execution cycles. The comments and label in this file remain after being copied from **MODETAB.ASM**.
* **TIMETABL.ASM**: The content of this file currently duplicates the content of **MODETAB.ASM**. I think this is the original file, and the intent was to break the components of each entry into two separate tables. The idea is that it's better to maintain these in purpose-focused tables so the values can be used as-is. When stored in packed fomat, the values must be unpacked before they can be used.
