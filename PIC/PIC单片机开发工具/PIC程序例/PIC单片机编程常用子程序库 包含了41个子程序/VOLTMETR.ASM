        TITLE  'VOLTMETER/AD CONVERTER PROGRAM REV 3-29-90'
        LIST   P=16C54,F=inhx16

ACCA     EQU     8
ACCB     EQU     0A
ACCC     EQU     0C
ACCD     EQU     0E
ACCE     EQU     10
TMEAS    EQU     12
TEMP     EQU     14

VCALMS   EQU     60              ;VCAL MSB VALUE IN HEX
VCALLS   EQU     0A4             ;VCAL LSB VALUE IN HEX

         ORG 1FF
         GOTO    VOLTS           ;PROGRAM CODE
         ORG     0               ;SUBROUTINES

MADD     MOVF    ACCA+1,W
         ADDWF   ACCB+1          ;ADD LSB
         BTFSC   3,0             ;ADD IN CARRY
         INCF    ACCB
         MOVF    ACCA,W
         ADDWF   ACCB            ;ADD MSB
         RETLW   0
         NOP

MPY      CALL    SETUP           ;RESULTS IN B(16 MSB'S) AND C(16 LSB'S)
MLOOP    RRF     ACCD            ;ROTATE D RIGHT
         RRF     ACCD+1
         SKPNC                   ;NEED TO ADD?
         CALL    MADD
         RRF     ACCB
         RRF     ACCB+1
         RRF     ACCC
         RRF     ACCC+1
         DECFSZ  TEMP            ;LOOP UNTIL ALL BITS CHECKED
         GOTO    MLOOP
         RETLW   0

         NOP
SETUP    MOVLW   10
         MOVWF   TEMP
         MOVF    ACCB,W          ;MOVE B TO D
         MOVWF   ACCD
         MOVF    ACCB+1,W
         MOVWF   ACCD+1
         MOVF    ACCC,W
         MOVWF   ACCE
         MOVF    ACCC+1,W
         MOVWF   ACCE+1
         CLRF    ACCB
         CLRF    ACCB+1
         RETLW   0

         NOP
DIV      CALL    SETUP
         MOVLW   20
         MOVWF   TEMP
         CLRF    ACCC
         CLRF    ACCC+1
DLOOP    CLRC
         RLF     ACCE+1
         RLF     ACCE
         RLF     ACCD+1
         RLF     ACCD
         RLF     ACCC+1
         RLF     ACCC
         MOVF    ACCA,W
         SUBWF   ACCC,W          ;CHECK IF A>C
         SKPZ
         GOTO    NOCHK
         MOVF    ACCA+1,W
         SUBWF   ACCC+1,W        ;IF MSB EQUAL THEN CHECK LSB
NOCHK    SKPC                    ;CARRY SET IF C>A
         GOTO    NOGO
         MOVF    ACCA+1,W        ;C-A INTO C
         SUBWF   ACCC+1
         BTFSS   3,0
         DECF    ACCC
         MOVF    ACCA,W
         SUBWF   ACCC
         SETC                    ;SHIFT A 1 INTO B (RESULT)
NOGO     RLF     ACCB+1
         RLF     ACCB
         DECFSZ  TEMP            ;LOOP UNTILL ALL BITS CHECKED
         GOTO    DLOOP
         RETLW   0

DSCHRG   MOVLW   B'00001110'     ;DISCHARGE C (RA0 ON)
         TRIS    5
         MOVLW   0FF
         MOVWF   TEMP
LOOP     DECFSZ  TEMP            ;WAIT
         GOTO    LOOP
         MOVLW   B'00001111'     ;ALL RA HIGH Z
         TRIS    5
         RETLW   0

M_TIME   CLRF    1               ;CLEAR RTCC REGISTER
         CLRF    ACCA+1          ;CLEAR 16 BIT COUNTER
         CLRF    ACCA
TLOOP    INCFSZ  ACCA+1
         GOTO    ENDCHK
         INCFSZ  ACCA
         GOTO    ENDCHK
         GOTO    END_M
ENDCHK   BTFSS   1,0             ;CHECK FOR RTCC TRIP
         GOTO    TLOOP
END_M    MOVF    1,W
         RETLW   0

VOLTS    MOVLW   B'00000110'     ;SET S2 AND S3 HIGH(ON WHEN ACTIVATED)
         MOVWF   6
         MOVLW   B'11110000'     ;ACTIVATE SWITCHES S1-S4
         TRIS    6
         MOVLW   B'00101000'     ;SELECT POSITIVE EDGE FOR RTCC
         OPTION
         MOVLW   B'00000000'
         MOVWF   5               ;SET RA0 LOW (ON WHEN ACTIVATED)

MEAS     CALL    DSCHRG          ;CHARGE CAPACITOR TO VIN
         MOVLW   B'00001010'     ;S2 AND S4 ON
         MOVWF   6
         CALL    M_TIME          ;MEASURE TIME
         MOVF    ACCA+1,W
         MOVWF   TMEAS+1         ;STORE LSB
         MOVF    ACCA,W
         MOVWF   TMEAS           ;STORE MSB

CAL      MOVLW   B'00000101'     ;S1 AND S3 ON
         MOVWF   6
         CALL    DSCHRG          ;CHARGE CAPACITOR TO VREF
         MOVLW   B'00001001'     ;S1 AND S4 ON
         MOVWF   6
         CALL    M_TIME          ;MEASURE TIME

         MOVLW   VCALLS
         MOVWF   ACCB+1
         MOVLW   VCALMS
         MOVWF   ACCB

         CALL    MPY             ;MULTIPLY ACCA(TCAL) * ACCB(VREF)
         MOVF    TMEAS+1,W
         MOVWF   ACCA+1
         MOVF    TMEAS,W
         MOVWF   ACCA

         CALL    DIV             ;DIVIDE ACCB(TCAL * V) BY ACCA(TMEAS)

         GOTO VOLTS

         END
