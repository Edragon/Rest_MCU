;实战四《简易四路抢答器》
;该抢答器供不多于4个参赛队或者个人的抢答比赛场合使用。每个参赛队的座位前
;安装1只抢答按钮开关（用板上的S9、S10、S11、S12）和一个信号灯（D4、D5、D6、D7）。
;主持人座位前装一只复原开关（板上S3）、1只蜂鸣器（板上BUZ1）和一个抢答器工作状态
;指示灯（D10),每当主持人口头发出号令之后.哪个队先按下座位上的按钮开关,该座位的信
;号灯就先被点亮,同时封锁其他按钮开关的活动.并且熄灭主持人座位上的状态指示灯和发出
;三声类似于电话振铃的提示声,以声明此次抢答动作已经完成.在主持人确认后,按下复原按钮
;,状态指示灯重新点亮,并且同时发出"笛-笛-"声,为下一次抢答作好准备.
;PIC单片机学习网     陈学乾       http://www.pic16.com
;程序文件名:"MCD-INTBUZ.ASM"
;*********************************************************************
;程序清单
;*********************************************************************
tmr0         equ    1h    ;定义定时器/计数器0寄存器地址
status       equ    3h    ;定义状态寄存器地址
option_reg   equ   81h    ;定义选项寄存器地址
option_temp  equ   0a6h   ;（在BACK1）定义选项寄存器的备份寄存器的地址
intcon       equ   0bh    ;定义中断控制寄存器地址
portc        equ   7h     ;定义端口RC的数据寄存器地址
trisc        equ   87h    ;定义端口RC的方向控制寄存器地址
portb        equ   06h    ;定义端口RB的数据寄存器地址
trisb        equ   86h    ;定义端口RB的方向控制寄存器地址
c            equ   0      ;定义进位标志位的位地址
z            equ   2      ;定义0标志位的位地址
w            equ   0      ;定义传送目标寄存器为W的指示位
f            equ   1      ;定义传送目标寄存器为RAM的指示位
t0if         equ   2      ;定义TMR0中断标志位的位地址
t0ie         equ   5      ;定义TMR0中断使能位的位地址
inte         equ   4      ;定义外部中断使能位的位地址
intf         equ   1      ;定义外部中断标志位的位地址
count        equ   20h    ;定义一个计数器变量
count1       equ   24h    ;定义一个计数器变量
count2       equ   25h    ;定义一个计数器变量
count3       equ   27h    ;定义一个计数器变量
count4       equ   28h    ;定义一个计数器变量
portb_b      equ   21h    ;为PORTC定义一个备份寄存器
w_temp       equ   7fh    ;为W在体0和体1定义2个备份寄存器
;w_temp      equ   0ffh   ;（若是16F873/4，则需保留FFH单元）
status_temp  equ   23h    ;为STATUS定义一个备份寄存器
rp0          equ   5h     ;定义状态寄存器中的页选位RP0
;******************复位向量和中断向量***********************
             org 000h     ;
             nop          ;设置一条ICD必须的空操作指令
             goto main    ;
             org 0004h    ;
             goto serv    ;跳转到中断服务子程序
;*******************主程序************************************
main
             bsf status,rp0   ;
             movlw 0          ;
             movwf trisc      ;设置RC口全部为输出
             movlw 0ffh       ;
             movwf trisb      ;设置RB口全部为输入
             movlw 02h        ;设置选项寄存器：上拉电阻启用；INT下降沿触发
             movwf option_reg ;分频器给TMR0；分频比1：8
             bcf status,rp0   ;
             movlw 90h        ;
             movwf intcon     ;开发INT中断
             clrf portc       ;RC口灯全灭
loop
             movf portb,w      ;读取RB口数据
             iorlw b'11100001'  ;送RB口的数到备份寄存器并将除S9、S10、S11、S12以外的位全部送1
             movwf portb_b      ;
             xorlw 0ffh         ;没有键按下转LOOP继续检测
             btfsc status,z     ;
             goto loop          ;
             call delay10ms     ;防抖动廷时
             movf portb,w       ;
             iorlw b'11100001'  ;
             xorwf portb_b,0    ;再次读取RB口的数据，与前一次读的数相同则键值有效
             btfsc status,z     ;
             goto loop          ;
             comf portb_b,w     ;取反以便使被按下按键的位为1，其它位为0
             movwf portc        ;送RC口显示
             call tone3t        ;调用发声三次子程序
loop1
             comf portb,w       ;检测按键是否有松开
             andlw b'00011110'  ;
             btfsc status,z     ;
             goto loop          ;松开了返回
             goto loop1         ;没松开继续检测
;*********************中断服务子程序*****************************
serv                             
;********************保存护现场部分*******************************
             movwf w_temp        ;保护W
             swapf status,w      ;保护STATUS
             clrf status         ;选择体0
             movwf status_temp   ;将STATUS存入体0的备份寄存器
;********************* 调查中断源**********************************
             btfsc intcon,intf    ;检查不是INT中断，返回
             goto intserv         ;是！转到INT中断处理部分
             goto retfie0         ;
