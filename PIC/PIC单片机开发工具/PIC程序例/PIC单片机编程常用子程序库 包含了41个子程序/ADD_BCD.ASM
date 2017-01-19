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
;               Clock Cycles    :       17   ( worst case )
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
BCDAdd  movf    Num_1,W
	clrf    Num_1           ;clear num_1
	addwf   Num_2,1         ; do binary addition
	btfsc   STATUS,C        ;< 256 then skip
	goto    inc_n1n2        ;else inc all
	movlw   66              ;add 66
	addwf   Num_2,1         ;/
	btfss   STATUS,DC       ;half carry?
	goto    sub_06          ;no then subtract
	btfss   STATUS,C        ;full carry?
	goto    sub_60          ;yes then subtract
inc_n1  incf    Num_1,1         ;inc it
	retlw   0               ;clr w
sub_06  btfss   STATUS,C        ;full carry
	goto    sub_66          ;yes subtract 66
	movlw   6               ;else subtract 6
	goto    sub_com         ;do common
sub_66  movlw   66              
sub_com subwf   Num_2,1                   
	retlw   0
sub_60  movlw   60
	goto    sub_com
inc_n1n2
	movlw   66
	addwf   Num_2,1
	goto    inc_n1
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
;
	org     1FF
	goto    main
;
	END




