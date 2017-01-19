#define PAGE    EJECT        

	TITLE   "General Purpose Math Routines For PIC17C42 : Ver 1.0"

	LIST    columns=120, WRAP, L=0
;
	include "17c42.h"
;
;*******************************************************************
;       Define RAM Locations necessary For the "ARITH.ASM"
;   RAM locations should be defined before calling the library math
; routines
;*******************************************************************
;
MODE_FAST       equ     TRUE
SIGNED          equ     FALSE
;
;*******************************************************************
;
 #if MODE_FAST

  CBLOCK  0x18
     ACCaLO, ACCaHI, ACCbLO, ACCbHI     ; Ram Locations for Arithmetic
     ACCcLO, ACCcHI, ACCdLO, ACCdHI     ;     Routines
  ENDC

 #else

  CBLOCK  0x20
     ACCaLO, ACCaHI, ACCbLO, ACCbHI
     ACCcLO, ACCcHI, ACCdLO, ACCdHI
  ENDC

 #endif
;

  CBLOCK
     tempLo, tempHi, count, sign
  ENDC

  CBLOCK
	NumLo, NumHi
	iterCnt
  ENDC
;
	CBLOCK                          ; RAM locations for "Diff" routine
		XnLo, XnHi, Xn_1_Lo
		Xn_1_Hi, Xn_2_Lo, Xn_2_Hi
		DiffKLo, DiffKHi                ; DiffK = h = Step Size
		DiffLo, DiffHi
	ENDC
;
	CBLOCK                          ; RAM Locations for "Integrate"
		X0Lo, X0Hi, X1Lo, X1Hi  ; Routine
		X2Lo, X2Hi, X3Lo, X3Hi
		IntgKLo, IntgKHi           ; INTEGRATE CONST = 3*h/8
		IntgLo, IntgHi
	ENDC
;
;*******************************************************************
;
mulcnd  equ     ACCaLO
mulplr  equ     ACCaHI
L_byte  equ     ACCbLO
H_byte  equ     ACCbHI
;
_LUPCNT  equ     10             ; Set Desired Number of iterations
SqrtLo  equ     ACCdLO         ; for Square Root Routine(NEWTON Iterations)
SqrtHi  equ     ACCdHI
;
;  Define RAM locations for the Random Number Generators
;
RandLo  equ     ACCaLO
RandHi  equ     ACCaHI   ; 16 bit Pseudo Random Number
GaussHi equ     ACCbHI
GaussLo equ     ACCbLO ; 16 bit Gaussian distributed number
GaussTmp equ    tempLo
;
	PAGE

	ORG     0x0000
;*******************************************************************
;                       Math Routines Test Program
;*******************************************************************
;
;    Load constant values to ACCa & ACCb for testing
;
main
	call    loadAB          ; result of adding ACCb+ACCa->ACCb
	call    D_add           ; Here Accb = 81FE
;
	call    loadAB          ; result of subtracting ACCb - ACCa->ACCb
	call    D_sub           ; Here Accb = 7E00
;
	call    loadAB          ; result of multiplying ACCb*ACCa->(ACCd,ACCc)
	call    D_mpyS          ; Here (ACCd,ACCc) = 00FF 7E01
;
	call    loadAB          ; result of multiplying ACCb*ACCa->(ACCd,ACCc)
	call    D_mpyF          ; Here (ACCd,ACCc) = 00FF 7E01
;
	call    loadAB          ; result of multiplying ACCb/ACCa->(ACCd,ACCc)
	call    D_divS          ; Here (ACCd,ACCc) = 0040 003f
;
	call    loadAB          ; result of multiplying ACCb/ACCa->(ACCd,ACCc)
	call    D_divF          ; Here (ACCd,ACCc) = 0040 003f
;
	movlw    0xf3
	movwf     NumHi
	movlw    0xf6            ; Set input test number = 62454
	movwf     NumLo           ;  = F3F6h
	call    Sqrt            ; result = 00F9h = 249 (in SqrtLo)
;                               ; exact sqrt(62454) = 249.9
;
	movlw    0xff
	movwf     mulplr          ; multiplier (in mulplr) = 0FF
	movlw    0xff            ; multiplicand(W Reg )   = 0FF
	movwf     mulcnd
	call    mpy8x8_F        ; The result 0FF*0FF = FE01 is in locations
;                               ; H_byte & L_byte
	movlw    0xff
	movwf     mulplr          ; multiplier (in mulplr) = 0FF
	movlw    0xff            ; multiplicand(W Reg )   = 0FF
	movwf     mulcnd
	call    mpy8x8_S        ; The result 0FF*0FF = FE01 is in locations
