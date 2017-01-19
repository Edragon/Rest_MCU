;*******************************************************************
;                    Double Precision Multiplication
;
;               ( Optimized for Code Size : Looped Code )
;
;*******************************************************************;
;   Multiplication : ACCb(16 bits) * ACCa(16 bits) -> ACCb,ACCc ( 32 bits )
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_mpy
;      (d) The 32 bit result is in location ( ACCbHI,ACCbLO,ACCcHI,ACCcLO )
;
;   Performance :
;               Program Memory  :       033
;               Clock Cycles    :       333
;
;       Note : The above timing is the worst case timing, when the
;               register ACCb = FFFF. The speed may be improved if
;               the register ACCb contains a number ( out of the two
;               numbers ) with less number of 1s.
;               The performance specs are for Unsigned arithmetic ( i.e,
;               with "SIGNED equ  FALSE ").
;
;               The performance specs are for Unsigned arithmetic ( i.e,
;               with "SIGNED equ  FALSE ").
;
;*******************************************************************;
;
ACCaLO  equ     10
ACCaHI  equ     11
ACCbLO  equ     12
ACCbHI  equ     13
ACCcLO  equ     14
ACCcHI  equ     15
ACCdLO  equ     16
ACCdHI  equ     17
temp    equ     18
sign    equ     19
;
	include "picreg.h"
	org     0
;*******************************************************************
SIGNED  equ     TRUE            ; Set This To 'TRUE' if the routines
;                               ; for Multiplication & Division needs
;                               ; to be assembled as Signed Integer
;                               ; Routines. If 'FALSE' the above two
;                               ; routines ( D_mpy & D_div ) use
;                               ; unsigned arithmetic.
;*******************************************************************
;         Double Precision Subtraction ( ACCb - ACCa -> ACCb )
;
D_add   movf    ACCaLO,w        ; Addition ( ACCb + ACCa -> ACCb )
	addwf   ACCbLO          ;add lsb
	btfsc   STATUS,CARRY    ;add in carry
	incf    ACCbHI
	movf    ACCaHI,w
	addwf   ACCbHI            ;add msb
	retlw   0
;*******************************************************************
;               Double Precision Multiply ( 16x16 -> 32 )
;         ( ACCb*ACCa -> ACCb,ACCc ) : 32 bit output with high word
;  in ACCb ( ACCbHI,ACCbLO ) and low word in ACCc ( ACCcHI,ACCcLO ).
;
D_mpyS                           ;results in ACCb(16 msb's) and ACCc(16 lsb's)
;
     IF   SIGNED
     CALL    S_SIGN
     ENDIF
;
	call    setup
mloop   rrf     ACCdHI          ;rotate d right
	rrf     ACCdLO
	btfsc   STATUS,CARRY    ;need to add?
	call    D_add
	rrf     ACCbHI
	rrf     ACCbLO
	rrf     ACCcHI
	rrf     ACCcLO
	decfsz  temp            ;loop until all bits checked
	goto    mloop
;
    IF    SIGNED
	btfss   sign,MSB
	retlw   0
	comf    ACCcLO          ; negate ACCa ( -ACCa -> ACCa )
	incf    ACCcLO
	btfsc   STATUS,Z_bit
	decf    ACCcHI
	comf    ACCcHI
	btfsc   STATUS,Z_bit
neg_B   comf    ACCbLO          ; negate ACCb
	incf    ACCbLO
	btfsc   STATUS,Z_bit
	decf    ACCbHI
	comf    ACCbHI
	retlw   0
    ELSE
	retlw   0
    ENDIF
;
;*******************************************************************
;
setup   movlw   .16             ; for 16 shifts
	movwf   temp
	movf    ACCbHI,w          ;move ACCb to ACCd
	movwf   ACCdHI
	movf    ACCbLO,w
	movwf   ACCdLO
	clrf    ACCbHI
	clrf    ACCbLO
	retlw   0
;
;*******************************************************************
;
neg_A   comf    ACCaLO          ; negate ACCa ( -ACCa -> ACCa )
	incf    ACCaLO
	btfsc   STATUS,Z_bit
	decf    ACCaHI
	comf    ACCaHI
	retlw   0
;
;*******************************************************************
;  Assemble this section only if Signed Arithmetic Needed
;
     IF    SIGNED
;
S_SIGN  movf    ACCaHI,W
	xorwf   ACCbHI,W
	movwf   sign
	btfss   ACCbHI,MSB        ; if MSB set go & negate ACCb
	goto    chek_A
;
	comf    ACCbLO          ; negate ACCb
	incf    ACCbLO
	btfsc   STATUS,Z_bit
	decf    ACCbHI
	comf    ACCbHI
;
chek_A  btfss   ACCaHI,MSB        ; if MSB set go & negate ACCa
	retlw   0
	goto    neg_A
;
     ENDIF
;
;*******************************************************************
;                       Test Program
;*******************************************************************
;    Load constant values to ACCa & ACCb for testing
;
main    movlw   1
	movwf   ACCaHI
	movlw   0FF             ; loads ACCa = 01FF
	movwf   ACCaLO
;
	movlw   07F
	movwf   ACCbHI
	movlw   0FF             ; loads ACCb = 7FFF
	movwf   ACCbLO
;
	call    D_mpyS          ; Here (ACCb,ACCc) = 00FF 7E01
;
self    goto    self
;
	org     PIC54
	goto    main
	END
;****************************************************************
