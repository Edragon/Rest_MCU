;实战十二《877A软件模拟I2C通信读写24C02》
;该试验功能是单片机复位一次,自动从24C02中读取数据到数码管显示,然后对值加1再写入24C02，最终数码管中的数据就是开机的次数，具有一定的实用意义
;本电路所使用24C02为ATMEL的,或不是该厂的,则烧写时间可能会有差异
;必须调整本程序的DELAY时间
;本实战的目的是让大家进上步熟悉I2C通信的时序，熟悉24CXX的读写,会用软件模拟I2C通信
;硬件接法:
;1.24CXX的SDA接877A的RB5口，SCLK接877A的RB4口，WP接地，A0，A1，A2接地
;2.实验本实验须将MCD-DEMO实验板上的93CXX系列芯片先取下,在实验过程中不要按动同样接在RB口的按键,以免影响通信时序.
;3.实验板上拔码开关S4，S5要置ON，其它拔码开关都可以关闭。
;PIC单片机学习网  陈学乾  http://www.pic16.com   讨论论坛：http://pic16.com/bbs/
;版权所有，转载请注明出处，并不能去掉或改变文件中的说明文字。
;程序文件名“MCD-24C02.ASM"
;程序清单如下:
;************************************
    LIST      P=16F877A, R=DEC
    include "P16F877A.inc"
;***********************************
__CONFIG _DEBUG_OFF&_CP_OFF&_WRT_HALF&_CPD_OFF&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_XT_OSC;
;************************************ 定义查表偏移量
#define SDA  PORTB,5
#define SCLK PORTB,4
;*********************
COUNT     EQU   20H
ADDR     EQU   21H
DAT     EQU   23H
TEMP     EQU   24H
;**********************
  ORG 000H
  NOP              ;放置一条ICD必需的空操作指令
  GOTO MAIN
  ORG 004H
  RETURN
  ORG 0008H
;******************************************************
TABLE            
        ADDWF PCL,1              ;地址偏移量加当前PC值                                      	
	    RETLW 0C0H 	   		;0 
	    RETLW 0F9H 	   		;1                                
	    RETLW 0A4H 	   		;2
	    RETLW 0B0H 	   		;3
	    RETLW 99H 	   		;4
	    RETLW 92H 	   		;5
	    RETLW 82H 	   		;6
	    RETLW 0F8H 		   	;7
	    RETLW 80H 	   		;8
	    RETLW 98H 	   		;9
        RETLW 00H 	   		;A
	    RETLW 00H 	   		;B
	    RETLW 00H 		   	;C
	    RETLW 00H 	   		;D
	    RETLW 00H 	   		;E
        RETLW 00H 	   		;F
;*******************************************************
MAIN           
  MOVLW  0FFH
  MOVWF  PORTC            ;数码管先全部熄灭
  MOVLW  0FFH
  MOVWF  PORTA
  MOVLW  0FFH
  MOVWF  PORTB            ;SDT,SCLK都为高 

  BSF STATUS,RP0          ;定义RA口,RC,RB口全部为输出
  MOVLW 07H
  MOVWF ADCON1            ;设置RA口全部为普通数字IO口
  CLRW
  MOVWF TRISB             ;
  MOVWF TRISA
  MOVWF TRISC          
  MOVWF OPTION_REG        ;开启RB口内部弱上拉
  BCF STATUS,RP0

  CLRW         ;地址00H
  CALL RD24    ;读地址
  MOVWF DAT     ;读出的值送F1
  SUBLW .9    ;若读出的值大于9,则F1送为0,从0开始(因为1位数码管只能显示到0-9)
  BC  TT2     ;C=0就转TT2
TT1
  CLRF  DAT
TT2
  MOVFW DAT
  CALL TABLE   ;取显示段码
  MOVWF PORTC   ;段码送C口
  BCF   PORTA ,1  ;点亮第一位数码管
  INCF  DAT ,1     ;每次上电,存入24CXX的00H地址的值加1
  CLRW             ;地址00H
  CALL  WT24       ;写24CXX
  GOTO  $
