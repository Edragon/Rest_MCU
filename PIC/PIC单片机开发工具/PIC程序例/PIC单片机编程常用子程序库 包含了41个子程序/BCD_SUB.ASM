;*******************  Unsigned BCD Subtraction   ***************
;
;       This routine performs a 2 Digit Unsigned BCD Subtraction.
; It is assumed that the two BCD numbers to be subtracted are in
; locations Num_1 & Num_2. The result is the difference of Num_1 & Num_2
; ( Num_2 - Num_1) and is stored in location Num_2 and the overflow carry
; is returned in location Num_1.
;
;   Performance :
;               Program Memory  :       31
;               Clock Cycles    :       21  ( worst case )
;
;*******************************************************************
;
Num_1   equ     8       ; Overflow flow carry overwrites Num_1
result  equ     8
;
Num_2   equ     9       ; Num_2 - Num_1 overwrites Num_2
O_flow  equ     9
;
	include         "picreg.h"
;
BCDSub  movf    Num_1,w
	subwf   Num_2
	clrf    Num_1
	rlf     Num_1
	btfss   STATUS,DC
	goto    adjst1
	btfss   Num_2,3         ; Adjust LSD of Result
	goto    Over_1
	btfsc   Num_2,2
	goto    adjst1          ; Adjust LSD of Result
	btfss   Num_2,1
	goto    Over_1          ; No : Go for MSD
adjst1  movlw   6
	subwf   Num_2
Over_1  btfss   Num_1,0         ; CY = 0 ?
	goto    adjst2          ; Yes, adjust MSD of result
	clrf    Num_1
	btfss   Num_2,7         ; No, test for MSD >9
	RETLW   0
	btfsc   Num_2,6
	goto    adjst2
	btfss   Num_2,5
	RETLW   0
adjst2  movlw   60              ; add 6 to MSD
	subwf   Num_2
	clrf    Num_1
	btfss   STATUS,CARRY    ; test if underflow
	RETLW   0
	movlw   1
	movwf   Num_1
Over    RETLW   0
;
;********************************************************************
;               Test Program
;*********************************************************************
main    movlw   23
	movwf   Num_1      ; Set Num_1 = 23
	movlw   99
	movwf   Num_2      ; Set Num_2 = 99
	call    BCDSub     ; After subtraction, Num_2 = 76 ( 99-23 )
;                          ;  and Num_1 = 0 ( indicates positive result )
;
	movlw   99
	movwf   Num_1      ; Set Num_1 = 99
	movlw   0
	movwf   Num_2      ; Set Num_2 = 0
;
	call    BCDSub     ; After subtraction, Num_2 = 1
;                          ;  and Num_1 = 1 ( indicates negative result )
;                          ;  -1  <-  ( -99 )
;
self    goto    self
;
	org     1FF
	goto    main
;
	END

