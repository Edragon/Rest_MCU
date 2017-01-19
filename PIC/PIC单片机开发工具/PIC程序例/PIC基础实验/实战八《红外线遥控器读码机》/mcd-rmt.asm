;红外线遥控读码机,用本实例配合本站套件可读出任何6121或6122(CD6121/CD6122/SC6121/SC6122)及其兼容芯片的红外线遥控器的用户码、键码。
;本例是一个红外线遥控接收解码程序,程序中数码管显示用的是定时器中断法的动态扫描
;动态显示二位数码管的方法，中断法，我们以3MS中断一次从而交换两位数码管轮流点亮。
;对准实验板红外线接收头轻按要测定的遥控器的待测按键一次，此时实验板的中间两位数码管将显示该键的键码，
;(显示为16进制的),轻触实验板的S10此时显示器切换为显示当前遥控器用户码的低8位, 轻触实验板的S11此时显示器切换为显示当前遥控器用户码的高8位,
;轻触实验板的S9此时显示再一次回到显示当前键的键码.
;注意:所有的显示均为16进制,'A'显示为'A','B'显示为'b','C'显示为'c','D'显示为'd','E'显示为'E','F'显示为'F'.
;注意6121的遥控器发射码依次为:同步头(引导码)+32位数据码(用户码低8位+用户码高8位+键码+键码的反码)
;引导码是由9MS的高电平加4.5MS的低电平构成,我们接收到的刚好反相为9MS的低电平加4.5MS的高电平.
;数据码'0'是由560US的高电平加560US的低电平构成,接收时反相为560US的低电平加560US的高电平构成.
;数据码'1'是由560US的高电平加1.69MS的高电平构成,接收时反相为560US的低电平加1.69MS的高电平构成.
;PIC单片机学习网    陈学乾   http://www.pic16.com
;程序文件名：“MCD-RMT.ASM"
;*******************************************************************
RTCC   EQU 01H           ;定义定时器0地址
PC     EQU 02H           ;定义程序计数器低字节寄存器地址
STATUS EQU 03H           ;定义状态寄存器地址
PORTA  EQU 05H           ;定义RA口数据寄存器地址
PORTB  EQU 06H           ;定义RB口数据寄存器地址
PORTC  EQU 07H           ;定义RC口数据寄存器地址
INTCON EQU 0BH           ;定义中断控制寄存器

OPTION_REG  EQU 81H      ;
TRISA       EQU 85H      ;定义RA口方向控制寄存器
TRISB       EQU 86H      ;定义RB口方向控制寄存器
TRISC       EQU 87H      ;定义RC口方向控制寄存器
ADCON1      EQU 9FH      ;定义ADC模块控制寄存器1的地址
;-----------------------STATUS
C           EQU 0        ;定义进位标志位位地址
Z           EQU 2         ;定义0标志位位地址
RP0         EQU 5          ;寄存器体选
;-------------------------INTCON
T0IF        EQU 2          ;定时器0溢出中断标志位
T0IE        EQU 5          ;定时器0溢出中断允许/禁止
GIE         EQU 7          ;总中断允许/禁止
;-------------------------
RMT         EQU 1          ;遥控接收输入脚位地址（RA。1）
;-------------------------
BITIN       EQU 7           ;遥控接收数据位位标志
;-------------------------
CNT0         EQU 20H          ;用户临时寄存器1
CNT1         EQU 21H          ;用户临时寄存器2
CNT2         EQU 22H          ;用户临时寄存器3
CNT3         EQU 23H          ;用户临时寄存器4
TABADD       EQU 24H          ;数码管显示码取码用寄存器
FLAGS        EQU 25H         ;显示位选标志位
DISPBUF_H    EQU 26H         ;显示器高位
DISPBUF_L    EQU 27H         ;显示器低位
W_TEMP       EQU 2BH         ;W现场保护寄存器
STATUS_TEMP  EQU 2CH         ;STATUS现场保护寄存器
CSR0         EQU 2DH         ;遥控键码反码寄存器
CSR1         EQU 2EH        ;遥控器键码寄存器
CSR2         EQU 2FH        ;遥控器用户码高8位寄存器
CSR3         EQU 30H        ;遥控器用户码低8位寄存器
FLAGS2       EQU 31H        ;临时寄存器
CSR0A        EQU 32H        ;遥控接收32位数据暂存寄存器
CSR1A        EQU 33H        ;遥控接收32位数据暂存寄存器
CSR2A        EQU 34H        ;遥控接收32位数据暂存寄存器
CSR3A        EQU 35H        ;遥控接收32位数据暂存寄存器
;--------------------
               ORG 0000H
               NOP             ;放置一条ICD必须的空操作指令
               GOTO MAIN
               ORG  0004H
               GOTO TMR0SERV    ;定时器中断,扫描数码管
               ORG  0008H