;****************************
RD24  
       MOVWF ADDR       ;地址暂存于F4中
       CALL START24   ;启动I2C
       MOVLW 0A0H 
       CALL SUBS    ;写器件地址1010000+最后一位0写操作 
       MOVFW ADDR       ;载入地址
       CALL SUBS    ;写地址 
       CALL START24   ;再发开始信号
       MOVLW  0A1H    ;写器件地址1010000+最后一位1读操作
       CALL SUBS      
       BSF STATUS ,RP0
       BSF TRISB ,5            ;设SDA脚为输入,准备读
       BCF STATUS ,RP0 
       MOVLW 08H          ;共读8位数据
       MOVWF COUNT
RD000 
       NOP
       NOP
       NOP
       BSF SCLK            ;读数据
       NOP
       BSF STATUS,C
       BTFSS SDA
       BCF STATUS,C
       RLF TEMP ,1
       BCF SCLK
       DECFSZ COUNT ,1      ;循环读完8位
       GOTO RD000
       BSF STATUS ,RP0
       BCF TRISB ,5            ;恢复SDA脚为输出
       BCF STATUS ,RP0
       BSF SDA
       CALL DELAY2
       BSF SCLK
       CALL DELAY2
       BCF SCLK          ;应答毕,SDA置1
       CALL STOP          ;送停止信号
       MOVFW  TEMP          ;将读的数据送入W中
       RETURN
;******************************写入24C02程序
WT24    MOVWF ADDR         ;  先将地址暂存于F4  
        CALL START24      ;开始条件
        MOVLW 0A0H
        CALL  SUBS      ;写器件地址1010000+最后一位0写操作
        MOVFW ADDR          ;载入地址
        CALL  SUBS      ;写地址
        MOVFW DAT          ;载入数据 
        CALL SUBS       ;写数据
        CALL STOP         ;停止信号
        RETURN 

START24
                      ;开始条件
        BSF  SDA
        BSF  SCLK
        CALL DELAY2
        BCF  SDA
        CALL DELAY2
        BCF  SCLK
        RETURN 

STOP   
        BCF  SDA       ;停止条件
        NOP
        NOP 
        BSF  SCLK
        CALL DELAY2
        BSF  SDA
        RETURN 

SUBS                   ;写数据 
       MOVWF TEMP     ;将要写的数据存于F2中
       MOVLW 08H
       MOVWF COUNT    ;写8位数据
SH01  
       RLF TEMP ,1
       BSF SDA
       BTFSS  STATUS ,C
       BCF SDA
       NOP
       BSF SCLK
       CALL DELAY2
       BCF SCLK
       DECFSZ COUNT ,1  ;循环写完8位
       GOTO SH01
       BSF  SDA
       NOP
       NOP
       BSF  SCLK
       BSF  STATUS,RP0
       BSF  TRISB ,5
       BCF  STATUS,RP0
REP
       BTFSC SDA     ;判应答到否，未到则等待
       GOTO REP
       BCF  SCLK
       BSF  STATUS,RP0
       BCF  TRISB ,5
       BCF  STATUS,RP0
       RETURN

DELAY2  
        NOP
        NOP
        NOP
        NOP
        RETURN 
;********************************************
       end                   ;源程序结束
;*****************************************************
;    进入该实战演练的工序流程如下:
;    1.创建源文件和编辑源文件;在此介绍一种不同于前面讲的创建源文件的方法,用Windows附件中的”记事本”
;   这个为大家所熟知和好用的文件编辑器,并且可以方便的加入中文注释.不过有两点需要注意,一是注释前面的
;   分号”;”必须用西文半角输入;二是必须用”.asm”扩展名存储到事先建立的一个专用子目录下.
;    2.打开MPLAB集成开发环境:首先在WINDOWS环境下,选用开始>程序>Microchip MPLAB>MPLAB命令,启动MPLAB
;   并进入MPLAB的桌面.
;    3.创建项目:选用菜单File>New或Project>New Project,在事先建立的一个专用子目录下创建一个新项目,将
;   用记事本创建的源文件加入到该项目中.
;    4.建立项目中的目标文件:选择菜单Project >Build All(项目>建立所有文件),MPLAB将自动调用MPASM将项目
;   文件管理下的源文件(.asm)汇编成十六进制的目标文件(.hex).
