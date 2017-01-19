;单通道模拟量采集器+数码管显示

;所用资源
;1、TMRO定时器。为保证采样精度提供所需的延时
;2、PORTA端口。AN0做为模拟输入信号口，其他做为数码管的位选
;3、PORTC端口。做为7段共阳极数码管的段信号（其中PORTC7为小数点）

;功能说明
;1、本实战的目的是让大家熟悉ADC模块的功能以及AD转换的方法
;2、项目实现的功能：从芯片RA0输入一个可以随时变化的模拟量（通过调节DEMO板VR1实现）
;则单片机就能够及时地把该模拟量进行模/数转换，并用LED显示出来，我们可以看到转换结果
;会随模拟量的变化而变化，从而以让我们了解片内ADC模块的工作情况。
;3、本例的软件设计思路：利用单片机片内硬件资源TMR0和预分频器，为ADC提供定时启动信号。但是
;没有利用其中断功能，而是采用了软件查询方式，转换结果采用了右对齐方式，
;A/D转换的时钟源选用了系统周期的8倍，本例对于ADC的电压基准要求不高，
;我们就选用了电源电压VDD和VSS作为基准电压，
;4、对于A/D转换过程是否完成也没有利用ADC模块的中断功能，而是以软件方式查询其中启动位GO是否为0。本例中选用的模拟通道为AN0。

;硬件连接
;1、拨码开关S13第2必须置ON以打开ANO模拟输入通道，S13其他位可关闭
;2、拨码开关S5数码管位信号必须置ON，但是为了影响显示效果，最好把第8位关闭。
;3、拨码开关S4数码管段信号必须置ON。

;本实例原提供者:pic16论坛会员sxwy ,在此鸣谢sxwy同志共享本实例.
;由深圳市乾龙盛电子科技有限公司（PIC单片机学习网）技术部钟闺田(工程师)验正并加于整理、注释.
;网站 http://www.pic16.com   讨论论坛：http://pic16.com/bbs/
;版权所有，转载请注明出处，并不能去掉或改变文件中的说明文字。
;程序文件名“ADC.ASM"

;程序清单如下:

;***************************************************************************************
#include "p16f877A.inc"
 errorlevel -302
;***********************************
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;
;************************************
disbuf    equ 20h            ;显示缓冲区20,21,22
ledtemp   equ 29h
vrevh     equ 2Ah
vrevl     equ 2Bh
SOUH      equ 40h            ;子程序入口高位
SOU       equ 41h            ;子程序入口低位
RLTH      equ 42h            ;子程序入口高位
RLT       equ 43h            ;子程序入口低位
CNT       equ 44h            ;子程序用寄存器
TEMP1     equ 45h            ;子程序用
TEMP2     equ 46h            ;同上
TEMP3     equ 47h            ;同上
TEMP4     equ 48h            ;同上
  
 
;*****************************************
 org 0000h
 NOP
 goto start 
 org 0005H
start:
 banksel TRISA
 movlw B'00000001'                 ;AN0>>>>DC input DC通道上输入,注意,这里是打开RA0,但是在ICD上RA0 控制第二个LED.RA1
 movwf TRISA                       ;对应第一个LED,这一点在显示结果时请自已区分
 movlw B'00000000'
 movwf TRISC
 movlw B'10000111'                 ;预分频器给TMRO，且分频比为1：256                      
 movwf OPTION_REG
 clrf  STATUS
 movlw 0xa0                        ;TMRO初值
 movwf TMR0
 ;***** ***************ADC初始化
 ;***** *****************
ATOD:
 banksel ADCON1
 movlw B'10001110'                 ;转换结果右对齐，除RA0为模拟输入口外，其他RA口跟RE口均为普通数字口
 movwf ADCON1
 CLRF  STATUS
 movlw B'01000001'                 ;转换时钟频率为内部时钟的1/8，AN0通道，允许ADC工作，暂时不开启AD转换
 movwf ADCON0
 ;*****  ************************
 movlw 0x00
 movwf  disbuf
 movwf  disbuf+1
 movwf  disbuf+2

 CLRF   STATUS
 BTFSS  INTCON,T0IF                ;等待和循环检测TMR0溢出中断标志位
 GOTO   $-1                        ;如果没有发生TMR0溢出中断则返回循环检测
 BCF    INTCON,T0IF                ;保证足够的采样时间
 movlw 0xa0                        ;TMRO初值
 movwf TMR0                 
 bsf    ADCON0,GO                  ;开始转换
ADWAIT:
 btfsc ADCON0,GO
 goto ADWAIT                       ;等待转换完成
 banksel ADRESH
 movf ADRESH,w                     ;读电压值高2位
 CLRF STATUS
 movwf vrevh
 BANKSEL ADRESL
 movf ADRESL,w                     ;读电压低8位
 CLRF STATUS
 movwf vrevl                       ;装值放入接收寄存器VERVH,VERVL,为节省时间
                                   ;采样值可以直接放入SOUH,SOU,但运算不方便
 ;*******测试用B'1100001111'**********************