;                               ; H_byte & L_byte
; Test The Random Number Generators
; Capture data into trace buffer by TABLE WRITES to a
; dummy Program Memory location
;
	movlw    0xff
	movwf    tblptrl
	movlw    0x5f
	movwf    tblptrh
;
	movlw    0x30
	movwf     RandHi
	movlw    0x45
	movwf     RandLo
;
	goto    GaussPoint
;
RandPoint
	call    Random16
	tlwt      _LOW,RandLo           ; only for data capture
	tablwt     _HIGH,0,RandHi       ; using PICMASTER
	goto    RandPoint
;
GaussPoint
	call    Gauss
	tlwt      _LOW,GaussLo          ; only for data capture
	tablwt     _HIGH,0,GaussHi      ; using PICMASTER
	goto    GaussPoint
;
self    goto    self            ; End Of Test Routines
;
loadAB
	movlw    0x01
	movwf     ACCaHI
	movlw    0xff             ; loads ACCa = 01FF
	movwf     ACCaLO
;
	movlw    0x7f
	movwf     ACCbHI
	movlw    0xFF             ; loads ACCb = 7FFF
	movwf     ACCbLO
	return
;
	PAGE
;*******************************************************************
;                 Double Precision Arithmetic Routines
;
;    Routines : Addition, Subtraction, Multiplication ,Division
;               Square Root
;
;               NOTE :  MODE_FAST must first be set to either
;                       TRUE or FALSE
;
;  MODE_FAST determines the RAM address locations of ACCa thru ACCd
;
;  If MODE_FAST is set TRUE, data transfers can be done efficiently
;  using "MOVFP" & "MOVPF" instructions instead of indirectly moving
;  at first to W Reg and then to the desired RAM locations
;
;               The speed increase using this way of locating ACCa to
;         ACCd will result in a saving of about 20 Cycles/filter stage
;         In this case ( a 2 stage filter), it is faster by 40 Cycles
;
;  If due to other constraints, ACCa thru ACCd cannot be set at
; address 0x18 to 0x1f, then the user is required to set
; MODE_FAST to FALSE
;
	PAGE
;*******************************************************************
;                 Double Precision Addition
;
;   Addition :  ACCb(16 bits) + ACCa(16 bits) -> ACCb(16 bits)
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_add
;      (d) The result is in location ACCbLO & ACCbHI ( 16 bits )
;
;   Performance :
;               Program Memory  :  4 (excluding call & return)
;               Clock Cycles    :  4 (excluding call & return)
;               W Register      :  Used
;               Scratch RAM     :  0
;
;*******************************************************************;
;
D_add
	movfp    ACCaLO,wreg
	addwf     ACCbLO           ;addwf lsb
	movfp    ACCaHI,wreg
	addwfc    ACCbHI           ;addwf msb with carry
	return
;
	PAGE
;*******************************************************************
;                 Double Precision Subtraction
;
;   Subtraction : ACCb(16 bits) - ACCa(16 bits) -> ACCb(16 bits)
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_sub
;      (d) The result is in location ACCbLO & ACCbHI ( 16 bits )
;
;   Performance :
;               Program Memory  :   4  (excluding call & return )
;               Clock Cycles    :   4  (excluding call & return )
;               W Register      :   Used
;               scratch RAM     :   0
;*******************************************************************;
;
D_sub
	movfp    ACCaLO,wreg
	subwf     ACCbLO
	movfp    ACCaHI,wreg
	subwfb    ACCbHI
	return
;
	PAGE
;*******************************************************************
;               Function to negate a 16 bit integer
;  The two 8 bit integers are assumed to be in 2 consecutive
; locations. Before calling this routine, FSR0 should be loaded with
; the address of the lower byte.
;       Assume that ALUSTA register is set for no autoincrement of
; FSR0.
;*******************************************************************
;
negateAlt
	movfp    indf0,wreg
	bcf      _fs1
	negw     indf0
	bsf      _fs1
	movfp    indf0,wreg
	clrf     indf0
	subwfb    indf0
	return
;
negate
	comf    indf0
	bcf      _fs1
	incf     indf0
	bsf      _fs1
	btfsc      _z
	decf     indf0
	comf    indf0
	return
;
	PAGE
