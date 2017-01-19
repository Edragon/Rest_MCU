;18B10温度测量+LCD1602显示温度

;实战目的
;1、学习18B20单总线温度传感器的使用。
;2、学习LCD的使用。
;3、学习10进制转10进制的方法。

;所有资源：
;1、TMRO定时器。产生温度转换所需要的延时时间。
;2、PORTA口。即做LCD显示时可控制端口，RA2同时做18B20的数据接口
;3、PORTC口。做LCD显示时的数据口。

;功能说明
;1、通过18B20采集当前环境
;最高温度可显示127.9375，最低温度可显示0.0625（无负温度处理部分）
;2、将温度在LCD上显示（3位整数，4位小数）

;硬件连接
;1，在18B20按DEMO板上的标识插在插座U8上
;2，拨码开关S13第4位置ON
;3，其他所有拨码开关都置OFF

;深圳市乾龙盛电子科技有限公司（PIC单片机学习网）
;网站 http://www.pic16.com   讨论论坛：http://pic16.com/bbs/
;实例编制:技术部 钟闺田(工程师)   论坛网名:zhongruntian
;版权所有，转载请注明出处，并不能去掉或改变文件中的说明文字。
;程序文件名“LCDAND18B20.ASM“

;源程序如下：
 LIST P=PIC16F877
 TITLE="LCD DISPLAY"
 ERRORLEVEl -302           ;去掉编译时的302号提示信息
;__CONFIG B'000010010101' ;代码保护开启；WRT_ENABLE;CPD_ENABLE;LVP_DISABLE;BODEN_ENABLE
                         ;PWRTE_ENABLE;WDT_ENABLE;OSC_XT

;*****************以下是暂存器的定义*****************************
#INCLUDE<P16F877A.INC>
#DEFINE RS PORTA,1         ;LCD控制信号
#DEFINE RW PORTA,2         ;LCD控制信号
#DEFINE E  PORTA,3         ;LCD控制信号
#DEFINE DAT PORTC          ;LCD数据线
#DEFINE DQ PORTA,2         ;18B20数据口

 
    CBLOCK 20H
DQ_DELAY1
DQ_DELAY2
TEMP
TEMP1
TEMP2                         ;存放采样到的温度值
COUNT
COUNT1
 ENDC
TMR0_VALUE        EQU  0AH   ;寄存器初值为6，预分频比1：4，中断一次时间为4*（256-6）=1000us
DQ_DELAY_VALUE1   EQU  0FAH
DQ_DELAY_VALUE2   EQU  4H

;***********************以下是宏定义****************************
READ_STATE  MACRO           ;读18B20的状态
    BCF    RS
    BSF    RW
    BSF    E
    ENDM

WRITE_COMMAND MACRO         ;写命令
    BCF    RS
    BCF    RW
    BCF    E
    ENDM

WRITE_DATA MACRO            ;写数据
    BSF    RS
    BCF    RW
    BCF    E
    ENDM
;**********************以下是程序的开始************************
	ORG    00H              
    NOP   
	GOTO   MAIN             ;入口地址
	ORG    04H
    RETFIE                  ;在中断入口出放置一条中断返回指令，防止干扰产生中断
   

;***************************主程序*******************************
MAIN
    CLRF     PORTC
    CLRF     PORTA
    BANKSEL  TRISA
    CLRF     TRISA              ;A口所有先设置为输出
    CLRF     TRISC
	MOVLW    01H
    MOVWF    OPTION_REG         ;分频比1：4，定时器，内部时钟源
    MOVLW    06H
    MOVWF    ADCON1             ;关闭所有A/D口
	BCF      STATUS,RP0
    MOVLW    00H
	MOVWF    INTCON             ;关闭所有中断，且同时清零T0IF
    
	CLRF     TEMP
    CLRF     TEMP1
    CLRF     TEMP2              ;清零临时寄存器
  
     
;****************************循环处理部分************************

