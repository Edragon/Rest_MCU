;动态数码时钟显示实验参考程序

;使用资源：
;1，TMRO定时器。确定显示的位，及显示延时。
;2，TMR1定时器。秒信号产生。
;3，PORTA端口。六共阳极位数码管的位选信号，低电平有效
;4，PORTC端口。数码管的七段，RC7不用。

;功能说明:
;1.六位数码管动态扫描显示时间（格式为：HHMMSS，24小时制）。
;2.时钟信号由单片机内部定时器硬件单元编程产生。

;本实战的目的是让大家进一步熟悉定时器的编程，多位数码管动态扫描显示的编程。

;硬件接法:
;1.实验板上拨码开关S4、S5的所有位必须置ON，其他都可以关闭。
;2.最好把93C46跟24CXX存储器从板上取下。

;本实例原提供者:pic16论坛会员 leef728 ,在此鸣谢leef728同志共享本实例.
;由深圳市乾龙盛电子科技有限公司技术部钟闺田(工程师)(论坛网名:zhongruntian)验正并加于整理、注释.
;网站:PIC单片机学习网 http://www.pic16.com   讨论论坛：http://pic16.com/bbs/
;版权所有，转载请注明出处，并不能去掉或改变文件中的说明文字。
;程序文件名“TIME.ASM"
;程序清单如下:
;************************************
   LIST P=16F877A
   INCLUDE"P16F877A.INC"     
   ERRORLEVEL -302
;***********************************
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;
;***************文件寄存器定义**************
    CBLOCK 0X20
   WAW
   YIW   
   BAW
   QIW
   GEW
   SHW 
   TEMP
   COUNTER
   S3
   DAA    
   STATUS_TMP
   W_TMP 
    ENDC
;********************程序开始****************
   ORG  0000H
   NOP                                          ;复位地址
   GOTO MAIN        
   ORG  0004H

;********************中断处理程序***********
   MOVWF W_TMP
   SWAPF STATUS,W
   CLRF STATUS
   MOVWF STATUS_TMP                             ;以上4条指令为中断现场保护
   BCF  INTCON,2                                ;清除TMRO中断标志位
   MOVF TEMP,W                                  ;时间存放单元的地址
   MOVWF FSR
   MOVF INDF,W                                  ;取得某一位的时间值
   CALL BMA                                     ;查表得时间的显示代码
   MOVWF PORTC                                  ;送数码管显示
   COMF DAA,W                                   ;位码取反
   MOVWF PORTA                                  ;点亮相应的数码管
   RLF  DAA,F                                   ;准备点亮下一位
   INCF TEMP,F                                  ;下一时间存放单元地址
   BTFSS DAA,6                                  ;是否显示完六位
   GOTO RT
   MOVLW 01H                                    ;是，重新开始新一轮显示
   MOVWF DAA                                    
   MOVLW 20H                                    ;重新获取时间单元的地址
   MOVWF TEMP 
RT   
   SWAPF STATUS_TMP,W                           ;中断现场恢复   
   MOVWF STATUS
   SWAPF W_TMP,F
   SWAPF W_TMP,W
   MOVLW 0XE0                                   ;赋定时器初值
   MOVWF TMR0
   RETFIE   
 
;*******************主程序开始****************  
MAIN   
   BANKSEL TRISA                                ;选择体1
   MOVLW 00H
   MOVWF TRISA                                  ;PORTA设置为输出
   MOVWF TRISC                                  ;PORTC设置为输出
   MOVLW 06H 
   MOVWF ADCON1                                 ;设置A口为普通数字口
   BANKSEL INTCON
   MOVLW 00H
   MOVWF YIW 
   MOVWF WAW
   MOVWF QIW
   MOVWF BAW
   MOVWF SHW
   MOVWF GEW                                    ;以上7条指令清零时间
   MOVWF DAA
   MOVLW 20H
   MOVWF TEMP                                   ;时间存放单元地址

   BSF  STATUS,RP0
   MOVLW 0X05
   MOVWF OPTION_REG                             ;分频器给TMR0做定时用，且分频比1：4
   BCF  STATUS,RP0
   BSF  INTCON,7                                ;开启中断总允许位GIE
   BSF  INTCON,5                                ;开启TMRO中断允许位
   BCF  INTCON,2                                ;清除TMRO中断标志位
   MOVLW 0XE0                                   ;TMRO赋初值 
   MOVWF TMR0

   CLRF DAA                                     
   INCF DAA,F                                   ;显示位设置