;*******************************************************************
;                       Double Precision Multiplication
;
;               ( Optimized for Code : Looped Code )
;
;   Multiplication : ACCb(16 bits) * ACCa(16 bits) -> ACCd,ACCc ( 32 bits )
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_mpyS
;      (d) The 32 bit result is in location ( ACCdHI,ACCdLO,ACCdHI,ACCdLO )
;
;   Performance :
;            Program Memory  :   21 (UNSIGNED)
;                                52 (SIGNED)
;            Clock Cycles    :   242 (UNSIGNED :excluding CALL & RETURN)
;                            :   254 (SIGNED :excluding CALL & RETURN)
;            Scratch RAM     :   1 (used only if SIGNED arithmetic)
;
;       Note : The above timing is the worst case timing, when the
;               register ACCb = FFFF. The speed may be improved if
;               the register ACCb contains a number ( out of the two
;               numbers ) with less number of 1s.
;
;               Double Precision Multiply ( 16x16 -> 32 )
;         ( ACCb*ACCa -> ACCb,ACCc ) : 32 bit output with high word
;  in ACCd ( ACCdHI,ACCdLO ) and low word in ACCc ( ACCcHI,ACCcLO ).
;********************************************************************
;
D_mpyS                          ;results in ACCd(16 msb's) and ACCc(16 lsb's)
;

     #if   SIGNED
	CALL    S_SIGN
     #endif
;
	clrf     count
	bsf     count,4         ; set count = 16
;
  #if MODE_FAST
	movpf    ACCbLO,tempLo
	movpf    ACCbHI,tempHi
  #else
	movfp    ACCbLO,wreg
	movwf     tempLo
	movfp    ACCbHI,wreg
	movwf     tempHi
  #endif
	clrf     ACCdHI
	clrf     ACCdLO
;
; shift right and addwf 16 times
;
mpyLoop
	rrcf     tempHi
	rrcf     tempLo
	btfss      _carry
	goto    NoAdd                   ; LSB is 0, so no need to addwf
	movfp    ACCaLO,wreg
	addwf     ACCdLO            ;addwf lsb
	movfp    ACCaHI,wreg
	addwfc    ACCdHI            ;addwf msb
NoAdd
	rrcf     ACCdHI
	rrcf     ACCdLO
	rrcf     ACCcHI
	rrcf     ACCcLO
	decfsz     count
	goto    mpyLoop
;
    #if SIGNED
	btfss      sign,MSB
	return
	comf    ACCcLO
	incf     ACCcLO
	btfsc      _z
	decf     ACCcHI
	comf    ACCcHI
	btfsc      _z
	decf     ACCdLO
	comf    ACCdLO
	btfsc      _z
	decf     ACCdHI
	comf    ACCdHI
	return
    #else
	return
    #endif
;
;  Assemble this section only if Signed Arithmetic Needed
;
     #if    SIGNED
;
S_SIGN
	movfp    ACCaHI,wreg
	xorwf     ACCbHI,w
	movwf     sign              ; MSB of sign determines whether signed
	btfss      ACCbHI,MSB        ; if MSB set go & negate ACCb
	goto    chek_A
	comf    ACCbLO
	incf     ACCbLO
	btfsc      _z                ; negate ACCb
	decf     ACCbHI
	comf    ACCbHI
;
chek_A
	btfss      ACCaHI,MSB        ; if MSB set go & negate ACCa
	return
	comf    ACCaLO
	incf     ACCaLO
	btfsc      _z                ; negate ACCa
	decf     ACCaHI
	comf    ACCaHI
	return
;
     #endif
;
	PAGE
;*******************************************************************
;                       Double Precision Multiplication
;
;               ( Optimized for Speed : straight Line Code )
;
;   Multiplication : ACCb(16 bits) * ACCa(16 bits) -> ACCd,ACCc ( 32 bits )
;      (a) Load the 1st operand in location ACCaLO & ACCaHI ( 16 bits )
;      (b) Load the 2nd operand in location ACCbLO & ACCbHI ( 16 bits )
;      (c) CALL D_mpy
;      (d) The 32 bit result is in location ( ACCdHI,ACCdLO,ACCdHI,ACCdLO )
;
;   Performance :
;            Program Memory  :   179 (UNSIGNED)
;                                204 (SIGNED)
;            Clock Cycles    :   176 (UNSIGNED :excluding CALL & RETURN)
;                            :   183 (SIGNED :excluding CALL & RETURN)
;
;       Note : The above timing is the worst case timing, when the
;               register ACCb = FFFF. The speed may be improved if
;               the register ACCb contains a number ( out of the two
;               numbers ) with less number of 1s.
;
;               The performance specs are for Unsigned arithmetic ( i.e,
;               with "SIGNED equ  FALSE ").
;
;               Upon return from subroutine, the input registers
;
;
;**********************************************************
;               Multiplication Macro
;**********************************************************
;
mulMac  MACRO
	variable i

	i = 0

	#if SIGNED
	  .while i < 15
	#else
	  .while i < 16
	#endif
	     .if i < 8
		btfss      ACCbLO,i        ; test low byte
	     .else
		btfss      ACCbHI,i-8      ; test high byte
	     .fi
		goto    NoAdd#v(i)      ; LSB is 0, so no need to addwf
		movfp    ACCaLO,wreg
		addwf     ACCdLO           ;addwf lsb
		movfp    ACCaHI,wreg
		addwfc    ACCdHI           ;addwf msb
