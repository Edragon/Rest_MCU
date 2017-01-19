;实战十一《877A软件模拟SPI通信读写93C46》
;功能说明:
;1.做一个灯的左移,将左移的8个码建于TABLE中.
;2.从TABLE中取出数据并以16位的方式存入93C46中,地址00H-03H.
;3.将93C46的00H-03H地址中的数据码取出并存入877A的RAM(30H)-(37H),并输出至877A的RC口.
;当断电再复电,数据码不会消失.
;4.本电路所使用93C46为ATMEL或MICROCHIP的,或不是该厂的,则烧写时间会有差异
;必须调整本程序的DELAY时间
;本实战的目的是让大家进上步熟悉SPI通信的时序，熟悉93C46的读写,会用软件模拟SPI通信
;硬件接法:
;1.93C46的CS接877A的RB1口;CLK接877A的RB2口;DI接877A的RB4口;DO接877A的RB5口;93C46的ORG端接VCC,使93C46工作于16位方式
;2.实验本实验须将MCD-DEMO实验板上的24CXX系列芯片先取下,在实验过程中不要按动同样接在RB口的按键,以免影响通信时序.
;3.实验板上拔码开关S1要置ON，其它拔码开关都可以关闭。
;PIC单片机学习网  陈学乾  http://www.pic16.com   讨论论坛：http://pic16.com/bbs/
;版权所有，转载请注明出处，并不能去掉或改变文件中的说明文字。
;程序文件名“MCD-93C46.ASM"
;程序清单如下:
;************************************
    LIST      P=16F877A, R=DEC
    include "P16F877A.inc"
;***********************************
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;
;************************************ 定义查表偏移量
READ   EQU   0  ;读93C46
WRITE  EQU   1  ;写入93C46 
EWEN   EQU   2  ;93C46写入使能
EWDS   EQU   3  ;93C46写入禁止
;*************************************定义引脚位地址
CS     EQU   1
CLK    EQU   2
DI     EQU   4
DO     EQU   5
;*********************
ADR46  EQU   20H
F1     EQU   23H
F2     EQU   24H
F3     EQU   25H
F4     EQU   26H
F5     EQU   27H
F6     EQU   28H
F7     EQU   29H
;**********************
  ORG 000H
  NOP              ;放置一条ICD必需的空操作指令
  GOTO MAIN
  ORG 0008H
;******************************************************
TABLE
  ADDWF PCL ,1   ;查表，PORTC一个灯左移
  RETLW  01H
  RETLW  02H
  RETLW  04H
  RETLW  08H
  RETLW  10H
  RETLW  20H
  RETLW  40H
  RETLW  80H
;*******************************************************
TO9346
  MOVWF F1        ;将W的值送F1暂存
  BSF  PORTB ,CS          ;写入起始位1
  BSF  PORTB ,DI
  BSF  PORTB ,CLK
  CALL DELAY
  BCF  PORTB ,CLK
  CALL DELAY
  MOVFW F1
  ADDWF PCL ,1
  GOTO  SREAD    ;读
  GOTO  SWRITE   ;写
  GOTO  SEWEN    ;写使能
  GOTO  SEWDS    ;写禁止
;*****************************************************
MAIN
  MOVLW  00H
  MOVWF  PORTC            ;LED先全部熄灭
  MOVLW  20H
  MOVWF  PORTB            ;除DO外,其它通信口全送0

  BSF STATUS,RP0          ;定义RA口,RC口全部为输出
  MOVLW 20H
  MOVWF TRISB             ;RB口5脚为入,其它全为出
  CLRW
  MOVWF TRISC             ;RC口全为输出.
  MOVWF OPTION_REG        ;开启RB口内部弱上拉
  BCF STATUS,RP0
;*************************************
LOOP
  CLRF    21H             ;取码指针
  CLRF    ADR46          ;93C46的地址00H
  MOVLW   04H
  MOVWF   22H             ;4组8个码
