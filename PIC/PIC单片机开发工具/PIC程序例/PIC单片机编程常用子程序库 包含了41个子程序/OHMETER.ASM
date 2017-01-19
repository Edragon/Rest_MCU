        TITLE  'OHMETER/TEMPERATURE SENSING PROGRAM REV 3-29-90'
        LIST   P=16C54,F=inhx16

ACCA   EQU     8
ACCB   EQU     0A
ACCC   EQU     0C
ACCD   EQU     0E
ACCE   EQU     10
TCAL   EQU     12
TEMP   EQU     14

RCALMS EQU     2F              ;RCAL MSB VALUE IN HEX
RCALLS EQU     3C              ;RCAL LSB VALUE IN HEX

       ORG 1FF
       GOTO    OHMS
       ORG     0

MADD   MOVF    ACCA+1,W
       ADDWF   ACCB+1          ;ADD LSB
       BTFSC   3,0             ;ADD IN CARRY
       INCF    ACCB
       MOVF    ACCA,W
       ADDWF   ACCB            ;ADD MSB
       RETLW   0
       NOP

MPY    CALL    SETUP           ;RESULTS IN B(16 MSB'S) AND C(16 LSB'S)
MLOOP  RRF     ACCD            ;ROTATE D RIGHT
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
SETUP  MOVLW   10
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
DIV    CALL    SETUP
       MOVLW   20
       MOVWF   TEMP
       CLRF    ACCC
       CLRF    ACCC+1
DLOOP  CLRC
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
NOCHK  SKPC                    ;CARRY SET IF C>A
       GOTO    NOGO
       MOVF    ACCA+1,W        ;C-A INTO C
       SUBWF   ACCC+1
       BTFSS   3,0
       DECF    ACCC
       MOVF    ACCA,W
       SUBWF   ACCC
       SETC                    ;SHIFT A 1 INTO B (RESULT)
NOGO   RLF     ACCB+1
       RLF     ACCB
       DECFSZ  TEMP            ;LOOP UNTILL ALL BITS CHECKED
       GOTO    DLOOP
       RETLW   0

DSCHRG MOVLW   B'00001011'     ;ACTIVATE RA2
       TRIS    5
       MOVLW   0FF
       MOVWF   TEMP
LOOP   DECFSZ  TEMP            ;WAIT
       GOTO    LOOP
       MOVLW   B'00001111'     ;ALL OUTPUTS OFF
       TRIS    5
       RETLW   0

M_TIME CLRF    1               ;CLEAR RTCC
       CLRF    ACCA+1
       CLRF    ACCA
TLOOP  INCFSZ  ACCA+1
       GOTO    ENDCHK
       INCFSZ  ACCA
       GOTO    ENDCHK
       GOTO    END_M
ENDCHK BTFSS   1,0             ;CHECK FOR RTCC TRIP
       GOTO    TLOOP
END_M  MOVF    1,W
       RETLW   0

OHMS   MOVLW   B'00000011'     ;SET RA0 AND RA1 HIGH (ON WHEN ACTIVATED)
       MOVWF   5
       MOVLW   B'00101000'     ;SELECT POSITIVE EDGE FOR RTCC
       OPTION

CAL    CALL    DSCHRG          ;DISCHARGE CAPACITOR
       MOVLW   B'00001110'     ;ACTIVATE RA0
       TRIS    5
       CALL    M_TIME          ;MEASURE TIME
       MOVF    ACCA+1,W
       MOVWF   TCAL+1          ;STORE LSB
       MOVF    ACCA,W
       MOVWF   TCAL            ;STORE MSB

MEAS   CALL    DSCHRG          ;DISCHARGE CAPACITOR
       MOVLW   B'00001101'     ;ACTIVATE RA1
       TRIS    5
       CALL    M_TIME          ;MEASURE TIME

       MOVLW   RCALLS          ;CALIBRATION LSB VALUE
       MOVWF   ACCB+1
       MOVLW   RCALMS          ;CALIBRATION MSB VALUE
       MOVWF   ACCB

       CALL    MPY             ;MULTIPLY ACCA(MEAS) * ACCB(RCAL)
       MOVF    TCAL+1,W
       MOVWF   ACCA+1
       MOVF    TCAL,W
       MOVWF   ACCA

       CALL    DIV             ;DIVIDE ACCB(MEAS * R) BY ACCA(TCAL)

       GOTO OHMS

       END