NoAdd#v(i)
		rrcf     ACCdHI
		rrcf     ACCdLO
		rrcf     ACCcHI
		rrcf     ACCcLO
		bcf      _carry
		i = i+1
	  .endw
	#if SIGNED
		rrcf     ACCdHI
		rrcf     ACCdLO
		rrcf     ACCcHI
		rrcf     ACCcLO
		bcf     _carry
	#endif
;
	ENDM
;
	PAGE
;***************************************************************
;                       Double Precision Negate Macros
;***************************************************************
AltNegMac       MACRO   fileRegLo,fileRegHi
			movfp    fileRegLo,wreg
			negw     fileRegLo
			movfp    fileRegHi,wreg
			clrf     fileRegHi
			subwfb    fileRegHi
		ENDM

;
negMac  MACRO   fileRegLo, fileRegHi
	comf    fileRegLo       ; negate FileReg ( -FileReg -> FileReg )
	incf     fileRegLo
	btfsc      _z
	decf     fileRegHi
	comf    fileRegHi
	ENDM
;
NegMac32        MACRO   x3,x2,x1,x0
	movfp   x3,wreg
	negw    x3
	movfp   x2,wreg
	clrf    x2
	subwfb  x2
	movfp   x1,wreg
	clrf    x1
	subwfb  x1
	movfp   x0,wreg
	clrf    x0
	subwfb  x0
		ENDM
;
	PAGE
;*******************************************************************;
;               Double Precision Multiply ( 16x16 -> 32 )
;         ( ACCb*ACCa -> ACCb,ACCc ) : 32 bit output with high word
;  in ACCd ( ACCdHI,ACCdLO ) and low word in ACCc ( ACCcHI,ACCcLO ).
;
D_mpyF                          ;results in ACCd(16 msb's) and ACCc(16 lsb's)
;
     #if   SIGNED
;
	movfp    ACCaHI,wreg
	xorwf     ACCbHI,w
	movwf     sign
	btfss      ACCbHI,MSB        ; if MSB set go & negate ACCb
	goto    chek_A_MSB_MPY
;
	negMac  ACCbLO,ACCbHI
;
chek_A_MSB_MPY
	btfss      ACCaHI,MSB        ; if MSB set go & negate ACCa
	goto    continue_MPY
	negMac  ACCaLO,ACCaHI
;
     #endif
;
continue_MPY
	clrf    ACCdHI
	clrf    ACCdLO
	bcf     _carry

;
; use the mulMac macro 16 times
;
	mulMac
;
    #if SIGNED
	btfss   sign,MSB        ; negate (ACCc,ACCd)
	return
	NegMac32 ACCcHI,ACCcLO,ACCdHI, ACCdLO
	return
    #else
	return
    #endif
;
	PAGE
;*******************************************************************
;                       Double Precision Division
;
;               ( Optimized for Code : Looped Code )
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
;            Program Memory  :   31 (UNSIGNED)
;                                39 (SIGNED)
;               Clock Cycles    : 300 (UNSIGNED : excluding CALL & RETURN)
;                               : 312 (SIGNED : excluding CALL & RETURN)
;
;       NOTE :
;               The performance specs are for Unsigned arithmetic ( i.e,
;               with "SIGNED equ  FALSE ").
;
;*******************************************************************
;       Double Precision Divide ( 16/16 -> 16 )
;
;         ( ACCb/ACCa -> ACCb with remainder in ACCc ) : 16 bit output
; with Quotiont in ACCb (ACCbHI,ACCbLO) and Remainder in ACCc (ACCcHI,ACCcLO).
;
;               B/A = (Q) + (R)/A
;       or      B = A*Q + R
;
;                       where   B :     Numerator
;                               A :     Denominator
;                               Q :     Quotiont (Integer Result)
;                               R :     Remainder
;
;       Note :  Check for ZERO Denominator or Numerator is not performed
;               A ZERO Denominator will produce incorrect results
;
;       SIGNED Arithmetic :
;                       In case of signed arithmetic, if either
;  numerator or denominator is negative, then both Q & R are
;  represented as negative numbers
;               -(B/A) = -(Q) + (-R)/A
;       or      -B = (-Q)*A + (-R)
;
;*******************************************************************
;
D_divS
;
	bsf      _fs0
	bsf      _fs1            ; set no auto-incrment for fsr0

     #if    SIGNED
	CALL    S_SIGN
     #endif
;
	clrf     count
	bsf      count,4         ; set count = 16
	clrf     ACCcHI
	clrf     ACCcLO
	clrf     ACCdLO
	clrf     ACCdHI
