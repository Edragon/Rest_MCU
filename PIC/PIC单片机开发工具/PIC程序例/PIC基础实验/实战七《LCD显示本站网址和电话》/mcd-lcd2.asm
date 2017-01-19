;ʵս�ߡ�LCD��ʾ��վ��ַ�͵绰��
;��ʵս��Ŀ�����ô�ҽ��ϲ���Ϥ��������÷���MCD1����LCD�Ķ�д����
;PIC��Ƭ��ѧϰ��  ��ѧǬ  http://www.pic16.com
;�����ļ�����MCD-LCD2.ASM"
;�����嵥����:
;************************************
PCL     EQU 2H   ;�������洢�����ֽڵ�ַ
STATUS  EQU 3H   ;����״̬�Ĵ�����ַ
PORTA   EQU 5H   ;����RA�����ݼĴ�����ַ
PORTC   EQU 7H   ;����RC�����ݼĴ�����ַ
TRISA   EQU 85H  ;����RA�ڷ�����ƼĴ�����ַ
TRISC   EQU 87H  ;����RC�ڷ�����ƼĴ�����ַ
ADCON1  EQU 9FH  ;����ADCģ����ƼĴ���1�ĵ�ַ
;********************
Z       EQU 2    ;����0״̬λ��λ��ַ
RP0     EQU 5    ;����ҳѡλRP0��λ��ַ
;*********************
RS EQU 1         ;LCD�Ĵ���ѡ���źŽŶ�����RA.1��
RW EQU 2         ;LCD��/д�źŽŶ�����RA.2��
E  EQU 3         ;LCDƬѡ�źŽŶ�����RA.3��
COUNT EQU 24H    ;��������Ĵ�����ַ
TMP1  EQU 25H    ;������ʱ�Ĵ�����ַ
;**********************
  ORG 000H
  NOP              ;����һ��ICD����Ŀղ���ָ��
  GOTO MAIN
  ORG 0008H
;******************************************************
TABLE                     ;ȡ��һ�е���ʾ��WWW.PIC16.COM
           ADDWF PCL,1    ;��ַƫ�����ӵ�ǰPCֵ
           RETLW 20H      ;�ո�
           RETLW 57H      ;W
           RETLW 57H      ;W
           RETLW 57H      ;W
           RETLW 2EH      ;.
           RETLW 50H      ;P
           RETLW 49H      ;I
           RETLW 43H      ;C
           RETLW 31H      ;1
           RETLW 36H      ;6
           RETLW 2EH      ;.
           RETLW 43H      ;C
           RETLW 4FH      ;O
           RETLW 4DH      ;M
           RETLW 20H      ;�ո�
           RETLW 20H      ;�ո�
           RETLW 00H
;-------------------- ----------------------------------
TABLE1                               ;ȡ�ڶ��е���ʾ��TEL0755 27528531 
            ADDWF PCL,1              ;��ַƫ�����ӵ�ǰPCֵ                                                 	
	    RETLW 54H 	   		;T 
	    RETLW 45H 	   		;E                             
	    RETLW 4CH 	   		;L
	    RETLW 30H 	   		;0
	    RETLW 37H 	   		;7
	    RETLW 35H 	   		;5
	    RETLW 35H 		   	;5
	    RETLW 20H 	   		;�ո�
	    RETLW 32H 	   		;2
            RETLW 37H                   ;7
            RETLW 35H                   ;5
            RETLW 32H                   ;2
            RETLW 38H                   ;8
            RETLW 35H                   ;5
            RETLW 33H                   ;3
            RETLW 31H                   ;1
            RETLW 00H
