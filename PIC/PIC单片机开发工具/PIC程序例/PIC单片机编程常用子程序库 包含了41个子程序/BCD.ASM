#define PAGE    EJECT

    TITLE   "BCD Arithmetic Routines : Ver 1.0"

;*******************************************************************
;                      BCD Arithmetic Routines
;*******************************************************************

	LIST     columns=120, WRAP, L=0

	include "17c42.h"

	CBLOCK   0x20
		Lbyte, Hbyte
		R2, R1, R0             ;must maintain R2, R1, R0 sequence
		count
		Num1, Num2
	ENDC
;
BCD     equ      Num1
Htemp   equ      Num1
Ltemp   equ      Num2
;
	PAGE

	ORG     0x0000
;*******************************************************************
;                      BCD Arithmetic Test Program
;*******************************************************************
;
main
	setf     Hbyte
	setf     Lbyte
;                               ; 16 bit binary num = 0xffff
	call    B2_BCD_Looped   ; after conversion the Decimal Num
;                               ; in R0, R1, R2 = 06,55,35
	setf     Hbyte
	setf     Lbyte
	call    B2_BCD_Straight ; same as above, but straight line code
;
	movlw    0x06
	movwf     R0
	movlw    0x55
	movwf     R1
	movlw    0x35
	movwf     R2              ; setf R0R1R2 = 65535
;
	call    BCDtoB          ; after conversion Hbyte = 0xff
;                               ; and Lbyte = 0xff
	movlw    0x99
	movwf     Num1
	movlw    0x99
	movwf     Num2            ; setf Num1 = Num2 = 0x99 (max BCD)
;
	call    BCDAdd          ; after addition, Num2 = 98
;                               ; and Num1 = 01 ( 99+99 = 198)
;
	movlw    0x63            ; setf Wreg = 63 hex
	call    BinBCD          ; after conversion, BCD = 99
;                               ; 63 hex = 99 decimal.
;
self    goto    self
;
	PAGE
;*******************************************************************;
;                  Binary To BCD Conversion Routine (8 bit)
;
;       This routine converts the 8 bit binary number in the W Reg
; to a 2 digit BCD number in location BCD( compacted BCD Code)
;       The least significant digit is returned in location LSD and
; the most significant digit is returned in location MSD.
;
;   Performance :
;               Program Memory  :  10
;               Clock Cycles    :  62  (worst case when W = 63 Hex )
;                                      ( i.e max Decimal number 99 )
;*******************************************************************
;
BinBCD
	clrf     BCD
again
	addlw    -10
	btfss      _carry
	goto    swapBCD
	incf     BCD
	goto    again
swapBCD
	addlw    10
	swapf    BCD
	iorwf     BCD
	return
;
	PAGE
;********************************************************************
;                Binary To BCD Conversion Routine (16 Bit)
;                       (LOOPED Version)
;
;      This routine converts a 16 Bit binary Number to a 5 Digit
; BCD Number.
;
;       The 16 bit binary number is input in locations Hbyte and
; Lbyte with the high byte in Hbyte.
;       The 5 digit BCD number is returned in R0, R1 and R2 with R0
; containing the MSD in its right most nibble.
;
;   Performance :
;               Program Memory  :  32
;               Clock Cycles    :  750
;
;*******************************************************************;
;
B2_BCD_Looped
	bsf      _fs0
	bsf      _fs1            ; set fsr0 for no auto increment
;
	bcf      _carry
	clrf     count
	bsf      count,4         ; set count = 16
	clrf     R0
	clrf     R1
	clrf     R2
loop16a
	rlcf     Lbyte
	rlcf     Hbyte
	rlcf     R2
	rlcf     R1
	rlcf     R0
;
	dcfsnz   count
	return
adjDEC
	movlw    R2              ; load R2 as indirect address ptr
	movwf     fsr0
	call    adjBCD
;
	incf     fsr0
	call    adjBCD
;
	incf     fsr0
	call    adjBCD
;
	goto    loop16a
;
adjBCD
	movfp    indf0,wreg
	addlw    0x03
	btfsc      wreg,3          ; test if result > 7
	movwf     indf0
	movfp    indf0,wreg
	addlw    0x30
	btfsc      wreg,7          ; test if result > 7
	movwf     indf0           ; save as MSD
	return
;
;********************************************************************
;                Binary To BCD Conversion Routine (16 Bit)
;                       (Partial Straight Line Version)
;
;      This routine converts a 16 Bit binary Number to a 5 Digit
; BCD Number.
;
;       The 16 bit binary number is input in locations Hbyte and
; Lbyte with the high byte in Hbyte.
;       The 5 digit BCD number is returned in R0, R1 and R2 with R0
; containing the MSD in its right most nibble.
;
;   Performance :
;               Program Memory  :  44
;               Clock Cycles    :  572
;
;*******************************************************************;
;
B2_BCD_Straight
	bsf      _fs0
	bsf      _fs1            ; set fsr0 for no auto increment
