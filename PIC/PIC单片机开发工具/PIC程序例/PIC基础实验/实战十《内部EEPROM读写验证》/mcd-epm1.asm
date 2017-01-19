;实战《内部EEPROM读写实验》
;本实战的目的是让大家熟悉PIC16F87X内部EEPROM的读写方法
;项目实现的功能：对于地址为00H-3FH的64个EEPROM数据存储单元，分
;别将数据0-63依次烧写进去，然后再循环读出，显示在8只LED发光二极管上
;PIC单片机学习网  陈学乾  http://www.pic16.com
;程序文件名“MCD-EMP1.ASM"
;程序清单如下:
;************************************
STATUS   EQU 3H       ;定义状态寄存器地址
RP0      EQU 5H       ;定义页选位RP0的位地址
RP1      EQU 6H       ;定义页选位RP1的位地址
Z        EQU 2H       ;定义0状态位的位地址
PORTC    EQU 7H       ;定义RC口数据寄存器地址
TRISC    EQU 87H      ;定义RC口方向控制寄存器地址
EECON1   EQU 18CH     ;定义写控制寄存器1的地址
EECON2   EQU 18DH     ;定义写控制寄存器2的地址
EEDATA   EQU 10CH     ;定义读/写数据寄存器地址
EEADR    EQU 10DH     ;定义读/写地址寄存器地址
RD       EQU  0       ;定义读启动控制位位地址
WR       EQU  1       ;定义写启动控制位位地址
WREN     EQU  2       ;定义写使能控制位位地址
EEPGD    EQU  7       ;定义访问目标选择控制位位址
F        EQU  1       ;定义目标寄存器为RAM的指示符
W        EQU  0       ;定义目标寄存器为W的指示符
ADDR     EQU  70H     ;定义地址变量
DATA1    EQU  71H     ;定义数据变量
;*************************************
    ORG     0000H        ;
    NOP                  ;放置一条ICD必须的空操作指令
    GOTO    MAIN         ;
    ORG     0008H        ;
MAIN
    BCF     STATUS,RP1   ;选体1为当前体
    BSF     STATUS,RP0   ;
    MOVLW   00H          ;设定RC全部为输出
    MOVWF   TRISC        ;
    BSF     STATUS,RP1   ;体3为当前体
    CLRF    ADDR         ;地址变量清0
    CLRF    DATA1        ;数据变量清0
WRITE
    BSF     STATUS,RP1   ;选定体3
    BTFSC   EECON1,WR    ;上一次写操作是否完成
    GOTO    $-1          ;否！返回继续检测
    BCF     STATUS,RP0   ;选定体2
    MOVF    ADDR,W       ;取地址
    MOVWF   EEADR        ;送地址寄存器
    MOVF    DATA1,W      ;取数据
    MOVWF   EEDATA       ;送数据寄存器
    BSF     STATUS,RP0   ;选定体3
    BCF     EECON1,EEPGD ;选定EEPROM为访问对向
    BSF     EECON1,WREN  ;开放写操作使能控制
    MOVLW    55H         ;
    MOVWF   EECON2       ;送55H到寄存器EECON2（读写内部EEPROM，这句是固定的）
    MOVLW   0AAH         ;
    MOVWF   EECON2       ;送AAH到寄存器EECON2（读写内部EEPROM，这句是固定的）
    BSF     EECON1,WR    ;启动写操作
    BCF     EECON1,WREN  ;禁止写操作发生
    INCF    DATA1,F      ;数据递增
    INCF    ADDR,F       ;地址递增
    MOVF    ADDR,W       ;
    XORLW   D'64'        ;将当前地址与64比较
    BTFSS   STATUS,Z     ;检测=64否
    GOTO    WRITE        ;否！继续写后面单元
READ1
    DECF    ADDR,F       ;地址递减
    BCF     STATUS,RP0   ;选体2为当前体
    BSF     STATUS,RP1   ;
    MOVF    ADDR,W       ;取地址
    MOVWF   EEADR        ;送地址寄存器
    BSF     STATUS,RP0   ;选体3为当前体
    BCF     EECON1,EEPGD  ;选定EEPROM为访问对象
    BSF     EECON1,RD     ;启动读操作
    BCF     STATUS,RP0    ;体2为当前体
    MOVF    EEDATA,W      ;取数据
    BCF     STATUS,RP1    ;体0为当前体
    MOVWF   PORTC         ;送显LED
    CALL    DELAY         ;调用廷时子程序
    MOVF    ADDR,F        ;检测当前地址
    BTFSS   STATUS,Z      ;是否为0？是！跳一步
    GOTO    READ1         ;否！返回继续读出和显示
READ2 
    INCF    ADDR,F        ;地址递增
    BCF     STATUS,RP0    ;选体2为当前体
    BSF     STATUS,RP1    ;
    MOVF    ADDR,W        ;取地址
    MOVWF   EEADR         ;送地址寄存器
    BSF     STATUS,RP0     ;选体3为当前体
    BCF     EECON1,EEPGD   ;选定EEPROM为访问对象
    BSF     EECON1,RD      ;启动读操作
    BCF     STATUS,RP0     ;体2为当前体
    MOVF    EEDATA,W       ;取数据
    BCF     STATUS,RP1     ;体0为当前体
    MOVWF   PORTC          ;送显LED
    CALL    DELAY          ;调用廷时子程序
    MOVF    ADDR,W         ;检测当前地址与64比较
    XORLW   D'64'          ;
    BTFSS   STATUS,Z       ;是否等于64
    GOTO    READ2          ;否！返回继续读出和显示
    GOTO    READ1          ;返回大循环起点
;******************************************
DELAY
    MOVLW    0             ;
    MOVWF    72H           ;将外层循环参数值256送外层循环寄存器
DELAY1
    MOVLW     0            ;将内层循环参数值256送内层循环寄存器
    MOVWF    73H           ;
    DECFSZ   73H,1         ;递减廷时程序
    GOTO     $-1           ;
    DECFSZ   72H,1         ;
    GOTO     DELAY1        ;
    RETURN
;********************************************
    END
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
;    6.电路设置:将演示板的S1全部拔到ON，S13全部拔到OFF，S4,S5全部拔到OFF ，LCD不用插在演示板上，
;   将用于选择频率的插针跳线插到”XT OSC”位置上.
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