; movlw 0x03                        ;这里可以手动往VREVH,VrevL两个寄存器输入10位AD值,以便用来测试是否能
                                   ;在LED上显示正确的电压值,如:30F=B'1100001111'(10位采样AD值);
                                   ;30F的实际值是3.823V,那么在LED上将显示3.82,寄存器21,22,23的值分别为3,8,2
 ;movwf vrevh                       ;程序正常采样时这四句话要屏蔽;
; movlw 0x0f
; movwf vrevl
 ;************************************************
 movf vrevh,w
 movwf SOUH                        ;将被乘数放入SOUH,SOU
 movf vrevl,w
 movwf SOU
 movlw 0x00                        ;乘数放入RLTH,RLT
 movwf RLTH
 movlw 0x05                        ;
 movwf RLT                         ;这里表示:30F*5,结果放入RLTH,RLT,SOUH,SOU;
 call DUMUL                        ;>>>>>>5*V_gather,result>>>RLTH,RLT SOUH,SOU
 
 movlw 0x04                        ;准备除1024(400),放数入RLTH,RLT!!!!关键所以,要理解为重.....以下三步都是这样的操作
 movwf RLTH                        ;除法子程序用SOUH,SOU除以RLTH,RLT,因为上面的乘法程序不会超过两个字节
 movlw 0x00                        ;5V*3FF(10位满值)=13FB,所以在调用除法程序前不用考虑RLTH,RLT是否有其他值而被值   
 movwf RLT                         ;0X0400冲掉
 call  DUDIV                       ;调用除法程序,商在SOUH,SOU,余数在RLTH,RLT,对于余数再*0A处理.然后再除 0x0400
 movf  SOU,w                       ;这样的话除两次就是小数点后两位精度
 movwf disbuf                      ;这里得到电压整数值
 movf RLTH,w
 movwf SOUH                        ;送余数到SOUH,SOU,然后*0A,为小数点后一位的运算作准备
 movf RLT,w
 movwf SOU 
 movlw 0x00
 movwf RLTH
 movlw 0x0A
 movwf RLT
 call DUMUL;                       >>>余数*10>>>RLTH,RLT SOUH,SOU,这里一般在souh,sou两个字节,为除法作准备
 
 movlw 0x04                        ;放除数0X0400
 movwf RLTH
 movlw 0x00
 movwf RLT
 call DUDIV                        ;原来的余数再除以0X400
 movf SOU,w 
 movwf disbuf+1                    ;//取商到第二位电压值,这里是小数点的后一位
 movf RLTH,w                       ;然后将余数放到SOUH,SOU,为下一次乘法作准备
 movwf SOUH
 movf RLT,w
 movwf SOU 
 movlw 0x00
 movwf RLTH
 movlw 0x0A                        ;SOUH,SOU,RLTH,RLT为乘法入口
 movwf RLT
 call DUMUL                        ;>>>*10>>>RLTH,RLT SOUH,SOU,再乘以0A,出口在RLTH,RLT,SOUH,SOU
 movlw 0x04
 movwf RLTH
 movlw 0x00
 movwf RLT
 call DUDIV                       ;再除以0X0400,除完这一次后就不要再除了,因为是保留小数点后两位
 movf SOU,w 
 movwf disbuf+2                   ;取电压值,这里是小数点后两位值  
 call Led_scan
 call delay_same1
 goto ATOD                        ;循环转换
 

;*********************led scan*************************
;LED扫描程序,对应于ICD,下面程序可以优化,请自已进行优化
Led_scan: 
 movlw ledtable                   ;取得表头地址
 movwf ledtemp                    
 movf disbuf+2,w                  ;取得偏移量
 addwf ledtemp,w                  ;表头地址加上偏移量做为跳转地址
 call ledconvert                  ;查表
 movwf PORTC                      ;送数码管显示
 movlw B'11101111'
 movwf PORTA                      ;点亮相应的数码管
 call delay_same                  ;延时一段时间，保证显示足够亮度
 movlw 0ffh
 movwf PORTC                      ;清除显示，防止干扰其他位显示
 
 movlw ledtable   
 movwf ledtemp    
 movf disbuf+1,w  
 addwf ledtemp,w  
 call ledconvert  
 movwf PORTC      
 movlw B'11011111'
 movwf PORTA      
 call delay_same  
 movlw 0ffh       
 movwf PORTC      
 
 movlw ledtable
 movwf ledtemp
 movf disbuf,w
 addwf ledtemp,w
 call ledconvert
 andlw b'01111111'               ;加上小数点
 movwf PORTC
 movlw B'11111011'
 movwf PORTA
 call delay_same 
 movlw 0ffh
 movwf PORTC

 movlw 0ffh                     ;关闭所有显示
 movwf PORTA
 return
;*******end for led send***************************************
;;----------------数码管查表程序-------------------------------
ledconvert
 movwf 2