;先启动18B20温度转换程序，在判断温度转换是否完成（需750us）
;未完成则调用显示子程序，直到完成温度转换
;完成后读取温度值
;送LCD显示
LOOP 
    CALL     RESET_18B20      ;调用复位18B20子程序
    MOVLW    0CCH 
    MOVWF    TEMP
    CALL     WRITE_18B20      ;SKIP ROM命令
    MOVLW    44H
    MOVWF    TEMP
    CALL     WRITE_18B20      ;温度转换命令   
    CLRF     STATUS
    BCF     INTCON,T0IF       
    CALL     DELAY_750MS      ;调用温度转换所需要的750MS延时
    NOP
    CALL     RESET_18B20      
    MOVLW    0CCH 
    MOVWF    TEMP
    CALL     WRITE_18B20      ;SKIP ROM命令
    MOVLW    0BEH 
    MOVWF    TEMP
    CALL     WRITE_18B20      ;读温度命令
    CALL     READ_18B20       ;调用读温度低字节
    MOVFW    TEMP
    MOVWF    TEMP1            ;保存到TEMP1
    CALL     READ_18B20       ;调用读温度高字节
    MOVFW    TEMP
    MOVWF    TEMP2            ;保存到TMEP2
	CALL     RESET_18B20      
    CALL     TEMP_CHANGE      ;调用温度转换程序
    CALL     DISPLAY          ;调用LCD显示程序
    GOTO     LOOP             ;循环工作

;***************************LCD显示子程序************************
DISPLAY
;LCD模块初始化,由厂家提供的资料显示,其初始化过程为:

;6----写指令38H,此条指令是将LCD显示模块设置为8位数据线,双行,5X7点阵显示
;7----检测Busy信号;
;8----写指令08H,关闭显示
;9----检测Busy信号;
;10---写指令01H,显示清屏
;以后写入光标等的控制指令.
    BANKSEL  TRISA
    CLRF     TRISA           ;A口为LCD控制信号，全输出
    BANKSEL  PORTA

	NOP    
    MOVLW   38H
    CALL    COMMAND_WRITE    ;显示模式设置：16*2显示，5*7点阵，8位数码接口
    MOVLW   08H
    CALL    COMMAND_WRITE    ;显示关闭，不显示光标
    MOVLW   01H
    CALL    COMMAND_WRITE    ;显示清屏
    MOVLW   06H
    CALL    COMMAND_WRITE    ;显示光标移动设置（右移），整屏显示不移动
    MOVLW   0CH
    CALL    COMMAND_WRITE    ;显示开及光标设置，不显示光标
DISPLAY0
    MOVLW   84H
    CALL    COMMAND_WRITE    ;设置显示起始位置
    CALL    BUSY             ;判忙
   
    MOVLW   8H               ;共8个数据需要显示
    MOVWF   COUNT
    MOVLW   37H              ;取数地址
    MOVWF   FSR
DISPLAY1
    INCF    FSR,1            ;取数地址加1
    MOVFW   INDF
    CALL    DATA_WRITE       ;调用写数据子程序
    DECFSZ  COUNT,1
    GOTO    DISPLAY1         	  
    RETURN

;*****************************写命令子程序***********************
COMMAND_WRITE   
    WRITE_COMMAND            ;设置写命令所需要的控制信号
    MOVWF    DAT             ;把命令字送数据口
    BSF      E
    NOP
    BCF      E              
    CALL     BUSY            ;判忙
    RETURN
;**************************判总线忙子程序************************
BUSY       
    BSF      STATUS,RP0
    MOVLW    80H
    MOVWF    TRISC           ;数据口最高位置为输入口
    BCF      STATUS,RP0
    READ_STATE
    NOP
    BCF      E
    BTFSC    DAT,7           ;是否忙
    GOTO     BUSY            ;是，继续判断
    BANKSEL  TRISC
    CLRF     TRISC           ;否，数据最高位恢复为输出状态
    BCF      STATUS,RP0
    RETURN
;*************************写数据子程序***************************
DATA_WRITE
    WRITE_DATA
    MOVWF    DAT
    BSF      E
    NOP
    BCF      E
    CALL     BUSY
    RETURN
   
