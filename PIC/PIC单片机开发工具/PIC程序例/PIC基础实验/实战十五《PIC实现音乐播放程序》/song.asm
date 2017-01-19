;PIC16F877A实现音乐播放程序（《两只老虎》片段）

;功能说明:
;1.通过驱动实验板上的蜂鸣器发声，实现音乐的播放。
;2.从TABLE中取出播放音乐的音调（1、2....7）通过改变该表中的值即可实现播放不同的音乐。
;3.从TABLE_YP中取出播放音乐的音频，即该音调持续的时间。
;4.调整DELAY延时的长短即可实现音乐播放的快慢。

;本实战的目的是让大家进一步熟悉 D单片机如何驱动蜂鸣器发声。并通过改变持续发声的时间长短来实现不同频率的声音。

;硬件接法:
;1、蜂鸣器接RC6口。
;2、本程序使用实验板上的蜂鸣器发生发声，拨码开关13的第5位必须置1，其他码开关都可以关闭。

;本实例原提供者:pic16论坛会员 ppmy ,在此鸣谢ppmy同志共享本实例.
;由深圳市乾龙盛电子科技有限公司技术部钟闺田(工程师)(论坛网名:zhongruntian)验正并加于整理、注释.
;网站:PIC单片机学习网 http://www.pic16.com   讨论论坛：http://pic16.com/bbs/
;版权所有，转载请注明出处，并不能去掉或改变文件中的说明文字。
;程序文件名“SONG.ASM"
;程序清单如下:
;***********************************
    LIST      P=PIC16F877,R=DEC
    #INCLUDE  P16F877.INC
;***********************************
    Errorlevel -302,-305
 __CONFIG _DEBUG_OFF&_CP_ALL&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;

;***********************************寄存器定义
    CBLOCK    0x20
    JP
    YP
    L1
    L2
    TA:2
    COUNT1
    COUNT2
    W_STACK
    ST_STACK
    ENDC
;************************************
    ORG    0X0000 
    nop                             ;放置一条MCD所必须的空指令
    GOTO   MAIN                     ;主程序
    ORG    0x0004
    BTFSC  PIR1,TMR1IF              ;中断子程序
    GOTO   T1                       ;转T1处理      
    RETFIE
    ORG    0x0010
;************************************
MAIN
    CLRWDT                          ;喂狗
    BCF    STATUS,RP0
    CLRF   INTCON                   ;清除其他中断标志位
    CLRF   PORTC
    CLRF   PIR1                     ;清除TMR1中断标志位
    BSF    STATUS,RP0
    BSF    PIE1,0                   ;使能TMR1中断
    MOVLW  B'10111111'              ;除RC6口输出外，其他口都设为输入
    MOVWF  TRISC                    
    BCF    STATUS,RP0 
    MOVLW  0xC0                     ;开启中断总允许位GIE跟PEIE
    MOVWF  INTCON
REPLAY
    CLRF   COUNT1                   ;从头开始查表（亦即从头开始唱歌）
SING
    CLRF   TMR1L                    
    CLRF   TMR1H                    ;清零TMR1定器
    MOVF   COUNT1,0
    CALL   TABLE                    
    MOVWF  COUNT2                   ;暂存查表结果于COUNT2中
    BCF    STATUS,Z
    SUBLW  0x00                     ;判断是否查表到最后一个数值
    BTFSC  STATUS,Z
    GOTO   REPLAY                   ;是，说明音乐播放完成，重头开始播放
    MOVF   COUNT2,0    
    ANDLW  0x0F                     ;去掉高4位只保留低4位
    MOVWF  JP                       ;保存到JP中
    SWAPF  COUNT2,0                 ;高低半字节交换
    ANDLW  0x0F                     ;去掉高4位只保留低4位
    MOVWF  YP                       ;保存到YP中，这样查表的结果的被分成高低半字节两部分分别存放在YP跟JP中
    DECF   YP,1
    MOVF   YP,0
    CALL   TABLE_YP                 
    MOVWF  TMR1H                    ;作为TMR1初值的高8位
    MOVWF  TA                       ;暂存TA中
    INCF   YP,0
    CALL   TABLE_YP
    MOVWF  TMR1L                    ;作为TMR1初值的低8位
    MOVWF  TA+1                     ;暂存TA+1中
    BSF    T1CON,TMR1ON             ;开启TMR1定时器
    CALL   DELAY                    ;延时一段时间
    INCF   COUNT1                   ;COUNT1加1，以便查表得到下一个播放的音调
    GOTO   SING                     ;返回播放下一个音调