;-------------------------------------------------
CONVERT   
            MOVWF    	PC             	   ;将W寄存器内的7段显示码地址放入PC 
TABLE                                       ;PC执行新地址指令， 跳到相对的地址执行?              	
	  RETLW       0C0H   		;0  ;RETLW指令，将七段显示码存入W后返回
	  RETLW       0F9H  		;1                                
	  RETLW       0A4H  		;2
	  RETLW       0B0H  		;3
	  RETLW       099H  		;4
	  RETLW       092H  		;5
	  RETLW       082H   		;6
	  RETLW       0F8H   	        ;7
	  RETLW       080H  		;8
	  RETLW       090H  		;9
          RETLW       088H            ;A
          RETLW       083H            ;b
          RETLW       0A7H            ;c 
          RETLW       0A1H            ;d
          RETLW       086H            ;E
          RETLW       08EH            ;F
;----- -----------------------------------------------
TMR0SERV
                MOVWF      W_TEMP            ;现场保护
                SWAPF      STATUS,W          ;用SWAPF才不会影响标志位
                MOVWF      STATUS_TEMP       ;将W和STATUS存入各保护寄存器

                MOVLW      0FFH
                MOVWF      PORTC             ;先熄灭所有数码管以免闪烁
                BSF        PORTA,4
                BSF        PORTA,5
                BSF        PORTA,0
                BSF        PORTA,2
                BSF        PORTA,3
  
                MOVLW      TABLE
                MOVWF      TABADD           ;将转换表的首地址存入TABADD  
                MOVFW      DISPBUF_L        ;计数值(W)与转换表的起始地址相加
                BTFSS      FLAGS,1
                MOVFW      DISPBUF_H
                ADDWF      TABADD,W
                CALL       CONVERT          ;存入W后调用转换表子程序
                MOVWF      PORTC            ;送RC口显示

                BTFSS      FLAGS,1          ;根据标志位选择是点亮那一个数码管
                BCF        PORTA,3
                BTFSC      FLAGS,1
                BCF        PORTA,2
                COMF       FLAGS,1

                MOVLW      .155         ;送定时器初值
                MOVWF      RTCC

                BCF        INTCON,T0IF      ;清定时器0溢出中断标志位
                SWAPF      STATUS_TEMP,W    ;恢复中断前STATUS，W的值
                MOVWF      STATUS
                SWAPF      W_TEMP,F
                SWAPF      W_TEMP,W         ;（用SWAPF才不会影响STATUS的值）
                RETFIE
;------------------------------------------------
MAIN
               CLRF        PORTA
               CLRF        PORTB   ;初始化IO口
     
               BSF         STATUS,RP0 ;设置寄存器体1
               MOVLW       07H
               MOVWF       ADCON1     ;设置RA口全部为普通数字IO口
               MOVLW       0C2H       ;将RMT设置为输入,其它所有IO口设置为输出
               MOVWF       TRISA 
               MOVLW       0FFH       ;RB口全部为输入
               MOVWF       TRISB  
               MOVLW       00H        ;RC口全部为输出
               MOVWF       TRISC
               MOVLW       04H
               MOVWF       OPTION_REG  ;预分频器分配给定时器0，分频比1:32;开启RB口弱上拉.
               BCF         STATUS,RP0  ;恢复寄存器体0
   
               MOVLW       .155
               MOVWF       RTCC       ;定时器送初值(255-155)*32US=3.2MS,每3.2MS一次中断 
               MOVLW       0FFH       ;先让数码管全部不显示
               MOVWF       PORTC
               CLRF        DISPBUF_L  ;数码管先显示00
               CLRF        DISPBUF_H
               BCF         INTCON,T0IF
               BSF         INTCON,T0IE ;定时器0溢出中断允许
               BSF         INTCON,GIE  ;总中断允许
;--------------------------------------------------
LOOP	  	   
               BTFSS       PORTB,1     ;是否按下S9
               GOTO        KEY1        ;跳转键处理
               BTFSS       PORTB,2     ;是否按下S10
               GOTO        KEY2         ;跳转键处理
               BTFSS       PORTB,3      ;是否按下S11
               GOTO        KEY3          ;跳转键处理
               BTFSS       PORTA,RMT    ;是否有遥控器按下
               GOTO        RCV          ;跳转遥控接收程序
               GOTO        LOOP         ;反复检测
