;实战6《LCD显示单个B字》
;本实战的目的是让大家熟悉MCD1配套LCD的读写方法
;PIC单片机学习网  陈学乾  http://www.pic16.com
;程序文件名“MCD-LCD1.ASM"
;程序清单如下:
;**********************************************
STATUS  EQU 3H   ;定义状态寄存器地址
PORTA   EQU 5H   ;定义RA口数据寄存器地址
PORTC   EQU 7H   ;定义RC口数据寄存器地址
TRISA   EQU 85H  ;定义RA口方向控制寄存器地址
TRISC   EQU 87H  ;定义RC口方向控制寄存器地址
ADCON1  EQU 9FH  ;定义ADC模块控制寄存器1的地址
;********************
Z       EQU 2    ;定义0状态位的位地址
RP0     EQU 5    ;定义页选位RP0的位地址
;*********************
RS EQU 1         ;LCD寄存器选择信号脚定义在RA.1脚
RW EQU 2         ;LCD读/写信号脚定义在RA.2脚
E  EQU 3         ;LCD片选信号脚定义在RA.3脚
;**********************
  ORG 000H 
  NOP            ;放置一条ICD必需的空操作指令
  GOTO MAIN
  ORG 0008H
MAIN
  BSF STATUS,RP0     ;定义RA口,RC口全部为输出
  MOVLW 07H
  MOVWF ADCON1            ;设置RA口全部为普通数字IO口
  MOVLW 00H
  MOVWF TRISA
  MOVWF TRISC
  BCF STATUS,RP0

  CALL DELAY         ;调用廷时,刚上电LCD复位不一定有PIC快
  MOVLW 01H
  MOVWF PORTC        ;清屏
  CALL ENABLE
  MOVLW 38H
  MOVWF PORTC        ;8位2行5x7点阵
  CALL ENABLE
  MOVLW 0FH
  MOVWF PORTC        ;显示器开、光标开、闪烁开
  CALL ENABLE
  MOVLW 06H
  MOVWF PORTC         ;文字不动，光标自动右移
  CALL ENABLE
  MOVLW 0C0H
  MOVWF PORTC         ;写入显示起始地址（第一行第一个位置）
  CALL ENABLE
  MOVLW 42H
  MOVWF PORTC         ;字母"B"的代码
  BSF PORTA,RS
  BCF PORTA,RW
  BCF PORTA,E
  CALL DELAY
  BSF PORTA,E
  GOTO $
ENABLE
  BCF PORTA,RS         ;写入控制命令的子程序
  BCF PORTA,RW
  BCF PORTA,E
  CALL DELAY
  BSF PORTA,E
  RETLW 0
;********************************************
DELAY                       
                             ;子程序名，也是子程序入口地址
       movlw   0ffh          ;将外层循环参数值FFH经过W
       movwf   20h          ;送入用作外循环变量的20H单元
lp0    movlw   0ffh          ;将内层循环参数值FFH经过W
       movwf   21h           ;送入用作内循环变量的21H单元
lp1    nop
       decfsz   21h,1         ;变量21H内容递减，若为0跳跃
       goto     lp1           ;跳转到LP1处
       decfsz    20h,1         ;变量20H内容递减，若为0跳跃
       goto     lp0           ;跳跃到LP0处
       return                 ;返回主程序
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
;    5.ICD参数设置:通过菜单命令Project>Edit Project或者Option>Development Mode,将开发模式设置为
;   ”MPLAB ICD Debugger”,点击OK按钮,打开ICD的工作窗口,在调试阶段,可以按照说明书图2-10设置各项,但需注意
;   OSCILLATOR应设置为XT方式,尤其需要说明的是，选中“Enable Debug Mode”（使能调试模式）选项，在向目
;   标单片机烧写机器码程序时，会将调试临控程序同时写入单片机的指定程序存储器区域，然后才允许用ICD方式调试。
;    6.电路设置:将演示板的S1全部拔到OFF，S13全部拔到OFF，S4,S5全部拔到OFF ，LCD对准脚位插在演示板上，
;   将用于选择频率的插针跳线插到”XT OSC”位置上，板上93CXX、24CXX应拿下。
;    7.向目标单片机烧写目标程序:用户在点击功能按钮”Program”向目标单片机烧写机器码程序时,会等待一段时间，
;   并且在条状的状态信息栏中，出现提示信息。有一点需要引起注意，就是PIC16F87X单片机的FLASH程序存储器的擦写
;   周期是有限的，大约为1000次，应尽量节省它的使用寿命。
;    8.运行和调试用户程序和用户电路:在各项参数设置好后,将ICD的工作窗口最小化,利用前面讲的”运行及调试”中介
;   绍的几种方法进行调试.当用自动单步方式调试时,建议临时禁止廷时子程序发挥作用,具体的方法是,可在CALL DELAY指
;   令前添加一个分号,并且重新汇编一次.为了学习目的,在调试过程中可以人为地加入一些软件漏洞(BUG)或硬件故障,来模
;   仿单片机端口引脚的片内或片外故障.
;    9.定型烧写目标单片机;经过多次重复上述步骤的反复修改和调试,使得程序和电路在联机状态完全正常,这时可以进行
;   定型烧写,即将ICD窗口中的”Enable Debug Mode”(使能调试模式)选项消除,不再将调试临控程序写入单片机中.
;    10.独立运行验收:上一步中的烧写过程完成后,即可将ICD模块和ICD仿真头(或演示板)之间的6芯电缆断开,让单片机在
;   演示板独立运行,观察实际效果.
;
;



