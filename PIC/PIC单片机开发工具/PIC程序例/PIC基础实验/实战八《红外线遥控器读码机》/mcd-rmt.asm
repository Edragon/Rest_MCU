;������ң�ض����,�ñ�ʵ����ϱ�վ�׼��ɶ����κ�6121��6122(CD6121/CD6122/SC6121/SC6122)�������оƬ�ĺ�����ң�������û��롢���롣
;������һ��������ң�ؽ��ս������,�������������ʾ�õ��Ƕ�ʱ���жϷ��Ķ�̬ɨ��
;��̬��ʾ��λ����ܵķ������жϷ���������3MS�ж�һ�δӶ�������λ���������������
;��׼ʵ�������߽���ͷ�ᰴҪ�ⶨ��ң�����Ĵ��ⰴ��һ�Σ���ʱʵ�����м���λ����ܽ���ʾ�ü��ļ��룬
;(��ʾΪ16���Ƶ�),�ᴥʵ����S10��ʱ��ʾ���л�Ϊ��ʾ��ǰң�����û���ĵ�8λ, �ᴥʵ����S11��ʱ��ʾ���л�Ϊ��ʾ��ǰң�����û���ĸ�8λ,
;�ᴥʵ����S9��ʱ��ʾ��һ�λص���ʾ��ǰ���ļ���.
;ע��:���е���ʾ��Ϊ16����,'A'��ʾΪ'A','B'��ʾΪ'b','C'��ʾΪ'c','D'��ʾΪ'd','E'��ʾΪ'E','F'��ʾΪ'F'.
;ע��6121��ң��������������Ϊ:ͬ��ͷ(������)+32λ������(�û����8λ+�û����8λ+����+����ķ���)
;����������9MS�ĸߵ�ƽ��4.5MS�ĵ͵�ƽ����,���ǽ��յ��ĸպ÷���Ϊ9MS�ĵ͵�ƽ��4.5MS�ĸߵ�ƽ.
;������'0'����560US�ĸߵ�ƽ��560US�ĵ͵�ƽ����,����ʱ����Ϊ560US�ĵ͵�ƽ��560US�ĸߵ�ƽ����.
;������'1'����560US�ĸߵ�ƽ��1.69MS�ĸߵ�ƽ����,����ʱ����Ϊ560US�ĵ͵�ƽ��1.69MS�ĸߵ�ƽ����.
;PIC��Ƭ��ѧϰ��    ��ѧǬ   http://www.pic16.com
;�����ļ�������MCD-RMT.ASM"
;*******************************************************************
RTCC   EQU 01H           ;���嶨ʱ��0��ַ
PC     EQU 02H           ;���������������ֽڼĴ�����ַ
STATUS EQU 03H           ;����״̬�Ĵ�����ַ
PORTA  EQU 05H           ;����RA�����ݼĴ�����ַ
PORTB  EQU 06H           ;����RB�����ݼĴ�����ַ
PORTC  EQU 07H           ;����RC�����ݼĴ�����ַ
INTCON EQU 0BH           ;�����жϿ��ƼĴ���

OPTION_REG  EQU 81H      ;
TRISA       EQU 85H      ;����RA�ڷ�����ƼĴ���
TRISB       EQU 86H      ;����RB�ڷ�����ƼĴ���
TRISC       EQU 87H      ;����RC�ڷ�����ƼĴ���
ADCON1      EQU 9FH      ;����ADCģ����ƼĴ���1�ĵ�ַ
;-----------------------STATUS
C           EQU 0        ;�����λ��־λλ��ַ
Z           EQU 2         ;����0��־λλ��ַ
RP0         EQU 5          ;�Ĵ�����ѡ
;-------------------------INTCON
T0IF        EQU 2          ;��ʱ��0����жϱ�־λ
T0IE        EQU 5          ;��ʱ��0����ж�����/��ֹ
GIE         EQU 7          ;���ж�����/��ֹ
;-------------------------
RMT         EQU 1          ;ң�ؽ��������λ��ַ��RA��1��
;-------------------------
BITIN       EQU 7           ;ң�ؽ�������λλ��־
;-------------------------
CNT0         EQU 20H          ;�û���ʱ�Ĵ���1
CNT1         EQU 21H          ;�û���ʱ�Ĵ���2
CNT2         EQU 22H          ;�û���ʱ�Ĵ���3
CNT3         EQU 23H          ;�û���ʱ�Ĵ���4
TABADD       EQU 24H          ;�������ʾ��ȡ���üĴ���
FLAGS        EQU 25H         ;��ʾλѡ��־λ
DISPBUF_H    EQU 26H         ;��ʾ����λ
DISPBUF_L    EQU 27H         ;��ʾ����λ
W_TEMP       EQU 2BH         ;W�ֳ������Ĵ���
STATUS_TEMP  EQU 2CH         ;STATUS�ֳ������Ĵ���
CSR0         EQU 2DH         ;ң�ؼ��뷴��Ĵ���
CSR1         EQU 2EH        ;ң��������Ĵ���
CSR2         EQU 2FH        ;ң�����û����8λ�Ĵ���
CSR3         EQU 30H        ;ң�����û����8λ�Ĵ���
FLAGS2       EQU 31H        ;��ʱ�Ĵ���
CSR0A        EQU 32H        ;ң�ؽ���32λ�����ݴ�Ĵ���
CSR1A        EQU 33H        ;ң�ؽ���32λ�����ݴ�Ĵ���
CSR2A        EQU 34H        ;ң�ؽ���32λ�����ݴ�Ĵ���
CSR3A        EQU 35H        ;ң�ؽ���32λ�����ݴ�Ĵ���
;--------------------
               ORG 0000H
               NOP             ;����һ��ICD����Ŀղ���ָ��
               GOTO MAIN
               ORG  0004H
               GOTO TMR0SERV    ;��ʱ���ж�,ɨ�������
               ORG  0008H
;-------------------------------------------------
CONVERT   
            MOVWF    	PC             	   ;��W�Ĵ����ڵ�7����ʾ���ַ����PC 
TABLE                                       ;PCִ���µ�ַָ� ������Եĵ�ִַ��?              	
	  RETLW       0C0H   		;0  ;RETLWָ����߶���ʾ�����W�󷵻�
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
                MOVWF      W_TEMP            ;�ֳ�����
                SWAPF      STATUS,W          ;��SWAPF�Ų���Ӱ���־λ
                MOVWF      STATUS_TEMP       ;��W��STATUS����������Ĵ���

                MOVLW      0FFH
                MOVWF      PORTC             ;��Ϩ�����������������˸
                BSF        PORTA,4
                BSF        PORTA,5
                BSF        PORTA,0
                BSF        PORTA,2
                BSF        PORTA,3
  
                MOVLW      TABLE
                MOVWF      TABADD           ;��ת������׵�ַ����TABADD  
                MOVFW      DISPBUF_L        ;����ֵ(W)��ת�������ʼ��ַ���
                BTFSS      FLAGS,1
                MOVFW      DISPBUF_H
                ADDWF      TABADD,W
                CALL       CONVERT          ;����W�����ת�����ӳ���
                MOVWF      PORTC            ;��RC����ʾ

                BTFSS      FLAGS,1          ;���ݱ�־λѡ���ǵ�����һ�������
                BCF        PORTA,3
                BTFSC      FLAGS,1
                BCF        PORTA,2
                COMF       FLAGS,1

                MOVLW      .155         ;�Ͷ�ʱ����ֵ
                MOVWF      RTCC

                BCF        INTCON,T0IF      ;�嶨ʱ��0����жϱ�־λ
                SWAPF      STATUS_TEMP,W    ;�ָ��ж�ǰSTATUS��W��ֵ
                MOVWF      STATUS
                SWAPF      W_TEMP,F
                SWAPF      W_TEMP,W         ;����SWAPF�Ų���Ӱ��STATUS��ֵ��
                RETFIE
;------------------------------------------------
MAIN
               CLRF        PORTA
               CLRF        PORTB   ;��ʼ��IO��
     
               BSF         STATUS,RP0 ;���üĴ�����1
               MOVLW       07H
               MOVWF       ADCON1     ;����RA��ȫ��Ϊ��ͨ����IO��
               MOVLW       0C2H       ;��RMT����Ϊ����,��������IO������Ϊ���
               MOVWF       TRISA 
               MOVLW       0FFH       ;RB��ȫ��Ϊ����
               MOVWF       TRISB  
               MOVLW       00H        ;RC��ȫ��Ϊ���
               MOVWF       TRISC
               MOVLW       04H
               MOVWF       OPTION_REG  ;Ԥ��Ƶ���������ʱ��0����Ƶ��1:32;����RB��������.
               BCF         STATUS,RP0  ;�ָ��Ĵ�����0
   
               MOVLW       .155
               MOVWF       RTCC       ;��ʱ���ͳ�ֵ(255-155)*32US=3.2MS,ÿ3.2MSһ���ж� 
               MOVLW       0FFH       ;���������ȫ������ʾ
               MOVWF       PORTC
               CLRF        DISPBUF_L  ;���������ʾ00
               CLRF        DISPBUF_H
               BCF         INTCON,T0IF
               BSF         INTCON,T0IE ;��ʱ��0����ж�����
               BSF         INTCON,GIE  ;���ж�����
;--------------------------------------------------
LOOP	  	   
               BTFSS       PORTB,1     ;�Ƿ���S9
               GOTO        KEY1        ;��ת������
               BTFSS       PORTB,2     ;�Ƿ���S10
               GOTO        KEY2         ;��ת������
               BTFSS       PORTB,3      ;�Ƿ���S11
               GOTO        KEY3          ;��ת������
               BTFSS       PORTA,RMT    ;�Ƿ���ң��������
               GOTO        RCV          ;��תң�ؽ��ճ���
               GOTO        LOOP         ;�������
;--------------------------------------------------
KEY1                                     ;����������ʾ
              
               CLRF        CNT0          ;����������
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
               SWAPF       CSR1,W        ;����ֵ�ߵ�λ�������ȴ����λ
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_H     ;����Ĵ���
               MOVFW       CSR1          ;����ֵ��λ����
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_L     ;����Ĵ��� 
               BTFSS       PORTB,1       ;�ȴ����ͷ�
               GOTO        $-1      
               GOTO       LOOP
;----------------------------------------------------
KEY2                                     ;���û����8λ����ʾ
               CLRF        CNT0          ;����������
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
               SWAPF       CSR3,W        ;�û����8λ �ߵ�λ�������ȴ����λ
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_H     ;����Ĵ���
               MOVFW       CSR3          ;�û����8λ ��λ����
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_L     ;����Ĵ��� 
               BTFSS       PORTB,2       ;�ȴ����ͷ�
               GOTO        $-1      
               GOTO       LOOP
;-------------------------------------------------------
KEY3                                     ;���û����8λ����ʾ
               CLRF        CNT0
               MOVLW        .100         ;����������
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
               SWAPF       CSR2,W        ;��ʾֵ�ߵ�λ�������ȴ����λ
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_H     ;����Ĵ���
               MOVFW       CSR2          ;��ʾֵ��λ����
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_L     ;����Ĵ��� 
               BTFSS       PORTB,3       ;�ȴ����ͷ�
               GOTO        $-1      
               GOTO       LOOP                             
;--------------------------------------------------
RCV
               BTFSC       PORTA,RMT
               GOTO        LOOP        ;�Ǹ����˳�
               MOVLW        .4
               MOVWF       CNT1       ;4*256*10us
               CLRF        CNT2
               CLRF        CNT0
RCV1                                     ;�ȼ���������9MS�͵�ƽ
               GOTO        $+1           ;ÿһ��ѭ��10US 
               NOP
               BTFSC       PORTA,RMT
               INCF        CNT2,1
               BTFSS       PORTA,RMT
               CLRF        CNT2
               BTFSC       CNT2,3         ;�ߵ�ƽ����8*10US=80US��Ϊ��Ч�ߵ�ƽ,������һЩ�����ź�
               GOTO        RCV2
               DECFSZ      CNT0,1
               GOTO        RCV1
               DECFSZ      CNT1,1
               GOTO        RCV1
               GOTO        LOOP           ;�͵�ƽ����4*256*10US=10.24MS���Ǵ�������
RCV2
               MOVLW        .3             
               SUBWF       CNT1,0         ;�͵�ƽС��2*256*10US=5.12MS���Ǵ�������
               SKPNC
               GOTO        LOOP
               MOVLW       .3
               MOVWF       CNT1           ;3*256*10us
               CLRF        CNT2
               CLRF        CNT0
RCV3
               GOTO        $+1             ;ÿһ��ѭ��10US
               NOP
               BTFSS       PORTA,RMT
               INCF        CNT2,1
               BTFSC       PORTA,RMT
               CLRF        CNT2
               BTFSC       CNT2,3         ; �͵�ƽ����8*10US=80US��Ϊ��Ч�͵�ƽ,������һЩ�����ź�
               GOTO        RCV4
               DECFSZ      CNT0,1         
               GOTO        RCV3
               DECFSZ      CNT1,1
               GOTO        RCV3
               GOTO        LOOP           ;�ߵ�ƽ����3*256*10US=7.68MS���Ǵ����
RCV4
               MOVLW       .3
               SUBWF       CNT1,0         ;�ߵ�ƽС��1*256*10US=2.56MS���Ǵ����
               SKPNC
               GOTO        LOOP
               
               MOVLW       .32
               MOVWF      CNT2            ;�������ݹ�32λ,16λ�û���,8λ�������8λ������ķ���
RCV5
               CLRF       CNT3 
               MOVLW      .170           ;�͵�ƽ����256-170=86*10US=860US����
               MOVWF      CNT0  
               MOVLW      .56
               MOVWF      CNT1            ;�ߵ�ƽ����256-56=200*10US=2MS����
RCV5_HI            
               GOTO       $+1
               NOP
               BTFSC      PORTA,RMT
               INCF       CNT3,1
               BTFSS      PORTA,RMT
               CLRF       CNT3
               BTFSC      CNT3,2        ;�ߵ�ƽ����8*10US=80US��Ϊ��Ч�ߵ�ƽ
               GOTO       RCV6
               INCFSZ     CNT0,1
               GOTO       RCV5_HI       ;�͵�ƽ����860US���Ǵ����
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
               BTFSC      CNT3,3      ;�͵�ƽ����10*8US=80US������Ч�͵�ƽ
               GOTO       COMPARE 
               INCFSZ     CNT1,1      
               GOTO       RCV6_LO     ;�ߵ�ƽ����256-56=200*10US=2MS����
               GOTO       LOOP
COMPARE        
               MOVLW        .170
               SUBWF        CNT0,1     ;CNT0��ֵ����ʼֵ����ʵ�ʵ͵�ƽ����ֵ
               MOVLW        .56
               SUBWF        CNT1,1     ;CNT1��ֵ����ʼֵ����ʵ�ʸߵ�ƽ����ֵ
               MOVFW        CNT1
               ADDWF        CNT0,1     ;���ߵ͵�ƽ�ļ�������һ�𲢴���CNT0,ͨ���Ƚϸߵ͵�ƽ�ܵ�ʱ����ȷ����1����0
               SKPNC
               GOTO         LOOP       ;�ܵ�ֵ����255(��ʱ�����255*10US=2.55MS)�����
               MOVLW        .70
               SUBWF        CNT0,0
               SKPC
               GOTO         LOOP        ;�ܵ�ʱ��С��70*10US=700US���Ǵ����
               MOVLW        .130         ;130*10=1.3MS
               SUBWF        CNT0,0
               SKPNC
               GOTO         COMPARE_H     ;ʱ�����1.3MSתȥȷ���Ƿ�1
               BCF          FLAGS2,BITIN  ;ʱ����700US-1.3MS֮������0
               GOTO         MOVDATA       ;����
COMPARE_H
               MOVLW        .160
               SUBWF        CNT0,0
               SKPC
               GOTO         LOOP            ;С��160*10US=1.6MS,�����
               MOVLW        .230
               SUBWF        CNT0,0
               SKPNC 
               GOTO         LOOP            ;����230*10US=2.3MS,����� 
               BSF          FLAGS2,BITIN    ;ʱ����1.6MS-2.3MS֮������1            
MOVDATA
               RRF         CSR0A,1           ;��ÿһλ������Ӧ�Ĵ���
               RRF         CSR1A,1
               RRF         CSR2A,1
               RRF         CSR3A,1
               BCF         CSR0A,7
               BTFSC       FLAGS2,BITIN     ;���յ�ǰλ����CSR0.7
               BSF         CSR0A,7
               DECFSZ      CNT2,1           ;�Ƿ������32λ
               GOTO        RCV5
               

               MOVFW       CSR0A            ;����ʱ�Ĵ����е��������Ӧ�Ĵ���
               MOVWF       CSR0
               MOVFW       CSR1A
               MOVWF       CSR1
               MOVFW       CSR2A
               MOVWF       CSR2
               MOVFW       CSR3A
               MOVWF       CSR3
    
               COMF        CSR0,0           ;�Ƚϼ���ķ���ȡ�����Ƿ���ڼ���
               XORWF       CSR1,0
               BNZ         LOOP             ;����������յ����Ǵ������Ϣ
                                            ;����������ʾ
               SWAPF       CSR1,W        ;��ʾֵ�ߵ�λ�������ȴ����λ
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_H     ;����Ĵ���
               MOVFW       CSR1          ;��ʾֵ��λ����
               ANDLW       0FH           ;���ε���λ
               MOVWF       DISPBUF_L     ;����Ĵ���       
               GOTO       LOOP
