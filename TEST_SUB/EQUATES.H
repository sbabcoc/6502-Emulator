/*                     -----------------------------						*/
/*                    |  E  Q  U  A  T  E  S  .  H  |						*/
/*                     -----------------------------						*/

/* This module contains definitions of constants used by the 6502 emulator.	*/

/*   -----------------------------------------------------------------		*/
/*  | 6 5 0 2   S t a t u s   R e g i s t e r   D e f i n i t i o n s |		*/
/*   -----------------------------------------------------------------		*/

#define	S_6502	1 << 7		/* Sign: 0 = positive, 1 = negative				*/
#define	V_6502	1 << 6		/* Overflow: indicates a sign change occurred	*/
#define	B_6502	1 << 4		/* Break: set by the BRK instruction			*/
#define	D_6502	1 << 3		/* Decimal Mode: set for BCD arithmetic			*/
#define	I_6502	1 << 2		/* Interrupt Mask: 0 = enabled, 1 = disabled	*/
#define	Z_6502	1 << 1		/* Zero: 0 = result non-zero, 1 = result zero	*/
#define	C_6502	1 << 0		/* Carry: 0 = borrow/, 1 = carry/				*/
							/*            no carry     no borrow			*/

/*   -----------------------------------------------------------------		*/
/*  | 8 0 x 8 6   F l a g s   R e g i s t e r   D e f i n i t i o n s |		*/
/*   -----------------------------------------------------------------		*/

#define	SF_8086	1 << 7		/* Sign: 0 = positive, 1 = negative				*/
#define	ZF_8086	1 << 6		/* Zero: 0 = result non-zero, 1 = result zero	*/
#define	OF_8086	1 << 1		/* Overflow: indicates a sign change occurred	*/
#define	CF_8086	1 << 0		/* Carry: 0 = no carry/, 1 = carry/				*/
							/*            no borrow      borrow				*/

#define	PL		0 << 7
#define	MI		1 << 7