;
;  Looped code
;
divLoop
	bcf      _carry
	rlcf     ACCbLO
	rlcf     ACCbHI
	rlcf     ACCcLO
	rlcf     ACCcHI
	movfp    ACCaHI,wreg
	subwf     ACCcHI,w          ;check if a>c
	btfss      _z
	goto    notz
	movfp    ACCaLO,wreg
	subwf     ACCcLO,w        ; if msb equal then check lsb
notz
	btfss      _carry    ; carry set if c>a
	goto    nosub           ; if c < a
subca
	movfp    ACCaLO,wreg     ; c-a into c
	subwf     ACCcLO
	movfp    ACCaHI,wreg
	subwfb    ACCcHI
	bsf      _carry              ;shift a 1 into d (result)
nosub
	rlcf     ACCdLO
	rlcf     ACCdHI
	decfsz     count
	goto    divLoop

;
    #if SIGNED
	btfss      sign,MSB
	return
	movlw    ACCcLO
	movwf     fsr0
	call    negate
	movlw    ACCdLO
	movwf     fsr0
	call    negate
	return
    #else
	return
    #endif
;
	PAGE
;*******************************************************************
;                       Double Precision Division
;
;               ( Optimized for Speed : straight Line Code )
;
;*******************************************************************;
;   Division : ACCb(16 bits) / ACCa(16 bits) -> ACCb(16 bits) with
;                                               Remainder in ACCc (16 bits)
;
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;      (c) CALL D_div
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;
;               B/A = (Q) + (R)/A
;       or      B = A*Q + R
;
;                       where   B :     Numerator
;                               A :     Denominator
;                               Q :     Quotiont (Integer Result)
;                               R :     Remainder
;
;       Note :  Check for ZERO Denominator or Numerator is not performed
;               A ZERO Denominator will produce incorrect results
;
;       SIGNED Arithmetic :
;                       In case of signed arithmetic, if either
;  numerator or denominator is negative, then both Q & R are
;  represented as negative numbers
;               -(B/A) = -(Q) + (-R)/A
;       or      -B = (-Q)*A + (-R)
;
;   Performance :
;            Program Memory  :   325 (UNSIGNED)
;                                354 (SIGNED)
;               Clock Cycles    : 250 (UNSIGNED : excluding CALL & RETURN)
;                               : 260 (SIGNED : excluding CALL & RETURN)
;
;*******************************************************************;
;       division macro
;
divMac  MACRO
	variable i

       i = 0
      .while i < 16
;
		bcf      _carry
		rlcf     ACCbLO
		rlcf     ACCbHI
		rlcf     ACCcLO
		rlcf     ACCcHI
		movfp    ACCaHI,wreg
		subwf     ACCcHI,w          ;check if a>c
		btfss      _z
		goto    notz#v(i)
		movfp    ACCaLO,wreg
		subwf     ACCcLO,w        ;if msb equal then check lsb
notz#v(i)       btfss     _carry    ;carry set if c>a
		goto    nosub#v(i)           ; if c < a
subca#v(i)      movfp    ACCaLO,wreg        ;c-a into c
		subwf     ACCcLO
		movfp    ACCaHI,wreg
		subwfb    ACCcHI
		bsf      _carry            ;shift a 1 into d (result)
nosub#v(i)      rlcf     ACCdLO
		rlcf     ACCdHI
       i=i+1
      .endw
;
	ENDM
;
	PAGE
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
;*******************************************************************
;
D_divF
;
     #if   SIGNED
	movfp    ACCaHI,wreg
	xorwf     ACCbHI,w
	movwf     sign
	btfss      ACCbHI,MSB        ; if MSB set go & negate ACCb
	goto    chek_A_MSB_DIV
;
	negMac  ACCbLO,ACCbHI
;
chek_A_MSB_DIV
	btfss   ACCaHI,MSB        ; if MSB set go & negate ACCa
	goto    continue_DIV
	negMac  ACCaLO,ACCaHI

     #endif
;
continue_DIV
	clrf     ACCcHI
	clrf     ACCcLO
	clrf     ACCdLO
	clrf     ACCdHI

;
; straight line code : using the macro divMac
;
	divMac
;
    #if SIGNED
	btfss   sign,MSB        ; negate (ACCc,ACCd)
	return
	negMac  ACCcLO,ACCcHI
	negMac  ACCdLO,ACCdHI
	return
    #else
	return
    #endif
;
	PAGE
