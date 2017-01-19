;ʵս����������LED��˸�ơ�
;��ʵս��Ŀ�����ô�ҽ�һ����ϤIO����������ĵ�ʹ��
;���Ŵ�ҶԳ���ָ��Ľ�һ����Ϥ,��ʵ�������˼򵥵�ע��
;ͨ��ǰ���ʵ����Ҷ�PIC16F87X(A)�ļĴ����Ѿ����˳�������ʶ,��ʵ������
;��������Ĵ���,������PIC16F877��Ԥ�����ļ�
;PIC��Ƭ��ѧϰ��     ��ѧǬ      http://www.pic16.com
;������Ϊ"MCD-LED3.ASM"
;*************************************************
;*  ��������һ��LED�Ƶ�ѭ����˸����,��INT��(S3)���л�*
;*  ��˸ģʽ                                     *
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
	clrf	PORTC			;��D��
	movlw	00h
	movwf	MODESEL		;��ʼ��ģʽѡ��Ĵ���
	movwf	MODESELB
	movlw	b'10010000'
	movwf	INTCON		;��ʼ���жϿ���
	bsf	STATUS,RP0
	clrf	TRISC			;��C��ȫΪ���
	movlw	b'10111111'
	OPTION			;ѡ��INT�½�����Ч	

	bcf	STATUS,RP0
	call	FMsel
        movwf   PORTDB			
	movwf	PORTC
main	btfsc	PORTB,0		;\
	goto	$+6			; \
	call	Delay			;  ����ȥ����
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
Delay					; callָ��ռ��2��ָ������
	clrf	Count			; �� Countռ��1��ָ������
Dloop
	decfsz	Count,f			; ������ָ���ʱ
	goto	Dloop			; (256 * 3) -1 ��ָ������
	return				;  returnռ��2��ָ������

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
;    6.��·����:����ʾ���S1ȫ���ε�ON��S4ȫ���ε�OFF��S13�ĵ�1�ε�ON����5����6����7ȫ���ε�OFF ��LCD��Ҫ������ʾ���ϣ�
;   ��ʹ�˿�Cֻ��8ֻ��������ܽ�ͨ;������ѡ��Ƶ�ʵĲ������߲嵽��XT OSC��λ����.
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
