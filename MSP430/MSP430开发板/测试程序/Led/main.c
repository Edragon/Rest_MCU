/*
 * MSP430开发板LED测试程序
 * 
 * 用途：串口中断应用
 * 
 * 作者				日期				备注
 * Huafeng Lin			20010/03/27			新增
 * Huafeng Lin			20010/03/27			修改
 * 
 */

#include<msp430x14x.h>
#define uchar unsigned char
#define uint  unsigned int

void set_led1(void)
{P6SEL &=~BIT7;//选择I/O功能
 P6DIR |=BIT7;//设为输出
 P6OUT |=BIT7;//置1
}
void clr_led1(void)
{P6SEL &=~BIT7;//选择I/O功能
 P6DIR |=BIT7;//设为输出
 P6OUT &=~BIT7;//置0
}
void set_led2()
{P6SEL &=~BIT6;//选择I/O功能
 P6DIR |=BIT6;//设为输出
 P6OUT |=BIT6;//置1
}
void clr_led2(void)
{P6SEL &=~BIT6;//选择I/O功能
 P6DIR |=BIT6;//设为输出
 P6OUT &=~BIT6;//置0
}
void set_led3()
{P6SEL &=~BIT5;//选择I/O功能
 P6DIR |=BIT5;//设为输出
 P6OUT |=BIT5;//置1
}
void clr_led3(void)
{P6SEL &=~BIT5;//选择I/O功能
 P6DIR |=BIT5;//设为输出
 P6OUT &=~BIT5;//置0
}
void set_led4()
{P6SEL &=~BIT4;//选择I/O功能
 P6DIR |=BIT4;//设为输出
 P6OUT |=BIT4;//置1
}
void clr_led4(void)
{P6SEL &=~BIT4;//选择I/O功能
 P6DIR |=BIT4;//设为输出
 P6OUT &=~BIT4;//置0
}
void delay(void)
{uint time=30000;
 while(time--);
}
void main( void )
{
  WDTCTL=WDTPW+WDTHOLD;
  while(1)
  {
    set_led1();
    set_led2();
    set_led3();
    set_led4();
    delay();
    clr_led1();
    clr_led2();
    clr_led3();
    clr_led4();
    delay();
  }
}
