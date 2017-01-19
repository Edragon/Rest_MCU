opt subtitle "HI-TECH Software Omniscient Code Generator (PRO mode) build 9453"

opt pagewidth 120

	opt pm

	processor	16F72
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
	FNCALL	_main,_delay_ms
	FNROOT	_main
	global	_PORTB
psect	maintext,global,class=CODE,delta=2
global __pmaintext
__pmaintext:
_PORTB	set	6
	global	_TRISB
_TRISB	set	134
	global	_TRISC
_TRISC	set	135
	file	"LED.as"
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
	global	?_delay_ms
?_delay_ms:	; 0 bytes @ 0x0
	global	?_main
?_main:	; 0 bytes @ 0x0
	global	delay_ms@z
delay_ms@z:	; 2 bytes @ 0x0
	ds	2
	global	??_delay_ms
??_delay_ms:	; 0 bytes @ 0x2
	global	delay_ms@y
delay_ms@y:	; 2 bytes @ 0x2
	ds	2
	global	delay_ms@x
delay_ms@x:	; 1 bytes @ 0x4
	ds	1
	global	??_main
??_main:	; 0 bytes @ 0x5
;;Data sizes: Strings 0, constant 0, data 0, bss 0, persistent 0 stack 0
;;Auto spaces:   Size  Autos    Used
;; COMMON          62      5       5
;; BANK0           32      0       0
;; BANK1           32      0       0

;;
;; Pointer list with targets:



;;
;; Critical Paths under _main in COMMON
;;
;;   _main->_delay_ms
;;
;; Critical Paths under _main in BANK0
;;
;;   None.
;;
;; Critical Paths under _main in BANK1
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
;; (0) _main                                                 0     0      0      75
;;                           _delay_ms
;; ---------------------------------------------------------------------------------
;; (1) _delay_ms                                             5     3      2      75
;;                                              0 COMMON     5     3      2
;; ---------------------------------------------------------------------------------
;; Estimated maximum stack depth 1
;; ---------------------------------------------------------------------------------

;; Call Graph Graphs:

;; _main (ROOT)
;;   _delay_ms
;;

;; Address spaces:

;;Name               Size   Autos  Total    Cost      Usage
;;BITCOMMON           3E      0       0       0        0.0%
;;NULL                 0      0       0       0        0.0%
;;CODE                 0      0       0       0        0.0%
;;COMMON              3E      5       5       1        8.1%
;;BITSFR0              0      0       0       1        0.0%
;;SFR0                 0      0       0       1        0.0%
;;BITSFR1              0      0       0       2        0.0%
;;SFR1                 0      0       0       2        0.0%
;;STACK                0      0       1       2        0.0%
;;BANK0               20      0       0       3        0.0%
;;BITSFR3              0      0       0       4        0.0%
;;SFR3                 0      0       0       4        0.0%
;;ABS                  0      0       0       4        0.0%
;;BITBANK0            20      0       0       5        0.0%
;;BITSFR2              0      0       0       5        0.0%
;;SFR2                 0      0       0       5        0.0%
;;BITBANK1            20      0       0       6        0.0%
;;BANK1               20      0       0       7        0.0%
;;DATA                 0      0       0       8        0.0%

	global	_main
psect	maintext

;; *************** function _main *****************
;; Defined at:
;;		line 14 in file "D:\PIC16F72\PIC16 DEMO\main.c"
;; Parameters:    Size  Location     Type
;;		None
;; Auto vars:     Size  Location     Type
;;		None
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2, status,0, pclath, cstack
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 17F/0
;;		Unchanged: FFE80/0
;; Data sizes:     COMMON   BANK0   BANK1
;;      Params:         0       0       0
;;      Locals:         0       0       0
;;      Temps:          0       0       0
;;      Totals:         0       0       0
;;Total ram usage:        0 bytes
;; Hardware stack levels required when called:    1
;; This function calls:
;;		_delay_ms
;; This function is called by:
;;		Startup code after reset
;; This function uses a non-reentrant model
;;
psect	maintext
	file	"D:\PIC16F72\PIC16 DEMO\main.c"
	line	14
	global	__size_of_main
	__size_of_main	equ	__end_of_main-_main
	
_main:	
	opt	stack 7
; Regs used in _main: [wreg+status,2+status,0+pclath+cstack]
	line	15
	
l822:	
;main.c: 15: TRISB=0x00;
	bsf	status, 5	;RP0=1, select bank1
	clrf	(134)^080h	;volatile
	line	16
;main.c: 16: TRISC=0x00;
	clrf	(135)^080h	;volatile
	line	19
	
