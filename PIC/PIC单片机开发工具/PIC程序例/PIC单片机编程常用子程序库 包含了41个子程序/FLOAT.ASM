;*******************************************************************
;       Binary Floating Point Addition, Subtraction, Multiplication
;                       and Divide routines.
;
;*******************************************************************;
;
;   Addition :  ACCb(16 bits) + ACCa(16 bits) -> ACCb(16 bits)
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits ) with
;          the 8 bit exponent in EXPa.
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits ) with
;          the 8 bit exponent in EXPb.
;      (c) CALL F_add
;      (d) The result is in location ACCbLO & ACCbHI ( 16 bits ) with
;          the 8 bit exponent in EXPb
;
;       Program Memory :        55 locations
;
;*******************************************************************;
;
;   Subtraction : ACCb(16 bits) - ACCa(16 bits) -> ACCb(16 bits)
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits ) with
;          the 8 bit exponent in EXPa .
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits ) with
;          the 8 bit exponent in EXPb .
;      (c) CALL F_sub
;      (d) The result is in location ACCbLO & ACCbHI ( 16 bits ) with
;          the 8 bit exponent in EXPb.
;
;       Program Memory :        61 locations
;
;*******************************************************************;
;
;   Multiplication :
;   ACCb(16 bits)EXP(b) * ACCa(16 bits)EXPa -> ACCb(16 bits)EXPb
;   where, EXP(x) represents an 8 bit exponent.
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits ) with
;                               an 8 bit exponent in location EXPa
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits ) with
;                               an 8 bit exponent in location EXPb
;      (c) CALL F_mpy
;      (d) The 16 bit result overwrites ACCb(ACCbLO & ACCbHI). The exponent
;               is stored in EXPb and the results are normalized.
;
; NOTE : If one needs to get a 32 bit product( & an 8 bit exponent ),
;        re assemble the program after changing the line " Mode16 equ TRUE"
;        to " Mode16  equ  FALSE ".
;        If this option is chosen, then the 32 bit result is returned in
;        ( ACCbHI, ACCbLO, ACCcHI, ACCcLO ) and the 8 bit exponent in EXPb.
;        This method ( with " Mode16 equ FALSE " ) is NOT Recommended.
;
;       Program Memory :        102 locations
;
;*******************************************************************;
;
;   Division :
;       ACCb(16 bits)EXP(b) / ACCa(16 bits)EXP(a) -> ACCb(16 bits)EXP(b)
;                                       with Remainder in ACCc (16 bits)
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;                                               with exponent in EXPa
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;                                               with exponent in EXPa
;      (c) CALL F_div
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;                                       with exponent in EXPb
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;
;       Program Memory :        86 locations
;
;*******************************************************************;
;
ACCaLO  equ     10
ACCaHI  equ     11
EXPa    equ     12
ACCbLO  equ     13
ACCbHI  equ     14
EXPb    equ     15
ACCcLO  equ     16
ACCcHI  equ     17
ACCdLO  equ     18
ACCdHI  equ     19
temp    equ     1A
sign    equ     1B
;
	include "picreg.h"
;
Mode16  equ     TRUE            ; Change this to FALSE if a 32 bit propduct
;                               ; is desired for F_mpy routine.
;
	org     0
;*******************************************************************
;       Floating Point Subtraction  ( ACCb - ACCa -> ACCb )
;
F_sub   call    neg_A           ; At first negate ACCa; Then add
;
F_add   movf    EXPa,w          ; scale mantissas
	subwf   EXPb,w          ; find the greater exponent
	btfsc   STATUS,Z_bit
	goto    padd            ; exponents are equal
	btfsc   STATUS,CARRY    ;
	call    F_swap          ; if A > B then swap ( A<->B )
	movf    EXPa,w
	subwf   EXPb
scloop  call    shftSR
	incfsz  EXPb
	goto    scloop
	movf    EXPa,w
	movwf   EXPb
padd    movf    ACCaHI,w
	iorwf   ACCbHI,w
	movwf   sign
	call    D_add           ; compute double precision integer add
	btfss   sign,MSB
	btfss   ACCbHI,MSB
	retlw   0
	bcf     STATUS,CARRY
	incf    EXPb
	goto    shftR
;
;*******************************************************************
;         Double Precision Subtraction ( ACCb - ACCa -> ACCb )
;
D_sub   call    neg_A           ; At first negate ACCa; Then add
;
D_add   movf    ACCaLO,w        ; Addition ( ACCb + ACCa -> ACCb )
	addwf   ACCbLO          ;add lsb
	btfsc   STATUS,CARRY    ;add in carry
	incf    ACCbHI
	movf    ACCaHI,w
	addwf   ACCbHI            ;add msb
	retlw   0
;*******************************************************************
;
;
shftSR  bcf     STATUS,CARRY
	btfsc   ACCbHI,MSB
	bsf     STATUS,CARRY            ; set carry if < 0
shftR   rrf     ACCbHI
	rrf     ACCbLO
	retlw   0
;
shftSL  bcf     STATUS,CARRY
;
	if   Mode16
	rlf     ACCcLO
	rlf     ACCcHI
	endif
;
	rlf     ACCbLO
	rlf     ACCbHI
	bcf     ACCbHI,MSB
	btfsc   STATUS,CARRY
	bsf     ACCbHI,MSB
	retlw   0
;
;*******************************************************************
;   Binary Floating Point Multiplication :
;   ACCb(16 bits)EXP(b) * ACCa(16 bits)EXPa -> ACCb(16 bits)EXPb
;
F_mpy
	call    S_SIGN
	call    setup