;*******************************************************************
;
;            Square Root By Newton Raphson Method
;
;    This routine computes the square root of a 16 bit number(with
;  low byte in NumLo & high byte in NumHi ). After loading NumLo &
;  NumHi with the desired number whose square root is to be computed,
;  branch to location Sqrt ( by "GOTO  Sqrt" ). " CALL  Sqrt" cannot
;  be issued because the Sqrt function makes calls to Math routines
;  and the stack is completely used up.
;       The result = sqrt(NumHi,NumLo) is returned in location SqrtLo.
;  The total number of iterations is set to ten. If more iterations
;  are desired, change "LupCnt equ .10" to the desired value. Also,
;  the initial guess value of the square root is given set as
;  input/2 ( in subroutine "init" ). The user may modify this scheme
;  if a better initial approximation value is known. A good initial
;  guess will help the algorithm converge at a faster rate and thus
;  less number of iterations required.
;       Two utility math routines are used by this program : D_divS
;  and D_add. These two routines are listed as seperate routines
;  under double precision Division and double precision addition
;  respectively.
;
;  Note : If square root of an 8 bit number is desired, it is probably
;         better to have a table look scheme rather than using numerical
;         methods.
;               This method is computationally quite intensive and
;         slow, but very accurate and the convergence rate is high
;
;   Performance :
;               Program Memory  :   22 (excluding D_divS subroutine)
;               Clock Cycles    :   3000 (approximately,with 10 iterations)
;
;       The #of cycles depends on Number of Iterations Selected.
; In a lot of cases 5 or less iterations may be sufficient
;
;
;*******************************************************************
;               Newton-Raphson Method
;*************************************************************

Sqrt
	call    SqrtInit            ; compute initial sqrt = Num/2
nextIter
   #if MODE_FAST
	movfp    NumLo,ACCbLO
	movfp    NumHi,ACCbHI
   #else
	movfp    NumLo,wreg
	movwf     ACCbLO
	movfp    NumHi,wreg
	movwf     ACCbHI
   #endif
;
	call    D_divS          ; double precision division
				; double precision addition
	movfp    ACCdLO,wreg     ; ACCd + ACCa -> ACCd
	addwf     ACCaLO           ;addwf lsb
	movfp    ACCdHI,wreg
	addwfc    ACCaHI           ;addwf msb
				; now divide by 2
	bcf      _carry
	rrcf     ACCaHI
	rrcf     ACCaLO
;
	decfsz     iterCnt
	goto    nextIter
	return                     ; End Sqrt
;
SqrtInit
	movlw    _LUPCNT
	movwf     iterCnt         ; set number of iterations
  #if MODE_FAST
	movfp    NumHi,ACCaHI
	movfp    NumLo,ACCaLO
  #else
	movfp    NumHi,wreg
	movwf     ACCaHI
	movfp    NumLo,wreg         ; set initial guess root = NUM/2
	movwf     ACCaLO
  #endif
	bcf      _carry
	rrcf     ACCaHI
	rrcf     ACCaLO      ; set initial sqrt = Num/2
	return
;
	PAGE
;*******************************************************************
;                   8x8 Software Multiplier
;               ( Fast Version : Straight Line Code )
;
;   The 16 bit result is stored in 2 bytes
;
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;
;       Performance :
;                    Program Memory  :  36 words
;                    # of cycles     :  36       (excluding call & return)
;                    Scratch RAM     :   0 locations
;                    W Register      :  Used
;
;  This routine is optimized for speed efficiency ( straight line code )
;  For code efficiency, refer to "mult8x8S.asm" ( looped code )
;*******************************************************************
;     Define a macro for adding & right shifting
;
multiply    MACRO
	variable  i ;
	  i = 0
	  .while i < 8
		btfsc     mulplr,i
		addwf    H_byte
		rrcf    H_byte
		rrcf    L_byte
	    i = i+1 ;
	  .endw
	ENDM                    ; End of macro
;
;
mpy8x8_F
	clrf     H_byte
	clrf     L_byte
	movfp    mulcnd,wreg     ; move the multiplicand to W reg.
	bcf      _carry          ; Clear the carry bit in the status Reg.
;
	multiply
;
	return
;
	PAGE
;*******************************************************************
;                   8x8 Software Multiplier
;               ( Code Efficient : Looped Code )
;
;   The 16 bit result is stored in 2 bytes
;
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;
;       Performance :
;                    Program Memory  :  13 words (excluding call & return)
;                    # of cycles     :  69       (excluding call & return)
;                    Scratch RAM     :  1 byte
;                    W Register      :  Used
;
;  This routine is optimized for code efficiency ( looped code )
;  For time efficiency code refer to "mult8x8F.asm" ( straight line code )
;*******************************************************************
;
mpy8x8_S
	clrf     H_byte
	clrf     L_byte
	clrf     count
	bsf      count,3         ; set count = 8
	movfp    mulcnd,wreg
	bcf     _carry    ; Clear the carry bit in the status Reg.
