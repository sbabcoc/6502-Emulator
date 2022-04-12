#include <stdio.h>
#include <string.h>
#include "equates.h"

void main(int,char *[]);
extern short SBC_10(unsigned char,unsigned char,unsigned char);

void main(int argc, char *argv[])
	{
	FILE *source;
	char srcPath[32];
	char *pArg;
	unsigned short arg;
	short parm1, parm2, carryIn;
	short result, flagsOut;
	short srcResult;
	short srcSign, srcZero, srcOver;
	char signStr[3],zeroStr[3], overStr[3];
	char symbol;
	short test1, test2;

	pArg = argv[1];
	pArg += 2;

	arg = (unsigned short) *pArg;
	sprintf(srcPath, "..\\dec_mode.sub\\sub_0x%c0", arg);
	source = fopen(srcPath, "r");

	arg -= (arg <= '9') ? '0' : '0' + (('A' - '9') - 1);
	arg *= 0x10;


	for (parm1 = arg; parm1 < (arg+0x10); parm1++)
		{
		for (parm2=0x0000; parm2<0x0100; parm2++)
			{
			for (carryIn = C_6502; carryIn >= 0; carryIn -= C_6502)
				{
				fscanf(source, "%*[^=]= %x", &srcResult);
				fscanf(source, "  %s %s %*s %*s %*s %s %*s", signStr, overStr, zeroStr);
				srcSign = (!strcmp(signStr, "NG")) ? SF_8086 : 0;
				srcOver = (!strcmp(overStr, "OV")) ? OF_8086 : 0;
				srcZero = (!strcmp(zeroStr, "ZR")) ? ZF_8086 : 0;

				result = SBC_10((unsigned char) (parm1 & 0xFF),
								(unsigned char) (parm2 & 0xFF),
								carryIn);

				flagsOut = result >> 8;
				result &= 0x00FF;

				flagsOut &= (SF_8086 | OF_8086 | ZF_8086);
				flagsOut ^= (srcSign | srcOver | srcZero);

				switch(flagsOut)
					{
					case 0:
						symbol = '.';
						break;

					case ZF_8086:
						symbol = 'z';
						break;

					case OF_8086:
						symbol = 'v';
						break;

					case OF_8086 | ZF_8086:
						symbol = 'X';
						break;

					case SF_8086:
						symbol = 's';
						break;

					case SF_8086 | ZF_8086:
						symbol = 'U';
						break;

					case SF_8086 | OF_8086:
						symbol = 'T';
						break;

					case SF_8086 | OF_8086 | ZF_8086:
						symbol = 'A';
						break;
					}

				putchar(symbol);
				if ((carryIn == 0) && ((parm2 % 0x10) == 0x0F))
					{
					putchar('\n');
					}
				}
 			}
		}
	}
