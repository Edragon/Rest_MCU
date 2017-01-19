#include"pic.h"

int a;

void delay_ms(unsigned int z)
{
	unsigned char x;
	unsigned int y;
	for(x=110;x>0;x--)
		for(y=z;y>0;y--);
}

void main()
{
	TRISB=0x00;        //定义端口B为输出模式
	TRISC=0x00;        //定义端口C为输出模式
	while(1)
	{
		PORTB=0xFE;			//1111 1110
		delay_ms(100);
		PORTB=0xFD;
		delay_ms(100);
	    PORTB=0xFB;
		delay_ms(100);
        PORTB=0xF7;
		delay_ms(100);
		PORTB=0xEF;
		delay_ms(100);
	    PORTB=0xDF;
		delay_ms(100);
	    PORTB=0xBF;
		delay_ms(100);
	    PORTB=0x7F;
		delay_ms(100);
	}
}