loop
	btfsc      mulplr,0
	addwf     H_byte
	rrcf     H_byte
	rrcf     L_byte
	rrncf      mulplr
	decfsz     count
	goto    loop
;
	return
;
	PAGE
;*******************************************************************
;                       Numerical Differenciation
;
;       The so called "Three-Point Formula" is implemented to
; differenciate a sequence of points (uniformly sampled).
;       The eqn implemented is :
;             f'(Xn) = [ f(Xn - 2h) - 4*f(Xn - h) + 3*f(Xn)]*0.5/h
;    where Xn is the present sample and 'h' is the step size.
;
;       The above formula may be rewritten as :
;
;         f'(Xn) = [ 0.5*f(Xn -2) - 2*f(Xn - 1) + 0.5*3*f(Xn)]*1/DiffK
;  where DiffK = h = Step Size
;
;   This differenciation routine can be used very effectively
; in the computation of the differential component part in
; a PID Loop calculation in Motor Control Applications
;
;       Double precision arithmetic is used throught
;  The present sample value is assumed to be in locations
; (XnHi, XnLo). The past two values are assumed to be in locations
; (Xn_1_Hi, Xn_1_Lo) & (Xn_2_Hi, Xn_2_Lo).
;       The output value is located in DiffHi & DiffLo. No overflow
; checking mechanism is implemented. If the values are limited
; to 12 bits, then the user need not worry about overflows
;
;  It is user's responsibility to update the past values with the
; present values before calling this routine.
;  After computation, the present value Xn is not moved to Xn_1
; because the user may want these values to be intact for other
; computations ( say numerical integration)
;       Also it is user's responsibility to set past 2 values
; (Xn_1 & Xn_2) values to be zero on initialization.
;
;*******************************************************************
;
Diff
	movfp    Xn_2_Lo,wreg
	addwf     XnLo,w
	movwf     ACCbLO
	movfp    Xn_2_Hi,wreg
	addwfc    XnHi,w
	movwf     ACCbHI          ; Y = f(Xn-2) + f(Xn)
;
	movfp    XnLo,wreg
	addwf     ACCbLO
	movfp    XnHi,wreg
	addwfc    ACCbHI
	movfp    XnLo,wreg
	addwf     ACCbLO
	movfp    XnHi,wreg
	addwfc    ACCbHI    ; Y = f(Xn-2) + 3*f(Xn)
;
	bcf      _carry
	rrcf     ACCbHI
	rrcf     ACCbLO    ; Y = 0.5*[ f(Xn-2) + 3*f(Xn) ]

;
	movfp    Xn_1_Lo,wreg
	subwf     ACCbLO
	movfp    Xn_1_Hi,wreg
	subwfb    ACCbHI
	movfp    Xn_1_Lo,wreg
	subwf     ACCbLO
	movfp    Xn_1_Hi,wreg
	subwfb    ACCbHI    ; Y = 0.5*[f(Xn-2) + 3*f(Xn)] - 2*f(Xn-1)
;
	movfp    DiffKLo,wreg
	movwf     ACCaLO
	movfp    DiffKHi,wreg
	movwf     ACCaHI
;
	call    D_divS
	movfp    ACCbLO,wreg
	movwf     DiffLo
	movfp    ACCbHI,wreg
	movwf     DiffHi          ; result = Y/h
;
	return
;
	PAGE
