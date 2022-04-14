        .model  small
        .data

;                   -----------------------------------
;                  |  P  R  O  C  T  A  B  .  A  S  M  |
;                   -----------------------------------
;
; The following is a table of near pointers to the procedures that emulate
; the 6502 instruction set.  Each procedure may be used by multiple opcodes
; depending on the addressing modes supported by the instruction emulated.
;
; NOTE : The official placement of the 'NOP' instruction is at opcode x'EA'.

include proc_abs.def

;----------------------------------------------------------------------------

ProcTab label   word

;-------------------------------------------------------------------------,
;         0       1       2       3       4       5       6       7       ;
;             8       9       A       B       C       D       E       F   ;
;-------------------------------------------------------------------------;---,
dw      BRK_0,  ORA_E,  NOP_0,  NOP_0,  TSB_7,  ORA_7,  ASL_7,  NOP_0     ; 0 ;
dw          PHP_0,  ORA_2,  ASL_1,  NOP_0,  TSB_4,  ORA_4,  ASL_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BPL_3,  ORA_F,  ORA_D,  NOP_0,  TRB_7,  ORA_8,  ASL_8,  NOP_0     ; 1 ;
dw          CLC_0,  ORA_6,  INA_1,  NOP_0,  TRB_4,  ORA_5,  ASL_5,  NOP_0 ;   ;
                                                                          ;   ;
dw      JSR_4,  AND_E,  NOP_0,  NOP_0,  BIT_7,  AND_7,  ROL_7,  NOP_0     ; 2 ;
dw          PLP_0,  AND_2,  ROL_1,  NOP_0,  BIT_4,  AND_4,  ROL_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BMI_3,  AND_F,  AND_D,  NOP_0,  BIT_8,  AND_8,  ROL_8,  NOP_0     ; 3 ;
dw          SEC_0,  AND_6,  DEA_1,  NOP_0,  BIT_5,  AND_5,  ROL_5,  NOP_0 ;   ;
                                                                          ;   ;
dw      RTI_0,  EOR_E,  NOP_0,  NOP_0,  NOP_0,  EOR_7,  LSR_7,  NOP_0     ; 4 ;
dw          PHA_0,  EOR_2,  LSR_1,  NOP_0,  JMP_4,  EOR_4,  LSR_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BVC_3,  EOR_F,  EOR_D,  NOP_0,  NOP_0,  EOR_8,  LSR_8,  NOP_0     ; 5 ;
dw          CLI_0,  EOR_6,  PHY_0,  NOP_0,  NOP_0,  EOR_5,  LSR_5,  NOP_0 ;   ;
                                                                          ;   ;
dw      RTS_0,  ADC_E,  NOP_0,  NOP_0,  STZ_7,  ADC_7,  ROR_7,  NOP_0     ; 6 ;
dw          PLA_0,  ADC_2,  ROR_1,  NOP_0,  JMP_A,  ADC_4,  ROR_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BVS_3,  ADC_F,  ADC_D,  NOP_0,  STZ_8,  ADC_8,  ROR_8,  NOP_0     ; 7 ;
dw          SEI_0,  ADC_6,  PLY_0,  NOP_0,  JMP_B,  ADC_5,  ROR_5,  NOP_0 ;   ;
                                                                          ;   ;
dw      BRA_3,  STA_E,  NOP_0,  NOP_0,  STY_7,  STA_7,  STX_7,  NOP_0     ; 8 ;
dw          DEY_0,  BIT_2,  TXA_0,  NOP_0,  STY_4,  STA_4,  STX_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BCC_3,  STA_F,  STA_D,  NOP_0,  STY_8,  STA_8,  STX_9,  NOP_0     ; 9 ;
dw          TYA_0,  STA_6,  TXS_0,  NOP_0,  STZ_4,  STA_5,  STZ_5,  NOP_0 ;   ;
                                                                          ;   ;
dw      LDY_2,  LDA_E,  LDX_2,  NOP_0,  LDY_7,  LDA_7,  LDX_7,  NOP_0     ; A ;
dw          TAY_0,  LDA_2,  TAX_0,  NOP_0,  LDY_4,  LDA_4,  LDX_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BCS_3,  LDA_F,  LDA_D,  NOP_0,  LDY_8,  LDA_8,  LDX_9,  NOP_0     ; B ;
dw          CLV_0,  LDA_6,  TSX_0,  NOP_0,  LDY_5,  LDA_5,  LDX_6,  NOP_0 ;   ;
                                                                          ;   ;
dw      CPY_2,  CMP_E,  NOP_0,  NOP_0,  CPY_7,  CMP_7,  DEC_7,  NOP_0     ; C ;
dw          INY_0,  CMP_2,  DEX_0,  NOP_0,  CPY_4,  CMP_4,  DEC_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BNE_3,  CMP_F,  CMP_D,  NOP_0,  NOP_0,  CMP_8,  DEC_8,  NOP_0     ; D ;
dw          CLD_0,  CMP_6,  PHX_0,  NOP_0,  NOP_0,  CMP_5,  DEC_5,  NOP_0 ;   ;
                                                                          ;   ;
dw      CPX_2,  SBC_E,  NOP_0,  NOP_0,  CPX_7,  SBC_7,  INC_7,  NOP_0     ; E ;
dw          INX_0,  SBC_2,  NOP_0,  NOP_0,  CPX_4,  SBC_4,  INC_4,  NOP_0 ;   ;
                                                                          ;   ;
dw      BEQ_3,  SBC_F,  SBC_D,  NOP_0,  NOP_0,  SBC_8,  INC_8,  NOP_0     ; F ;
dw          SED_0,  SBC_6,  PLX_0,  NOP_0,  NOP_0,  SBC_5,  INC_5,  NOP_0 ;   ;
;-------------------------------------------------------------------------'---'

end