mloop   bcf     STATUS,CARRY    ; clear carry bit       ??????????
	rrf     ACCdHI          ;rotate d right
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
	movf    EXPa,w
	addwf   EXPb
;
	IF   Mode16
	movf    ACCbHI
	btfss   STATUS,Z_bit
	goto    finup           ; if ACCbHI != 0
	movf    ACCbLO
	btfss   STATUS,Z_bit
	goto    Shft08          ; if ACCbLO != 0 && ACCbHI == 0
;
	movf    ACCcHI,w
	movwf   ACCbHI          ; if ACCb == 0, then move ACCc to ACCb
	movf    ACCcLO,w
	movwf   ACCbLO
	movlw   .16
	addwf   EXPb
	goto    finup
;
Shft08  movf    ACCbLO,w
	movwf   ACCbHI
	movf    ACCcHI,w
	movwf   ACCbLO
	movlw   .8
	addwf   EXPb
;
	ENDIF                   ; matching endif for IF Mode16
;
finup   btfss   sign,MSB
	goto    F_norm
;
	decf    ACCcLO          ; negate ACCc
	comf    ACCcLO
	btfsc   STATUS,Z_bit
	decf    ACCcHI
	comf    ACCcHI
	btfsc   STATUS,Z_bit
;
neg_B   decf    ACCbLO          ; negate ACCb
	comf    ACCbLO
	btfsc   STATUS,Z_bit
	decf    ACCbHI
	comf    ACCbHI
;
	goto    F_norm
;
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
	clrf    ACCbLO          ; clear ACCb ( ACCbLO & ACCbHI )
	retlw   0
;

;*******************************************************************
;   Floating Point Division :
;   ACCb(16 bits)EXP(b) / ACCa(16 bits)EXPa -> ACCb(16 bits)EXPb , with
;                               remainder in ACCc ( 16 bits ).
;
F_div   call    S_SIGN
	call    setup
	clrf    ACCcHI
	clrf    ACCcLO
dloop   bcf     STATUS,CARRY     ;????????
	rlf     ACCdLO
	rlf     ACCdHI
	rlf     ACCcLO
	rlf     ACCcHI
	movf    ACCaHI,w        ; check if ACCa > ACCb
	subwf   ACCcHI,w
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
	movf    EXPa,w
	subwf   EXPb
	btfss   sign,MSB
	goto    F_norm
	decf    ACCbLO          ; negate ACCb
	comf    ACCbLO
	btfsc   STATUS,Z_bit
	decf    ACCbHI
	comf    ACCbHI
	goto    F_norm
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
;*******************************************************************
;      Normalize Routine
; Normalizes ACCb for use in floating point calculations.
; Call this routine as often as possible to minimize the loss
; of precission. This routine normalizes ACCb so that the
; mantissa is maximized and the exponent minimized.
;
;
;
F_norm  movf    ACCbHI
	btfss   STATUS,Z_bit
	goto    C_norm
	movf    ACCbLO
	btfsc   STATUS,Z_bit
	retlw   0
C_norm  btfsc   ACCbHI,6
	retlw   0
	call    shftSL
	decf    EXPb
	goto    C_norm
;
;*******************************************************************
;  Swap ACCa & ACCb   [ (ACCa,EXPa) <--> (ACCb,EXPb) ]
;
F_swap
	movf    ACCaHI,w
	movwf   temp
	movf    ACCbHI,w        ;ACCaHI <--> ACCbHI
	movwf   ACCaHI
	movf    temp,w
	movwf   ACCbHI
;
	movf    ACCaLO,w
	movwf   temp
	movf    ACCbLO,w        ;ACCaLO <--> ACCbLO
	movwf   ACCaLO
	movf    temp,w
	movwf   ACCbLO
;
	movf    EXPa,w
	movwf   temp
	movf    EXPb,w          ;EXPa <--> EXPb
	movwf   EXPa
	movf    temp,w
	movwf   EXPb
;
	retlw   0
;
;*******************************************************************
;                       Test Program
;*******************************************************************
;    Load constant values to (ACCa, EXPa) & (ACCb, EXPb) for testing
;
loadAB  movlw   1
	movwf   ACCaHI
	movlw   0FF             ; loads ACCa = 01FF EXP(4)
	movwf   ACCaLO
	movlw   04
	movwf   EXPa
;
	movlw   07F
	movwf   ACCbHI
	movlw   0FF             ; loads ACCb = 7FFF EXP(6)
	movwf   ACCbLO
	movlw   06
	movwf   EXPb
	retlw   0
;
main    nop
;
	call    loadAB          ; result of adding ACCb(EXPb)+ACCa(EXPa)->ACCb(EXPb)
	call    F_add           ; Here Accb = 403F, EXPb = 07
;
	call    loadAB          ; result of subtracting ACCb(EXPb)-ACCa(EXPa)->ACCb(EXPb)
	call    F_sub           ; Here Accb = 7F7F, EXPb = 06
;
	call    loadAB          ; result of multiplying ACCb(EXPb) * ACCa(EXPa)->ACCb(EXPb)
	call    F_mpy           ; Here ACCb = FF7E, EXPb = 12
;
	call    loadAB          ; result of dividing ACCb(EXPb) / ACCa(EXPa)->ACCb(EXPb) with
	call    F_div           ; remainder in ACCc. Here ACCb =4000, EXPb = FA (same as -6)
;                               ; & the remainder ACCc = 003F
;
self    goto    self
;
	org     PIC54
	goto    main
	END
;****************************************************************