;------------------------------------------------------
     END
;***********************************************************
;    �����ʵս�����Ĺ�����������:
;    1.����Դ�ļ��ͱ༭Դ�ļ�;�ڴ˽���һ�ֲ�ͬ��ǰ�潲�Ĵ���Դ�ļ��ķ���,��Windows�����еġ����±���
;   ���Ϊ�������֪�ͺ��õ��ļ��༭��,���ҿ��Է���ļ�������ע��.������������Ҫע��,һ��ע��ǰ���
;   �ֺš�;�����������İ������;���Ǳ����á�.asm����չ���洢�����Ƚ�����һ��ר����Ŀ¼��.
;    2.��MPLAB���ɿ�������:������WINDOWS������,ѡ�ÿ�ʼ>����>Microchip MPLAB>MPLAB����,����MPLAB
;   ������MPLAB������.
;    3.������Ŀ:ѡ�ò˵�File>New��Project>New Project,�����Ƚ�����һ��ר����Ŀ¼�´���һ������Ŀ,��
;   �ü��±�������Դ�ļ����뵽����Ŀ��.
;    4.������Ŀ�е�Ŀ���ļ�:ѡ��˵�Project >Build All(��Ŀ>���������ļ�),MPLAB���Զ�����MPASM����Ŀ
;   �ļ������µ�Դ�ļ�(.asm)����ʮ�����Ƶ�Ŀ���ļ�(.hex).
;    5.ICD��������:ͨ���˵�����Project>Edit Project����Option>Development Mode,������ģʽ����Ϊ
;   ��MPLAB ICD Debugger��,���OK��ť,��ICD�Ĺ�������,�ڵ��Խ׶�,���԰���˵����ͼ2-10���ø���,����ע��
;   OSCILLATORӦ����ΪXT��ʽ,������Ҫ˵�����ǣ�ѡ�С�Enable Debug Mode����ʹ�ܵ���ģʽ��ѡ�����Ŀ
;   �굥Ƭ����д���������ʱ���Ὣ�����ٿس���ͬʱд�뵥Ƭ����ָ������洢������Ȼ���������ICD��ʽ���ԡ�
;    6.��·����:����ʾ���S1ȫ���ε�OFF��S13�ĵ�3λ�ε�ON����λOFF��S4ȫ���ε�ON,S5�ĵ�5��6λ�ε�ON����λOFF��LCD��Ҫ������ʾ���ϣ�
;   ������ѡ��Ƶ�ʵĲ������߲嵽��XT OSC��λ���ϣ�����93CXX��24CXXӦ���¡�
;    7.��Ŀ�굥Ƭ����дĿ�����:�û��ڵ�����ܰ�ť��Program����Ŀ�굥Ƭ����д���������ʱ,��ȴ�һ��ʱ�䣬
;   ��������״��״̬��Ϣ���У�������ʾ��Ϣ����һ����Ҫ����ע�⣬����PIC16F87X��Ƭ����FLASH����洢���Ĳ�д
;   ���������޵ģ���ԼΪ1000�Σ�Ӧ������ʡ����ʹ��������
;    8.���к͵����û�������û���·:�ڸ���������úú�,��ICD�Ĺ���������С��,����ǰ�潲�ġ����м����ԡ��н�
;   �ܵļ��ַ������е���.�����Զ�������ʽ����ʱ,������ʱ��ֹ͢ʱ�ӳ��򷢻�����,����ķ�����,����CALL DELAYָ
;   ��ǰ���һ���ֺ�,�������»��һ��.Ϊ��ѧϰĿ��,�ڵ��Թ����п�����Ϊ�ؼ���һЩ���©��(BUG)��Ӳ������,��ģ
;   �µ�Ƭ���˿����ŵ�Ƭ�ڻ�Ƭ�����.
;    9.������дĿ�굥Ƭ��;��������ظ���������ķ����޸ĺ͵���,ʹ�ó���͵�·������״̬��ȫ����,��ʱ���Խ���
;   ������д,����ICD�����еġ�Enable Debug Mode��(ʹ�ܵ���ģʽ)ѡ������,���ٽ������ٿس���д�뵥Ƭ����.
;    10.������������:��һ���е���д������ɺ�,���ɽ�ICDģ���ICD����ͷ(����ʾ��)֮���6о���¶Ͽ�,�õ�Ƭ����
;   ��ʾ���������,�۲�ʵ��Ч��.
;
;