ledtable
 RETLW 0c0h                     ;0
 RETLW 0f9h                     ;1
 RETLW 0a4h                     ;2
 RETLW 0b0h                     ;3
 RETLW 099h                     ;4
 RETLW 092h                     ;5
 RETLW 082h                     ;6
 RETLW 0F8h                     ;7
 RETLW 080h                     ;8
 RETLW 090h                     ;9
 return
delay_same                      ;延时
 movlw 0F0h
 movwf 70h
lop0 decfsz 70h,1
 goto lop0
 return 
delay_same1
 movlw 0F0h
 movwf 71h
lop1 decfsz 71h,1
 goto lop1
 return 


;********************************************************************************
;//是16*16进制,如果要十进制,则要进行BCD转换
;********************DUMUL test Date:0808,ok*************************************
;具体可参考相关子程序库
;最大实现FFFF*FFFF=FFFE0001的算法 比如:0X08 0X43 * 0X00 0X10>>>0X84 0X30
;本程序实现双字节无符号数乘法。
;入口参数：被乘数在SOUH:SOU中，乘数在RLTH:RLT中。
;出口参数：结果在RLTH:RLT:SOUH:SOU中。
            IFNDEF       DUMUL1
            #DEFINE     DUMUL1                
DUMUL       MOVLW       .16
            MOVWF       CNT
            MOVF        SOU,W
            MOVWF       TEMP3
            MOVF        SOUH,W
            MOVWF       TEMP4
            CLRF        SOU         ;用于暂
            CLRF        SOUH        ;存
            CLRF        TEMP1       ;结
            CLRF        TEMP2       ;果
            BCF         STATUS,C
LOOP3       RRF         TEMP4,F
            RRF         TEMP3,F     ;将被乘数的某一位送到C中
            BTFSC       STATUS,C
            CALL        DUADD       ;将RLTH:RLT中的被乘数加上
            RRF         SOUH,F
            RRF         SOU,F
            RRF         TEMP2,F
            RRF         TEMP1,F     ;被乘数右移
            DECFSZ      CNT,F
            GOTO        LOOP3
            MOVF        SOUH,W      ;保存结果
            MOVWF       RLTH
            MOVF        SOU,W
            MOVWF       RLT
            MOVF        TEMP2,W      
            MOVWF       SOUH
            MOVF TEMP1,W
            MOVWF       SOU
            RETURN
            ;INCLUDE     "DUADD.ASM"
           ENDIF


;********************DUADD*********************
;本程序实现双字节无符号数加法。
;入口参数：被加数在SOUH:SOU中，加数在RLTH:RLT中。
;出口参数：结果在SOUH:SOU中,进位位在STATUS:C中。
;占用资源：W,024H,025H,026H,027H,一重堆栈。
           IFNDEF       DUADD1
            #DEFINE     DUADD1

DUADD       MOVF        RLT,W 
            ADDWF       SOU,F
            MOVF        RLTH,W
            BTFSC       STATUS,C
            INCFSZ      RLTH,W
            ADDWF       SOUH,F
            RETURN
           ENDIF

;********************DUDIV*********************
;本程序实现双字节无符号数除法。
;入口参数：被除数在SOUH:SOU中，除数在RLTH:RLT中。
;出口参数：商在SOUH:SOU中,余数在RLTH:RLT中.
;占用资源：W,STATUS,023H,024H,025H,026H,027H,028H,029H,一重堆栈。
;说    明: 用户在调用该子程序之前必须确定除数不为零,否则得不到正确结果.

            IFNDEF       DUDIV1
            #DEFINE     DUDIV1
                        
DUDIV       MOVLW       .16         ;循环16次
            MOVWF       CNT
            CLRF        TEMP2
            CLRF        TEMP1       ;TEMP2:TEMP1得到余数
            BCF         STATUS,C
            RLF         SOU,F
            RLF         SOUH,F
            RLF         TEMP1,F
            RLF         TEMP2,F
LOOP79      MOVF        RLTH,W
            SUBWF       TEMP2,W     ;检测是否余数大于除数
            BTFSS       STATUS,Z
            GOTO        NOCHK
            MOVF        RLT,W
            SUBWF       TEMP1,W     ;如果高位相等则检测低位
NOCHK       BTFSS       STATUS,C    
            GOTO        NOGO
            MOVF        RLT,W       ;余数减除数
            SUBWF       TEMP1,F
            BTFSS       STATUS,C
            DECF        TEMP2,F
            MOVF        RLTH,W
            SUBWF       TEMP2,F
            BSF         STATUS,C    ;结果中移入1
NOGO        RLF         SOU,F
            RLF         SOUH,F
            RLF         TEMP1,F
            RLF         TEMP2,F
            DECFSZ      CNT,F        
            GOTO        LOOP79
            BCF         STATUS,C
            RRF         TEMP2,W
            MOVWF       RLTH
            RRF         TEMP1,W     ;恢复余数
            MOVWF       RLT
            RETLW       0
           ENDIF
;**************************************************
 end


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