;*******************************************************************
;
;                       Numerical Integration
;
;
;       Simpson's Three-Eighths Rule is implemented
;
;       Y(n) = [ f(X0) + 3*f(X1) + 3*f(X2) + f(X3)]*3*h/8
;
;  where 'h' is the step size and the integral is over the
;  range X0 to X3
;       The above equation can be rewritten as
;
;       Y(n) = [ f(X0) + 3*f(X1) + 3*f(X2) + f(X3)]*IntgK
;
;   where IntgK = 3*h/8 (in locations (IntgKHi, IntgKHi)
;
;   This Integration routine can be used very effectively
; in the computation of the integral component part in
; a PID Loop calculation in Motor Control Applications
;
;       Double precision arithmetic is used throught
;  The three input values over which the integral is to be computed
; are assumed to be in locations (X0Lo,X0Hi), (X1Lo,X1Hi) , (X2Lo,X2Hi)
; and (X3Lo,X3Hi)
;       The output value is located in IntgHi & IntgLo. No overflow
; checking mechanism is implemented. If the values are limited
; to 12 bits, then the user need not worry about overflows
;
;  It is user's responsibility to update the past values with the
; present values before calling this routine.
;  After computation, the present value Xn is not moved to Xn_1
; because the user may want these values to be intact for other
; computations ( say numerical integration)
;       Also it is user's responsibility to set past 2 values
; (Xn_1 & Xn_2) values to be zero on initialization.
;
;
;*******************************************************************
;
Integrate
	movfp    X0Lo,wreg
	addwf     X3Lo,w
	movwf     ACCbLO
	movfp    X0Hi,wreg
	addwfc    X3Hi,w
	movwf     ACCbHI          ; Intg = f(X0) + f(X3)
;
	movfp    X1Lo,wreg
	addwf     ACCbLO
	movfp    X1Hi,wreg
	addwfc    ACCbHI   ; Intg = f(X0) + f(X3) +X1
	movfp    X1Lo,wreg
	addwf     ACCbLO
	movfp    X1Hi,wreg
	addwfc    ACCbHI   ; Intg = f(X0) + f(X3) +2*X1
	movfp    X1Lo,wreg
	addwf     ACCbLO
	movfp    X1Hi,wreg
	addwfc    ACCbHI   ; Intg = f(X0) + f(X3) +3*X1
;
	movfp    X2Lo,wreg
	addwf     ACCbLO
	movfp    X2Hi,wreg
	addwfc    ACCbHI   ; Intg = f(X0) + f(X3) +3*X1 + X2
	movfp    X2Lo,wreg
	addwf     ACCbLO
	movfp    X2Hi,wreg
	addwfc    ACCbHI   ; Intg = f(X0) + f(X3) +3*X1 + 2*X2
	movfp    X2Lo,wreg
	addwf     ACCbLO
	movfp    X2Hi,wreg
	addwfc    ACCbHI   ; Intg = f(X0) + f(X3) +3*X1 + 3*X2
;
	movfp    IntgKLo,wreg
	movwf     ACCaLO
	movfp    IntgKHi,wreg
	movwf     ACCaHI          ;  ACCa = IntgK (prepare for multiplication)
;
	call    D_mpyS          ; make sure to set for either SIGNED or UNSIGNED
	movfp    ACCdLO,wreg
	movwf     IntgLo          ; 32 bit result in ACCd & ACCc
	movfp    ACCdHI,wreg
	movwf     IntgHi          ; upper 16 bits = result
;
	return
;
	PAGE
;*******************************************************************
;
;                       Random Number Generator
;
; This routine generates a 16 Bit Pseudo Sequence Random Generator
; It is based on Linear shift register feedback. The sequence
; is generated by (Q15 xorwf Q14 xorwf Q12 xorwf Q3 )
;
;    The 16 bit random number is in location RandHi(high byte)
;  & RandLo (low byte)
;
;       Before calling this routine, make sure the initial values
; of RandHi & RandLo are NOT ZERO
;       A good chiose of initial random number is 0x3045
;*******************************************************************
;
Random16
	rlcf     RandHi,w
	xorwf     RandHi,w
	rlcf     wreg            ; carry bit = xorwf(Q15,14)
;
	swapf    RandHi
	swapf    RandLo,w
	rlncf      wreg
	xorwf     RandHi,w        ; LSB = xorwf(Q12,Q3)
	swapf    RandHi
	andlw   0x01
	rlcf     RandLo
	xorwf     RandLo
	rlcf     RandHi
	return
;
	PAGE
;*******************************************************************
;                       Gaussian Noise Generator
;
; This routine generates a 16 Bit Gaussian distributed random
; points. This routine calls the routine "Random16", which
; generates a psuedo random noise sequence. Gaussian noise
; is computed using the CENTRAL LIMIT THEOREM.
;       The Central Limit Theorem states that the average weighted
; sum of uncorelated samples tends to have a Gaussian distribution
; For practical purposes, the sum could be over a sample size
; of 32 Random numbers. Better results could result if a larger
; sample size is desired. For faster results, a sum over 16 samples
; would also be adequate ( say, for applications like Speech synthesis,
; channel simulations, etc).
;
;       The 16 bit Gaussian distributed point is in locations
; GaussHi & GaussLo
;
;       Before calling this routine, the initial seed of Random
; number should be NON ZERO ( refer to notes on "Random16" routine
;
;*******************************************************************
;
Gauss
	clrf     count
	bsf      count,5         ; set Sample size = 32
	clrf     GaussLo
	clrf     GaussHi
	clrf     GaussTmp
;
NextGauss
	call    Random16        ; get a random value
	movfp    RandLo,wreg
	addwf     GaussLo
	movfp    RandHi,wreg
	addwfc    GaussHi
	clrf     wreg
	addwfc    GaussTmp
	decfsz     count
	goto    NextGauss       ; sum 16 random numbers
;
	movlw    5
GaussDiv16
	rrcf     GaussTmp
	rrcf     GaussHi
	rrcf     GaussLo           ; weghted average
	decfsz     wreg              ; divide by 32
	goto    GaussDiv16
;
	return
;

	END                       ; End Of arith.asm
