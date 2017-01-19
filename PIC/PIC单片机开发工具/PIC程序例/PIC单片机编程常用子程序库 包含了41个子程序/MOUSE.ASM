 TITLE " MOUSE "
 LIST   P=16C54,R=O
;
;*******************************************
;*                                         *
;*   MOUSE CONTROLLER                      *
;*                                         *
;*   VERSION : 25 APRIL, 1990              *
;*                                         *
;*   PIC MODE = PIC16C54XT   CLK=4.0MHZ    *
;*******************************************
;
;-------------------------------------------
;       FILES ASSIGNMENT
;-------------------------------------------
;
STATUS EQU 3            ;STATUS REGISTER
RA EQU 5                ;I/O PORT A
RB EQU 6                ;I/O PORT B
TIMER1 EQU 10           ;COUNTER FOR DELAY
CSTAT EQU 14            ;CO-ORDINATE STATUS
BSTAT EQU 15            ;BUTTON STATUS
DATA0 EQU 16            ;  
DATA1 EQU 17            ;
DATA2 EQU 20            ;5 BYTE RS232 DATA
DATA3 EQU 21            ;
DATA4 EQU 22            ;
FLAGA EQU 23            ;GENERAL PURPOSE FLAG
XCOUNT EQU 24           ;X-MOVEMENT COUNTER
YCOUNT EQU 25           ;Y-MOVEMENT COUNTER
FLAGB EQU 26            ;GENERAL PURPOSE FLAG
COUNT EQU 30            ;GENERAL PURPOSE COUNTER
DATA_AREA EQU 31             ;FOR TEMP. STORAGE
;
;------------------------------------------
;       BIT ASSIGNMENT
;------------------------------------------
;
YC EQU 0                ;Y-CLOCK PIN
YD EQU 1                ;Y-DATA PIN
UP EQU 1                ;MOVING UP FLAG
XC EQU 2                ;X-CLOCK PIN
XD EQU 3                ;X-DATA PIN
RI EQU 3                ;MOVING RIGHT FLAG
BU1 EQU 0               ;BUTTON #1 PIN
BU2 EQU 2               ;BUTTON #2 PIN
CA EQU 0                ;CARRY FLAG
RD EQU 7                ;RECEIVED DATA PIN TO RS232
ZERO_AREA EQU 2              ;ZERO FLAG
TR EQU 2                ;TIGGER FLAG
;
;===========================================
;       SUBROUTINES
;===========================================
;
;*******************************************
 ORG 0
;*******************************************
;
;===========================================
; DELAY A BIT TIME AND CHECK XC & YC STATUS
;===========================================
BIT
 BTFSS RA,XC            ;XC = 1 ?
 GOTO BIT0
 BTFSC CSTAT,XC         ;(XC=1)
 GOTO BITY              ;(XC ALWAYS = 1)
 INCF XCOUNT            ;(XC --|__)
 BCF FLAGB,RI           ;DEFAULT LEFT
 BTFSS RA,XD            ;LEFT / RIGHT ?
 GOTO BITY
 BSF FLAGB,RI
 GOTO BITY
BIT0
 BTFSS CSTAT,XC         ;(XC=0)
 GOTO BITY              ;(XC ALWAYS = 0)
 INCF XCOUNT            ;(XC __|--)
 BCF FLAGB,RI           ;DEFAULT LEFT
 BTFSC RA,XD            ;LEFT / RIGHT ?
 GOTO BITY
 BSF FLAGB,RI
BITY
 BTFSS RA,YC            ;YC = 1 ?
 GOTO BITY0
 BTFSC CSTAT,YC         ;(YC=1)
 GOTO BITDY             ;(YC ALWAYS = 1)
 INCF YCOUNT            ;(YC --|__)
 BCF FLAGB,UP           ;DEFAULT DOWN
 BTFSS RA,YD            ;DOWN / UP ?
 GOTO BITDY
 BSF FLAGB,UP
 GOTO BITDY
BITY0
 BTFSS CSTAT,YC         ;(YC=0)
 GOTO BITDY             ;(YC ALWAYS = 0)
 INCF YCOUNT            ;(YC __|--)
 BCF FLAGB,UP           ;DEFAULT DOWN
 BTFSC RA,YD            ;DOWN / UP ?
 GOTO BITDY
 BSF FLAGB,UP
BITDY
 MOVF RA,W              ;SAVE COOR. STATUS
 MOVWF CSTAT
 MOVLW 193D             ;0.833 MS DELAY
 MOVWF TIMER1
BITD0
 NOP
 DECFSZ TIMER1
 GOTO BITD0
 RETLW 0
;
;=================================================
;
;************************************************
;*      SUBROUTINE TO SEND A BYTE               *
;*      AS RS232C FORMAT 8,N,1                  *
;************************************************
;
BYTE
 CLRF COUNT             ;RESET 8 BIT COUNT
 BTFSS FLAGA,TR         ;ANY TRIGGER
 GOTO BYTE0
 BCF RB,RD              ;LOW RD FOR START BIT
BYTE0
 CALL BIT
BYTE1
 BTFSS FLAGA,TR         ;ANY TRIGGER ?
 GOTO BYTE3
 RRF DATA_AREA               ;SHIFT DATA TO CARRY
 BTFSS STATUS,CA        ;0 / 1 ?
 GOTO BYTE2
 BSF RB,RD              ;SEND A 1
 GOTO BYTE3