;**************************************************************
KS   
   CALL DELAY                                   ;调用200ms定时程序
   CALL DELAY
   CALL DELAY
   CALL DELAY
   CALL DELAY                                   ;调用5次，刚好1s
   INCF GEW,F
   MOVF GEW,W                                   ;判断秒的个位是否够10
   XORLW .10
   BTFSS STATUS,Z
   GOTO KS                                      ;是，秒的个位清0，秒的十位加1
   INCF SHW,F                                    
   CLRF GEW
   CLRF STATUS
   MOVF SHW,W
   XORLW .6                                     ;判断秒的十位是否为6（1分钟60秒）
   BTFSS STATUS,Z 
   GOTO KS
   INCF BAW,F                                   ;是，秒的十位清0，分的个位加1
   CLRF SHW
   CLRF STATUS
   MOVF BAW,W
   XORLW .10                                    ;判断分的各位是否够10
   BTFSS STATUS,Z
   GOTO KS
   INCF QIW,F                                   ;是，分的个位清0，分的十位加1
   CLRF BAW
   CLRF STATUS
   MOVF QIW,W
   XORLW .6                                     ;判断分的十位是否够6（1小时60分）
   BTFSS STATUS,Z
   GOTO KS
   INCF WAW,F                                   ;是，分的十位清0，时的个位加1
   CLRF QIW
   CLRF STATUS
   MOVF WAW,W
   XORLW .4                                     ;判断时的个位是否够4（24小时制）
   BTFSS STATUS,Z
   GOTO KS
   INCF YIW,F                                   ;是，时的个位清0，时的十位加1
   CLRF WAW
   CLRF STATUS
   MOVF YIW,W
   XORLW .2                                     ;判断时的十位是否够2
   BTFSS STATUS,Z
   GOTO KS
   
   CLRF GEW                                     ;是，使时间回到00-00-00
   CLRF SHW
   CLRF BAW
   CLRF QIW
   CLRF WAW
   CLRF YIW
   GOTO KS                                      ;循环显示
;**************************200ms延时程序********************
DELAY  
   NOP
   BANKSEL PIE1
   BCF  PIE1,0                                  ;禁止TMR1中断
   BANKSEL T1CON
   MOVLW 24H                                    ;TMR1分频1:4
   MOVWF T1CON
   BCF  PIR1,0
   MOVLW 0X3C
   MOVWF TMR1H
   MOVLW 0XB0
   MOVWF TMR1L                                  ;TMR1赋初值0X3CB0
   BSF  T1CON,0 
LOP 
   BTFSS PIR1,0                                 ;查询是否定时时间到
   GOTO LOP
   RETURN
  
;**********************************************************
BMA 
   ADDWF PCL,F                                 ;考察偏移量      
   RETLW 0XC0                                  ;"0" 编码
   RETLW 0XF9                                  ;"1" 编码
   RETLW 0XA4                                  ;"2" 编码
   RETLW 0XB0                                  ;"3" 编码
   RETLW 0X99                                  ;"4" 编码
   RETLW 0X92                                  ;"5" 编码
   RETLW 0X82                                  ;"6" 编码
   RETLW 0XF8                                  ;"7" 编码
   RETLW 0X80                                  ;"8" 编码
   RETLW 0X98                                  ;"9" 编码
   RETLW 0XFF

;**********************************************************
  END                                          ;源程序结束
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