;*********************复位DS18B20子程序**************************
RESET_18B20
;根据DATASHEET介绍,写数据时应遵照如下规定：
;主控制器把总线拉低至少480us，
;18B20等待15-60us后，把总线拉低做为返回给控制器的应答信号  	
    BANKSEL  TRISA
    BCF      TRISA,2
    BCF      STATUS,RP0
    BCF      DQ
    MOVLW    0A0H
    MOVWF    COUNT           ;160US
    DECFSZ   COUNT,1
    GOTO     $-1             ;拉低480us
    BSF      DQ              ;释放总线  
    MOVLW    14H
    MOVWF    COUNT
    DECFSZ   COUNT,1
    GOTO     $-1             ;等待60us
    BANKSEL  TRISA
    BSF      TRISA,2         ;DQ设置为输入
    BCF      STATUS,RP0
    BTFSC    DQ              ;数据线是否为低
    GOTO     RESET_18B20     ;否则继续复位
    MOVLW    4H
    MOVWF    COUNT
    DECFSZ   COUNT,1         ;延时一段时间后再次判断
    GOTO     $-1
    BTFSC    DQ
    GOTO     RESET_18B20
    MOVLW    4BH             
    MOVWF    COUNT
    DECFSZ   COUNT,1
    GOTO     $-1 
    BANKSEL  TRISA
    BCF      TRISA,2         ;DQ设置为输出
    BCF      STATUS,RP0
    RETURN
;*********************写DS18B20子程序****************************
WRITE_18B20
;根据DATASHEET介绍,写数据时应遵照如下规定：
;写数据0时，主控制器把总线拉低至少60us
;写数据1时，主控制器把总线拉低，但必须在15us内释放    
    MOVLW    8H
    MOVWF    COUNT           ;8位数据
    BANKSEL  TRISA
    BCF      TRISA,2
    BCF      STATUS,RP0
    BCF      STATUS,C
WRITE_18B20_1
    BSF      DQ              ;先保持DQ为高
    MOVLW    5H
    MOVWF    COUNT1
    BCF      DQ              ;拉低DQ15us
    DECFSZ   COUNT1,1
    GOTO     $-1            
    RRF      TEMP,1          
    BTFSS    STATUS,C        ;判断写的数据为0还是1
    GOTO     WRITE_0          
    BSF      DQ              ;为1，立即拉高数据线
    GOTO     WRITE_END
WRITE_0
    BCF      DQ              ;继续保持数据线为低
WRITE_END
    MOVLW    0FH
    MOVWF    COUNT1          ;保持45ms
    DECFSZ   COUNT1,1
    GOTO     $-1
    BSF      DQ              ;释放总线
    DECFSZ   COUNT,1         ;是否写完8位数据
    GOTO     WRITE_18B20_1
    RETURN
;**********************读DS18B20子程序****************************
READ_18B20
;根据DATASHEET介绍,读数据时应遵照如下规定：
;读数据0时，主控制器把总线拉低后，18B20再把总线拉低60us
;读数据1时，主控制器把总线拉低后，保持总线状态不变
;主控制器在数据线拉低后15us内读区数据线上的状态。         
     MOVLW    8H               ;一次读8位数据
     MOVWF    COUNT
READ_18B20_1
     BANKSEL  TRISA
     BCF      TRISA,2          ;数据线先设为输出
     BCF      STATUS,RP0
     BCF      DQ               ;先拉低数据线
     MOVLW    1H
     MOVWF    COUNT1          
     DECFSZ   COUNT1,1         ;拉低总线3us 
     GOTO     $-1
     BSF      DQ               ;释放总线
     BANKSEL  TRISA
     BSF      TRISA,2          ;数据线设为输入
     BCF      STATUS,RP0
     MOVLW    2H
     MOVWF    COUNT1
     DECFSZ   COUNT1,1         ;延时6ms
     GOTO     $-1
     BSF      STATUS,C
     BTFSS    DQ               ;判断数据线状态
     BCF      STATUS,C
     RRF      TEMP,1           ;移位到TEMP中
     MOVLW    12H
     MOVWF    COUNT1
     DECFSZ   COUNT1,1
     GOTO     $-1              ;读一位数据至少需要60us
     DECFSZ   COUNT,1          ;是否读完8位
     GOTO     READ_18B20_1
     RETURN
