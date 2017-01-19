/*
 * MSP430开发板串口测试程序
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
#define uint unsigned int
uchar data[] = {'w','w','w','.','l','c','s','o','f','t','.','n','e','t','\r','\n'};
uchar j=0;
uchar k=0;
delay ()
{
  uchar n;
  for(n=100;n>0;n--)
  {
    ;
  }
}
void initsys(void)
{
  BCSCTL1 &= ~XT2OFF;
  uchar i;
  do
  {
    IFG1 &= ~OFIFG;
    for(i=0xee;i>0;i--)
    {
      ;
    }
  }
  while((IFG1&OFIFG)!=0);    
  BCSCTL2 |= SELM_2 + SELS;       
}
void set()
{
  U0CTL |= SWRST;      //开启设置
  U0TCTL = SSEL1;   //选择 SMCLK=6M        波特率=9600
  /* 6M / 9600 = 625       625 = 0x0271     0.000 * 8= 0*/
  /* 32768/9600=3.4133    0.4133*8=4*/
  U0BR0 = 0x41;         
  U0BR1 = 0x03;
  U0MCTL =0x00;     //00000000
  U0CTL |= CHAR;       //长度8位
  U0CTL &= ~SWRST;
 
}
void send(uchar num)
{
  
  TXBUF0 = num;
  while((IFG1&UTXIFG0)==0); 
}
void receive()
{
  //P2DIR |= 0xff;
  IFG1 &= 0xbf;
  j = RXBUF0;
  P4OUT = j;
}
void main( void )
{
  WDTCTL = WDTPW + WDTHOLD;
  initsys();
  P3DIR |= 0x10;
  P4DIR |= 0xff;
  P4OUT = 0x00;
  P3SEL |= 0x30; 
  set();
  ME1 |= UTXE0 + URXE0;
  IE1 |= URXIE0;
  
  _EINT();

  for(k=0;k<16;k++)
  {
    send(data[k]);
  }
  while(1);
}
#pragma vector=UART0TX_VECTOR
__interrupt void usart_tx(void)
{
  while((IFG1&URXIFG0)==1);
  delay();
}
#pragma vector=UART0RX_VECTOR
__interrupt void usart0_rx (void)
{
  if((U0RCTL & RXERR)==0)
   {
     receive();
     delay();
   }
  else
  {
    U0RCTL &= ~(FE + OE + BRK);
  }
  //while((IFG1&URXIFG0)==0);
}