START
  MOVLW   EWEN            ;写入使能
  CALL    TO9346
  MOVFW   21H             ;载入取码指针
  CALL    TABLE           ;至TABLE 取码
  MOVWF   F5              ;存入"写入寄存器"
  INCF    21H ,1          ;取下一个码
  MOVFW   21H
  CALL    TABLE           ;至TABLE 取码
  MOVWF   F4
  MOVLW   WRITE           
  CALL    TO9346          ;写入数据
  MOVLW   EWDS
  CALL    TO9346          ;写禁止
  INCF    21H  ,1         ;取下一个码
  INCF    ADR46 ,1        ;取下一个地址
  CALL    DELAY1
  DECFSZ  22H ,1          ;直到写完四个地址
  GOTO    START
  MOVLW   30H             ;存入877A的RAM首地址
  MOVWF   FSR
  CLRF    ADR46           ;93C46的地址00
  MOVLW   04H
  MOVWF   22H             ;读93C46的四个地址,8个码
;*****************
A1
  MOVLW   READ
  CALL    TO9346          ;读地址中的数据
  MOVFW   F5
  MOVWF   INDF            ;读出的数据存入877A的RAM
  INCF    FSR ,1
  MOVFW   F4
  MOVWF   INDF
  INCF    ADR46 ,1         ;读下一个地址
  INCF    FSR ,1
  DECFSZ  22H ,1          ;直到读完四个地址
  GOTO    A1
A2
  MOVLW   08H
  MOVWF   22H
  MOVLW   30H             ;RAM 30h-37H 共8个码
  MOVWF   FSR
OUTPUT
  MOVFW   INDF
  MOVWF   PORTC           ;输出结果到PORTC
  CALL    DELAY1   
  INCF    FSR ,1
  DECFSZ  22H ,1
  GOTO    OUTPUT
  GOTO    A2
;***************************
SREAD
  MOVLW  80H
  ADDWF  ADR46 ,0        ;6位地址加上两位操作码,10XXXXXX  读指令
  CALL   SDT46           ;写入操作码与地址
  CALL   RDT46           ;读高位数据
  MOVWF  F5              ;存入F5
  CALL   RDT46           ;读低位地址              
  MOVWF  F4              ;存入F4
  GOTO   EX9346
;**************************
SWRITE
  MOVLW  40H
  ADDWF  ADR46 ,0       ;6位地址加上两位操作码01XXXXXX  写指令
  CALL   SDT46          ;写入操作码及地址
  MOVFW  F5             ;载入数据
  CALL   SDT46          ;写入数据
  MOVFW  F4             ;载入数据
  CALL   SDT46          ;写入数据
  GOTO   EX9346 
;******************************
SEWEN
  MOVLW  30H          ;写入操作码0011XXXX  写使能指令
  CALL   SDT46
  GOTO   EX9346
;******************************
SEWDS
  CLRW            ;写入0000XXXX写禁止指令
  CALL   SDT46
;******************************
EX9346
  BCF   PORTB ,CS    ;结束时清CS为0
  RETURN
;******************************
SDT46:
  MOVWF  F2          ;将要写的数据送F2
  MOVLW  08H         ;写入8位数据
  MOVWF  F3
SD1:
  RLF    F2 ,1
  BSF    PORTB ,DI
  BTFSS  STATUS ,C
  BCF    PORTB ,DI
  BSF    PORTB ,CLK
  CALL   DELAY
  BCF    PORTB ,CLK
  CALL   DELAY
  DECFSZ  F3 ,1
  GOTO    SD1
  RETURN
;******************************
RDT46
  MOVLW  08H         ;读出8位数据
  MOVWF  F3
RD1
  BSF  PORTB ,CLK
  CALL DELAY
  BCF  PORTB ,CLK
  CALL DELAY
  BSF  STATUS ,C
  BTFSS  PORTB ,DO
  BCF  STATUS ,C
  RLF  F2 ,1
  DECFSZ  F3 ,1
  GOTO  RD1
  MOVFW F2      ;读得的数据送W
  RETURN
;********************************
DELAY
  MOVLW  1FH     ;CLK时序廷时
  MOVWF  F7
  DECFSZ F7 ,1
  GOTO $-1
  RETURN
;*******************************
DELAY1              ;廷时
  MOVLW  .20
  MOVWF  F4
D1
  MOVLW  .40
  MOVWF  F5
D2
  MOVLW  .248
  MOVWF  F6
  DECFSZ F6 ,1
  GOTO  $-1
  DECFSZ F5 ,1
  GOTO   D2
  DECFSZ F4 ,1
  GOTO   D1
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