;*******************************************************
MAIN

  BSF STATUS,RP0          ;����RA��,RC��ȫ��Ϊ���
  MOVLW 07H
  MOVWF ADCON1            ;����RA��ȫ��Ϊ��ͨ����IO��
  MOVLW 00H
  MOVWF TRISA
  MOVWF TRISC
  BCF STATUS,RP0

  CALL DELAY              ;����͢ʱ,���ϵ�LCD��λ��һ����PIC��
  MOVLW 01H
  MOVWF PORTC             ;����
  CALL ENABLE
  MOVLW 38H
  MOVWF PORTC             ;8λ2��5x7����
  CALL ENABLE
  MOVLW 0FH               ;��ʾ��������꿪����˸��
  MOVWF PORTC
  CALL ENABLE
  MOVLW 06H               ;���ֲ���������Զ�����
  MOVWF PORTC             
  CALL ENABLE
  MOVLW 80H
  MOVWF PORTC             ;��ʾλ��
  CALL ENABLE


  CALL WRITE1             ;�����͵�һ�����ӳ���WWW.PIC16.COM"
  MOVLW 0C0H
  MOVWF PORTC            ;��һ�е�λ��       
  CALL ENABLE
  CALL WRITE2            ;�����͵ڶ������ӳ���TEL0755 27528531"
  MOVLW 0C2H 
  MOVWF PORTC             ;�ڶ��е�λ��
  CALL ENABLE
  GOTO $
  
;***********************
WRITE1
  CLRF COUNT          ;�͵�һ�����ֳ���
WRITE_A
  MOVFW COUNT
  CALL TABLE
  MOVWF TMP1
  CALL WRITE3
  INCF COUNT,1
  MOVFW TMP1
  XORLW 00H
  BTFSS STATUS,Z
  GOTO WRITE_A
  RETLW 0
;*************************
WRITE2                 ;�͵ڶ������ӳ���
  CLRF COUNT
WRITE2_A
  MOVFW COUNT
  CALL TABLE1
  MOVWF TMP1
  CALL WRITE3
  INCF COUNT,1
  MOVFW TMP1
  XORLW 00H
  BTFSS STATUS,Z
  GOTO WRITE2_A
  RETLW 0
;**************************
WRITE3                 ;�����ݵ�LCD�ӳ���
  MOVWF PORTC
  BSF PORTA,RS
  BCF PORTA,RW
  BCF PORTA,E
  CALL DELAY
  BSF PORTA,E
  RETLW 0
;*******************************************
ENABLE
  BCF PORTA,RS         ;д�����������ӳ���
  BCF PORTA,RW
  BCF PORTA,E
  CALL DELAY
  BSF PORTA,E
  RETLW 0
;********************************************
DELAY                       
                             ;�ӳ�������Ҳ���ӳ�����ڵ�ַ
       movlw   0ffh          ;�����ѭ������ֵFFH����W
       movwf   20h          ;����������ѭ��������20H��Ԫ
lp0    movlw   0ffh          ;���ڲ�ѭ������ֵFFH����W
       movwf   21h           ;����������ѭ��������21H��Ԫ
lp1    decfsz   21h,1         ;����21H���ݵݼ�����Ϊ0��Ծ
       goto     lp1           ;��ת��LP1��
       decfsz    20h,1         ;����20H���ݵݼ�����Ϊ0��Ծ
       goto     lp0           ;��Ծ��LP0��
       return                 ;����������
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
;    5.ICD��������:ͨ���˵�����Project>Edit Project����Option>Development Mode,������ģʽ����Ϊ
;   ��MPLAB ICD Debugger��,���OK��ť,��ICD�Ĺ�������,�ڵ��Խ׶�,���԰���˵����ͼ2-10���ø���,����ע��
;   OSCILLATORӦ����ΪXT��ʽ,������Ҫ˵�����ǣ�ѡ�С�Enable Debug Mode����ʹ�ܵ���ģʽ��ѡ�����Ŀ
;   �굥Ƭ����д���������ʱ���Ὣ�����ٿس���ͬʱд�뵥Ƭ����ָ������洢������Ȼ���������ICD��ʽ���ԡ�
;    6.��·����:����ʾ���S1ȫ���ε�OFF��S13ȫ���ε�OFF��S4,S5ȫ���ε�OFF ��LCD��׼��λ������ʾ���ϣ�
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

