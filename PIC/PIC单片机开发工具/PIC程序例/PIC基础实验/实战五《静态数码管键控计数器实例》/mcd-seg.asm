;实战5《静态数码管键控计数器实例》
;本实验的目的是让大家熟悉数码管，学习怎样应用查表程序，本程序的功能是要用PIC来实现1位
;数码管显示，程序复位后先由第一个数码管从0循环显示到9，再由第二个数码管从0显示到9，然后第三个,
;第四个,第五个,第六个再由第一个数码管显示返复循环。程序中用一个计数器由0计数到9，同时将其在LED
;上显示出来。该例给出计数值与显示码的转换方法。
;PIC单片机学习网    陈学乾   http://www.pic16.com
;程序文件名：“MCD-SEG.ASM"
;************************************************
;程序清单
  LIST P=16F877A,R=DEC    
;************************************************
 __CONFIG B'11011100110001'; 
RTCC      EQU    01H
PCL       EQU    02H ;定义程序计数器低字节寄存器地址
STATUS    EQU    03H ;定义状态寄存器地址
PORTA     EQU    05H ;定义RA口数据寄存器地址
PORTB     EQU    06H
PORTC     EQU    07H ;定义RC口数据寄存器地址
INTCON    EQU    0BH

OPTION_REG EQU   81H
TRISA     EQU    85H ;定义RA口方向控制寄存器
TRISB     EQU    86H
TRISC     EQU    87H ;定义RC口方向控制寄存器
ADCON1    EQU 9FH  ;定义ADC模块控制寄存器1的地址
;-----------------------STATUS
C         EQU    0   ;定义进位标志位位地址
Z         EQU    2   ;定义0标志位位地址
RP0       EQU    5   ;定义页选位RP0位地址
;-----------------------
COUNTER   EQU    20H  ;定义计数器寄存器
COUNT0    EQU    21H  ;定义廷时变量计数器
COUNT1    EQU    22H  ;定义廷时变量计数器
COUNT2    EQU    23H  ;定义廷时变量计数器
DISP_COUNT EQU   24H
DISP_COUNT1  EQU  25H
DISPBUFF_1   EQU  26H
DISPBUFF_2   EQU  27H
DISPBUFF_0   EQU  28H
DISPBUFF_3   EQU  29H
DISPBUFF_4   EQU  2AH
DISPBUFF_5   EQU  2BH
DATA1         EQU  2CH
;-------------------------INTCON
T0IF       EQU 2 ;定时器0溢出中断标志位
T0IE       EQU 5 ;定时器0溢出中断允许/禁止
GIE        EQU 7 ;总中断允许/禁止
W_TEMP     EQU 7FH
STATUS_TEMP EQU 30H
;--------------------
          ORG 0000H   
          NOP         ;放置一条ICD必需的空操作指令
          GOTO MAIN
          ORG 0004H
TMR0SERV
    MOVWF W_TEMP         ;现场保护
    SWAPF STATUS,W       ;用SWAPF才不会影响标志位
    MOVWF STATUS_TEMP    ;将W和STATUS存入各保护寄存器

    MOVLW 0FFH
    MOVWF PORTC          ;先熄灭数码管以免闪烁
    MOVLW 0FFH
    MOVWF PORTA

    MOVFW DISP_COUNT
    MOVWF DISP_COUNT1
    DECFSZ DISP_COUNT1,1
    GOTO  TMR0_1
    MOVFW DISPBUFF_0
    CALL CONVERT       ;存入W后调用转换表子程序
    MOVWF PORTC        ;送RB口显示
    BCF PORTA,0
    GOTO  TMR0_END
TMR0_1
    DECFSZ DISP_COUNT1,1
    GOTO  TMR0_2
    MOVFW DISPBUFF_1
    CALL CONVERT       ;存入W后调用转换表子程序
    MOVWF PORTC        ;送RB口显示
    BCF PORTA,1
    GOTO  TMR0_END
TMR0_2
    DECFSZ DISP_COUNT1,1
    GOTO  TMR0_3
    MOVFW  DISPBUFF_2
    CALL CONVERT       ;存入W后调用转换表子程序
    MOVWF PORTC        ;送RB口显示
    BCF PORTA,2
    GOTO  TMR0_END
TMR0_3
    DECFSZ DISP_COUNT1,1
    GOTO TMR0_4
    MOVFW  DISPBUFF_3
    CALL CONVERT       ;存入W后调用转换表子程序
    MOVWF PORTC 
    BCF  PORTA,3
    GOTO TMR0_END
TMR0_4
    DECFSZ DISP_COUNT1,1
    GOTO TMR0_5
    MOVFW  DISPBUFF_4
    CALL CONVERT       ;存入W后调用转换表子程序
    MOVWF PORTC 
    BCF PORTA,4
    GOTO TMR0_END
TMR0_5
    MOVFW  DISPBUFF_5
    CALL CONVERT       ;存入W后调用转换表子程序
    MOVWF PORTC 
    BCF PORTA,5
TMR0_END
    MOVLW 06H
    DECF DISP_COUNT,1
    SKPNZ
    MOVWF DISP_COUNT

    MOVLW 155            ;送定时器初值
    MOVWF RTCC

    BCF INTCON,T0IF        ;清定时器0溢出中断标志位
    SWAPF STATUS_TEMP,W     ;恢复中断前STATUS，W的值
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W          ;（用SWAPF才不会影响STATUS的值）
    RETFIE   