;**************************延时程序
DELAY                         
    MOVLW  200            
    MOVWF  L1            
DELAY_1
    MOVLW  225            
    MOVWF  L2             
DELAY_2
    DECFSZ L2,1          
    GOTO   DELAY_2         
    DECFSZ L1,1          
    GOTO   DELAY_1                         
    DECFSZ JP,1
    GOTO   DELAY
    CLRWDT
    RETURN  
;*************************中断现场保护              
PUSH
    MOVWF  W_STACK                ;保存W的值
    MOVF   STATUS,0
    MOVWF  ST_STACK               ;保存STATUS的值
    RETURN
;************************中断现场恢复
POP
    MOVF   ST_STACK,0
    MOVWF  STATUS                 ;恢复STATUS的值
    MOVF   W_STACK,0              ;恢复W的值
    RETURN
;************************中断处理子程序
T1
    CALL   PUSH                   ;调用现场保护程序
    MOVLW  0x40                   ;RC6口输出取反
    XORWF  PORTC,1
    MOVF   TA,0                  
    MOVWF  TMR1H                  
    MOVF   TA+1,0
    MOVWF  TMR1L                  ;给TMR1赋初值
    BSF    T1CON,TMR1ON           ;开启定时器
    BCF    PIR1,TMR1IF            ;清除标志位
    CALL   POP                    ;调用现场恢复程序
    RETFIE

TABLE_YP
    ADDWF  PCL,1        
    RETLW  0xFC   ;1
    RETLW  0x44
    RETLW  0xFC   ;2
    RETLW  0xAC
    RETLW  0xFD   ;3
    RETLW  0x09
    RETLW  0xFD   ;4
    RETLW  0x34
    RETLW  0xFD   ;5
    RETLW  0x82
    RETLW  0xFD   ;6
    RETLW  0xC8
    RETLW  0xFE   ;7
    RETLW  0x06   
TABLE
    ADDWF  PCL,1
    RETLW  0x14
    RETLW  0x34
    RETLW  0x54
    RETLW  0x14
    RETLW  0x14
    RETLW  0x34
    RETLW  0x54
    RETLW  0x14
    RETLW  0x54
    RETLW  0x74
    RETLW  0x98
    RETLW  0x54
    RETLW  0x74
    RETLW  0x98
    RETLW  0x93
    RETLW  0xB1
    RETLW  0x93
    RETLW  0x71
    RETLW  0x54
    RETLW  0x14
    RETLW  0x93
    RETLW  0xB1
    RETLW  0x93
    RETLW  0x71
    RETLW  0x54
    RETLW  0x14
    RETLW  0x14
    RETLW  0x94
    RETLW  0x18
    RETLW  0x14
    RETLW  0x94
    RETLW  0x18
    RETLW  0x00    
;********************************************
       end                   ;源程序结束
;********************************************
           
;  进入该实战演练的工序流程如下:
;  1.创建源文件和编辑源文件;在此介绍一种不同于前面讲的创建源文件的方法,用Windows附件中的”记事本”
;  这个为大家所熟知和好用的文件编辑器,并且可以方便的加入中文注释.不过有两点需要注意,一是注释前面的
;  分号”;”必须用西文半角输入;二是必须用”.asm”扩展名存储到事先建立的一个专用子目录下.
;  2.打开MPLAB集成开发环境:首先在WINDOWS环境下,选用开始>程序>Microchip MPLAB>MPLAB命令,启动MPLAB
;  并进入MPLAB的桌面.
;  3.创建项目:选用菜单File>New或Project>New Project,在事先建立的一个专用子目录下创建一个新项目,将
;  用记事本创建的源文件加入到该项目中.
;  4.建立项目中的目标文件:选择菜单Project >Build All(项目>建立所有文件),MPLAB将自动调用MPASM将项目
;  文件管理下的源文件(.asm)汇编成十六进制的目标文件(.hex).
