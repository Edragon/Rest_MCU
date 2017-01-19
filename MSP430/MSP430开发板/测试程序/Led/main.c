/*
 * MSP430������LED���Գ���
 * 
 * ��;�������ж�Ӧ��
 * 
 * ����				����				��ע
 * Huafeng Lin			20010/03/27			����
 * Huafeng Lin			20010/03/27			�޸�
 * 
 */

#include<msp430x14x.h>
#define uchar unsigned char
#define uint  unsigned int

void set_led1(void)
{P6SEL &=~BIT7;//ѡ��I/O����
 P6DIR |=BIT7;//��Ϊ���
 P6OUT |=BIT7;//��1
}
void clr_led1(void)
{P6SEL &=~BIT7;//ѡ��I/O����
 P6DIR |=BIT7;//��Ϊ���
 P6OUT &=~BIT7;//��0
}
void set_led2()
{P6SEL &=~BIT6;//ѡ��I/O����
 P6DIR |=BIT6;//��Ϊ���
 P6OUT |=BIT6;//��1
}
void clr_led2(void)
{P6SEL &=~BIT6;//ѡ��I/O����
 P6DIR |=BIT6;//��Ϊ���
 P6OUT &=~BIT6;//��0
}
void set_led3()
{P6SEL &=~BIT5;//ѡ��I/O����
 P6DIR |=BIT5;//��Ϊ���
 P6OUT |=BIT5;//��1
}
void clr_led3(void)
{P6SEL &=~BIT5;//ѡ��I/O����
 P6DIR |=BIT5;//��Ϊ���
 P6OUT &=~BIT5;//��0
}
void set_led4()
{P6SEL &=~BIT4;//ѡ��I/O����
 P6DIR |=BIT4;//��Ϊ���
 P6OUT |=BIT4;//��1
}
void clr_led4(void)
{P6SEL &=~BIT4;//ѡ��I/O����
 P6DIR |=BIT4;//��Ϊ���
 P6OUT &=~BIT4;//��0
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
