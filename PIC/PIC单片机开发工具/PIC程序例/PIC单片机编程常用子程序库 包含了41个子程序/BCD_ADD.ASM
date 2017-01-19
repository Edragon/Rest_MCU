;*******************  Unsigned BCD Addition   ***************
;
;       This routine performs a 2 Digit Unsigned BCD Addition
; It is assumed that the two BCD numbers to be added are in
; locations Num_1 & Num_2. The result is the sum of Num_1+Num_2
; and is stored in location Num_2 and the overflow carry is returned
; in location Num_1
;
;   Performance :
;               Program Memory  :       25
;               Clock Cycles    :       23   ( worst case )
;
;       Rev 2.0 changed on 7/30/92.
;
;*******************************************************************;
;
Num_1   equ     8       ; Overflow flow carry overwrites Num_1
result  equ     8
;
Num_2   equ     9       ; Num_2 + Num_1 overwrites Num_2
O_flow  equ     9
;
;
	include         "picreg.h"
;
BCDAdd  movf    Num_1,w
	addwf   Num_2       ; do binary addition
	clrf    Num_1
	rlf     Num_1
	btfsc   STATUS,DC       ; Is DC = 0 ?
	goto    adjust          ; adjust LSD
	movlw   6
	addwf   Num_2          ; Test for LSD > 9 ( by adding 6
	btfsc   STATUS,CARRY
	incf    Num_1
	btfss   STATUS,DC       ; & checking Digit Carry
	subwf   Num_2           ; LSD < 9 , so get back original value.
	goto    over1
adjust  movlw   6
	addwf   Num_2
over1   movlw   60              ; add 6 to MSD
	addwf   Num_2
	btfsc   STATUS,CARRY
	goto    over3
	btfss   Num_1,0
	subwf   Num_2
	RETLW   0
over3   movlw   1
	movwf   Num_1
	RETLW   0
;
;********************************************************************
;               Test Program
;*********************************************************************
main    movlw   99
	movwf   Num_1      ; Set Num_1 = 99 ( max BCD digit )
	movlw   99
	movwf   Num_2      ; Set Num_2 = 99
;
	call    BCDAdd     ; After addition, Num_2 = 98
;                          ;  and Num_1 = 01 ( 99+99 = 198 -> max number )
;
self    goto    self
;
	org     1FF
	goto    main
;
	END




