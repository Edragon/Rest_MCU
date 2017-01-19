//实验目的：熟悉A/D转换
//软件思路：选择RAO做为模拟输入通道；
//          连续转换4次再求平均值做为转换结果
//          最后结构只取低8位
//          结果送数码管的低3位显示
//硬件要求：拨码开关S14第2位置ON，第1位置OFF
//          拨码开关S6全部置ON，S5第4-6位置ON，第1-3位置OFF
//          为不影响结果，其他拨码开关置OFF。
#include<pic.h>              //包含单片机内部资源预定义
 __CONFIG(0x1832);        
//芯片配置字，看门狗关，上电延时开，掉电检测关，低压编程关，加密，4M晶体HS振荡
 const char TABLE[]={0xc0,0xf9,0xa4,0xb0,0x99,0x92,0X82,0XF8,0X80,0X90}; 
 //定义常数0-9的数据表格
 void  DELAY();              //delay函数申明
 void  init();               //I/O口初始化函数申明
 void  display(int x);       //显示函数申明
//------------------------------------------------
  //主程序开始
 void  main()               
 {
   int result=0x00;          //定义转换结果寄存器
   while(1)                  //死循环
   {
   int i;                    //定义循环次数控制寄存器
   result=0x00;              //转换结果清0
   for(i=5;i>0;i--)          //求5次转换结果的平均值
     {
      init();                //调用初始化函数
      //ADGO=0X1;              //开启转换过程
     // while(ADGO);           //等待转换完成
	  GO_DONE=0x01;
      while(GO_DONE);
      result=result+ADRESL;  //累计转换结果
      }
      result=result/5;       //求5次结果的平均值
     display(result);        //调用显示函数
   }
  }
//-----------------------------------------------
 //初始化函数
 void  init()               
  {
   PORTA=0XFF;               
   PORTD=0XFF;               //熄灭所有显示
   TRISA=0X1;                //设置RA0为输入，其他为输出            
   TRISD=0X00;               //设置D口全为输出
   ADCON1=0X8E;              //转换结果左对齐，RA0做模拟输入口，其它做普通I/O
   ADCON0=0X41;              //系统时钟Fosc/8，选择RA0通道，允许ADC工作
   DELAY();                  //保证采样延时
   }
//-----------------------------------------------
//显示函数
 void display(int x)          
   {
     int  bai,shi,ge,temp;   //定义4个临时变量
     temp=x;                 //暂存AD转换的结果
     bai=temp/0x64;          //求显示的百位
     shi=(temp%0x64)/0xa;    //求显示的十位
     ge=(temp%0x64)%0xa;     //求显示的个位
     PORTD=TABLE[bai];       //查表得百位显示的代码
     PORTA=0x37;             //RA3输出低电平，点亮百位显示
     DELAY();                //延时一定时间，保证显示亮度
     PORTD=TABLE[shi];       //查表得十位显示的代码
     PORTA=0x2F;             //RA4输出低电平，点亮十位显示
     DELAY();                //延时一定时间，保证亮度
     PORTD=TABLE[ge];        //求个位显示的代码
     PORTA=0x1F;             //RA5输出低电平，点亮个位显示
     DELAY();                //延时一定时间，保证亮度
   }

//----------------------------------------------
//延时程序
void  DELAY()              //延时程序
    {
     int i;                 //定义整形变量
     for(i=0x100;i--;);     //延时
    }