;--------------------------------------------------
KEY1                                     ;将键码送显示
              
               CLRF        CNT0          ;消除键抖动
               MOVLW       .100
               MOVWF       CNT1 
KEY1_A
               BTFSC       PORTB,1      
               INCF        CNT0,1
               BTFSS       PORTB,1
               CLRF        CNT0
               BTFSC       CNT0,3
               GOTO        LOOP
               DECFSZ      CNT1,1
               GOTO        KEY1_A
               SWAPF       CSR1,W        ;键码值高低位交换，先处理高位
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_H     ;存入寄存器
               MOVFW       CSR1          ;键码值低位处理
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_L     ;存入寄存器 
               BTFSS       PORTB,1       ;等待键释放
               GOTO        $-1      
               GOTO       LOOP
;----------------------------------------------------
KEY2                                     ;将用户码低8位送显示
               CLRF        CNT0          ;消除键抖动
               MOVLW       .100
               MOVWF       CNT1
KEY2_A
               BTFSC       PORTB,2       
               INCF        CNT0,1
               BTFSS       PORTB,2
               CLRF        CNT0
               BTFSC       CNT0,3
               GOTO        LOOP
               DECFSZ      CNT1,1
               GOTO        KEY2_A
               SWAPF       CSR3,W        ;用户码低8位 高低位交换，先处理高位
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_H     ;存入寄存器
               MOVFW       CSR3          ;用户码低8位 低位处理
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_L     ;存入寄存器 
               BTFSS       PORTB,2       ;等待键释放
               GOTO        $-1      
               GOTO       LOOP
;-------------------------------------------------------
KEY3                                     ;将用户码高8位送显示
               CLRF        CNT0
               MOVLW        .100         ;消除键抖动
               MOVWF        CNT1
KEY3_A
               BTFSC       PORTB,3       
               INCF        CNT0,1
               BTFSS       PORTB,3
               CLRF        CNT0
               BTFSC       CNT0,3
               GOTO        LOOP
               DECFSZ      CNT1,1
               GOTO        KEY3_A
               SWAPF       CSR2,W        ;显示值高低位交换，先处理高位
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_H     ;存入寄存器
               MOVFW       CSR2          ;显示值低位处理
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_L     ;存入寄存器 
               BTFSS       PORTB,3       ;等待键释放
               GOTO        $-1      
               GOTO       LOOP                             
;--------------------------------------------------
RCV
               BTFSC       PORTA,RMT
               GOTO        LOOP        ;是干扰退出
               MOVLW        .4
               MOVWF       CNT1       ;4*256*10us
               CLRF        CNT2
               CLRF        CNT0
RCV1                                     ;先检测引导码的9MS低电平
               GOTO        $+1           ;每一个循环10US 
               NOP
               BTFSC       PORTA,RMT
               INCF        CNT2,1
               BTFSS       PORTA,RMT
               CLRF        CNT2
               BTFSC       CNT2,3         ;高电平大于8*10US=80US则为有效高电平,否则是一些干扰信号
               GOTO        RCV2
               DECFSZ      CNT0,1
               GOTO        RCV1
               DECFSZ      CNT1,1
               GOTO        RCV1
               GOTO        LOOP           ;低电平大于4*256*10US=10.24MS则是错误脉冲
RCV2
               MOVLW        .3             
               SUBWF       CNT1,0         ;低电平小于2*256*10US=5.12MS则是错误脉冲
               SKPNC
               GOTO        LOOP
               MOVLW       .3
               MOVWF       CNT1           ;3*256*10us
               CLRF        CNT2
               CLRF        CNT0
RCV3
               GOTO        $+1             ;每一个循环10US
               NOP
               BTFSS       PORTA,RMT
               INCF        CNT2,1
               BTFSC       PORTA,RMT
               CLRF        CNT2
               BTFSC       CNT2,3         ; 低电平大于8*10US=80US则为有效低电平,否则是一些干扰信号
               GOTO        RCV4
               DECFSZ      CNT0,1         
               GOTO        RCV3
               DECFSZ      CNT1,1
               GOTO        RCV3
               GOTO        LOOP           ;高电平大于3*256*10US=7.68MS则是错误的
