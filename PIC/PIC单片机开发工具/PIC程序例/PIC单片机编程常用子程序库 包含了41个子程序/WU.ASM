                TITLE        "Key Stroke Wake Up"
LIST  P = 16C54
;******************************************************
;       Program demonstrating key stroke wake up for
;       the PIC16CXX. Program has been implemented for
;       two keys, but can be extended for more keys.
;       When SW1 is pressed a green LED lights up.
;       When SW2 is pressed a red LED lights up.
;******************************************************
;
; Define equates
;
        PC       EQU    2
        PORT_B   EQU    6
        SCAN1    EQU    2
        SCAN2    EQU    3
        SW1      EQU    0
        SW2      EQU    1
        GRN_LED  EQU    4
        RED_LED  EQU    5
        MSEC_20  EQU    D'20'
        DB1      EQU    8
        GP       EQU    8
        DB2      EQU    9
;
;PORT_B ASSIGNMENTS:
;       0 --> SW1       INPUT
;       1 --> SW2       INPUT
;       2 --> SCAN1     OUTPUT
;       3 --> SCAN2     OUTPUT
;       4 --> GRN_LED   OUTPUT
;       5 --> RED_LED   OUTPUT
;     6&7 --> ASSIGNED AS DUMMY OUTPUTS
PAGE
;
;
        ORG      0
;
START
        CALL    INIT_PORT_B     ;INITIALIZE PORT B
        CALL    DELAY           ;DELAY 20 MSECS
        CALL    SCAN_KEYS       ;GET KEY VALUES
        MOVWF   GP              ;SAVE IN RAM
        BTFSC   GP,SW1          ;SKIP IF SW1 NOT PRESSED
        CALL    TURN_GREEN_ON   ;ELSE DO ROUTINE
        BTFSC   GP,SW2          ;SKIP IF SW2 NOT PRESSED
        CALL    TURN_RED_ON     ;ELSE DO ROUTINE
CHK_FOR_KEY
        CALL    DELAY           ;DELAY FOR 20 MSEC
        CALL    SCAN_KEYS       ;GET KEY HIT
        XORLW   0               ;EXCL. OR WITH 0
        BNZ     CHK_FOR_KEY     ;KEY STILL PRESSED
                                ;THEN LOOP
NO_KEY_PRESSED
        BCF     PORT_B,SCAN1    ;SET SCAN LINES LOW
        BCF     PORT_B,SCAN2    ;       /
        SLEEP                   ;SLEEP
;
PAGE
;
INIT_PORT_B
        MOVLW   B'00000011'     ; config RB0, 1 as i/p's
        TRIS    PORT_B          ;  and RB2-7 as o/p's
        MOVLW   0FFh
        MOVWF   PORT_B          ;DEFAULT VALUES FOR PORT_B
        RETLW   0               ;RETURN WITH NO ERROR
;
;This routine, scans two keys and returns the following:
;       0 if no key is pressed
;       1 if SW1 is pressd
;       2 if SW2 is pressed
;       3 if SW1 and SW2 are pressed
;
SCAN_KEYS
        BCF     PORT_B,SCAN1    ;ENABLE SCAN FOR SW1
        BCF     PORT_B,SCAN2    ;EANBLE SCAN FOR SW2
        MOVLW   B'00000011'     ;LOAD MASK IN W
        ANDWF   PORT_B,0        ;AND WITH PORT
        BSF     PORT_B,SCAN1    ;DISABLE SCAN
        BSF     PORT_B,SCAN2    ;       /
        ADDWF   PC,1            ;GET OFFSET TO TABLE
        RETLW   3               ;SW1 AND SW2 PRESSED
        RETLW   2               ;SW2 PRESSED
        RETLW   1               ;SW1 PRESSED
        RETLW   0               ;NO KEY PRESSED
;
;DELAY, IS A APPROX. WAIT FOR 20.4mSECS, FOR A SYSTEM
;USING A 2 Mhz CRYSTAL CLOCK.
DELAY
        MOVLW   MSEC_20
        MOVWF   DB1
DLY1
        CLRF    DB2
        DECFSZ  DB1
        GOTO    DLY2
        RETLW   0
DLY2
        DECFSZ  DB2             ;INNER LOOP = 1.02 MSEC.
        GOTO    DLY2            ;       /
        GOTO    DLY1
;
;
TURN_GREEN_ON
        BCF     PORT_B,GRN_LED
        RETLW   0
;
TURN_RED_ON
        BCF     PORT_B,RED_LED
        RETLW   0
;
        END

