/*
 * MSP430开发板按键测试程序
 * 
 * 用途：按键测试程序
 * 
 * 作者				日期				备注
 * Huafeng Lin			20010/08/14			新增
 * Huafeng Lin			20010/08/14			修改
 * 
 */

#include<msp430x14x.h>

int keyvalue;

int checkkey(void)
{
  int nP10,nP11,nP12,nP13;
  nP10 = P1IN & BIT0;
  nP11 = (P1IN & BIT1) >> 1;
  nP12 = (P1IN & BIT2) >> 2;
  nP13 = (P1IN & BIT3) >> 3;
  if(nP10 == 0 || nP11 == 0 || nP12 == 0 || nP13 == 0)
  {
    return 1;
  }

  return 0;
}

int getkeyvalue(void)
{
  int value = -1;
  
  if ((P1IN & BIT0) == 0) value = 0;
  if (((P1IN & BIT1) >> 1) == 0) value = 1;
  if (((P1IN & BIT2) >> 1) == 0) value = 2;
  if (((P1IN & BIT3) >> 1) == 0) value = 3;
  
  return value;
}

delay (unsigned int x)
{
  unsigned int m,n;
  for (m=x;m>0;m--)
  {
    for (n=100;n>0;n--)
    {
      ;
    }
  }
}

void main( void )
{
  WDTCTL = WDTPW + WDTHOLD;
  P1DIR = 0x00;
  P6DIR = BIT4 + BIT5 + BIT6 + BIT7;
  P6OUT = 0xff;
  
  while (1)
  {
    keyvalue = -1;
    
    delay(20);    
    if (checkkey())
    {
      keyvalue = getkeyvalue();
    }
    
    switch (keyvalue)
    {
      case 0: P6OUT = ~BIT4; break;
      case 1: P6OUT = ~BIT5; break;
      case 2: P6OUT = ~BIT6; break;
      case 3: P6OUT = ~BIT7; break;
      default: break;
    }
  }
}