RCV4
               MOVLW       .3
               SUBWF       CNT1,0         ;高电平小于1*256*10US=2.56MS则是错误的
               SKPNC
               GOTO        LOOP
               
               MOVLW       .32
               MOVWF      CNT2            ;接收数据共32位,16位用户码,8位控制码加8位控制码的反码
RCV5
               CLRF       CNT3 
               MOVLW      .170           ;低电平大于256-170=86*10US=860US错误
               MOVWF      CNT0  
               MOVLW      .56
               MOVWF      CNT1            ;高电平大于256-56=200*10US=2MS错误
RCV5_HI            
               GOTO       $+1
               NOP
               BTFSC      PORTA,RMT
               INCF       CNT3,1
               BTFSS      PORTA,RMT
               CLRF       CNT3
               BTFSC      CNT3,2        ;高电平大于8*10US=80US则为有效高电平
               GOTO       RCV6
               INCFSZ     CNT0,1
               GOTO       RCV5_HI       ;低电平大于860US则是错误的
               GOTO       LOOP
RCV6
               CLRF       CNT3
RCV6_LO              
               GOTO       $+1
               NOP
               BTFSS      PORTA,RMT
               INCF       CNT3,1
               BTFSC      PORTA,RMT
               CLRF       CNT3
               BTFSC      CNT3,3      ;低电平大于10*8US=80US则是有效低电平
               GOTO       COMPARE 
               INCFSZ     CNT1,1      
               GOTO       RCV6_LO     ;高电平大于256-56=200*10US=2MS错误
               GOTO       LOOP
COMPARE        
               MOVLW        .170
               SUBWF        CNT0,1     ;CNT0的值减初始值等于实际低电平计数值
               MOVLW        .56
               SUBWF        CNT1,1     ;CNT1的值减初始值等于实际高电平计数值
               MOVFW        CNT1
               ADDWF        CNT0,1     ;将高低电平的计数加在一起并存入CNT0,通过比较高低电平总的时间来确定是1还是0
               SKPNC
               GOTO         LOOP       ;总的值大于255(即时间大于255*10US=2.55MS)则错误
               MOVLW        .70
               SUBWF        CNT0,0
               SKPC
               GOTO         LOOP        ;总的时间小于70*10US=700US则是错误的
               MOVLW        .130         ;130*10=1.3MS
               SUBWF        CNT0,0
               SKPNC
               GOTO         COMPARE_H     ;时间大于1.3MS转去确定是否1
               BCF          FLAGS2,BITIN  ;时间在700US-1.3MS之间则是0
               GOTO         MOVDATA       ;送数
COMPARE_H
               MOVLW        .160
               SUBWF        CNT0,0
               SKPC
               GOTO         LOOP            ;小于160*10US=1.6MS,则错误
               MOVLW        .230
               SUBWF        CNT0,0
               SKPNC 
               GOTO         LOOP            ;大于230*10US=2.3MS,则错误 
               BSF          FLAGS2,BITIN    ;时间在1.6MS-2.3MS之间则是1            
MOVDATA
               RRF         CSR0A,1           ;将每一位移入相应寄存器
               RRF         CSR1A,1
               RRF         CSR2A,1
               RRF         CSR3A,1
               BCF         CSR0A,7
               BTFSC       FLAGS2,BITIN     ;接收当前位送入CSR0.7
               BSF         CSR0A,7
               DECFSZ      CNT2,1           ;是否接收完32位
               GOTO        RCV5
               

               MOVFW       CSR0A            ;将临时寄存器中的数存回相应寄存器
               MOVWF       CSR0
               MOVFW       CSR1A
               MOVWF       CSR1
               MOVFW       CSR2A
               MOVWF       CSR2
               MOVFW       CSR3A
               MOVWF       CSR3
    
               COMF        CSR0,0           ;比较键码的反码取反后是否等于键码
               XORWF       CSR1,0
               BNZ         LOOP             ;不等于则接收到的是错误的信息
                                            ;将键码送显示
               SWAPF       CSR1,W        ;显示值高低位交换，先处理高位
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_H     ;存入寄存器
               MOVFW       CSR1          ;显示值低位处理
               ANDLW       0FH           ;屏蔽掉高位
               MOVWF       DISPBUF_L     ;存入寄存器       
               GOTO       LOOP
;------------------------------------------------------
     END
;***********************************************************
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
;    6.电路设置:将演示板的S1全部拔到OFF，S13的第3位拔到ON其它位OFF，S4全部拔到ON,S5的第5第6位拔到ON其它位OFF，LCD不要插在演示板上，
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