;-------------------- ----------------------------------
CONVERT                              ;取数码管段码
            ADDWF PCL,1              ;地址偏移量加当前PC值
TABLE                                                    	
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
        RETLW 7FH                   ;.
        RETLW 00H
;*******************************************************
MAIN
            CLRF PORTA              ;初始化IO口
            CLRF PORTC              ;
     
            BSF STATUS,RP0          ;设置RA，RC口全部为输出
            MOVLW 07H
            MOVWF ADCON1            ;设置RA口全部为普通数字IO口
            MOVLW 00H
            MOVWF TRISA             ;
            MOVWF TRISC
            MOVLW  0FFH
            MOVWF TRISB
            MOVLW 00000100B
            MOVWF OPTION_REG    ;预分频器分配给定时器0，分频比1:32 
            BCF STATUS,RP0

            MOVLW 155
            MOVWF RTCC         ;定时器送初值(255-155)*32US=3.2MS,每3.2MS一次中断 
            MOVLW 0FFH         ;先让数码管全部不显示
            MOVWF PORTC
            MOVLW 06H
            MOVWF DISP_COUNT
            CLRW
            MOVWF DISPBUFF_1
            MOVLW 1
            MOVWF DISPBUFF_0
            MOVLW 2
            MOVWF DISPBUFF_3
            MOVLW 3
            MOVWF DISPBUFF_2
            MOVLW 4
            MOVWF DISPBUFF_5
            MOVLW 5
            MOVWF DISPBUFF_4
            
            BCF INTCON,T0IF
            BSF INTCON,T0IE    ;定时器0溢出中断允许
            BSF INTCON,GIE      ;总中断允许
;----------------------
LOOPA       BTFSS PORTB,1
            GOTO LOOP_1
            BTFSS PORTB,2
            GOTO LOOP_2
            BTFSS PORTB,4
            GOTO LOOP_3
            GOTO LOOPA
LOOP_1
           BTFSC PORTB,1
           GOTO LOOPA
           MOVLW 255
           MOVWF DATA1
SET_LOOP1A
          BTFSC PORTB,1        ;去抖动
          GOTO LOOPA
          DECFSZ DATA1,1
          GOTO SET_LOOP1A
          MOVLW 6
          MOVWF DISPBUFF_1
            MOVLW 7
            MOVWF DISPBUFF_0
            MOVLW 8
            MOVWF DISPBUFF_3
            MOVLW 9
            MOVWF DISPBUFF_2
            MOVLW 0AH
            MOVWF DISPBUFF_5
            MOVLW 0
            MOVWF DISPBUFF_4
SET_LOOP1B
   BTFSS PORTB,1       ;等待按键放开
   GOTO SET_LOOP1B
   GOTO LOOPA
;--------------------------------
LOOP_2
           BTFSC PORTB,2
           GOTO LOOPA
           MOVLW 255
           MOVWF DATA1
SET_LOOP2A
          BTFSC PORTB,2        ;去抖动
          GOTO LOOPA
          DECFSZ DATA1,1
          GOTO SET_LOOP2A
          MOVLW 0BH
          MOVWF DISPBUFF_1
            MOVLW 0BH
            MOVWF DISPBUFF_0
            MOVLW 0BH
            MOVWF DISPBUFF_3
            MOVLW 0BH
            MOVWF DISPBUFF_2
            MOVLW 0BH
            MOVWF DISPBUFF_5
            MOVLW 0BH
            MOVWF DISPBUFF_4
SET_LOOP2B
   BTFSS PORTB,2       ;等待按键放开
   GOTO SET_LOOP2B
   GOTO LOOPA
;--------------------------------------                  
LOOP_3
           BTFSC PORTB,4
           GOTO LOOPA
           MOVLW 255
           MOVWF DATA1
SET_LOOP3A
          BTFSC PORTB,4        ;去抖动
          GOTO LOOPA
          DECFSZ DATA1,1
          GOTO SET_LOOP3A
          MOVLW 0
          MOVWF DISPBUFF_1
            MOVLW 1
            MOVWF DISPBUFF_0
            MOVLW 2
            MOVWF DISPBUFF_3
            MOVLW 3
            MOVWF DISPBUFF_2
            MOVLW 4
            MOVWF DISPBUFF_5
            MOVLW 5
            MOVWF DISPBUFF_4
SET_LOOP3B
   BTFSS PORTB,4       ;等待按键放开
   GOTO SET_LOOP3B
   GOTO LOOPA     
;---------------------------------廷时子程序------
DELAY	  
            MOVLW  .2              ;设置延时常数
	    MOVWF  COUNT0
L1	  		
            MOVLW  .255            ;
	    MOVWF  COUNT1
L2	  	
            MOVLW  .255            ;
	    MOVWF  COUNT2
L3	  		
            DECFSZ COUNT2,1        ;递减循环 
	    GOTO L3                ;
	    DECFSZ COUNT1,1        ;
	    GOTO L2                ;
	    DECFSZ COUNT0,1        ;
	    GOTO L1                ;
	    RETLW  0

;----- -----------------------------------------------
            END
;******************************************************
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
;    6.电路设置:将演示板的S1全部拔到OFF，S13全部拔到OFF，S4,S5全部拔到ON ，LCD不要插在演示板上，
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

