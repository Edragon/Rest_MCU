
I2CCTR	EQU	10H
I2CAD	EQU	11H
REG3	EQU	12H
REG2	EQU	13H
REG1	EQU	14H
REG0	EQU	15H

GENR0	EQU	8H
GENR1	EQU	9H
BIT_COUNT EQU	9H
GENR2	EQU	0AH
BYTE_COUNT EQU	0AH


	movlw	4H
write
	MOVWF	BYTE_COUNT
	MOVLW	B8583W
WR_ABC
	MOVWF	I2CCTR
	MOVFW	GENR0
;
WR_MEM
	MOVWF	I2CAD
WR_MEM0
	MOVLW	IORA
	TRIS	RA
	BSF	RA,SCL
	MOVLW	I2CCTR+$20
	MOVWF	FSR
M_START
	NOP
	BTFSS	RA,SDA
	RETLW	0FFH
;	GOTO	^-1

	MOVLW	E2OUT
	TRIS	RA
	NOP
	BCF	RA,SDA		; to start
NXBY
WR_BYTE
	MOVLW	8H
	MOVWF	BIT_COUNT
BIT_LOOP
	nop
	RLF	0H
	BCF	RA,SCL
	BTFSS	3,0
	GOTO	^+3
	BSF	RA,SDA
	GOTO	^+2
	BCF	RA,SDA
	NOP
	NOP

	BSF	RA,SCL
	DECFSZ	BIT_COUNT
	GOTO	BIT_LOOP
	NOP
	NOP
	BCF	RA,SCL
	NOP
ACKG
	NOP
	MOVLW	IORA
	TRIS	RA
	BSF	RA,SCL
	NOP
	BTFSC	RA,SDA
	GOTO	ACKG

	INCF	FSR
	NOP
	bcf	RA,SCL
	MOVLW	E2OUT
	TRIS	RA
	DECFSZ	BYTE_COUNT
	GOTO	NXBY
;
W_STOP
	MOVLW	I2CAD+$0A2
	SUBWF	FSR,W
	BTFSS	3,0
	RETLW	0H
M_STOP
	BCF	RA,SDA
	NOP
	BSF	RA,SCL
	MOVLW	IORA
	NOP
	NOP
	NOP
	BSF	RA,SDA
	TRIS	RA
	RETLW	0H

;------------------------------
;
ST_CMEMAD
	MOVFW	GENR0
	MOVWF	I2CAD
	MOVLW	C02W
	MOVWF	I2CCTR
	MOVLW	C02R
	MOVWF	REG3
;
ST_MEMAD
	MOVLW	2
	MOVWF	BYTE_COUNT
	CALL	WR_MEM0
	MOVLW	1
	MOVWF	BYTE_COUNT
	MOVFW	REG3
	MOVWF	I2CCTR
	CALL	WR_MEM0
	RETLW	0H
;--------------------------

RD_BYTES
	MOVWF	BYTE_COUNT
	MOVLW	REG3+$20
	MOVWF	FSR
RNXTB
	BCF	RA,SCL
	MOVLW	IORA
	tris	RA
	MOVLW	8H
	MOVWF	BIT_COUNT
RNX
	BCF	RA,SCL
	NOP
	BCF	3H,0
	BTFSC	RA,SDA
	BSF	3H,0
	RLF	0H

	BSF	RA,SCL
	NOP
	DECFSZ	BIT_COUNT
	GOTO	RNX

	INCF	FSR
	MOVLW	E2OUT
	BCF	RA,SCL
	TRIS	RA
	DECFSZ	BYTE_COUNT
	GOTO	T_ACKG
R_STOP
	CALL	M_STOP
	RETLW	0H
;
T_ACKG
	BCF	RA,SDA
	NOP
	BSF	RA,SCL
	XORLW	0FFH
	XORLW	0FFH
	XORLW	0FFH
	GOTO	RNXTB