BYTE2
 BCF RB,RD              ;SEND A 0
BYTE3
 CALL BIT
 INCF COUNT
 BTFSS COUNT,3          ;COUNT = 8 ?
 GOTO BYTE1
 BTFSS FLAGA,TR         ;ANY TRIGGER ?
 GOTO BYTE4
 BCF RB,RD              ;SEND SENT BIT
 CALL BIT
 BSF RB,RD
 CALL BIT
 GOTO BYTE5
BYTE4
 CALL BIT
 CALL BIT
BYTE5
 RETLW 0
;
;============================================
;       RESET ENTRY
;============================================ 
;
INIT
 MOVLW B'11000001'      ;DISABLE WATCH DOG
 OPTION
 MOVLW B'00001111'      ;INIT RB0~3 BE INPUTS
 TRIS RB                ;RB4~7 BE OUTPUTS
 MOVLW B'11111111'      ;INIT RA0~3 BE INPUTS
 TRIS RA
 BSF RB,RD              ;HIGH RD PIN
 COMF RB,W              ;GET INIT BUTTON INPUTS
 ANDLW B'00000101'
 IORLW B'10000000'
 MOVWF BSTAT
 MOVWF DATA0            
 MOVF RA,W
 MOVWF CSTAT
 CLRF FLAGA             ;CLEAR TR FLAG
 CLRF XCOUNT            ;RESET XCOUNT & YCOUNT
 CLRF YCOUNT
SCAN
 CLRF DATA1             ;UPDATE X,Y MOVEMENT DATA
 CLRF DATA2
 CLRF DATA3
 CLRF DATA4
 MOVF XCOUNT,W          ;XCOUNT = 0 ?
 BTFSS STATUS,ZERO_AREA
 GOTO WRITX
SCANA
 MOVF YCOUNT,W          ;YCOUNT = 0 ?
 BTFSS STATUS,ZERO_AREA
 GOTO WRITY
SCANB
 COMF RB,W              ;BUTTON STATUS CHANGE ?
 ANDLW B'00000101'
 IORLW B'10000000'
 SUBWF BSTAT
 BTFSC STATUS,ZERO_AREA      ;IF CHANGE THEN TRIGGER
 GOTO SCANC             ;(NO CHANGE)
 BSF FLAGA,TR           ;(CHANGE) SET TRIGGER FLAG
 COMF RB,W              ;FORMAT BUTTON STATUS DATA
 ANDLW B'00000101'
 IORLW B'10000000'
 MOVWF DATA0
SCANC
 COMF RB,W
 ANDLW B'00000101'
 IORLW B'10000000'
 MOVWF BSTAT
 MOVF DATA0,W           ;SEND DATA0,1,2,3,4 TO HOST
 MOVWF DATA_AREA
 CALL BYTE
 MOVF DATA1,W
 MOVWF DATA_AREA
 CALL BYTE
 MOVF DATA2,W
 MOVWF DATA_AREA
 CALL BYTE
 MOVF DATA3,W
 MOVWF DATA_AREA
 CALL BYTE
 MOVF DATA4,W
 MOVWF DATA_AREA
 CALL BYTE
 BCF FLAGA,TR           ;CLEAR TRIGGER FLAG
 GOTO SCAN
;
WRITX
 BSF FLAGA,TR           ;SET TRIGGER FLAG
 MOVLW 40H              ;IF XCOUNT > 64 THEN XCOUNT <-64
 SUBWF XCOUNT,W
 BTFSC STATUS,CA
 GOTO WRITR
WRITS
 BTFSS FLAGB,RI         ;LEFT / RIGHT ?
 GOTO WRITL
 COMF XCOUNT            ;(RIGHT) NEG XCOUNT
 INCF XCOUNT,W
WRITA
 MOVWF DATA1
 MOVWF DATA3
 CLRF XCOUNT            ;RESET XCOUNT
 GOTO SCANA
;
WRITR
 MOVLW 40H              ;XCOUNT <- 64
 MOVWF XCOUNT
 GOTO WRITS
;
WRITL
 MOVF XCOUNT,W          ;(LEFT)
 GOTO WRITA
; 
WRITY
 BSF FLAGA,TR           ;SET TRIGGER FLAG
 MOVLW 40H              ;IF YCOUNT > 64 THEN YCOUNT <-64
 SUBWF YCOUNT,W
 BTFSC STATUS,CA
 GOTO WRITV
WRITW
 BTFSS FLAGB,UP         ;DOWN / UP ?
 GOTO WRITD
 COMF YCOUNT            ;(UP) NEG YCOUNT
 INCF YCOUNT,W
WRITB
 MOVWF DATA2
 MOVWF DATA4
 CLRF YCOUNT            ;RESET YCOUNT
 GOTO SCANB 
;
WRITV
 MOVLW 40H              ;YCOUNT <- 64
 MOVWF YCOUNT
 GOTO WRITW
;
WRITD
 MOVF YCOUNT,W          ;(DOWN)
 GOTO WRITB
;
;===========================================
;       RESET ENTRY
;===========================================
;
 ORG 777
 GOTO INIT              ;JUMP TO PROGRAM STARTING
;
 END
;
;********************************************
