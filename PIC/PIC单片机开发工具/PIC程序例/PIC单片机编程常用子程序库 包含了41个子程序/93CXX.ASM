; THIS ROUTE IS USED FOR 93C46 (Configue as
; 16 bits organizatio) READ & WRITE ROUTE

RA	EQU	5
RB	EQU	6

BIT-COUNT EQU


DATA_HI EQU	10H	; HI half of words
DATA_LO EQU	11H	; LO half of words
ROM_AD	EQU	12H	; the address of 93c46

TEMR	EQU	13H	;
BIT_COUNT EQU	14H
;
CM_EWEN EQU	30H
CM_EWDS EQU	0H
;RA
CS	EQU	0
SK	EQU	1
DI	EQU	2


;---------------
;used transmiting the first bits in commands
START_BITS
	BCF	RA,SK
	NOP
	BSF	RA,CS
	NOP
	BSF	RA,DI
	NOP
	BSF	RA,SK
	NOP
	BCF	RA,SK
	RETLW	0
;------------------
;the route of transmitting a byte
TRMIT			;
	MOVLW	8
	MOVWF	BIT_COUNT
TRM0
	BCF	3,0
	BCF	RA,SK
	RLF	TEMR
	BTFSS	3,0
	GOTO	^+3
	BSF	RA,DI
	GOTO	^+2
	BCF	RA,DI
	NOP
	BSF	RA,SK
	DECFSZ	BIT_COUNT
	GOTO	TRM0
	RETLW	0H
;---------------------
;the route of receiving a byte
RECEIVE
	MOVLW	8H
	MOVWF	BIT_COUNT
	CLRF	TEMR
RV0
	BSF	RA,SK
	NOP
	NOP
	BSF	3,0
	BCF	RA,SK
	NOP
	BTFSS	RA,DO
	BCF	3,0
	RLF	TEMR
	DECFSZ	BIT_COUNT
	GOTO	RV0
	RETLW	0H
;=============================
; read a word data.
; the data in ROM_AD is the address of
; the word, which come from main route
RD_ROM
	MOVLW	080H
	IORWF	ROM_AD
	MOVFW	ROM_AD
	MOVWF	TEMR

	CALL	START_BITS
	CALL	TRMIT
RC_DA
	NOP
	BCF	RA,SK
	NOP
	BTFSC	RA,DO
	RETLW	0FFH
	CALL	RECEIVE
	MOVFW	TEMR
	MOVWF	DATA_HI

	CALL	RECEIVE
	MOVFW	TEMR
	MOVWF	DATA_LO
	BCF	RA,CS
	RETLW	0
;=============================
; write a word data.
; the data in ROM_AD is the address of
; the word, which come from main route
WRT
	MOVLW	40H
	IORWF	ROM_AD
	MOVFW	ROM_AD
	MOVWF	TEMR

	CALL	START_BITS
	CALL	TRMIT

	MOVFW	DATA_HI
	MOVWF	TEMR
	CALL	TRMIT
	MOVFW	DATA_LO
	MOVWF	TEMR
	BCF	RA,CS
	RETLW	0H

;-----------------------------
EWEN
	MOVLW	CM_EWEN
	GOTO	EWDS+1
EWDS
	MOVLW	CM_EWDS
	MOVWF	ROM_AD
	MOVFW	ROM_AD
	MOVWF	TEMR

	CALL	START_BITS
	CALL	TRMIT
	BCF	RA,CS
	RETLW	0H

