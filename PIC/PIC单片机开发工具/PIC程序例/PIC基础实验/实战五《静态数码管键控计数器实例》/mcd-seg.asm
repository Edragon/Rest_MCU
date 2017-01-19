;ʵս5����̬����ܼ��ؼ�����ʵ����
;��ʵ���Ŀ�����ô����Ϥ����ܣ�ѧϰ����Ӧ�ò����򣬱�����Ĺ�����Ҫ��PIC��ʵ��1λ
;�������ʾ������λ�����ɵ�һ������ܴ�0ѭ����ʾ��9�����ɵڶ�������ܴ�0��ʾ��9��Ȼ�������,
;���ĸ�,�����,���������ɵ�һ���������ʾ����ѭ������������һ����������0������9��ͬʱ������LED
;����ʾ������������������ֵ����ʾ���ת��������
;PIC��Ƭ��ѧϰ��    ��ѧǬ   http://www.pic16.com
;�����ļ�������MCD-SEG.ASM"
;************************************************
;�����嵥
  LIST P=16F877A,R=DEC    
;************************************************
 __CONFIG B'11011100110001'; 
RTCC      EQU    01H
PCL       EQU    02H ;���������������ֽڼĴ�����ַ
STATUS    EQU    03H ;����״̬�Ĵ�����ַ
PORTA     EQU    05H ;����RA�����ݼĴ�����ַ
PORTB     EQU    06H
PORTC     EQU    07H ;����RC�����ݼĴ�����ַ
INTCON    EQU    0BH

OPTION_REG EQU   81H
TRISA     EQU    85H ;����RA�ڷ�����ƼĴ���
TRISB     EQU    86H
TRISC     EQU    87H ;����RC�ڷ�����ƼĴ���
ADCON1    EQU 9FH  ;����ADCģ����ƼĴ���1�ĵ�ַ
;-----------------------STATUS
C         EQU    0   ;�����λ��־λλ��ַ
Z         EQU    2   ;����0��־λλ��ַ
RP0       EQU    5   ;����ҳѡλRP0λ��ַ
;-----------------------
COUNTER   EQU    20H  ;����������Ĵ���
COUNT0    EQU    21H  ;����͢ʱ����������
COUNT1    EQU    22H  ;����͢ʱ����������
COUNT2    EQU    23H  ;����͢ʱ����������
DISP_COUNT EQU   24H
DISP_COUNT1  EQU  25H
DISPBUFF_1   EQU  26H
DISPBUFF_2   EQU  27H
DISPBUFF_0   EQU  28H
DISPBUFF_3   EQU  29H
DISPBUFF_4   EQU  2AH
DISPBUFF_5   EQU  2BH
DATA1         EQU  2CH
;-------------------------INTCON
T0IF       EQU 2 ;��ʱ��0����жϱ�־λ
T0IE       EQU 5 ;��ʱ��0����ж�����/��ֹ
GIE        EQU 7 ;���ж�����/��ֹ
W_TEMP     EQU 7FH
STATUS_TEMP EQU 30H
;--------------------
          ORG 0000H   
          NOP         ;����һ��ICD����Ŀղ���ָ��
          GOTO MAIN
          ORG 0004H
TMR0SERV
    MOVWF W_TEMP         ;�ֳ�����
    SWAPF STATUS,W       ;��SWAPF�Ų���Ӱ���־λ
    MOVWF STATUS_TEMP    ;��W��STATUS����������Ĵ���

    MOVLW 0FFH
    MOVWF PORTC          ;��Ϩ�������������˸
    MOVLW 0FFH
    MOVWF PORTA

    MOVFW DISP_COUNT
    MOVWF DISP_COUNT1
    DECFSZ DISP_COUNT1,1
    GOTO  TMR0_1
    MOVFW DISPBUFF_0
    CALL CONVERT       ;����W�����ת�����ӳ���
    MOVWF PORTC        ;��RB����ʾ
    BCF PORTA,0
    GOTO  TMR0_END
TMR0_1
    DECFSZ DISP_COUNT1,1
    GOTO  TMR0_2
    MOVFW DISPBUFF_1
    CALL CONVERT       ;����W�����ת�����ӳ���
    MOVWF PORTC        ;��RB����ʾ
    BCF PORTA,1
    GOTO  TMR0_END
TMR0_2
    DECFSZ DISP_COUNT1,1
    GOTO  TMR0_3
    MOVFW  DISPBUFF_2
    CALL CONVERT       ;����W�����ת�����ӳ���
    MOVWF PORTC        ;��RB����ʾ
    BCF PORTA,2
    GOTO  TMR0_END
TMR0_3
    DECFSZ DISP_COUNT1,1
    GOTO TMR0_4
    MOVFW  DISPBUFF_3
    CALL CONVERT       ;����W�����ת�����ӳ���
    MOVWF PORTC 
    BCF  PORTA,3
    GOTO TMR0_END
TMR0_4
    DECFSZ DISP_COUNT1,1
    GOTO TMR0_5
    MOVFW  DISPBUFF_4
    CALL CONVERT       ;����W�����ת�����ӳ���
    MOVWF PORTC 
    BCF PORTA,4
    GOTO TMR0_END
TMR0_5
    MOVFW  DISPBUFF_5
    CALL CONVERT       ;����W�����ת�����ӳ���
    MOVWF PORTC 
    BCF PORTA,5
TMR0_END
    MOVLW 06H
    DECF DISP_COUNT,1
    SKPNZ
    MOVWF DISP_COUNT

    MOVLW 155            ;�Ͷ�ʱ����ֵ
    MOVWF RTCC

    BCF INTCON,T0IF        ;�嶨ʱ��0����жϱ�־λ
    SWAPF STATUS_TEMP,W     ;�ָ��ж�ǰSTATUS��W��ֵ
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W          ;����SWAPF�Ų���Ӱ��STATUS��ֵ��
    RETFIE   