;*********************INT中断处理部分******************************
intserv
             clrf portc           ;令全部灯熄灭
             bsf portc,7          ;点亮D10，表示就绪
             call tone630         ;调用高音子程序
             call delay           ;调用1S廷时子程序
             call tone630         ;调用低音子程序
             bcf intcon,intf      ;清除INT中断标志位
;*************************恢复现场部分*****************************
retfie0
            swapf status_temp,w   ;恢复STATUS
            movwf status          ;
            swapf w_temp,f        ;恢复W
            swapf w_temp,w        ;
            retfie                ;中断返加
;*************************低音调发生子程序（500HZ/50MS）*************
tone500
            movlw .50             ;循环次数寄存器赋初值
            movwf count           ;50=500HZx0.05Sx2
t5lop  
            bcf intcon,t0if       ;清除TRM0溢出中断标志位
            movlw .131            ;给TMR0装入初值256-125=131
            movwf tmr0            ;启动定时器
t5here
            btfss intcon,t0if     ;定时器溢出否
            goto t5here           ;否!循环栓测
            movlw b'01000000'     ;只将BIT6置位
            xorwf portc,f         ;只将RC6(BUZ)脚电平反转,其余不变
            decfsz count,f        ;循环次数递减,为0,跳一步
            goto t5lop            ;不为0,跳回
            return                ;返回
;**************************高音调发生子程序(630HZ/50MS)*****************
tone630
            movlw .63            ;循环次数寄存器赋初值
            movwf count1         ;63=630HZx0.05Sx2
t6lop 
            bcf intcon,t0if      ;清除TRM0溢出中断标志位
            movlw .157           ;给TMR0装入初值157=256-99
            movwf tmr0           ;启动定时器
t6here
            btfss intcon,t0if     ;定时器溢出否
            goto t6here           ;否!循环栓测
            movlw b'01000000'     ;只将BIT6置位
            xorwf portc,f         ;只将RC6(BUZ)脚电平反转,其余不变
            decfsz count1,f       ;循环次数递减,为0,跳一步
            goto t6lop            ;不为0,跳回
            return                ;返回
;*********************发声1S子程序(1S=10x(50ms+50ms)***********
tonels
            movlw .10             ;循环次数寄存器赋初值
            movwf count2          ;
t1lop
            call tone500          ;调用低音子程序
            call tone630          ;调用高音子程序
            decfsz count2,f        ;循环次数递减,为0,跳一步
            goto t1lop            ;不为0,跳回
            return                ;返回
;*********************TMR0廷时子程序1S（1S=16x256x(256-12)US)********
delay
            bsf status,rp0        ;设置文件寄存器体1
            movf option_reg,w     ;保护选项寄存器内容
            movwf option_temp     ;
            movlw 07h             ;重设选项寄存器；上拉电阻启用，INT下降沿触发
            movwf option_reg      ;分频器给TRM0；分频比值设为1：256
            bcf status,rp0        ;恢复到文件寄存器体0
            movlw .16             ;循环利用TMROP定时16次
            movwf count3          ;溢出次数寄存器
d1lop
            bcf intcon,t0if        ;清除TMR0溢出中断标志位
            bcf intcon,t0ie        ;清除TMR0溢出中断使能位
            movlw .12              ;给TMR0装入初值12=256-244
            movwf tmr0             ;启动定时器
here
            btfss intcon,t0if      ;用查询法检测TMR0溢出否
            goto here              ;否！返回
            decfsz count3,f        ;是！溢出次数减1，为0，跳一步
            goto d1lop             ;否！循环利用TMR0
            bsf status,rp0         ;设置文件寄存器体1
            movf option_temp,w     ;恢复选项寄存器内容
            movwf option_reg       ;
            bcf status,rp0         ;恢复到文件寄存器体0
            return                 ;返回
;*************************断续发声3次报警子程序***********************
tone3t
            movlw .3               ;循环次数寄存器赋初值
            movwf count4           ;
t3lop
            call tonels            ;调用发声1S子程序
            call delay             ;调用廷时1S子程序
            decfsz count4,f        ;循环次数递减,为0,跳一步
            goto t3lop             ;不为0,跳回
            return                 ;返回
;**************************软件廷时10MS子程序****************************
delay10ms
            movlw .13              ;将外层循环参数值送到30H
            movwf 30h              ;
lp0
            movlw 0ffh             ;将内层循环参数值送到31H
            movwf 31h              ;
lp1
            decfsz 31h,1           ;变量31H内容递减，若为0则跳跃
            goto lp1               ;跳转到LP1
            decfsz 30h,1           ;变量30H内容递减，若为0则跳跃
            goto lp0               ;跳转到LP0
            return                 ;返回主程序
            end                    ;源程序结束
;***************************************************
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
;    6.电路设置:将演示板的S1全部拔到ON，S4全部拔到OFF，S13的第1、第5拔到ON，第6、第7拔到OFF ，LCD不要插在演示板上，
;   以使端口C只与8只发光二极管接通;将用于选择频率的插针跳线插到”XT OSC”位置上，板上93CXX、24CXX应拿下。
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