;
	bcf      _carry
	clrf     count
	bsf      count,4         ; set count = 16
	clrf     R0
	clrf     R1
	clrf     R2
loop16b
	rlcf     Lbyte
	rlcf     Hbyte
	rlcf     R2
	rlcf     R1
	rlcf     R0
;
	dcfsnz   count
	return                   ; DONE
	movlw    R2              ; load R2 as indirect address ptr
	movwf    fsr0
; adjustBCD
	movfp    indf0,wreg
	addlw    0x03
	btfsc    wreg,3          ; test if result > 7
	movwf    indf0
	movfp    indf0,wreg
	addlw    0x30
	btfsc    wreg,7          ; test if result > 7
	movwf    indf0           ; save as MSD
;
	incf     fsr0
; adjustBCD
	movfp    indf0,wreg
	addlw    0x03
	btfsc    wreg,3          ; test if result > 7
	movwf    indf0
	movfp    indf0,wreg
	addlw    0x30
	btfsc    wreg,7          ; test if result > 7
	movwf    indf0           ; save as MSD
;
	incf     fsr0
; adjustBCD
	movfp    indf0,wreg
	addlw    0x03
	btfsc    wreg,3          ; test if result > 7
	movwf    indf0
	movfp    indf0,wreg
	addlw    0x30
	btfsc    wreg,7          ; test if result > 7
	movwf    indf0           ; save as MSD
;
	goto    loop16b
;
	PAGE
;************************************************************************
;               BCD To Binary Conversion
;
;       This routine converts a 5 digit BCD number to a 16 bit binary
; number.
;       The input 5 digit BCD numbers are asumed to be in locations
; R0, R1 & R2 with R0 containing the MSD in its right most nibble.
;
;       The 16 bit binary number is output in registers Hbyte & Lbyte
; ( high byte & low byte repectively ).
;
;       The method used for conversion is :
;               input number X = abcde ( the 5 digit BCD number )
;       X = (R0,R1,R2) = abcde = 10[10[10[10a+b]+c]+d]+e
;
;   Performance :
;               Program Memory  :  30
;               Clock Cycles    :  112
;
;*******************************************************************;
;
mpy10b
	andlw    0x0f
	addwf     Lbyte
	btfsc      _carry
	incf     Hbyte
mpy10a
	bcf      _carry          ; multiply by 2
	rlcf     Lbyte,w
	movwf     Ltemp
	rlcf     Hbyte,w         ; (Htemp,Ltemp) = 2*N
	movwf     Htemp
;
	bcf      _carry          ; multiply by 2
	rlcf     Lbyte
	rlcf     Hbyte
	bcf      _carry          ; multiply by 2
	rlcf     Lbyte
	rlcf     Hbyte
	bcf      _carry          ; multiply by 2
	rlcf     Lbyte
	rlcf     Hbyte     ; (Hbyte,Lbyte) = 8*N
;
	movfp    Ltemp,wreg
	addwf     Lbyte
	movfp    Htemp,wreg
	addwfc    Hbyte
	return                     ; (Hbyte,Lbyte) = 10*N
;
;
BCDtoB
	clrf     Hbyte
	movfp    R0,wreg
	andlw    0x0f
	movwf     Lbyte
	call    mpy10a          ; result = 10a+b
;
	swapf    R1,w
	call    mpy10b          ; result = 10[10a+b]
;
	movfp    R1,wreg
	call    mpy10b          ; result = 10[10[10a+b]+c]
;
	swapf    R2,w
	call    mpy10b          ; result = 10[10[10[10a+b]+c]+d]
;
	movfp    R2,wreg
	andlw    0x0f
	addwf     Lbyte
	btfsc      _carry
	incf     Hbyte           ; result = 10[10[10[10a+b]+c]+d]+e
	return                  ; BCD to binary conversion done
;
	PAGE
;*******************************************************************;
;
;                 Unsigned BCD Addition
;
;       This routine performs a 2 Digit Unsigned BCD Addition
; It is assumed that the two BCD numbers to be added are in
; locations Num1 & Num2. The result is the sum of Num1+Num2
; and is stored in location Num2 and the overflow carry is returned
; in location Num1
;
;   Performance :
;               Program Memory  :       5
;               Clock Cycles    :       5
;
;*******************************************************************;
;
BCDAdd
	movfp    Num1,wreg
	addwf     Num2,w          ; perform binary addition
	daw     Num2      ; adjust for BCD addition
	clrf     Num1
	rlcf     Num1      ; set Num1 = carry bit
	return
;
;*******************************************************************
;
	END



