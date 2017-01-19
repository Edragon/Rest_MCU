opt subtitle "HI-TECH Software Omniscient Code Generator (PRO mode) build 9453"

opt pagewidth 120

	opt pm

	processor	16F877
clrc	macro
	bcf	3,0
	endm
clrz	macro
	bcf	3,2
	endm
setc	macro
	bsf	3,0
	endm
setz	macro
	bsf	3,2
	endm
skipc	macro
	btfss	3,0
	endm
skipz	macro
	btfss	3,2
	endm
skipnc	macro
	btfsc	3,0
	endm
skipnz	macro
	btfsc	3,2
	endm
indf	equ	0
indf0	equ	0
pc	equ	2
pcl	equ	2
status	equ	3
fsr	equ	4
fsr0	equ	4
c	equ	1
z	equ	0
pclath	equ	10
# 10 "D:\PIC16F72\PIC CODE\ADC\main.c"
	psect config,class=CONFIG,delta=2 ;#
# 10 "D:\PIC16F72\PIC CODE\ADC\main.c"
	dw 0x1832 ;#
	FNCALL	_main,_init
	FNCALL	_main,___awdiv
	FNCALL	_main,_display
	FNCALL	_display,___awdiv
	FNCALL	_display,___awmod
	FNCALL	_display,_DELAY
	FNCALL	_init,_DELAY
	FNROOT	_main
	global	_TABLE
psect	strings,class=STRING,delta=2
global __pstrings
__pstrings:
;	global	stringdir,stringtab,__stringbase
stringtab:
;	String table - string pointers are 1 byte each
stringcode:stringdir:
movlw high(stringdir)
movwf pclath
movf fsr,w
incf fsr
	addwf pc
__stringbase:
	retlw	0
psect	strings
	file	"D:\PIC16F72\PIC CODE\ADC\main.c"
	line	12
_TABLE:
	retlw	0C0h
	retlw	0F9h
	retlw	0A4h
	retlw	0B0h
	retlw	099h
	retlw	092h
	retlw	082h
	retlw	0F8h
	retlw	080h
	retlw	090h
	global	_TABLE
	global	_ADCON0
_ADCON0	set	31
	global	_PORTA
_PORTA	set	5
	global	_PORTD
_PORTD	set	8
	global	_GO_DONE
_GO_DONE	set	250
	global	_ADCON1
_ADCON1	set	159
	global	_ADRESL
_ADRESL	set	158
	global	_TRISA
_TRISA	set	133
	global	_TRISD
_TRISD	set	136
	file	"main.as"
	line	#
psect cinit,class=CODE,delta=2
global start_initialization
start_initialization:

psect cinit,class=CODE,delta=2
global end_of_initialization

;End of C runtime variable initialization code

end_of_initialization:
clrf status
ljmp _main	;jump to C main() function
psect	cstackCOMMON,class=COMMON,space=1
global __pcstackCOMMON
__pcstackCOMMON:
	global	?_init
?_init:	; 0 bytes @ 0x0
	global	?_DELAY
?_DELAY:	; 0 bytes @ 0x0
	global	??_DELAY
??_DELAY:	; 0 bytes @ 0x0
	global	?_main
?_main:	; 0 bytes @ 0x0
	global	?___awmod
?___awmod:	; 2 bytes @ 0x0
	global	DELAY@i
DELAY@i:	; 2 bytes @ 0x0
	global	___awmod@divisor
___awmod@divisor:	; 2 bytes @ 0x0
	ds	2
	global	??_init
??_init:	; 0 bytes @ 0x2
	global	___awmod@dividend
___awmod@dividend:	; 2 bytes @ 0x2
	ds	2
	global	??___awmod
??___awmod:	; 0 bytes @ 0x4
	global	___awmod@counter
___awmod@counter:	; 1 bytes @ 0x4
	ds	1
	global	___awmod@sign
___awmod@sign:	; 1 bytes @ 0x5
	ds	1
	global	?___awdiv
?___awdiv:	; 2 bytes @ 0x6
	global	___awdiv@divisor
