;ʵսʮһ��877A���ģ��SPIͨ�Ŷ�д93C46��
;����˵��:
;1.��һ���Ƶ�����,�����Ƶ�8���뽨��TABLE��.
;2.��TABLE��ȡ�����ݲ���16λ�ķ�ʽ����93C46��,��ַ00H-03H.
;3.��93C46��00H-03H��ַ�е�������ȡ��������877A��RAM(30H)-(37H),�������877A��RC��.
;���ϵ��ٸ���,�����벻����ʧ.
;4.����·��ʹ��93C46ΪATMEL��MICROCHIP��,���Ǹó���,����дʱ����в���
;��������������DELAYʱ��
;��ʵս��Ŀ�����ô�ҽ��ϲ���ϤSPIͨ�ŵ�ʱ����Ϥ93C46�Ķ�д,�������ģ��SPIͨ��
;Ӳ���ӷ�:
;1.93C46��CS��877A��RB1��;CLK��877A��RB2��;DI��877A��RB4��;DO��877A��RB5��;93C46��ORG�˽�VCC,ʹ93C46������16λ��ʽ
;2.ʵ�鱾ʵ���뽫MCD-DEMOʵ����ϵ�24CXXϵ��оƬ��ȡ��,��ʵ������в�Ҫ����ͬ������RB�ڵİ���,����Ӱ��ͨ��ʱ��.
;3.ʵ����ϰ��뿪��S1Ҫ��ON���������뿪�ض����Թرա�
;PIC��Ƭ��ѧϰ��  ��ѧǬ  http://www.pic16.com   ������̳��http://pic16.com/bbs/
;��Ȩ���У�ת����ע��������������ȥ����ı��ļ��е�˵�����֡�
;�����ļ�����MCD-93C46.ASM"
;�����嵥����:
;************************************
    LIST      P=16F877A, R=DEC
    include "P16F877A.inc"
;***********************************
__CONFIG _DEBUG_OFF&_CP_ALL&_WRT_HALF&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;
;************************************ ������ƫ����
READ   EQU   0  ;��93C46
WRITE  EQU   1  ;д��93C46 
EWEN   EQU   2  ;93C46д��ʹ��
EWDS   EQU   3  ;93C46д���ֹ
;*************************************��������λ��ַ
CS     EQU   1
CLK    EQU   2
DI     EQU   4
DO     EQU   5
;*********************
ADR46  EQU   20H
F1     EQU   23H
F2     EQU   24H
F3     EQU   25H
F4     EQU   26H
F5     EQU   27H
F6     EQU   28H
F7     EQU   29H
;**********************
  ORG 000H
  NOP              ;����һ��ICD����Ŀղ���ָ��
  GOTO MAIN
  ORG 0008H
;******************************************************
TABLE
  ADDWF PCL ,1   ;���PORTCһ��������
  RETLW  01H
  RETLW  02H
  RETLW  04H
  RETLW  08H
  RETLW  10H
  RETLW  20H
  RETLW  40H
  RETLW  80H
;*******************************************************
TO9346
  MOVWF F1        ;��W��ֵ��F1�ݴ�
  BSF  PORTB ,CS          ;д����ʼλ1
  BSF  PORTB ,DI
  BSF  PORTB ,CLK
  CALL DELAY
  BCF  PORTB ,CLK
  CALL DELAY
  MOVFW F1
  ADDWF PCL ,1
  GOTO  SREAD    ;��
  GOTO  SWRITE   ;д
  GOTO  SEWEN    ;дʹ��
  GOTO  SEWDS    ;д��ֹ
;*****************************************************
MAIN
  MOVLW  00H
  MOVWF  PORTC            ;LED��ȫ��Ϩ��
  MOVLW  20H
  MOVWF  PORTB            ;��DO��,����ͨ�ſ�ȫ��0

  BSF STATUS,RP0          ;����RA��,RC��ȫ��Ϊ���
  MOVLW 20H
  MOVWF TRISB             ;RB��5��Ϊ��,����ȫΪ��
  CLRW
  MOVWF TRISC             ;RC��ȫΪ���.
  MOVWF OPTION_REG        ;����RB���ڲ�������
  BCF STATUS,RP0
;*************************************
LOOP
  CLRF    21H             ;ȡ��ָ��
  CLRF    ADR46          ;93C46�ĵ�ַ00H
  MOVLW   04H
  MOVWF   22H             ;4��8����
START
  MOVLW   EWEN            ;д��ʹ��
  CALL    TO9346
  MOVFW   21H             ;����ȡ��ָ��
  CALL    TABLE           ;��TABLE ȡ��
  MOVWF   F5              ;����"д��Ĵ���"
  INCF    21H ,1          ;ȡ��һ����
  MOVFW   21H
  CALL    TABLE           ;��TABLE ȡ��
  MOVWF   F4
  MOVLW   WRITE           
  CALL    TO9346          ;д������
  MOVLW   EWDS
  CALL    TO9346          ;д��ֹ
  INCF    21H  ,1         ;ȡ��һ����
  INCF    ADR46 ,1        ;ȡ��һ����ַ
  CALL    DELAY1
  DECFSZ  22H ,1          ;ֱ��д���ĸ���ַ
  GOTO    START
  MOVLW   30H             ;����877A��RAM�׵�ַ
  MOVWF   FSR
  CLRF    ADR46           ;93C46�ĵ�ַ00
  MOVLW   04H
  MOVWF   22H             ;��93C46���ĸ���ַ,8����
;*****************
A1
  MOVLW   READ
  CALL    TO9346          ;����ַ�е�����
  MOVFW   F5
  MOVWF   INDF            ;���������ݴ���877A��RAM
  INCF    FSR ,1
  MOVFW   F4
  MOVWF   INDF
  INCF    ADR46 ,1         ;����һ����ַ
  INCF    FSR ,1
  DECFSZ  22H ,1          ;ֱ�������ĸ���ַ
  GOTO    A1
A2
  MOVLW   08H
  MOVWF   22H
  MOVLW   30H             ;RAM 30h-37H ��8����
  MOVWF   FSR
OUTPUT
  MOVFW   INDF
  MOVWF   PORTC           ;��������PORTC
  CALL    DELAY1   
  INCF    FSR ,1
  DECFSZ  22H ,1
  GOTO    OUTPUT
  GOTO    A2
;***************************
SREAD
  MOVLW  80H
  ADDWF  ADR46 ,0        ;6λ��ַ������λ������,10XXXXXX  ��ָ��
  CALL   SDT46           ;д����������ַ
  CALL   RDT46           ;����λ����
  MOVWF  F5              ;����F5
  CALL   RDT46           ;����λ��ַ              
  MOVWF  F4              ;����F4
  GOTO   EX9346
;**************************
SWRITE
  MOVLW  40H
  ADDWF  ADR46 ,0       ;6λ��ַ������λ������01XXXXXX  дָ��
  CALL   SDT46          ;д������뼰��ַ
  MOVFW  F5             ;��������
  CALL   SDT46          ;д������
  MOVFW  F4             ;��������
  CALL   SDT46          ;д������
  GOTO   EX9346 
;******************************
SEWEN
  MOVLW  30H          ;д�������0011XXXX  дʹ��ָ��
  CALL   SDT46
  GOTO   EX9346
;******************************
SEWDS
  CLRW            ;д��0000XXXXд��ָֹ��
  CALL   SDT46
;******************************
EX9346
  BCF   PORTB ,CS    ;����ʱ��CSΪ0
  RETURN
;******************************
SDT46:
  MOVWF  F2          ;��Ҫд��������F2
  MOVLW  08H         ;д��8λ����
  MOVWF  F3
SD1:
  RLF    F2 ,1
  BSF    PORTB ,DI
  BTFSS  STATUS ,C
  BCF    PORTB ,DI
  BSF    PORTB ,CLK
  CALL   DELAY
  BCF    PORTB ,CLK
  CALL   DELAY
  DECFSZ  F3 ,1
  GOTO    SD1
  RETURN
;******************************
RDT46
  MOVLW  08H         ;����8λ����
  MOVWF  F3
RD1
  BSF  PORTB ,CLK
  CALL DELAY
  BCF  PORTB ,CLK
  CALL DELAY
  BSF  STATUS ,C
  BTFSS  PORTB ,DO
  BCF  STATUS ,C
  RLF  F2 ,1
  DECFSZ  F3 ,1
  GOTO  RD1
  MOVFW F2      ;���õ�������W
  RETURN
;********************************
DELAY
  MOVLW  1FH     ;CLKʱ��͢ʱ
  MOVWF  F7
  DECFSZ F7 ,1
  GOTO $-1
  RETURN
;*******************************
DELAY1              ;͢ʱ
  MOVLW  .20
  MOVWF  F4
D1
  MOVLW  .40
  MOVWF  F5
D2
  MOVLW  .248
  MOVWF  F6
  DECFSZ F6 ,1
  GOTO  $-1
  DECFSZ F5 ,1
  GOTO   D2
  DECFSZ F4 ,1
  GOTO   D1
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
