;*******************************************************************
;                       Double Precision Division
;
;               ( Optimized for Code Size : Looped Code )
;
;*******************************************************************;
;   Division : ACCb(16 bits) / ACCa(16 bits) -> ACCb(16 bits) with
;                                               Remainder in ACCc (16 bits)
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;      (c) CALL D_div
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;
;   Performance :
;               Program Memory  :       037
;               Clock Cycles    :       310
;
;        NOTE :
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
SIGNED  equ     FALSE           ; Set This To 'TRUE' if the routines
;                               ; for Multiplication & Division needs
;                               ; to be assembled as Signed Integer
;                               ; Routines. If 'FALSE' the above two
;                               ; routines ( D_mpy & D_div ) use
;                               ; unsigned arithmetic.
;*******************************************************************
;       Double Precision Divide ( 16/16 -> 16 )
;
;         ( ACCb/ACCa -> ACCb with remainder in ACCc ) : 16 bit output
; with Quotiont in ACCb (ACCbHI,ACCbLO) and Remainder in ACCc (ACCcHI,ACCcLO).
;
;   NOTE  :  Before calling this routine, the user should make sure that
;            the Numerator(ACCb) is greater than Denominator(ACCa). If
;            the case is not true, the user should scale either Numerator
;            or Denominator or both such that Numerator is greater than
;            the Denominator.
;
;
D_divS
;
     IF   SIGNED
     CALL    S_SIGN
     ENDIF
;
	call    setup
	clrf    ACCcHI
	clrf    ACCcLO
dloop   bcf     STATUS,CARRY
	rlf     ACCdLO
	rlf     ACCdHI
	rlf     ACCcLO
	rlf     ACCcHI
	movf    ACCaHI,w
	subwf   ACCcHI,w          ;check if a>c
	btfss   STATUS,Z_bit
	goto    nochk
	movf    ACCaLO,w
	subwf   ACCcLO,w        ;if msb equal then check lsb
nochk   btfss   STATUS,CARRY    ;carry set if c>a
	goto    nogo
	movf    ACCaLO,w        ;c-a into c
	subwf   ACCcLO
	btfss   STATUS,CARRY
	decf    ACCcHI
	movf    ACCaHI,w
	subwf   ACCcHI
	bsf     STATUS,CARRY    ;shift a 1 into b (result)
nogo    rlf     ACCbLO
	rlf     ACCbHI
	decfsz  temp            ;loop untill all bits checked
	goto    dloop
;
    IF    SIGNED
	btfss   sign,MSB        ; check sign if negative
	retlw   0
	goto    neg_B          ; negate ACCa ( -ACCa -> ACCa )
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
	call    D_divS          ; remainder in ACCc. Here ACCb =0040 & ACCc=003F
;
self    goto    self
;
	org     PIC54
	goto    main
	END
;****************************************************************
