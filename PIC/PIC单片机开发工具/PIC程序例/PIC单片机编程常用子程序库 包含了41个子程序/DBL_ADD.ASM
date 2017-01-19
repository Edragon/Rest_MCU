;*******************************************************************
;                 Double Precision Addition & Subtraction
;
;*******************************************************************;
;   Addition :  ACCb(16 bits) + ACCa(16 bits) -> ACCb(16 bits)
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_add
;      (d) The result is in location ACCbLO & ACCbHI ( 16 bits )
;
;   Performance :
;               Program Memory  :       07
;               Clock Cycles    :       08
;*******************************************************************;
;   Subtraction : ACCb(16 bits) - ACCa(16 bits) -> ACCb(16 bits)
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_sub
;      (d) The result is in location ACCbLO & ACCbHI ( 16 bits )
;
;   Performance :
;               Program Memory  :       14
;               Clock Cycles    :       17
;*******************************************************************;
;
ACCaLO  equ     10
ACCaHI  equ     11
ACCbLO  equ     12
ACCbHI  equ     13
;
	include "picreg.h"
	org     0
;*******************************************************************
;         Double Precision Subtraction ( ACCb - ACCa -> ACCb )
;
D_sub   call    neg_A           ; At first negate ACCa; Then add
;
;*******************************************************************
;       Double Precision  Addition ( ACCb + ACCa -> ACCb )
;
D_add   movf    ACCaLO,w
	addwf   ACCbLO          ;add lsb
	btfsc   STATUS,CARRY    ;add in carry
	incf    ACCbHI
	movf    ACCaHI,w
	addwf   ACCbHI            ;add msb
	retlw   0
;
;
neg_A   comf    ACCaLO          ; negate ACCa ( -ACCa -> ACCa )
	incf    ACCaLO
	btfsc   STATUS,Z_bit
	decf    ACCaHI
	comf    ACCaHI
	retlw   0
;
;*******************************************************************
;                       Test Program
;*******************************************************************
;    Load constant values to ACCa & ACCb for testing
;
loadAB  movlw   1
	movwf   ACCaHI
	movlw   0FF             ; loads ACCa = 01FF
	movwf   ACCaLO
;
	movlw   07F
	movwf   ACCbHI
	movlw   0FF             ; loads ACCb = 7FFF
	movwf   ACCbLO
	retlw   0
;
main    nop
;
	call    loadAB          ; result of adding ACCb+ACCa->ACCb
	call    D_add           ; Here Accb = 81FE
;
	call    loadAB          ; result of subtracting ACCb - ACCa->ACCb
	call    D_sub           ; Here Accb = 7E00
;
self    goto    self
;
	org     PIC54
	goto    main
	END
;****************************************************************
