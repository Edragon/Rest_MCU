;ʵսʮ����877A���ģ��I2Cͨ�Ŷ�д24C02��
;�����鹦���ǵ�Ƭ����λһ��,�Զ���24C02�ж�ȡ���ݵ��������ʾ,Ȼ���ֵ��1��д��24C02������������е����ݾ��ǿ����Ĵ���������һ����ʵ������
;����·��ʹ��24C02ΪATMEL��,���Ǹó���,����дʱ����ܻ��в���
;��������������DELAYʱ��
;��ʵս��Ŀ�����ô�ҽ��ϲ���ϤI2Cͨ�ŵ�ʱ����Ϥ24CXX�Ķ�д,�������ģ��I2Cͨ��
;Ӳ���ӷ�:
;1.24CXX��SDA��877A��RB5�ڣ�SCLK��877A��RB4�ڣ�WP�ӵأ�A0��A1��A2�ӵ�
;2.ʵ�鱾ʵ���뽫MCD-DEMOʵ����ϵ�93CXXϵ��оƬ��ȡ��,��ʵ������в�Ҫ����ͬ������RB�ڵİ���,����Ӱ��ͨ��ʱ��.
;3.ʵ����ϰ��뿪��S4��S5Ҫ��ON���������뿪�ض����Թرա�
;PIC��Ƭ��ѧϰ��  ��ѧǬ  http://www.pic16.com   ������̳��http://pic16.com/bbs/
;��Ȩ���У�ת����ע��������������ȥ����ı��ļ��е�˵�����֡�
;�����ļ�����MCD-24C02.ASM"
;�����嵥����:
;************************************
    LIST      P=16F877A, R=DEC
    include "P16F877A.inc"
;***********************************
__CONFIG _DEBUG_OFF&_CP_OFF&_WRT_HALF&_CPD_OFF&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_XT_OSC;
;************************************ ������ƫ����
#define SDA  PORTB,5
#define SCLK PORTB,4
;*********************
COUNT     EQU   20H
ADDR     EQU   21H
DAT     EQU   23H
TEMP     EQU   24H
;**********************
  ORG 000H
  NOP              ;����һ��ICD����Ŀղ���ָ��
  GOTO MAIN
  ORG 004H
  RETURN
  ORG 0008H
;******************************************************
TABLE            
        ADDWF PCL,1              ;��ַƫ�����ӵ�ǰPCֵ                                      	
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
        RETLW 00H 	   		;A
	    RETLW 00H 	   		;B
	    RETLW 00H 		   	;C
	    RETLW 00H 	   		;D
	    RETLW 00H 	   		;E
        RETLW 00H 	   		;F
;*******************************************************
MAIN           
  MOVLW  0FFH
  MOVWF  PORTC            ;�������ȫ��Ϩ��
  MOVLW  0FFH
  MOVWF  PORTA
  MOVLW  0FFH
  MOVWF  PORTB            ;SDT,SCLK��Ϊ�� 

  BSF STATUS,RP0          ;����RA��,RC,RB��ȫ��Ϊ���
  MOVLW 07H
  MOVWF ADCON1            ;����RA��ȫ��Ϊ��ͨ����IO��
  CLRW
  MOVWF TRISB             ;
  MOVWF TRISA
  MOVWF TRISC          
  MOVWF OPTION_REG        ;����RB���ڲ�������
  BCF STATUS,RP0

  CLRW         ;��ַ00H
  CALL RD24    ;����ַ
  MOVWF DAT     ;������ֵ��F1
  SUBLW .9    ;��������ֵ����9,��F1��Ϊ0,��0��ʼ(��Ϊ1λ�����ֻ����ʾ��0-9)
  BC  TT2     ;C=0��תTT2
TT1
  CLRF  DAT
TT2
  MOVFW DAT
  CALL TABLE   ;ȡ��ʾ����
  MOVWF PORTC   ;������C��
  BCF   PORTA ,1  ;������һλ�����
  INCF  DAT ,1     ;ÿ���ϵ�,����24CXX��00H��ַ��ֵ��1
  CLRW             ;��ַ00H
  CALL  WT24       ;д24CXX
  GOTO  $
;****************************
RD24  
       MOVWF ADDR       ;��ַ�ݴ���F4��
       CALL START24   ;����I2C
       MOVLW 0A0H 
       CALL SUBS    ;д������ַ1010000+���һλ0д���� 
       MOVFW ADDR       ;�����ַ
       CALL SUBS    ;д��ַ 
       CALL START24   ;�ٷ���ʼ�ź�
       MOVLW  0A1H    ;д������ַ1010000+���һλ1������
       CALL SUBS      
       BSF STATUS ,RP0
       BSF TRISB ,5            ;��SDA��Ϊ����,׼����
       BCF STATUS ,RP0 
       MOVLW 08H          ;����8λ����
       MOVWF COUNT
RD000 
       NOP
       NOP
       NOP
       BSF SCLK            ;������
       NOP
       BSF STATUS,C
       BTFSS SDA
       BCF STATUS,C
       RLF TEMP ,1
       BCF SCLK
       DECFSZ COUNT ,1      ;ѭ������8λ
       GOTO RD000
       BSF STATUS ,RP0
       BCF TRISB ,5            ;�ָ�SDA��Ϊ���
       BCF STATUS ,RP0
       BSF SDA
       CALL DELAY2
       BSF SCLK
       CALL DELAY2
       BCF SCLK          ;Ӧ���,SDA��1
       CALL STOP          ;��ֹͣ�ź�
       MOVFW  TEMP          ;��������������W��
       RETURN
;******************************д��24C02����
WT24    MOVWF ADDR         ;  �Ƚ���ַ�ݴ���F4  
        CALL START24      ;��ʼ����
        MOVLW 0A0H
        CALL  SUBS      ;д������ַ1010000+���һλ0д����
        MOVFW ADDR          ;�����ַ
        CALL  SUBS      ;д��ַ
        MOVFW DAT          ;�������� 
        CALL SUBS       ;д����
        CALL STOP         ;ֹͣ�ź�
        RETURN 

START24
                      ;��ʼ����
        BSF  SDA
        BSF  SCLK
        CALL DELAY2
        BCF  SDA
        CALL DELAY2
        BCF  SCLK
        RETURN 

STOP   
        BCF  SDA       ;ֹͣ����
        NOP
        NOP 
        BSF  SCLK
        CALL DELAY2
        BSF  SDA
        RETURN 

SUBS                   ;д���� 
       MOVWF TEMP     ;��Ҫд�����ݴ���F2��
       MOVLW 08H
       MOVWF COUNT    ;д8λ����
SH01  
       RLF TEMP ,1
       BSF SDA
       BTFSS  STATUS ,C
       BCF SDA
       NOP
       BSF SCLK
       CALL DELAY2
       BCF SCLK
       DECFSZ COUNT ,1  ;ѭ��д��8λ
       GOTO SH01
       BSF  SDA
       NOP
       NOP
       BSF  SCLK
       BSF  STATUS,RP0
       BSF  TRISB ,5
       BCF  STATUS,RP0
REP
       BTFSC SDA     ;��Ӧ�𵽷�δ����ȴ�
       GOTO REP
       BCF  SCLK
       BSF  STATUS,RP0
       BCF  TRISB ,5
       BCF  STATUS,RP0
       RETURN

DELAY2  
        NOP
        NOP
        NOP
        NOP
        RETURN 
;********************************************
       end                   ;Դ�������
;*****************************************************
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
