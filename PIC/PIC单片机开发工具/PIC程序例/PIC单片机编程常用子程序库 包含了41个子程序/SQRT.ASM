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
;  under double precision Division and double precision addtion
;  respectively.
;
;  Note : If square root of an 8 bit number is desired, it is probably
;         better to have a table look scheme rather than using numerical
;         methods.
;
;
;
;   Performance :
;               Program Memory  :       27  (excluding Math Routines
;                                            D_divS & D_add )
;               Clock Cycles    :       3600 ( approximately )
;
;       To assemble this program, two routines, namely "D_add" &
;       "D_divS" must be included into this program. These two routines
;       are listed as separate programs in files "DBL_ADD.ASM" &
;       "DBL_DIVS.ASM" respectively.
;
;*******************************************************************
	include "picreg.h"
	org     0
;
LupCnt  equ     .10             ; Number of iterations
;
SqrtLo  equ     ACCaLO
SqrtHi  equ     ACCaHI
;
NumLo   equ     1D
NumHi   equ     1E
count   equ     1F
;
;
init
	movlw   LupCnt
	movwf   count
	movf    NumHi,W
	movwf   SqrtHi
	movf    NumLo,W         ; set initial guess root = NUM/2
	movwf   SqrtLo
	bcf     STATUS,CARRY
	rrf     SqrtHi
	rrf     SqrtLo
	retlw   0
;
div2    bcf     STATUS,CARRY
	rrf     ACCbHI,W
	movwf   SqrtHi
	rrf     ACCbLO,W
	movwf   SqrtLo
	retlw   0
;
Sqrt    call    init
sloop   movf    NumLo,W
	movwf   ACCbLO
	movf    NumHi,W
	movwf   ACCbHI
;
	call    D_divS          ; double precision division
	call    D_add           ; double precision addition
;                               ; the above 2 routines are listed
;                               ; as seperate routines
	call    div2
	decfsz  count
	goto    sloop
	goto    over            ; all iterations done
;                               ; branch back to desired location
;
;*************************************************************
;               Test Program
;*************************************************************
;
main    movlw   0F3
	movwf   NumHi
	movlw   0F6       ; Set input test number = 62454
	movwf   NumLo     ;  = F3F6h
;
	goto    Sqrt      ; cannot use CALL : Math routines
;                         ; use up all the stack.
over    nop               ; all iterations done
;
self    goto    self      ; result = 00F9h = 249
;                         ; exact sqrt(62454) = 249.9
;
	org     PIC54
	goto    main
;
	END