;*******************温度表示形式转换程序************************** 
;因为从18B20中读出的温度值是二进制形式，必须把它转换成对象ASCII才能在LCD上显示
;18B20中温度的表示为：S S S S S 2的6次方 2的5次方 2的4次方    2的3次方 2的2次方 。。。。2的负4次方
;结果整数放在38H开始的存储器里，小数部分放在3B开始的单元里
;38H(百位） 39H（十位） 3AH（个位） 3BH（小数点）3CH(十分位） 3DH（百分位） 3EH（千分位） 3FH（万分位）
TEMP_CHANGE 
;整数部分
;因为转换后温度值位于两个单元内，所以必须先把它们组合到一个单元内。
;因为最大值为127.9375，所以只需判断结果是否大于100来决定百位上的结果
;用循环减0AH的方法得到十位的值，最后剩下的被减数即为个位的结果    
    MOVLW    7H 
    ANDWF    TEMP2,1         ;只保留低3位
    SWAPF    TEMP2,0         
    MOVWF    3AH             ;转存3AH
    MOVFW    TEMP1
    MOVWF    TEMP2           ;转存TEMP2
    MOVLW    0F0H            
    ANDWF    TEMP2,1         ;清除低4位
    SWAPF    TEMP2,0         ;高低半字节交换
    IORWF    3AH,1           ;组合得到结果的7位整数部分
    
    MOVLW    64H             ;计算整数部分百位的结果
    SUBWF    3AH,W           ; -100
    BTFSS    STATUS,C
    GOTO     NEXT0           ;温度小于100
    MOVWF    3AH             ;减后的结果覆盖原来的数据
    MOVLW    1H            
    MOVWF    38H             ;整数部分最高位为1（不可能大于1）
    GOTO     $+2
NEXT0
    CLRF     38H             ;温度小于100，最高位为0
    CLRF     39H             ;计算整数部分十位的结果
    MOVLW    0AH             ; -10
    SUBWF    3AH,1
    BTFSS    STATUS,C
    GOTO     NEXT1
    INCF     39H,1           ;够减 十位上加1
    GOTO     $-5
NEXT1
    MOVLW    0AH
    ADDWF    3AH,1            ;多减一次再加回来，剩下的值即为个位上的值
    
    MOVLW    '.'
    MOVWF    3BH               ;小数点
    
;小数部分
;取四位精度
;计算方法为从最低位开始依次判断是否为1 ，若为1则分别加上：
;0.0625、0.125、0.25、0.5，而且只有百分位相加时有可能结果大于0AH
	CLRF     3CH
    CLRF     3DH
    CLRF     3EH
    CLRF     3FH
    BTFSS    TEMP1,0           
    GOTO     NEXT2
    MOVLW    5H
    MOVWF    3FH
    MOVLW    2H
    MOVWF    3EH
    MOVLW    6H
    MOVWF    3DH               ;万分位  
NEXT2
    BTFSS    TEMP1,1
    GOTO     NEXT3
    MOVLW    5H
    ADDWF    3EH,1
    MOVLW    2H
    ADDWF    3DH,1
    MOVLW    1H
    MOVWF    3CH              ;千分位

NEXT3
    BTFSS    TEMP1,2
    GOTO     NEXT5
    MOVLW    5H
    ADDWF    3DH,1
    MOVLW    0AH
    SUBWF    3DH,1
    BTFSS    STATUS,C
    GOTO     NEXT4
    INCF     3CH,1
    GOTO     $+3
NEXT4
    MOVLW    0AH
    ADDWF    3DH,1
    MOVLW    2H
    ADDWF    3CH,1            ;百分位

NEXT5
    BTFSS    TEMP1,3
    GOTO     NEXT6
    MOVLW    5H
    ADDWF    3CH,1           ;十分位
NEXT6
    MOVLW    30H             ;各位加上30H，转换成对应的ASCII码，以便能在LCD上显示
    ADDWF    38H,1
    ADDWF    39H,1
    ADDWF    3AH,1
    ADDWF    3CH,1
    ADDWF    3DH,1
    ADDWF    3EH,1
    ADDWF    3FH,1
   
    RETURN

;**************************延时750ms******************************
DELAY_750MS
    MOVLW    DQ_DELAY_VALUE2
    MOVWF    DQ_DELAY2
DELAY_750MS_2
    MOVLW    DQ_DELAY_VALUE1
    MOVWF    DQ_DELAY1
DELAY_750MS_1
    MOVLW    TMR0_VALUE
    MOVWF    TMR0               ;开启定时器
    BTFSS    INTCON,T0IF
    GOTO     $-1
    BCF     INTCON,T0IF
    DECFSZ   DQ_DELAY1,1
    GOTO     DELAY_750MS_1
    DECFSZ   DQ_DELAY2,1
    GOTO     DELAY_750MS_2
    RETURN
;**************************程序结束******************************
    END
    
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
