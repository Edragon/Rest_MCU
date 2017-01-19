;
;********************************************************************
;                  Binary To BCD Conversion Routine
;
;       This routine converts the 8 bit binary number in the W Register
; to a 2 digit BCD number.
;       The least significant digit is returned in location LSD and
; the most significant digit is returned in location MSD.
;
;   Performance :
;               Program Memory  :       10
;               Clock Cycles    :       81 (worst case when W = 63 Hex )
;                                          ( i.e max Decimal number 99 )
;*******************************************************************
;
LSD     equ     10
MSD     equ     11
;
	INCLUDE         "picreg.h"
;
BinBCD  clrf    MSD
	movwf   LSD
gtenth  movlw   .10
	subwf   LSD,W
	BTFSS   STATUS,CARRY
	goto    over
	movwf   LSD
	incf    MSD
	goto    gtenth
over    retlw   0
;*******************************************************************
;
main    movlw   63              ; W reg = 63 Hex
	call    BinBCD          ; after conversion, MSD = 9 & LSD = 9
self    goto    self            ; ( 63 Hex = 99 Decimal )
;
	org     1FF
	goto    main
;
	END





