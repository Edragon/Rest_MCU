;PIC16F877Aʵ�����ֲ��ų��򣨡���ֻ�ϻ���Ƭ�Σ�

;����˵��:
;1.ͨ������ʵ����ϵķ�����������ʵ�����ֵĲ��š�
;2.��TABLE��ȡ���������ֵ�������1��2....7��ͨ���ı�ñ��е�ֵ����ʵ�ֲ��Ų�ͬ�����֡�
;3.��TABLE_YP��ȡ���������ֵ���Ƶ����������������ʱ�䡣
;4.����DELAY��ʱ�ĳ��̼���ʵ�����ֲ��ŵĿ�����

;��ʵս��Ŀ�����ô�ҽ�һ����Ϥ D��Ƭ�����������������������ͨ���ı����������ʱ�䳤����ʵ�ֲ�ͬƵ�ʵ�������

;Ӳ���ӷ�:
;1����������RC6�ڡ�
;2��������ʹ��ʵ����ϵķ������������������뿪��13�ĵ�5λ������1�������뿪�ض����Թرա�

;��ʵ��ԭ�ṩ��:pic16��̳��Ա ppmy ,�ڴ���лppmyͬ־����ʵ��.
;��������Ǭ��ʢ���ӿƼ����޹�˾�������ӹ���(����ʦ)(��̳����:zhongruntian)��������������ע��.
;��վ:PIC��Ƭ��ѧϰ�� http://www.pic16.com   ������̳��http://pic16.com/bbs/
;��Ȩ���У�ת����ע��������������ȥ����ı��ļ��е�˵�����֡�
;�����ļ�����SONG.ASM"
;�����嵥����:
;***********************************
    LIST      P=PIC16F877,R=DEC
    #INCLUDE  P16F877.INC
;***********************************
    Errorlevel -302,-305
 __CONFIG _DEBUG_OFF&_CP_ALL&_CPD_ON&_LVP_OFF&_BODEN_OFF&_PWRTE_ON&_WDT_OFF&_HS_OSC;

;***********************************�Ĵ�������
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
    nop                             ;����һ��MCD������Ŀ�ָ��
    GOTO   MAIN                     ;������
    ORG    0x0004
    BTFSC  PIR1,TMR1IF              ;�ж��ӳ���
    GOTO   T1                       ;תT1����      
    RETFIE
    ORG    0x0010
;************************************
MAIN
    CLRWDT                          ;ι��
    BCF    STATUS,RP0
    CLRF   INTCON                   ;��������жϱ�־λ
    CLRF   PORTC
    CLRF   PIR1                     ;���TMR1�жϱ�־λ
    BSF    STATUS,RP0
    BSF    PIE1,0                   ;ʹ��TMR1�ж�
    MOVLW  B'10111111'              ;��RC6������⣬�����ڶ���Ϊ����
    MOVWF  TRISC                    
    BCF    STATUS,RP0 
    MOVLW  0xC0                     ;�����ж�������λGIE��PEIE
    MOVWF  INTCON
REPLAY
    CLRF   COUNT1                   ;��ͷ��ʼ����༴��ͷ��ʼ���裩
SING
    CLRF   TMR1L                    
    CLRF   TMR1H                    ;����TMR1����
    MOVF   COUNT1,0
    CALL   TABLE                    
    MOVWF  COUNT2                   ;�ݴ�������COUNT2��
    BCF    STATUS,Z
    SUBLW  0x00                     ;�ж��Ƿ������һ����ֵ
    BTFSC  STATUS,Z
    GOTO   REPLAY                   ;�ǣ�˵�����ֲ�����ɣ���ͷ��ʼ����
    MOVF   COUNT2,0    
    ANDLW  0x0F                     ;ȥ����4λֻ������4λ
    MOVWF  JP                       ;���浽JP��
    SWAPF  COUNT2,0                 ;�ߵͰ��ֽڽ���
    ANDLW  0x0F                     ;ȥ����4λֻ������4λ
    MOVWF  YP                       ;���浽YP�У��������Ľ���ı��ֳɸߵͰ��ֽ������ֱַ�����YP��JP��
    DECF   YP,1
    MOVF   YP,0
    CALL   TABLE_YP                 
    MOVWF  TMR1H                    ;��ΪTMR1��ֵ�ĸ�8λ
    MOVWF  TA                       ;�ݴ�TA��
    INCF   YP,0
    CALL   TABLE_YP
    MOVWF  TMR1L                    ;��ΪTMR1��ֵ�ĵ�8λ
    MOVWF  TA+1                     ;�ݴ�TA+1��
    BSF    T1CON,TMR1ON             ;����TMR1��ʱ��
    CALL   DELAY                    ;��ʱһ��ʱ��
    INCF   COUNT1                   ;COUNT1��1���Ա���õ���һ�����ŵ�����
    GOTO   SING                     ;���ز�����һ������

;**************************��ʱ����
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
;*************************�ж��ֳ�����              
PUSH
    MOVWF  W_STACK                ;����W��ֵ
    MOVF   STATUS,0
    MOVWF  ST_STACK               ;����STATUS��ֵ
    RETURN
;************************�ж��ֳ��ָ�
POP
    MOVF   ST_STACK,0
    MOVWF  STATUS                 ;�ָ�STATUS��ֵ
    MOVF   W_STACK,0              ;�ָ�W��ֵ
    RETURN
;************************�жϴ����ӳ���
T1
    CALL   PUSH                   ;�����ֳ���������
    MOVLW  0x40                   ;RC6�����ȡ��
    XORWF  PORTC,1
    MOVF   TA,0                  
    MOVWF  TMR1H                  
    MOVF   TA+1,0
    MOVWF  TMR1L                  ;��TMR1����ֵ
    BSF    T1CON,TMR1ON           ;������ʱ��
    BCF    PIR1,TMR1IF            ;�����־λ
    CALL   POP                    ;�����ֳ��ָ�����
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
       end                   ;Դ�������
;********************************************
           
;  �����ʵս�����Ĺ�����������:
;  1.����Դ�ļ��ͱ༭Դ�ļ�;�ڴ˽���һ�ֲ�ͬ��ǰ�潲�Ĵ���Դ�ļ��ķ���,��Windows�����еġ����±���
;  ���Ϊ�������֪�ͺ��õ��ļ��༭��,���ҿ��Է���ļ�������ע��.������������Ҫע��,һ��ע��ǰ���
;  �ֺš�;�����������İ������;���Ǳ����á�.asm����չ���洢�����Ƚ�����һ��ר����Ŀ¼��.
;  2.��MPLAB���ɿ�������:������WINDOWS������,ѡ�ÿ�ʼ>����>Microchip MPLAB>MPLAB����,����MPLAB
;  ������MPLAB������.
;  3.������Ŀ:ѡ�ò˵�File>New��Project>New Project,�����Ƚ�����һ��ר����Ŀ¼�´���һ������Ŀ,��
;  �ü��±�������Դ�ļ����뵽����Ŀ��.
;  4.������Ŀ�е�Ŀ���ļ�:ѡ��˵�Project >Build All(��Ŀ>���������ļ�),MPLAB���Զ�����MPASM����Ŀ
;  �ļ������µ�Դ�ļ�(.asm)����ʮ�����Ƶ�Ŀ���ļ�(.hex).
