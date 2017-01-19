;
;************************************************************************
;               BCD To Binary Conversion
;
;       This routine converts a 5 digit BCD number to a 16 bit binary
; number.
;       The input 5 digit BCD numbers are asumed to be in locations
; R0, R1 & R2 with R0 containing the MSD in its right most nibble.
;
;       The 16 bit binary number is output in registers H_byte & L_byte
; ( high byte & low byte repectively ).
;
;       The method used for conversion is :
;               input number X = abcde ( the 5 digit BCD number )
;               X = abcde = 10[10[10[10a+b]+c]+d]+e
;
;   Performance :
;               Program Memory  :       30
;               Clock Cycles    :       121
;
;*******************************************************************;
;
H_byte  equ     10
L_byte  equ     11
R0      equ     12              ; RAM Assignments
R1      equ     13
R2      equ     14
;
H_temp  equ     15      ; temporary register
L_temp  equ     16      ; temporary register
;
;
	INCLUDE         "picreg.h"
;
;
mpy10b  andlw   0F
	addwf   L_byte
	btfsc   STATUS,CARRY
	incf    H_byte
mpy10a  bcf     STATUS,CARRY    ; multiply by 2
	rlf     L_byte,w
	movwf   L_temp
	rlf     H_byte,w        ; (H_temp,L_temp) = 2*N
	movwf   H_temp
;
	bcf     STATUS,CARRY    ; multiply by 2
	rlf     L_byte
	rlf     H_byte
	bcf     STATUS,CARRY    ; multiply by 2
	rlf     L_byte
	rlf     H_byte
	bcf     STATUS,CARRY    ; multiply by 2
	rlf     L_byte
	rlf     H_byte          ; (H_byte,L_byte) = 8*N
;
	movf    L_temp,w
	addwf   L_byte
	btfsc   STATUS,CARRY
	incf    H_byte
	movf    H_temp,w
	addwf   H_byte
	retlw   0               ; (H_byte,L_byte) = 10*N
;
;
BCDtoB  clrf    H_byte
	movf    R0,w
	andlw   0F
	movwf   L_byte
	call    mpy10a          ; result = 10a+b
;
	swapf   R1,w
	call    mpy10b          ; result = 10[10a+b]
;
	movf    R1,w
	call    mpy10b          ; result = 10[10[10a+b]+c]
;
	swapf   R2,w
	call    mpy10b          ; result = 10[10[10[10a+b]+c]+d]
;
	movf    R2,w
	andlw   0F
	addwf   L_byte
	btfsc   STATUS,CARRY
	incf    H_byte          ; result = 10[10[10[10a+b]+c]+d]+e
	retlw   0               ; BCD to binary conversion done
;
;
;********************************************************************
;               Test Program
;*********************************************************************
main    movlw   06
	movwf   R0      ; Set R0 = 06
	movlw   55
	movwf   R1      ; Set R1 = 55
	movlw   35
	movwf   R2      ; Set R2 = 35      ( R0, R1, R2 = 6,55,35 )
;
	call    BCDtoB  ; After conversion H_Byte = FF & L_Byte = FF
;
self    goto    self
;
	org     1FF
	goto    main
;
	END