___awdiv@divisor:	; 2 bytes @ 0x6
	ds	2
	global	___awdiv@dividend
___awdiv@dividend:	; 2 bytes @ 0x8
	ds	2
	global	??___awdiv
??___awdiv:	; 0 bytes @ 0xA
	global	___awdiv@counter
___awdiv@counter:	; 1 bytes @ 0xA
	ds	1
	global	___awdiv@sign
___awdiv@sign:	; 1 bytes @ 0xB
	ds	1
	global	___awdiv@quotient
___awdiv@quotient:	; 2 bytes @ 0xC
	ds	2
	global	??_display
??_display:	; 0 bytes @ 0xE
	global	??_main
??_main:	; 0 bytes @ 0xE
psect	cstackBANK0,class=BANK0,space=1
global __pcstackBANK0
__pcstackBANK0:
	global	?_display
?_display:	; 0 bytes @ 0x0
	global	display@x
display@x:	; 2 bytes @ 0x0
	ds	2
	global	display@bai
display@bai:	; 2 bytes @ 0x2
	ds	2
	global	display@shi
display@shi:	; 2 bytes @ 0x4
	ds	2
	global	display@ge
display@ge:	; 2 bytes @ 0x6
	ds	2
	global	_display$1836
_display$1836:	; 2 bytes @ 0x8
	ds	2
	global	display@temp
display@temp:	; 2 bytes @ 0xA
	ds	2
	global	main@i
main@i:	; 2 bytes @ 0xC
	ds	2
	global	main@result
main@result:	; 2 bytes @ 0xE
	ds	2
;;Data sizes: Strings 0, constant 10, data 0, bss 0, persistent 0 stack 0
;;Auto spaces:   Size  Autos    Used
;; COMMON          14     14      14
;; BANK0           80     16      16
;; BANK1           80      0       0
;; BANK3           96      0       0
;; BANK2           96      0       0

;;
;; Pointer list with targets:

;; ?___awmod	int  size(1) Largest target is 0
;;
;; ?___awdiv	int  size(1) Largest target is 0
;;


;;
;; Critical Paths under _main in COMMON
;;
;;   _main->___awdiv
;;   _display->___awdiv
;;   _init->_DELAY
;;   ___awdiv->___awmod
;;
;; Critical Paths under _main in BANK0
;;
;;   _main->_display
;;
;; Critical Paths under _main in BANK1
;;
;;   None.
;;
;; Critical Paths under _main in BANK3
;;
;;   None.
;;
;; Critical Paths under _main in BANK2
;;
;;   None.

;;
;;Main: autosize = 0, tempsize = 0, incstack = 0, save=0
;;

;;
;;Call Graph Tables:
;;
;; ---------------------------------------------------------------------------------
;; (Depth) Function   	        Calls       Base Space   Used Autos Params    Refs
;; ---------------------------------------------------------------------------------
;; (0) _main                                                 4     4      0    1217
;;                                             12 BANK0      4     4      0
;;                               _init
;;                            ___awdiv
;;                            _display
;; ---------------------------------------------------------------------------------
;; (1) _display                                             12    10      2     800
;;                                              0 BANK0     12    10      2
;;                            ___awdiv
;;                            ___awmod
;;                              _DELAY
;; ---------------------------------------------------------------------------------
;; (1) _init                                                 0     0      0      23
;;                              _DELAY
;; ---------------------------------------------------------------------------------
;; (2) ___awmod                                              6     2      4     296
;;                                              0 COMMON     6     2      4
;; ---------------------------------------------------------------------------------
;; (2) ___awdiv                                              8     4      4     300
;;                                              6 COMMON     8     4      4
;;                            ___awmod (ARG)
;; ---------------------------------------------------------------------------------
;; (2) _DELAY                                                2     2      0      23
;;                                              0 COMMON     2     2      0
;; ---------------------------------------------------------------------------------
;; Estimated maximum stack depth 2
;; ---------------------------------------------------------------------------------

;; Call Graph Graphs:

;; _main (ROOT)
;;   _init
;;     _DELAY
;;   ___awdiv
;;     ___awmod (ARG)
;;   _display
;;     ___awdiv
;;       ___awmod (ARG)
;;     ___awmod
;;     _DELAY
;;

;; Address spaces:

;;Name               Size   Autos  Total    Cost      Usage
;;BITCOMMON            E      0       0       0        0.0%
;;EEDATA             100      0       0       0        0.0%
;;NULL                 0      0       0       0        0.0%
;;CODE                 0      0       0       0        0.0%
;;COMMON               E      E       E       1      100.0%
;;BITSFR0              0      0       0       1        0.0%
;;SFR0                 0      0       0       1        0.0%
;;BITSFR1              0      0       0       2        0.0%
;;SFR1                 0      0       0       2        0.0%
;;STACK                0      0       2       2        0.0%
;;ABS                  0      0       0       3        0.0%
;;BITBANK0            50      0       0       4        0.0%
;;BITSFR3              0      0       0       4        0.0%
;;SFR3                 0      0       0       4        0.0%
;;BANK0               50     10      10       5       20.0%
;;BITSFR2              0      0       0       5        0.0%
;;SFR2                 0      0       0       5        0.0%
;;BITBANK1            50      0       0       6        0.0%
;;BANK1               50      0       0       7        0.0%
;;BITBANK3            60      0       0       8        0.0%
;;BANK3               60      0       0       9        0.0%
;;BITBANK2            60      0       0      10        0.0%
;;BANK2               60      0       0      11        0.0%
;;DATA                 0      0       0      12        0.0%

	global	_main
psect	maintext,global,class=CODE,delta=2
global __pmaintext
__pmaintext:

;; *************** function _main *****************
;; Defined at:
;;		line 20 in file "D:\PIC16F72\PIC CODE\ADC\main.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;  i               2   12[BANK0 ] int 
;;  result          2   14[BANK0 ] int 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, fsr0l, fsr0h, status,2, status,0, btemp+1, pclath, cstack
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 60/0
;;		Unchanged: FFE00/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       4       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       4       0       0       0
;;Total ram usage:        4 bytes
;; Hardware stack levels required when called:    2
;; This function calls:
;;		_init
;;		___awdiv
;;		_display
;; This function is called by:
;;		Startup code after reset
;; This function uses a non-reentrant model
;;
psect	maintext
	file	"D:\PIC16F72\PIC CODE\ADC\main.c"
	line	20
	global	__size_of_main
	__size_of_main	equ	__end_of_main-_main
	
_main:	
	opt	stack 6
; Regs used in _main: [wreg-fsr0h+status,2+status,0+btemp+1+pclath+cstack]
	line	21
	
l2038:	
	line	22
;main.c: 22: while(1)
	
l649:	
	line	25