;-------------------- ----------------------------------
CONVERT                              ;ȡ����ܶ���
            ADDWF PCL,1              ;��ַƫ�����ӵ�ǰPCֵ
TABLE                                                    	
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
        RETLW 7FH                   ;.
        RETLW 00H
;*******************************************************
MAIN
            CLRF PORTA              ;��ʼ��IO��
            CLRF PORTC              ;
     
            BSF STATUS,RP0          ;����RA��RC��ȫ��Ϊ���
            MOVLW 07H
            MOVWF ADCON1            ;����RA��ȫ��Ϊ��ͨ����IO��
            MOVLW 00H
            MOVWF TRISA             ;
            MOVWF TRISC
            MOVLW  0FFH
            MOVWF TRISB
            MOVLW 00000100B
            MOVWF OPTION_REG    ;Ԥ��Ƶ���������ʱ��0����Ƶ��1:32 
            BCF STATUS,RP0

            MOVLW 155
            MOVWF RTCC         ;��ʱ���ͳ�ֵ(255-155)*32US=3.2MS,ÿ3.2MSһ���ж� 
            MOVLW 0FFH         ;���������ȫ������ʾ
            MOVWF PORTC
            MOVLW 06H
            MOVWF DISP_COUNT
            CLRW
            MOVWF DISPBUFF_1
            MOVLW 1
            MOVWF DISPBUFF_0
            MOVLW 2
            MOVWF DISPBUFF_3
            MOVLW 3
            MOVWF DISPBUFF_2
            MOVLW 4
            MOVWF DISPBUFF_5
            MOVLW 5
            MOVWF DISPBUFF_4
            
            BCF INTCON,T0IF
            BSF INTCON,T0IE    ;��ʱ��0����ж�����
            BSF INTCON,GIE      ;���ж�����
;----------------------
LOOPA       BTFSS PORTB,1
            GOTO LOOP_1
            BTFSS PORTB,2
            GOTO LOOP_2
            BTFSS PORTB,4
            GOTO LOOP_3
            GOTO LOOPA
LOOP_1
           BTFSC PORTB,1
           GOTO LOOPA
           MOVLW 255
           MOVWF DATA1
SET_LOOP1A
          BTFSC PORTB,1        ;ȥ����
          GOTO LOOPA
          DECFSZ DATA1,1
          GOTO SET_LOOP1A
          MOVLW 6
          MOVWF DISPBUFF_1
            MOVLW 7
            MOVWF DISPBUFF_0
            MOVLW 8
            MOVWF DISPBUFF_3
            MOVLW 9
            MOVWF DISPBUFF_2
            MOVLW 0AH
            MOVWF DISPBUFF_5
            MOVLW 0
            MOVWF DISPBUFF_4
SET_LOOP1B
   BTFSS PORTB,1       ;�ȴ������ſ�
   GOTO SET_LOOP1B
   GOTO LOOPA
;--------------------------------
LOOP_2
           BTFSC PORTB,2
           GOTO LOOPA
           MOVLW 255
           MOVWF DATA1
SET_LOOP2A
          BTFSC PORTB,2        ;ȥ����
          GOTO LOOPA
          DECFSZ DATA1,1
          GOTO SET_LOOP2A
          MOVLW 0BH
          MOVWF DISPBUFF_1
            MOVLW 0BH
            MOVWF DISPBUFF_0
            MOVLW 0BH
            MOVWF DISPBUFF_3
            MOVLW 0BH
            MOVWF DISPBUFF_2
            MOVLW 0BH
            MOVWF DISPBUFF_5
            MOVLW 0BH
            MOVWF DISPBUFF_4
SET_LOOP2B
   BTFSS PORTB,2       ;�ȴ������ſ�
   GOTO SET_LOOP2B
   GOTO LOOPA
;--------------------------------------                  
LOOP_3
           BTFSC PORTB,4
           GOTO LOOPA
           MOVLW 255
           MOVWF DATA1
SET_LOOP3A
          BTFSC PORTB,4        ;ȥ����
          GOTO LOOPA
          DECFSZ DATA1,1
          GOTO SET_LOOP3A
          MOVLW 0
          MOVWF DISPBUFF_1
            MOVLW 1
            MOVWF DISPBUFF_0
            MOVLW 2
            MOVWF DISPBUFF_3
            MOVLW 3
            MOVWF DISPBUFF_2
            MOVLW 4
            MOVWF DISPBUFF_5
            MOVLW 5
            MOVWF DISPBUFF_4
SET_LOOP3B
   BTFSS PORTB,4       ;�ȴ������ſ�
   GOTO SET_LOOP3B
   GOTO LOOPA     
;---------------------------------͢ʱ�ӳ���------
DELAY	  
            MOVLW  .2              ;������ʱ����
	    MOVWF  COUNT0
L1	  		
            MOVLW  .255            ;
	    MOVWF  COUNT1
L2	  	
            MOVLW  .255            ;
	    MOVWF  COUNT2
L3	  		
            DECFSZ COUNT2,1        ;�ݼ�ѭ�� 
	    GOTO L3                ;
	    DECFSZ COUNT1,1        ;
	    GOTO L2                ;
	    DECFSZ COUNT0,1        ;
	    GOTO L1                ;
	    RETLW  0

;----- -----------------------------------------------
            END
;******************************************************
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
;    6.��·����:����ʾ���S1ȫ���ε�OFF��S13ȫ���ε�OFF��S4,S5ȫ���ε�ON ��LCD��Ҫ������ʾ���ϣ�
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