l824:	
;main.c: 18: {
;main.c: 19: PORTB=0xFE;
	movlw	(0FEh)
	bcf	status, 5	;RP0=0, select bank0
	movwf	(6)	;volatile
	line	20
	
l826:	
;main.c: 20: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	21
	
l828:	
;main.c: 21: PORTB=0xFD;
	movlw	(0FDh)
	movwf	(6)	;volatile
	line	22
	
l830:	
;main.c: 22: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	23
	
l832:	
;main.c: 23: PORTB=0xFB;
	movlw	(0FBh)
	movwf	(6)	;volatile
	line	24
	
l834:	
;main.c: 24: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	25
	
l836:	
;main.c: 25: PORTB=0xF7;
	movlw	(0F7h)
	movwf	(6)	;volatile
	line	26
	
l838:	
;main.c: 26: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	27
	
l840:	
;main.c: 27: PORTB=0xEF;
	movlw	(0EFh)
	movwf	(6)	;volatile
	line	28
	
l842:	
;main.c: 28: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	29
	
l844:	
;main.c: 29: PORTB=0xDF;
	movlw	(0DFh)
	movwf	(6)	;volatile
	line	30
	
l846:	
;main.c: 30: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	31
	
l848:	
;main.c: 31: PORTB=0xBF;
	movlw	(0BFh)
	movwf	(6)	;volatile
	line	32
	
l850:	
;main.c: 32: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	line	33
	
l852:	
;main.c: 33: PORTB=0x7F;
	movlw	(07Fh)
	movwf	(6)	;volatile
	line	34
	
l854:	
;main.c: 34: delay_ms(100);
	movlw	064h
	movwf	(?_delay_ms)
	clrf	(?_delay_ms+1)
	fcall	_delay_ms
	goto	l824
	global	start
	ljmp	start
	opt stack 0
psect	maintext
	line	36
GLOBAL	__end_of_main
	__end_of_main:
;; =============== function _main ends ============

	signat	_main,88
	global	_delay_ms
psect	text20,local,class=CODE,delta=2
global __ptext20
__ptext20:

;; *************** function _delay_ms *****************
;; Defined at:
;;		line 6 in file "D:\PIC16F72\PIC16 DEMO\main.c"
;; Parameters:    Size  Location     Type
;;  z               2    0[COMMON] unsigned int 
;; Auto vars:     Size  Location     Type
;;  y               2    2[COMMON] unsigned int 
;;  x               1    4[COMMON] unsigned char 
;; Return value:  Size  Location     Type
;;		None               void
;; Registers used:
;;		wreg, status,2, status,0
;; Tracked objects:
;;		On entry : 17F/0
;;		On exit  : 17F/0
;;		Unchanged: FFE80/0
;; Data sizes:     COMMON   BANK0   BANK1
;;      Params:         2       0       0
;;      Locals:         3       0       0
;;      Temps:          0       0       0
;;      Totals:         5       0       0
;;Total ram usage:        5 bytes
;; Hardware stack levels used:    1
;; This function calls:
;;		Nothing
;; This function is called by:
;;		_main
;; This function uses a non-reentrant model
;;
psect	text20
	file	"D:\PIC16F72\PIC16 DEMO\main.c"
	line	6
	global	__size_of_delay_ms
	__size_of_delay_ms	equ	__end_of_delay_ms-_delay_ms
	
_delay_ms:	
	opt	stack 7
; Regs used in _delay_ms: [wreg+status,2+status,0]
	line	9
	
l804:	
;main.c: 7: unsigned char x;
;main.c: 8: unsigned int y;
;main.c: 9: for(x=110;x>0;x--)
	movlw	(06Eh)
	movwf	(delay_ms@x)
	line	10
	
l810:	
;main.c: 10: for(y=z;y>0;y--);
	movf	(delay_ms@z+1),w
	movwf	(delay_ms@y+1)
	movf	(delay_ms@z),w
	movwf	(delay_ms@y)
	
l812:	
	movf	((delay_ms@y+1)),w
	iorwf	((delay_ms@y)),w
	skipz
	goto	u11
	goto	u10
u11:
	goto	l816
u10:
	goto	l820
	
l816:	
	movlw	low(01h)
	subwf	(delay_ms@y),f
	movlw	high(01h)
	skipc
	decf	(delay_ms@y+1),f
	subwf	(delay_ms@y+1),f
	goto	l812
	line	9
	
l820:	
	decf	(delay_ms@x),f
	movf	(delay_ms@x),f
	skipz
	goto	u21
	goto	u20
u21:
	goto	l810
u20:
	line	11
	
l429:	
	return
	opt stack 0
GLOBAL	__end_of_delay_ms
	__end_of_delay_ms:
;; =============== function _delay_ms ends ============

	signat	_delay_ms,4216
psect	text21,local,class=CODE,delta=2
global __ptext21
__ptext21:
	global	btemp
	btemp set 07Eh

	DABS	1,126,2	;btemp
	global	wtemp0
	wtemp0 set btemp
	end