;main.c: 23: {
;main.c: 24: int i;
;main.c: 25: result=0x00;
	clrf	(main@result)
	clrf	(main@result+1)
	line	26
	
l2040:	
;main.c: 26: for(i=5;i>0;i--)
	movlw	05h
	movwf	(main@i)
	clrf	(main@i+1)
	line	28
	
l2046:	
;main.c: 27: {
;main.c: 28: init();
	fcall	_init
	line	31
	
l2048:	
;main.c: 31: GO_DONE=0x01;
	bsf	(250/8),(250)&7
	line	32
;main.c: 32: while(GO_DONE);
	
l652:	
	btfsc	(250/8),(250)&7
	goto	u331
	goto	u330
u331:
	goto	l652
u330:
	line	33
	
l2050:	
;main.c: 33: result=result+ADRESL;
	bsf	status, 5	;RP0=1, select bank1
	movf	(158)^080h,w	;volatile
	bcf	status, 5	;RP0=0, select bank0
	addwf	(main@result),f
	skipnc
	incf	(main@result+1),f
	line	26
	
l2052:	
	movlw	-1
	addwf	(main@i),f
	skipc
	decf	(main@i+1),f
	
l2054:	
	movf	(main@i+1),w
	xorlw	80h
	movwf	btemp+1
	movlw	(high(01h))^80h
	subwf	btemp+1,w
	skipz
	goto	u345
	movlw	low(01h)
	subwf	(main@i),w
u345:

	skipnc
	goto	u341
	goto	u340
u341:
	goto	l2046
u340:
	line	35
	
l2056:	
;main.c: 34: }
;main.c: 35: result=result/5;
	movlw	05h
	movwf	(?___awdiv)
	clrf	(?___awdiv+1)
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movf	(main@result+1),w
	movwf	1+(?___awdiv)+02h
	movf	(main@result),w
	movwf	0+(?___awdiv)+02h
	fcall	___awdiv
	movf	(1+(?___awdiv)),w
	movwf	(main@result+1)
	movf	(0+(?___awdiv)),w
	movwf	(main@result)
	line	36
	
l2058:	
;main.c: 36: display(result);
	movf	(main@result+1),w
	movwf	(?_display+1)
	movf	(main@result),w
	movwf	(?_display)
	fcall	_display
	goto	l649
	global	start
	ljmp	start
	opt stack 0
psect	maintext
	line	38
GLOBAL	__end_of_main
	__end_of_main:
;; =============== function _main ends ============

	signat	_main,88
	global	_display
psect	text110,local,class=CODE,delta=2
global __ptext110
__ptext110:

;; *************** function _display *****************
;; Defined at:
;;		line 54 in file "D:\PIC16F72\PIC CODE\ADC\main.c"
;; Parameters:    Size  Location     Type
;;  x               2    0[BANK0 ] int 
;; Auto vars:     Size  Location     Type
;;  temp            2   10[BANK0 ] int 
;;  ge              2    6[BANK0 ] int 
;;  shi             2    4[BANK0 ] int 
;;  bai             2    2[BANK0 ] int 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, fsr0l, fsr0h, status,2, status,0, pclath, cstack
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       2       0       0       0
;;      Locals:         0      10       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0      12       0       0       0
;;Total ram usage:       12 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    1
;; This function calls:
;;		___awdiv
;;		___awmod
;;		_DELAY
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text110
	file	"D:\PIC16F72\PIC CODE\ADC\main.c"
	line	54
	global	__size_of_display
	__size_of_display	equ	__end_of_display-_display
	
_display:	
	opt	stack 6
; Regs used in _display: [wreg-fsr0h+status,2+status,0+pclath+cstack]
	line	56
	
l2010:	
;main.c: 55: int bai,shi,ge,temp;
;main.c: 56: temp=x;
	movf	(display@x+1),w
	movwf	(display@temp+1)
	movf	(display@x),w
	movwf	(display@temp)
	line	57
	
l2012:	
;main.c: 57: bai=temp/0x64;
	movlw	064h
	movwf	(?___awdiv)
	clrf	(?___awdiv+1)
	movf	(display@temp+1),w
	movwf	1+(?___awdiv)+02h
	movf	(display@temp),w
	movwf	0+(?___awdiv)+02h
	fcall	___awdiv
	movf	(1+(?___awdiv)),w
	movwf	(display@bai+1)
	movf	(0+(?___awdiv)),w
	movwf	(display@bai)
	line	58
	
l2014:	
;main.c: 58: shi=(temp%0x64)/0xa;
	movlw	0Ah
	movwf	(?___awdiv)
	clrf	(?___awdiv+1)
	movf	(display@temp+1),w
	movwf	1+(?___awmod)+02h
	movf	(display@temp),w
	movwf	0+(?___awmod)+02h
	movlw	064h
	movwf	(?___awmod)
	clrf	(?___awmod+1)
	fcall	___awmod
	movf	(1+(?___awmod)),w
	movwf	1+(?___awdiv)+02h
	movf	(0+(?___awmod)),w
	movwf	0+(?___awdiv)+02h
	fcall	___awdiv
	movf	(1+(?___awdiv)),w
	movwf	(display@shi+1)
	movf	(0+(?___awdiv)),w
	movwf	(display@shi)
	line	59
	
l2016:	
;main.c: 59: ge=(temp%0x64)%0xa;
	movf	(display@temp+1),w
	movwf	1+(?___awmod)+02h
	movf	(display@temp),w
	movwf	0+(?___awmod)+02h
	movlw	064h
	movwf	(?___awmod)
	clrf	(?___awmod+1)
	fcall	___awmod
	movf	(1+(?___awmod)),w
	movwf	(_display$1836+1)
	movf	(0+(?___awmod)),w
	movwf	(_display$1836)
	
l2018:	
;main.c: 59: ge=(temp%0x64)%0xa;
	movlw	0Ah
	movwf	(?___awmod)
	clrf	(?___awmod+1)
	movf	(_display$1836+1),w
	movwf	1+(?___awmod)+02h
	movf	(_display$1836),w
	movwf	0+(?___awmod)+02h
	fcall	___awmod
	movf	(1+(?___awmod)),w
	movwf	(display@ge+1)
	movf	(0+(?___awmod)),w
	movwf	(display@ge)
	line	60
	
l2020:	
;main.c: 60: PORTD=TABLE[bai];
	movf	(display@bai),w
	addlw	low((_TABLE-__stringbase))
	movwf	fsr0
	fcall	stringdir
	movwf	(8)	;volatile
	line	61
	
l2022:	
;main.c: 61: PORTA=0x37;
	movlw	(037h)
	movwf	(5)	;volatile
	line	62
	
l2024:	
;main.c: 62: DELAY();
	fcall	_DELAY
	line	63
	
l2026:	
;main.c: 63: PORTD=TABLE[shi];
	movf	(display@shi),w
	addlw	low((_TABLE-__stringbase))
	movwf	fsr0
	fcall	stringdir
	movwf	(8)	;volatile
	line	64
	
l2028:	
;main.c: 64: PORTA=0x2F;
	movlw	(02Fh)
	movwf	(5)	;volatile
	line	65
	
l2030:	
;main.c: 65: DELAY();
	fcall	_DELAY
	line	66
	
l2032:	
;main.c: 66: PORTD=TABLE[ge];
	movf	(display@ge),w
	addlw	low((_TABLE-__stringbase))
	movwf	fsr0
	fcall	stringdir
	movwf	(8)	;volatile
	line	67
	
l2034:	
;main.c: 67: PORTA=0x1F;
	movlw	(01Fh)
	movwf	(5)	;volatile
	line	68
	
l2036:	
;main.c: 68: DELAY();
	fcall	_DELAY
	line	69
	
l663:	
	return
	opt stack 0
GLOBAL	__end_of_display
	__end_of_display:
;; =============== function _display ends ============

	signat	_display,4216
	global	_init
psect	text111,local,class=CODE,delta=2
global __ptext111
__ptext111:

;; *************** function _init *****************
;; Defined at:
;;		line 42 in file "D:\PIC16F72\PIC CODE\ADC\main.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2, status,0, pclath, cstack
;; Tracked objects:
;;		On entry : 0/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         0       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         0       0       0       0       0
;;Total ram usage:        0 bytes
;; Hardware stack levels used:    1
;; Hardware stack levels required when called:    1
;; This function calls:
;;		_DELAY
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text111
	file	"D:\PIC16F72\PIC CODE\ADC\main.c"
	line	42
	global	__size_of_init
	__size_of_init	equ	__end_of_init-_init
	
_init:	
	opt	stack 6
; Regs used in _init: [wreg+status,2+status,0+pclath+cstack]
	line	43
	
l2000:	
;main.c: 43: PORTA=0XFF;
	movlw	(0FFh)
	bcf	status, 5	;RP0=0, select bank0
	bcf	status, 6	;RP1=0, select bank0
	movwf	(5)	;volatile
	line	44
;main.c: 44: PORTD=0XFF;
	movlw	(0FFh)
	movwf	(8)	;volatile
	line	45
;main.c: 45: TRISA=0X1;
	movlw	(01h)
	bsf	status, 5	;RP0=1, select bank1
	movwf	(133)^080h	;volatile
	line	46
	
l2002:	
;main.c: 46: TRISD=0X00;
	clrf	(136)^080h	;volatile
	line	47
	
l2004:	
;main.c: 47: ADCON1=0X8E;
	movlw	(08Eh)
	movwf	(159)^080h	;volatile
	line	48
	
l2006:	
;main.c: 48: ADCON0=0X41;
	movlw	(041h)
	bcf	status, 5	;RP0=0, select bank0
	movwf	(31)	;volatile
	line	49
	
l2008:	
;main.c: 49: DELAY();
	fcall	_DELAY
	line	50
	
l660:	
	return
	opt stack 0
GLOBAL	__end_of_init
	__end_of_init:
;; =============== function _init ends ============

	signat	_init,88
	global	___awmod
psect	text112,local,class=CODE,delta=2
global __ptext112
__ptext112:

;; *************** function ___awmod *****************
;; Defined at:
;;		line 5 in file "C:\Program Files (x86)\HI-TECH Software\PICC\9.82\sources\awmod.c"
;; Parameters:    Size  Location     Type
;;  divisor         2    0[COMMON] int 
;;  dividend        2    2[COMMON] int 
;; Auto vars:     Size  Location     Type
;;  sign            1    5[COMMON] unsigned char 
;;  counter         1    4[COMMON] unsigned char 
;; Return value:  Size  Location     Type
;;                  2    0[COMMON] int 
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         4       0       0       0       0
;;      Locals:         2       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         6       0       0       0       0
;;Total ram usage:        6 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_display
;; This function uses a non-reentrant model
;;
psect	text112
	file	"C:\Program Files (x86)\HI-TECH Software\PICC\9.82\sources\awmod.c"
	line	5
	global	__size_of___awmod
	__size_of___awmod	equ	__end_of___awmod-___awmod
	
___awmod:	
	opt	stack 6
; Regs used in ___awmod: [wreg+status,2+status,0]
	line	8
	
l1964:	
	clrf	(___awmod@sign)
	line	9
	
l1966:	
	btfss	(___awmod@dividend+1),7
	goto	u261
	goto	u260
u261:
	goto	l1972
u260:
	line	10
	
l1968:	
	comf	(___awmod@dividend),f
	comf	(___awmod@dividend+1),f
	incf	(___awmod@dividend),f
	skipnz
	incf	(___awmod@dividend+1),f
	line	11
	
l1970:	
	clrf	(___awmod@sign)
	incf	(___awmod@sign),f
	line	13
	
l1972:	
	btfss	(___awmod@divisor+1),7
	goto	u271
	goto	u270
u271:
	goto	l1976
u270:
	line	14
	
l1974:	
	comf	(___awmod@divisor),f
	comf	(___awmod@divisor+1),f
	incf	(___awmod@divisor),f
	skipnz
	incf	(___awmod@divisor+1),f
	line	15
	
l1976:	
	movf	(___awmod@divisor+1),w
	iorwf	(___awmod@divisor),w
	skipnz
	goto	u281
	goto	u280
u281:
	goto	l1992
u280:
	line	16
	
l1978:	
	clrf	(___awmod@counter)
	incf	(___awmod@counter),f
	line	17
	goto	l1982
	line	18
	
l1980:	
	clrc
	rlf	(___awmod@divisor),f
	rlf	(___awmod@divisor+1),f
	line	19
	incf	(___awmod@counter),f
	line	17
	
l1982:	
	btfss	(___awmod@divisor+1),(15)&7
	goto	u291
	goto	u290
u291:
	goto	l1980
u290:
	line	22
	
l1984:	
	movf	(___awmod@divisor+1),w
	subwf	(___awmod@dividend+1),w
	skipz
	goto	u305
	movf	(___awmod@divisor),w
	subwf	(___awmod@dividend),w
u305:
	skipc
	goto	u301
	goto	u300
u301:
	goto	l1988
u300:
	line	23
	
l1986:	
	movf	(___awmod@divisor),w
	subwf	(___awmod@dividend),f
	movf	(___awmod@divisor+1),w
	skipc
	decf	(___awmod@dividend+1),f
	subwf	(___awmod@dividend+1),f
	line	24
	
l1988:	
	clrc
	rrf	(___awmod@divisor+1),f
	rrf	(___awmod@divisor),f
	line	25
	
l1990:	
	decfsz	(___awmod@counter),f
	goto	u311
	goto	u310
u311:
	goto	l1984
u310:
	line	27
	
l1992:	
	movf	(___awmod@sign),w
	skipz
	goto	u320
	goto	l1996
u320:
	line	28
	
l1994:	
	comf	(___awmod@dividend),f
	comf	(___awmod@dividend+1),f
	incf	(___awmod@dividend),f
	skipnz
	incf	(___awmod@dividend+1),f
	line	29
	
l1996:	
	movf	(___awmod@dividend+1),w
	movwf	(?___awmod+1)
	movf	(___awmod@dividend),w
	movwf	(?___awmod)
	line	30
	
l1530:	
	return
	opt stack 0
GLOBAL	__end_of___awmod
	__end_of___awmod:
;; =============== function ___awmod ends ============

	signat	___awmod,8314
	global	___awdiv
psect	text113,local,class=CODE,delta=2
global __ptext113
__ptext113:

;; *************** function ___awdiv *****************
;; Defined at:
;;		line 5 in file "C:\Program Files (x86)\HI-TECH Software\PICC\9.82\sources\awdiv.c"
;; Parameters:    Size  Location     Type
;;  divisor         2    6[COMMON] int 
;;  dividend        2    8[COMMON] int 
;; Auto vars:     Size  Location     Type
;;  quotient        2   12[COMMON] int 
;;  sign            1   11[COMMON] unsigned char 
;;  counter         1   10[COMMON] unsigned char 
;; Return value:  Size  Location     Type
;;                  2    6[COMMON] int 
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         4       0       0       0       0
;;      Locals:         4       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         8       0       0       0       0
;;Total ram usage:        8 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_main
;;		_display
;; This function uses a non-reentrant model
;;
psect	text113
	file	"C:\Program Files (x86)\HI-TECH Software\PICC\9.82\sources\awdiv.c"
	line	5
	global	__size_of___awdiv
	__size_of___awdiv	equ	__end_of___awdiv-___awdiv
	
___awdiv:	
	opt	stack 6
; Regs used in ___awdiv: [wreg+status,2+status,0]
	line	9
	
l1920:	
	clrf	(___awdiv@sign)
	line	10
	
l1922:	
	btfss	(___awdiv@divisor+1),7
	goto	u191
	goto	u190
u191:
	goto	l1928
u190:
	line	11
	
l1924:	
	comf	(___awdiv@divisor),f
	comf	(___awdiv@divisor+1),f
	incf	(___awdiv@divisor),f
	skipnz
	incf	(___awdiv@divisor+1),f
	line	12
	
l1926:	
	clrf	(___awdiv@sign)
	incf	(___awdiv@sign),f
	line	14
	
l1928:	
	btfss	(___awdiv@dividend+1),7
	goto	u201
	goto	u200
u201:
	goto	l1934
u200:
	line	15
	
l1930:	
	comf	(___awdiv@dividend),f
	comf	(___awdiv@dividend+1),f
	incf	(___awdiv@dividend),f
	skipnz
	incf	(___awdiv@dividend+1),f
	line	16
	
l1932:	
	movlw	(01h)
	xorwf	(___awdiv@sign),f
	line	18
	
l1934:	
	clrf	(___awdiv@quotient)
	clrf	(___awdiv@quotient+1)
	line	19
	
l1936:	
	movf	(___awdiv@divisor+1),w
	iorwf	(___awdiv@divisor),w
	skipnz
	goto	u211
	goto	u210
u211:
	goto	l1956
u210:
	line	20
	
l1938:	
	clrf	(___awdiv@counter)
	incf	(___awdiv@counter),f
	line	21
	goto	l1942
	line	22
	
l1940:	
	clrc
	rlf	(___awdiv@divisor),f
	rlf	(___awdiv@divisor+1),f
	line	23
	incf	(___awdiv@counter),f
	line	21
	
l1942:	
	btfss	(___awdiv@divisor+1),(15)&7
	goto	u221
	goto	u220
u221:
	goto	l1940
u220:
	line	26
	
l1944:	
	clrc
	rlf	(___awdiv@quotient),f
	rlf	(___awdiv@quotient+1),f
	line	27
	
l1946:	
	movf	(___awdiv@divisor+1),w
	subwf	(___awdiv@dividend+1),w
	skipz
	goto	u235
	movf	(___awdiv@divisor),w
	subwf	(___awdiv@dividend),w
u235:
	skipc
	goto	u231
	goto	u230
u231:
	goto	l1952
u230:
	line	28
	
l1948:	
	movf	(___awdiv@divisor),w
	subwf	(___awdiv@dividend),f
	movf	(___awdiv@divisor+1),w
	skipc
	decf	(___awdiv@dividend+1),f
	subwf	(___awdiv@dividend+1),f
	line	29
	
l1950:	
	bsf	(___awdiv@quotient)+(0/8),(0)&7
	line	31
	
l1952:	
	clrc
	rrf	(___awdiv@divisor+1),f
	rrf	(___awdiv@divisor),f
	line	32
	
l1954:	
	decfsz	(___awdiv@counter),f
	goto	u241
	goto	u240
u241:
	goto	l1944
u240:
	line	34
	
l1956:	
	movf	(___awdiv@sign),w
	skipz
	goto	u250
	goto	l1960
u250:
	line	35
	
l1958:	
	comf	(___awdiv@quotient),f
	comf	(___awdiv@quotient+1),f
	incf	(___awdiv@quotient),f
	skipnz
	incf	(___awdiv@quotient+1),f
	line	36
	
l1960:	
	movf	(___awdiv@quotient+1),w
	movwf	(?___awdiv+1)
	movf	(___awdiv@quotient),w
	movwf	(?___awdiv)
	line	37
	
l1462:	
	return
	opt stack 0
GLOBAL	__end_of___awdiv
	__end_of___awdiv:
;; =============== function ___awdiv ends ============

	signat	___awdiv,8314
	global	_DELAY
psect	text114,local,class=CODE,delta=2
global __ptext114
__ptext114:

;; *************** function _DELAY *****************
;; Defined at:
;;		line 74 in file "D:\PIC16F72\PIC CODE\ADC\main.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;  i               2    0[COMMON] int 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 60/0
;;		On exit  : 60/0
;;		Unchanged: FFF9F/0
;; Data sizes:     COMMON   BANK0   BANK1   BANK3   BANK2
;;      Params:         0       0       0       0       0
;;      Locals:         2       0       0       0       0
;;      Temps:          0       0       0       0       0
;;      Totals:         2       0       0       0       0
;;Total ram usage:        2 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_init
;;		_display
;; This function uses a non-reentrant model
;;
psect	text114
	file	"D:\PIC16F72\PIC CODE\ADC\main.c"
	line	74
	global	__size_of_DELAY
	__size_of_DELAY	equ	__end_of_DELAY-_DELAY
	
_DELAY:	
	opt	stack 6
; Regs used in _DELAY: [wreg+status,2+status,0]
	line	76
	
l1916:	
;main.c: 75: int i;
;main.c: 76: for(i=0x100;i--;);
	movlw	low(0100h)
	movwf	(DELAY@i)
	movlw	high(0100h)
	movwf	((DELAY@i))+1
	
l1918:	
	movlw	-1
	addwf	(DELAY@i),f
	skipc
	decf	(DELAY@i+1),f
	incf	((DELAY@i)),w
	skipnz
	incf	((DELAY@i+1)),w

	skipz
	goto	u181
	goto	u180
u181:
	goto	l1918
u180:
	line	77
	
l669:	
	return
	opt stack 0
GLOBAL	__end_of_DELAY
	__end_of_DELAY:
;; =============== function _DELAY ends ============

	signat	_DELAY,88
psect	text115,local,class=CODE,delta=2
global __ptext115
__ptext115:
	global	btemp
	btemp set 07Eh

	DABS	1,126,2	;btemp
	global	wtemp0
	wtemp0 set btemp
	end
