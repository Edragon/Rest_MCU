;实战三、《花样LED闪烁灯》
;该实战的目的是让大家进一步熟悉IO口输入输出的的使用
;随着大家对程序指令的进一定熟悉,本实例减略了简单的注释
;通过前面的实例大家对PIC16F87X(A)的寄存器已经有了初步的认识,本实例不再
;单独定义寄存器,引入了PIC16F877的预定义文件
;PIC单片机学习网     陈学乾      http://www.pic16.com
;程序名为"MCD-LED3.ASM"
;*************************************************
;*  本程序是一个LED灯的循环闪烁程序,用INT键(S3)来切换*
;*  闪烁模式                                     *
;*************************************************
	include <p16f877.inc>
;*----
MODESEL	equ	20h
MODESELB	equ	21h
Count		equ	22h
Count1	equ	23h
Count2	equ	24h
PORTDB	equ	25h

;*-----

	org	0
        nop
	goto	start
	org	4
	goto	ISR

	org	10
start
	clrf	PORTC			;清D口
	movlw	00h
	movwf	MODESEL		;初始化模式选择寄存器
	movwf	MODESELB
	movlw	b'10010000'
	movwf	INTCON		;初始化中断控制
	bsf	STATUS,RP0
	clrf	TRISC			;设C口全为输出
	movlw	b'10111111'
	OPTION			;选择INT下降沿有效	

	bcf	STATUS,RP0
	call	FMsel
        movwf   PORTDB			
	movwf	PORTC
main	btfsc	PORTB,0		;\
	goto	$+6			; \
	call	Delay			;  按键去抖动
	btfsc	PORTB,0
	goto	$+3			; /
	call	FMsel			;/
	movwf	PORTDB
	movf	MODESELB,W		;
	movwf	MODESEL		;
	call	LongDelay
	bcf	STATUS,C
	rlf	PORTDB,1
	btfsc	STATUS,C
	bsf	PORTDB,0
	movf	PORTDB,W
	movwf	PORTC
	goto	main

;*----------
Delay					; call指令占用2个指令周期
	clrf	Count			; 清 Count占用1个指令周期
Dloop
	decfsz	Count,f			; 这两行指令将延时
	goto	Dloop			; (256 * 3) -1 个指令周期
	return				;  return占用2个指令周期

;*----------------
LongDelay
	clrf	Count
	clrf	Count1
	movlw	0x01
	movwf	Count2
LDloop
	decfsz	Count,f
	goto	LDloop
	decfsz	Count1,f
	goto	LDloop
	decfsz	Count2,f
	goto	LDloop
	return

;*---------------
FMsel
	movf	MODESEL,w
	movwf	MODESELB
	movf	MODESEL,w
	addwf	PCL
	retlw	b'11111000'
	retlw	b'11110000'
	retlw	b'11100000'
	retlw	b'11000000'
	retlw	b'10000000'
	movlw	00h
	movwf	MODESELB
	bsf	INTCON,GIE
	retlw	b'11111000'
	return

;*-------------
ISR
	btfss	INTCON,INTF
	goto	$+3
	bcf	INTCON,INTF
	incf	MODESEL
	retfie
	end
;****************************************************
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
;    6.电路设置:将演示板的S1全部拔到ON，S4全部拔到OFF，S13的第1拔到ON、第5、第6、第7全部拔到OFF ，LCD不要插在演示板上，
;   以使端口C只与8只发光二极管接通;将用于选择频率的插针跳线插到”XT OSC”位置上.
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
