#include <stdio.h>
#include <string.h>
#include "equates.h"

void main(int,char *[]);
extern short ADC_10(unsigned char,unsigned char,unsigned char);

void main(int argc, char *argv[])
{
	short parm1,parm2,result;
	unsigned char _A,_F;
	char sf[3],vf[3],zf[3],cf[3];
	char *pArg;

	unsigned short arg;

	pArg = argv[1];
	pArg += 2;

	arg = (unsigned short) *pArg;
	arg -= (arg <= '9') ? '0' : '0' + (('A' - '9') - 1);
	arg *= 0x10;

	for (parm1 = arg; parm1 < (arg+0x10); parm1++)
		{
		for (parm2=0x0000;parm2<0x0100; parm2++)
			{
			result = ADC_10((unsigned char) (parm1 & 0xFF),
							(unsigned char) (parm2 & 0xFF),
							0);

			_A = (unsigned char) (result & 0xFF);
			_F = (unsigned char) (result >> 8);

			if (S_6502 & _F)
				{
				strcpy(sf, "NG");
				}
			else
				{
				strcpy(sf, "PL");
				}

			if (OF_8086 & _F)
				{
				strcpy(vf, "OV");
				}
			else
				{
				strcpy(vf, "NV");
				}

			if (ZF_8086 & _F)
				{
				strcpy(zf, "ZR");
				}
			else
				{
				strcpy(zf, "NZ");
				}

			if (C_6502 & _F)
				{
				strcpy(cf, "CY");
				}
			else
				{
				strcpy(cf, "NC");
				}

			printf("%.2X + %.2X = %.2X  %s %s BK 10 DI %s %s     ",
				parm1,parm2,_A,sf,vf,zf,cf);

			result = ADC_10((unsigned char) (parm1 & 0xFF),
							(unsigned char) (parm2 & 0xFF),
							C_6502);

			_A = (unsigned char) (result & 0xFF);
			_F = (unsigned char) (result >> 8);

			if (S_6502 & _F)
				{
				strcpy(sf, "NG");
				}
			else
				{
				strcpy(sf, "PL");
				}

			if (OF_8086 & _F)
				{
				strcpy(vf, "OV");
				}
			else
				{
				strcpy(vf, "NV");
				}

			if (ZF_8086 & _F)
				{
				strcpy(zf, "ZR");
				}
			else
				{
				strcpy(zf, "NZ");
				}

			if (C_6502 & _F)
				{
				strcpy(cf, "CY");
				}
			else
				{
				strcpy(cf, "NC");
				}

			printf("%.2X + %.2X + c = %.2X  %s %s BK 10 DI %s %s\n",
				parm1,parm2,_A,sf,vf,zf,cf);

			}
		}
}
