;*******************************************************************
;                   8x8 Software Multiplier
;               ( Fast Version : Straight Line Code )
;*******************************************************************
;
;   The 16 bit result is stored in 2 bytes
;
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;
;       Performance :
;                       Program Memory  :  35 locations
;                       # of cycles     :  37
;                       Scratch RAM     :   0 locations
;
;  This routine is optimized for speed efficiency ( straight line code )
;  For code efficiency, refer to "mult8x8S.asm" ( looped code )
;*******************************************************************
;
mulcnd  equ     09      ; 8 bit multiplicand
mulplr  equ     10      ; 8 bit multiplier
H_byte  equ     12      ; High byte of the 16 bit result
L_byte  equ     13      ; Low byte of the 16 bit result
;
;
	include         "picreg.h"
;
;****   Define a macro for adding & right shifting  **
;
mult    MACRO   bit             ; Begin macro
	btfsc   mulplr,bit
	addwf   H_byte,Same
	rrf     H_byte,Same
	rrf     L_byte,Same
	ENDM                    ; End of macro
;
; *****************************         Begin Multiplier Routine
mpy_F   clrf    H_byte
	clrf    L_byte
	movf    mulcnd,w        ; move the multiplicand to W reg.
	bcf     STATUS,CARRY    ; Clear the carry bit in the status Reg.
	mult    0
	mult    1
	mult    2
	mult    3
	mult    4
	mult    5
	mult    6
	mult    7
;
	retlw   0
;
;********************************************************************
;               Test Program
;*********************************************************************
main    movlw   0FF
	movwf   mulplr          ; multiplier (in mulplr)     = 0FF
	movlw   0FF
	movwf   mulcnd          ; multiplicand(in mulcnd )   = 0FF
;
	call    mpy_F           ; The result 0FF*0FF = FE01 is in locations
;                               ; H_byte & L_byte
;
self    goto    self
;
	org     01FF
	goto    main
;
	END
