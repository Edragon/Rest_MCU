		TITLE        "Alarm Clock"
LIST  P = 16C57
;
;Define Equates:
;       
	PIC57   EQU     7FFH
;************************************************************************
;External Ossc. used = 4.096Mhz. Prescaler of 32 used, which gives a
;31.25 microSec increment of the RTCC. If RTCC is intially loaded with 96,
;it would overflow to 0 in 5.000 milliSecs. Giving a 0.00% error.
	MSEC5   EQU     D'96'
;*************************************************************************
	C       EQU     0
	BEP     EQU     0
	RTATS   EQU     0
	DC      EQU     1
	HR10    EQU     1
	Z       EQU     2
	HR      EQU     2
	MIN10   EQU     3
	MIN     EQU     4
	FLASH   EQU     4
	PA0     EQU     5
	KEY_BEEP EQU    5
	AMPM    EQU     5
	PA1     EQU     6
	F0      EQU     0
	KEY_HIT EQU     6
	ALED    EQU     6
	AM_PM   EQU     7
	COLON   EQU     3
	ALRMLED EQU     2
	SERVICED EQU    7
	ALONOF  EQU     0
	INAL    EQU     1
	SILNC   EQU     2
	INAA    EQU     3
	INKEYBEP EQU    5
;
;DEFINE RAM LOCATIONS:
	RTCC    EQU     1
	PC      EQU     2
	STATUS  EQU     3
	FSR     EQU     4
	PORT_A  EQU     5
	PORT_B  EQU     6
	PORT_C  EQU     7
;DEFINE REAL TIME MODE REGS (RTM)
	MSTMR   EQU     8       ;MILLI SEC. TIMER
	STMR    EQU     9       ;SEC. TIMER
;*****************************************************
;DO NOT CHANGE RELATIVE POSITION OF NEXT 6 BYTES
	MTMR    EQU     0A      ;MIN. TIMER
	HTMR    EQU     0B      ;HOUR TIMER
;DEFINE ALARM TIME MODE REGS (ATM)
	MALARM  EQU     0C      ;MIN. ALARM
	HALARM  EQU     0D      ;HOUR ALARM
;DEFINE DATA ENTRY MODE REGS (DEM)
	MENTRY  EQU     0E      ;MIN. ENTRY
	HENTRY  EQU     0F      ;HOUR ENTRY
;*****************************************************
PAGE
;
;DEFINE FLAG REG AND FUNCTION:
	FLAG    EQU     10
;       BIT # 7|6|5|4|3|2|1|0|
;--------------|-|-|-|-|-|-|-|
;             X|X|X|X|X|X|0|0| --> REAL TIME MODE (RTM)
;             X|X|X|X|X|X|0|1| --> ALARM TIME MODE(ATM)
;             X|X|X|X|X|X|1|0| --> DATA ENTRY M0DE(DEM)
;             X|X|X|X|X|X|1|1| --> TEST MODE (TM)
;             X|X|X|X|X|Y|X|X| --> ALRMLED ON/OFF
;             X|X|X|X|Y|X|X|X| --> COLON LED ON/OFF
;             X|X|X|Y|X|X|X|X| --> FLASH DISPLAY
;             X|X|Y|X|X|X|X|X| --> KEY_BEEP
;             X|Y|X|X|X|X|X|X| --> KEY_HIT (0/1)
;             Y|X|X|X|X|X|X|X| --> SERVICED
; X = DEFINED ELSEWHERE IN TABLE 
; Y = DEFINED AS SHOWN (0/1)
;
	TEMP    EQU     11
	DIGIT   EQU     12
	NEW_KEY EQU     13
	KEY_NIBL EQU    14
	DEBOUNCE EQU    15
	MIN_SEC EQU     16      ;MIN/SECONDS TIMER
	ENTFLG  EQU     17
;flag dedicated to the key entry mode
;       BIT # 7|6|5|4|3|2|1|0|
;--------------|-|-|-|-|-|-|-|
;             X|X|X|X|X|X|X|Y| --> REAL/ALARM TIME STATUS
;             X|X|X|X|X|X|Y|X| --> HR10 DONE
;             X|X|X|X|X|Y|X|X| --> HR DONE
;             X|X|X|X|Y|X|X|X| --> MIN10 DONE
;             X|X|X|Y|X|X|X|X| --> MIN DONE
;             X|X|Y|X|X|X|X|X| --> INKEYBEP
;             X|Y|X|Y|X|X|X|X| --> NOT USED
;             Y|X|X|X|X|X|X|X| --> NOT USED
;
;
	ALFLAG  EQU     18
;flag dedicated to the alarm
;       BIT # 7|6|5|4|3|2|1|0|
;--------------|-|-|-|-|-|-|-|
;             X|X|X|X|X|X|X|Y| --> ALONOF
;             X|X|X|X|X|X|Y|X| --> INAL
;             X|X|X|X|X|Y|X|X| --> SILNC
;             X|X|X|X|Y|X|X|X| --> INAA
;             X|X|X|Y|X|X|X|X| --> NOT USED
;             X|X|Y|X|X|X|X|X| --> NOT USED
;             X|Y|X|Y|X|X|X|X| --> NOT USED
;             Y|X|X|X|X|X|X|X| --> NOT USED
;
	AAFLAG  EQU     19
;flag dedicated to the AA alarm
	AATMR   EQU     1A
;
;Port pin definitions:
;
;PORT_A:
;       BIT 0   --> BEEPER (ACTIVE LOW) OUTPUT
;       BIT 1-3 --> unused I/O
;
;PORT_B: ALL OUTPUTS
;       BIT 0&4 --> MSB DIGIT COMMON CATHODE & ALARM
;       BIT 1&5 --> 2ND DIGIT COMMOM CATHODE & COLON
;       BIT 2&6 --> 3RD DIGIT COMMON CATHODE & PM
;       BIT 3&7 --> LSB DIGIT COMMON CATHODE & AM
;
;PORT_C: 
;IN DISPLAY MODE ALL SEG/ANNN SET AS OUTPUTS
;IN KEY SCAN MODE COLS ARE OUTPUTS ROWS ARE INPUTS
;       BIT 0   --> SEGMENT A & COL 4 
;       BIT 1   --> SEGMENT B & COL 3
;       BIT 2   --> SEGMENT C & COL 2
;       BIT 3   --> SEGMENT D & COL 1
;       BIT 4   --> SEGMENT E & ROW 4
;       BIT 5   --> SEGMENT F & ROW 3
;       BIT 6   --> SEGMENT G & ROW 2
;       BIT 7   --> CA OF ALL ANNUNCIATORS & ROW 1
;
;
PAGE
;
	ORG     0
START
	GOTO    INIT_CLK        ;INITIALIZE CLOCK
;THIS ROUTINE RUNS A TEST ON THE LEDS.
;ALL THE RELEVENT LEDS ARE LIT UP FOR 2 SECS.
;
TEST_HARDWARE
	MOVLW   d'02'           ;DISPLAY FOR 2 SECS
	MOVWF   MIN_SEC         ;       /
;        
;
TEST_LOOP
	MOVF    MIN_SEC,W       ;GET MIN/SEC
	BTFSC   STATUS,Z        ;NOT 0 THEN SKIP
	GOTO    NORM_TIME       ;ELSE NORMAL TIME
	CALL    UPDATE_DISPLAY  ;UPDATE DISPLAY
	BSF     STATUS,PA0      ;GOTO PAGE 1
	CALL    UPDATE_TIMERS   ;WAIT AND UPDATE
	BCF     STATUS,PA0      ;RESET PAGE MARKER
	GOTO    TEST_LOOP       ;LOOP BACK
NORM_TIME
	BCF     FLAG,0          ;PUT IN REAL TIME
	BCF     FLAG,1
TIME_LOOP
	CALL    UPDATE_DISPLAY
	BSF     STATUS,PA1      ;GOTO PAGE 2
	CALL    SERVICE_KEYS
	BSF     STATUS,PA0      ;GOTO PAGE 3
	CALL    SOUND_AA        ;CHECK ALARM
	BCF     STATUS,PA1      ;GOTO PAGE 1
	CALL    UPDATE_TIMERS   ;WAIT AND UPDATE TIMERS
	BCF     STATUS,PA0      ;RESET PAGE MARKER
	BCF     STATUS,PA1      ;       /
	MOVF    FLAG,W          ;SEE IF IN ATM
	ANDLW   B'00000011'     ;       /
	XORLW   B'00000001'     ;      /
	BTFSC   STATUS,Z        ;SKIP IF NOT
	CALL    RESET_ATM
	GOTO    TIME_LOOP
;
RESET_ATM
	MOVF    MIN_SEC,W       ;GET MIN/SEC
	ANDLW   B'00001111'     ;       /
	BTFSS   STATUS,Z        ;Z THEN SKIP
	RETLW   0               ;ELSE RETURN
	BCF     FLAG,0          ;SET TO RTM
	BCF     FLAG,ALRMLED    ;CLEAR LED
	BTFSC   ALFLAG,ALONOF   ;TEST STAT
	BSF     FLAG,ALRMLED    ;SET LED
	RETLW   0               ;RETURN
PAGE
;
;
UPDATE_DISPLAY
	MOVLW   B'00000000'     ;CLEAR SEG DRIVE
	MOVWF   PORT_C          ;       /
	MOVLW   B'00111111'     ;SEE IF LAST DIGIT
	XORWF   PORT_B,0        ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    SCAN_KP         ;ELSE SCAN KEYPAD
UP_DSP_1
;SELECT DIGIT TO BE DISPLAYED
	COMF    PORT_B,0        ;GET COMPL. PORT B IN W
	BTFSC   STATUS,Z        ;NO DIGIT SELECTED?
	MOVLW   B'11000000'     ;THEN SELECT DEFAULT
	MOVWF   TEMP            ;SAVE IN TEMP
	COMF    TEMP            ;COMPLEMENT VALUE
	BSF     STATUS,C        ;SET CARRY
	RLF     TEMP            ;SHIFT LEFT
	BTFSS   STATUS,C        ;IF C=1 THEN SKIP
	RLF     TEMP            ;ELSE 3 TIMES...
	RLF     TEMP            ;THRU CARRY
	MOVF    TEMP,0          ;GET IN W
	MOVWF   PORT_B          ;OUTPUT TO PORT
;NOW THAT DIGIT IS SELECTED, SELECT SEG VALUES FOR THAT DIGIT
;FIRST FIND MODE OF OPERATION.
	MOVLW   MTMR            ;LOAD FSR WITH MTMR
	MOVWF   FSR             ;       /
	MOVF    FLAG,0          ;GET FLAG IN W
	ANDLW   B'00000011'     ;MASK OTHER BITS
	MOVWF   TEMP            ;SAVE IN TEMP
	XORLW   B'00000011'     ;IN TEST MODE
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    DO_TM           ;ELSE TEST MODE
	BCF     STATUS,C        ;CLEAR CARRY
	RLF     TEMP            ;LEFT SHIFT TEMP
	MOVF    TEMP,0          ;GET IN W
	ADDWF   FSR             ;CHANGE INDIRECT POINTER
	CALL    GET_7_SEG       ;GET 7 SEG DATA IN W
	MOVWF   DIGIT           ;SAVE IN DIGIT LOC.
	CALL    MASK_ANNC       ;MASK ANNC TO DIGIT
	BTFSC   FLAG,FLASH      ;NO FLASH THEN SKIP
	CALL    CHK_HALF_SEC    ;ELSE CHK. IF ON
	MOVF    DIGIT,0         ;GET BACK DIGIT
	MOVWF   PORT_C          ;OUTPUT TO PORT
	RETLW   0               ;RETURN
;
DO_TM
	MOVLW   B'11111111'     ;LIGHT ALL SEGMENTS
	MOVWF   PORT_C          ;       /
	RETLW   0               ;RETURN FROM UPDATE DISPLAY
;
CHK_HALF_SEC
	BTFSS   FLAG,COLON      ;IF COLON ON THEN DO
	GOTO    BLANK_DSP       ;ELSE BLANK DISPLAY
	RETLW   0
BLANK_DSP
	MOVLW   B'00000000'     ;MAKE PORT C LOW
	MOVWF   DIGIT
	RETLW   0
;
PAGE
;
;ON ENTRY FSR POINTS TO THE REAL TIME MODE'S MINUTES REGISTER.
;ON RETURN FSR POINTS TO THE TIMER REGISTER TO BE DISPLAYED.
;W REG. CONTAINS THE DECODED 7 SEG. INFO OF THE DIGIT
;TO BE DISPLAYED
;
GET_7_SEG
	COMF    PORT_B,0        ;COMPLEMENT B --> W
	ANDLW   B'11110000'     ;MASK LO NIBBLE
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	INCF    FSR             ;INC POINTER
	MOVF    F0,0            ;MOVE INDIRECT TO W
	MOVWF   TEMP            ;GET INTO TEMP
	COMF    PORT_B,0        ;COMPL.B --> W
	ANDLW   B'11110000'     ;MASK LO NIBBLE
	BTFSC   STATUS,Z        ;IF D1/2 THEN
	BCF     TEMP,AM_PM      ;CLEAR AM/PM BIT
	COMF    PORT_B,0        ;GET PORT B AGAIN
	ANDLW   B'11001100'     ;SEE IF D2 OR D4
	BTFSC   STATUS,Z        ;YES THEN SKIP
	SWAPF   TEMP            ;SWAP TEMP
	MOVLW   B'00001111'     ;MASK HI NIBBLE
	ANDWF   TEMP,0
	ADDWF   PC              ;ADD TO PC
	RETLW   B'00111111'     ;CODE FOR 0
	RETLW   B'00000110'     ;CODE FOR 1
	RETLW   B'01011011'     ;CODE FOR 2
	RETLW   B'01001111'     ;CODE FOR 3
	RETLW   B'01100110'     ;CODE FOR 4
	RETLW   B'01101101'     ;CODE FOR 5
	RETLW   B'01111101'     ;CODE FOR 6
	RETLW   B'00000111'     ;CODE FOR 7
	RETLW   B'01111111'     ;CODE FOR 8
	RETLW   B'01100111'     ;CODE FOR 9
;
;This routine scans the 4x4 hex key pad for a key hit.
;If key is pressed, KEY_HIT flag is set and the value of
;the hex key is returned in reg NEW_KEY
;If no key is detected, then a 0xff value is returned in
;register NEW_KEY and the flag KEY_HIT is reset.
;
SCAN_KP
	BTFSC   FLAG,KEY_HIT    ;KEY UNDER SERVICE?
	GOTO    UP_DSP_1        ;YES SKIP ROUTINE
	MOVLW   B'11111111'     ;SET DIGIT SINKS ...
	MOVWF   PORT_B          ;TO HIGH
	MOVLW   B'11110111'     ;SET KEY COL LOW
	MOVWF   TEMP            ;SAVE IN TEMP
SKP1
	MOVLW   B'00000000'     ;SET PORT C AS OUTPUTS
	TRIS    PORT_C          ;       /
	MOVF    TEMP,W
	ANDLW   B'00001111'     ;DISCHARGE PINS
	MOVWF   PORT_C          ;       /
	MOVLW   B'11110000'     ;SET AS I/O
	TRIS    PORT_C          ;   /
	MOVF    TEMP,W          ;GET OLD VALUE
	MOVWF   PORT_C          ;OUTPUT TO PORT
	MOVF    PORT_C,W        ;INPUT PORT VALUE
	ANDLW   B'11110000'     ;MASK LO BYTE
	XORLW   B'11110000'     ;SEE IF KEY HIT
	BTFSS   STATUS,Z        ;NO KEY THEN SKIP        
	GOTO    DET_KEY         ;LOAD KEY VALUE
SKP3        
	BSF     STATUS,C        ;SET CARRY
	RRF     TEMP            ;MAKE NEXT COL. LOW
	BTFSC   STATUS,C        ;ALL DONE THEN SKIP
	GOTO    SKP1
	CLRF    NEW_KEY         ;SET NEW_KEY = FF
	DECF    NEW_KEY         ;       /
SKP2                           
	CLRF    PORT_C          ;SETPORT C AS ...
	MOVLW   B'00000000'     ;OUTPUTS
	TRIS    PORT_C          ;       /
	GOTO    UP_DSP_1        ;RETURN
DET_KEY
;key is detected
	INCF    NEW_KEY,W       ;CHK IF KEY ...
	BTFSS   STATUS,Z        ;WAS RELEASED
	GOTO    SKP2            ;NO THEN RETURN
	MOVF    PORT_C,W        ;GET RAW KEY...
	IORLW   B'00001111'     ;VALUE.
	ANDWF   TEMP,W          ;   /
	MOVWF   NEW_KEY         ;SAVE IN NEW_KEY
	CALL    GET_KEY_VAL     ;GET ACTUAL KEY ...
	MOVWF   NEW_KEY         ;VALUE
	BSF     FLAG,KEY_HIT    ;SET KEY HIT FLAG
	GOTO    SKP2            ;RETURN
;
PAGE
;This routine decodes the hex value from the "raw" data got
;from scanning the rows and cols.
;   actual key value          raw hex value
;       ONE              EQU     77
;       TWO              EQU     7B
;       THREE            EQU     7D
;       C                EQU     7E      
;       FOUR             EQU     0B7
;       FIVE             EQU     0BB
;       SIX              EQU     0BD
;       D                EQU     0BE     
;       SEVEN            EQU     0D7
;       EIGHT            EQU     0DB
;       NINE             EQU     0DD
;       E                EQU     0DE
;       A                EQU     0E7
;       ZERO             EQU     0EB
;       B                EQU     0ED    
;       F                EQU     0EE     
;
;
GET_KEY_VAL
	ANDLW   B'00001111'     ;GET LO NIBBLE        
	MOVWF   KEY_NIBL        ;SAVE
	MOVLW   4               ;SET COUNT TO 4
	MOVWF   TEMP            ;       /
GKV1
	BSF     STATUS,C        ;SET CARRY
	RRF     KEY_NIBL        ;ROTATE NIBBLE
	BTFSS   STATUS,C        ;SKIP IF NOT Z
	GOTO    GET_HI_KEY      ;GOTO NEXT PART
	DECFSZ  TEMP            ;DEC COUNT
	GOTO    GKV1            ;LOOP
GO_RESET
	BSF     STATUS,PA0      ;SET MSB
	BSF     STATUS,PA1      ;       /
	GOTO    SYS_RESET       ;ELSE BIG ERROR
GET_HI_KEY
	DECF    TEMP            ;REDUCE BY 1
	SWAPF   NEW_KEY,W       ;GET HI NIBBLE
	ANDLW   B'00001111'     ;       /
	MOVWF   KEY_NIBL        ;SAVE
	MOVF    TEMP,W          ;GET OFFSET TO TBL
	ADDWF   PC              ;LOAD IN PC
	GOTO    GET147A         ;JUMP TO NEXT PART
	GOTO    GET2580         ;       /
	GOTO    GET369B         ;     /
	GOTO    GETCDEF         ;   /
;
GET147A
	MOVLW   4               ;SET COUNT TO 4
GETCOM
	MOVWF   TEMP            ;
GETCOM1
	BSF     STATUS,C        ;SET CARRY
	RRF     KEY_NIBL        ;ROTATE RIGHT
	BTFSS   STATUS,C        ;CHECK IF DONE
	GOTO    KEY_TBL         ;JUMP TO TABLE
	DECFSZ  TEMP            ;DEC COUNT
	GOTO    GETCOM1         ;LOOP
	GOTO    GO_RESET        ;ELSE ERROR
;
GET2580
	MOVLW   8               ;SET COUNT TO 8
	GOTO    GETCOM
;
GET369B
	MOVLW   D'12'           ;SET COUNT TO 12
	GOTO    GETCOM
;
GETCDEF
	MOVLW   D'16'           ;SET COUNT TO 16
	GOTO    GETCOM
PAGE
;
KEY_TBL 
	DECF    TEMP            ;REDUCE BY 1
	MOVF    TEMP,W          ;GET IN W
	ADDWF   PC              ;JUMP TO TABLE
	RETLW   1               ;KEY 1
	RETLW   4               ;KEY 4
	RETLW   7               ;KEY 7
	RETLW   0A              ;KEY A
	RETLW   2               ;KEY 2
	RETLW   5               ;KEY 5
	RETLW   8               ;KEY 8
	RETLW   0               ;KEY 0
	RETLW   3               ;KEY 3
	RETLW   6               ;KEY 6
	RETLW   9               ;KEY 9
	RETLW   0B              ;KEY B
	RETLW   0C              ;KEY C
	RETLW   0D              ;KEY D
	RETLW   0E              ;KEY E
	RETLW   0F              ;KEY F
;
PAGE
;
MASK_ANNC
	MOVLW   B'11111100'     ;CHK IF DIGIT 1
	XORWF   PORT_B,0        ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    MASK_ALARM      ;ELSE MASK ALARM
	MOVLW   B'11110011'     ;CHK IF DIGIT 2
	XORWF   PORT_B,0        ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    MASK_COLON      ;ELSE MASK COLON
	MOVLW   B'11001111'     ;CHK IF DIGIT 3
	XORWF   PORT_B,0        ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    MASK_PM         ;ELSE MASK PM
MASK_AM
	INCF    FSR             ;INC FSR
	BTFSS   F0,AM_PM        ;IF 0 THEN AM
	BSF     DIGIT,7         ;SET MSB
	GOTO    BLNK_LEAD_0     ;NEXT
MASK_PM
	INCF    FSR             ;INC FSR
	BTFSC   F0,AM_PM        ;IF 1 THEN PM
	BSF     DIGIT,7         ;SET MSB
	GOTO    BLNK_LEAD_0     ;NEXT
MASK_ALARM
	BTFSC   FLAG,ALRMLED    ;1 THEN LIGHT LED
	BSF     DIGIT,7         ;      /
	GOTO    BLNK_LEAD_0     ;NEXT
MASK_COLON
	BTFSC   FLAG,COLON      ;1 THEN LIGHT LED
	BSF     DIGIT,7         ;       /
	GOTO    BLNK_LEAD_0     ;NEXT
;
BLNK_LEAD_0
	MOVF    FLAG,W          ;GET IN W
	ANDLW   B'00000011'     ;SEE IF IN DEM
	XORLW   B'00000010'     ;CHECK
	BTFSC   STATUS,Z        ;NO THEN DO
	RETLW   0               ;ELSE RETURN
	MOVLW   B'11111100'     ;SEE IF DIGIT 1
	XORWF   PORT_B,0        ;       /
	BTFSS   STATUS,Z        ;YES THEN SKIP
	RETLW   0               ;RETURN
	MOVLW   B'00111111'     ;ELSE MASK G AND ANUNC
	ANDWF   DIGIT,0         ;GET IN W
	XORLW   B'00111111'     ;SEE IF 0
	BTFSS   STATUS,Z        ;YES THEN SKIP
	RETLW   0               ;RETURN
	MOVLW   B'10000000'     ;ELSE BLANK D1
	ANDWF   DIGIT           ;       /
	RETLW   0               ;RETURN
;
;
;
PAGE
;
;THIS ROUTINE SETS UP PORTS A,B,C AND THE INTERNAL
;REAL TIME CLOCK COUNTER.
INIT_CLK
	MOVLW   B'00001111'     ;MAKE ACTIVE HIGH
	MOVWF   PORT_A          ;       /
	MOVLW   B'00000000'     ;SET PORT A AS OUTPUTS
	TRIS    PORT_A
;
	MOVLW   B'11111111'     ;SET LEVELS HIGH
	MOVWF   PORT_B          ;       /
	MOVLW   B'00000000'     ;SET PORT B AS OUTPUTS
	TRIS    PORT_B
;
	MOVLW   B'00000000'     ;SET LEVELS LOW
	MOVWF   PORT_C          ;       /
	MOVLW   B'00000000'     ;SET PORT C AS OUTPUTS
	TRIS    PORT_C          ;       /
;
	MOVLW   B'00000100'     ;SET UP PRESCALER
	OPTION                  ;       /
;
	MOVLW   MSEC5           ;RTCC = 5 mSEC
	MOVWF   RTCC            ;       /
	CLRF    MSTMR           ;CLEAR MSTMR
	CLRF    STMR            ; & SEC TMR
	CLRF    MTMR            ;& MINUTES
	MOVLW   12H             ;MAKE HRS = 12
	MOVWF   HTMR            ;     /
	MOVWF   HALARM          ;MAKE HRS = 12
	CLRF    MALARM          ;       /
	MOVLW   B'00000011'     ;SET TO TEST MODE        
	MOVWF   FLAG            ;       /
	CLRF    ALFLAG          ;CLEAR ALL FLAG
	CLRF    AAFLAG          ;       /
	CLRF    ENTFLG          ;      /
	GOTO    TEST_HARDWARE
;
;All routines related to timer updates are located at
;address 200 and above.
PAGE
	ORG     0200
;
UPDATE_TIMERS
	MOVF    RTCC,W          ;SEE IF RTCC = 0
	BTFSS   STATUS,Z        ;IF 0 THEN SKIP
	GOTO    UPDATE_TIMERS   ;ELSE LOOP
	MOVLW   MSEC5           ;RTCC = 5 mSEC
	MOVWF   RTCC            ;       /
	INCF    MSTMR           ;INC 5 MILLI SEC
	BTFSC   FLAG,KEY_HIT    ;NO KEY HIT THEN SKIP
	GOTO    CHK_DE_BOUNCE   ;ELSE DEBOUNCE
UP_TMR_1
	MOVF    FLAG,W          ;ALARM MODE?
	ANDLW   B'00000011'     ;       /
	XORLW   B'00000001'     ;       /
	BTFSS   STATUS,Z        ;SKIP IF YES
	GOTO    UP_TMR_2        ;DO NEXT
	BSF     FLAG,ALRMLED    ;LIGHT LED
	BSF     FLAG,COLON      ;       /
	MOVLW   D'100'          ;IF 1/2 SEC
	SUBWF   MSTMR,0         ; BLINK
	BTFSS   STATUS,C        ;  /
	BCF     FLAG,ALRMLED    ;ALARM LED
	GOTO    UP_TMR_3        ;SKIP
UP_TMR_2
	BSF     FLAG,COLON      ;TURN ON
	MOVLW   D'100'          ;<100 BLINK COLON
	SUBWF   MSTMR,0         ;       /
	BTFSS   STATUS,C        ;YES THEN SKIP
	BCF     FLAG,COLON      ;ELSE TURN OFF
UP_TMR_3
	MOVF    MSTMR,0         ;GET MSTMR IN W
	XORLW   D'199'          ;= 199 THEN SKIP
	BTFSS   STATUS,Z        ;       /
	RETLW   0
;INC SECONDS COUNT
	CLRF    MSTMR           ;CLEAR MS_TMR
	MOVF    MIN_SEC,W       ;GET MIN_SEC TIMER
	ANDLW   B'00001111'     ;MASK MINUTES
	BTFSS   STATUS,Z        ;ZERO THEN SKIP
	DECF    MIN_SEC         ;REDUCE SECONDS
	MOVLW   STMR            ;LOAD FSR WITH S_TMR
	MOVWF   FSR             ;       /
	CALL    INC_60          ;INC SECONDS
	IORLW   0               ;DO AN OPERATION
	BTFSS   STATUS,Z        ;IF RETURN = 0 SKIP
	GOTO    CHK_AL_TIM      ;CHK ALRM 
;INC MINUTES COUNT
	SWAPF   MIN_SEC         ;SWAP MIN SEC
	MOVF    MIN_SEC,W       ;GET MIN_SEC IN W
	ANDLW   B'00001111'     ;MASK SECONDS
	BTFSS   STATUS,Z        ;SKIP IF NOT SET
	DECF    MIN_SEC         ;ELSE DEC
	SWAPF   MIN_SEC         ;SWAP BACK
	CALL    CHK_SILNC_TIM   ;SILNCE ON?
	MOVLW   MTMR            ;INC MINUTES
	MOVWF   FSR             ;       /
	CALL    INC_60          ;       /
	IORLW   0               ;DO AN OPERATION
	BTFSS   STATUS,Z        ;IF 0 THEN SKIP
	GOTO    CHK_AL_TIM      ;CHECK ALRAM TIME
;INC HOUR COUNT
	MOVLW   HTMR            ;GET HTMR IN FSR
	MOVWF   FSR
	CALL    INC_HR          ;INC HOURS
;
CHK_AL_TIM
	BTFSS   ALFLAG,ALONOF   ;IF OFF QUIT
	RETLW   0               ;       /
	BTFSC   ALFLAG,SILNC    ;RET IF IN SILENCE
	RETLW   0
	BTFSC   ALFLAG,INAL     ;ALREADY DONE
	GOTO    CHK_1_MIN       ;SEE IF 1 MIN UP
;        RETLW   0               ;YES THEN QUIT
	MOVF    HALARM,W        ;CHK HRS
	XORWF   HTMR,W          ;EQUAL?
	BTFSS   STATUS,Z        ;YES THEN SKIP
	RETLW   0               ;ELSE RET
	MOVF    MALARM,W        ;CHK MIN
	XORWF   MTMR,W          ;EQUAL?
	BTFSS   STATUS,Z        ;YES THEN SKIP
	RETLW   0               ;ELSE RET
	MOVF    STMR,W          ;SEE IF SEC=0
	BTFSS   STATUS,Z        ;YES THEN SKIP
	RETLW   0               ;NO THEN RET
	BSF     ALFLAG,INAL     ;SET IN ALARM FLAG
	MOVLW   10              ;SET 1 MIN TIMER
	MOVWF   MIN_SEC         ;       /
	RETLW   0
;
CHK_1_MIN
	SWAPF   MIN_SEC,W       ;SWAP IN W
	ANDLW   B'00001111'     ;CHK MINUTES
	BTFSS   STATUS,Z        ;0 THEN SKIP
	RETLW   0               ;ELSE RET
	BCF     ALFLAG,INAL     ;CLR IN ALARM
	BCF     ALFLAG,INAA     ;CLR IN AA
	BSF     PORT_A,BEP      ;STOP BEEPER
	RETLW   0
;
INC_60
	INCF    F0              ;INC AND GET IN W
	MOVF    F0,0            ;       /
	ANDLW   B'00001111'     ;MASK HI BITS
	XORLW   B'00001010'     ;= 10 THEN MAKE IT 0
	BTFSS   STATUS,Z        ;       /
	RETLW   1               ;ELSE RETURN NON ZERO
	MOVLW   B'11110000'     ;ZERO LSB
	ANDWF   F0              ;  /
	SWAPF   F0              ;SWAP INDIRECT
	INCF    F0              ;INC
	MOVF    F0,0            ;GET IN W
	SWAPF   F0              ;SWAP F0 BACK
	XORLW   D'6'            ;=6 THEN SKIP
	BTFSS   STATUS,Z        ;       /
	RETLW   1               ;ELSE RETURN NZ
	CLRF    F0              ;       /
	RETLW   0               ;RET 0
;
PAGE
;
CHK_SILNC_TIM
	BTFSS   ALFLAG,SILNC    ;CHK IF IN SILENCE
	RETLW   0               ;NO THEN SKIP
	SWAPF   MIN_SEC,W       ;GET MIN IN W
	ANDLW   B'00001111'     ;MASK SECS
	BTFSS   STATUS,Z        ;ZERO?
	RETLW   0               ;NO THEN RET
	BCF     ALFLAG,SILNC    ;RESET SILENCE
	MOVLW   10              ;SET I MIN TIMER
	MOVWF   MIN_SEC         ;       /
	RETLW   0
;
;
CHK_DE_BOUNCE
	BTFSC   ENTFLG,INKEYBEP ;IN KEY BEEP?
	GOTO    CHK_DEB_1       ;YES THEN DEC TIMER
	BTFSS   FLAG,KEY_BEEP   ;KEY BEEP SET?
	GOTO    CHK_SERV        ;NO, SEE IF SERVICED
	BTFSC   ALFLAG,INAA     ;IN AA?
	GOTO    CHK_BEP_ON      ;YES THEN SEE IF ON
CHK_DEB_1
	BSF     ENTFLG,INKEYBEP ;SET FLAG
	MOVF    DEBOUNCE,W      ;GET IN W
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	MOVLW   D'20'           ;ELSE DB 100 mSEC
	MOVWF   DEBOUNCE        ;       /
	BCF     PORT_A,BEP      ;TURN ON BEEPER
	DECFSZ  DEBOUNCE        ;DEC AND CHK
	GOTO    UP_TMR_1        ;GO BACK
	BSF     PORT_A,BEP      ;TURN OFF BEEPER
CHK_SERV
;        CLRF    DEBOUNCE
;        BSF     PORT_A,BEP
	BTFSS   FLAG,SERVICED   ;SERVICED THEN SKIP
	GOTO    UP_TMR_1        ;GO BACK
	BCF     FLAG,SERVICED   ;ELSE CLEAR FLAGS
	BCF     FLAG,KEY_HIT    ;       /
	BCF     FLAG,KEY_BEEP   ;RESET FLAG
	BCF     ENTFLG,INKEYBEP ;    /
	GOTO    UP_TMR_1        ;GO BACK
;
CHK_BEP_ON
	BTFSS   PORT_A,BEP      ;IF OFF THEN SKIP
	GOTO    UP_TMR_1        ;ELSE WAIT 
	GOTO    CHK_DEB_1       ;RETURN
;
;
INC_HR
	INCF    F0              ;INC HOUR TIMER
	MOVF    F0,W            ;GET HR TMR IN W
	MOVWF   TEMP            ;SAVE IN TEMP
	ANDLW   B'00001111'     ;CHK LO BYTE = 10
	XORLW   D'10'           ;       /
	BTFSS   STATUS,Z        ;YES THEN SKIP
	GOTO    INC_AM_PM       ;ELSE CHK 12
	MOVLW   B'00010000'     ;LOAD 1 IN MSB
	MOVWF   F0
	GOTO    RESTORE_AM_PM   ;RESTORE AM/PM
INC_AM_PM
	BCF     F0,AM_PM        ;CLEAR AM/PM
	MOVF    F0,W            ;GET IN W
	XORLW   12H             ;SEE IF 12 HEX
	BTFSS   STATUS,Z        ;YES THEN SKIP
	GOTO    CHK_13          ;ELSE CHK 13
	BTFSS   TEMP,AM_PM      ;IF SET, SKIP
	GOTO    SET_AM_PM       ;ELSE SET
	BCF     F0,AM_PM        ;CLEAR FLAG
	RETLW   0               ;RETURN
SET_AM_PM
	BSF     F0,AM_PM        ;SET FLAG
CHK_13
	MOVF    F0,W            ;GET IN W
	XORLW   13H             ;SEE IF 13
	BTFSS   STATUS,Z        ;YES THEN SKIP
	GOTO    RESTORE_AM_PM
SET_1_HR     
	MOVLW   B'00000001'     ;SET TO 1
	MOVWF   F0
RESTORE_AM_PM
	BTFSC   TEMP,AM_PM      ;SKIP IF AM
	BSF     F0,AM_PM        ;ELSE SET TO PM
	RETLW   0
;
;
;
PAGE
	ORG     400
;
;KEY DEFINITIONS
	ALARM_KEY       EQU     0A 
	CE_KEY          EQU     0B
	SNOOZE_KEY      EQU     0C
	AM_PM_KEY       EQU     0D
	CLR_ALARM_KEY   EQU     0E
	SET_KEY         EQU     0F
;
SERVICE_KEYS
	BTFSS   FLAG,KEY_HIT    ;NO KEY HIT THEN ...
	RETLW   0               ;RETURN
	BTFSC   FLAG,SERVICED   ;IF NOT SERVICED SKIP
	RETLW   0               ;ELSE RETURN
	BSF     FLAG,SERVICED   ;SET SERVICED FLAG
	MOVF    FLAG,W          ;GET MODE OF OPERATION
	ANDLW   B'00000011'     ;       /
	BTFSC   STATUS,Z        ;00 THEN RTM
	GOTO    RTMKS           ;RTM KEY SERVICE
	MOVWF   TEMP            ;SAVE IN TEMP
	DECFSZ  TEMP            ;REDUCE TEMP
	GOTO    SK1             ;SKIP
	GOTO    ATMKS           ;01, DO ALARM MODE
SK1
	DECFSZ  TEMP            ;REDUCE TEMP
	RETLW   0               ;11 THEN RETURN
	GOTO    DEMKS           ;10, DATA ENTRY MODE
;
;REAL TIME MODE KEY SERVICE
RTMKS
	CALL    CHK_AL_KEYS     ;CHK ALARM KEYS
	IORLW   0               ;SEE IF NZ RET
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	RETLW   0               ;ELSE RETURN
	MOVLW   SET_KEY         ;SEE IF SET KEY
	XORWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    SERV_SET_RTM    ;SERVICE SET KEY
	MOVLW   ALARM_KEY       ;ALARM KEY?
	XORWF   NEW_KEY,W       ;    /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    SERV_ALARM_RTM  ;ELSE SERVICE ALARM
IGNORE_KEY
	RETLW   0               ;ELSE RETURN
;
;ALARM TIME MODE KEY SERVICE
ATMKS
	CALL    CHK_AL_KEYS     ;CHECK ALRM KEYS
	IORLW   0               ;CHECK IF 0
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	RETLW   0               ;ELSE RETURN
	MOVLW   SET_KEY         ;SEE IF SET KEY
	XORWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    SERV_SET_ATM
	MOVLW   ALARM_KEY       ;GET ALARM KEY
	XORWF   NEW_KEY,W       ;SEE IF HIT
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    SERV_ALARM_ATM  ;ELSE SERVICE
	GOTO    IGNORE_KEY
;
;DATA ENTRY MODE KEY SERVICE
DEMKS
	CALL    CHK_AL_KEYS     ;CHECK ALARM KEYS
	IORLW   0               ;CHK IF 0
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	RETLW   0               ;ELSE RETURN
	MOVLW   SET_KEY         ;IF SET KEY THEN END
	XORWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    DEMKS_END       ;GOTO END
	MOVLW   CE_KEY          ;IF CLEAR ENTRY
	XORWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,Z        ;SKIP IF NO
	GOTO    DEMKS_END_1     ;ABANDON ENTRY
	BTFSS   ENTFLG,HR10     ;10'S HRS DONE?
	GOTO    ENT_HR_10       ;NO THEN GET
	BTFSS   ENTFLG,HR       ;HRS DONE?
	GOTO    ENT_HRS         ;NO THEN GET
	BTFSS   ENTFLG,MIN10    ;10'S MIN. DONE?
	GOTO    ENT_MIN_10      ;NO THEN GET
	BTFSS   ENTFLG,MIN      ;MIN DONE?
	GOTO    ENT_MIN         ;NO THEN GET
	GOTO    ENT_AM_PM       ;NO THEN GET
DEMKS_END
	BTFSS   ENTFLG,RTATS    ;GET OLD STATUS
	GOTO    LD_RTM          ;LOAD IN TIME
	MOVF    MENTRY,W        ;LD IN ALARM
	MOVWF   MALARM          ;       /
	MOVF    HENTRY,W        ;     /
	MOVWF   HALARM          ;   /
	BCF     FLAG,ALRMLED    ;CLEAR FLAG
	BTFSC   ALFLAG,ALONOF   ;SEE IF ON-OFF
	BSF     FLAG,ALRMLED    ;ELSE SET
DEMKS_END_1
	BCF     FLAG,0          ;RTM MODE
	BCF     FLAG,1          ;    /
	BCF     FLAG,FLASH      ;STOP FLASH
SERV_COM_RET
	BSF     FLAG,KEY_BEEP
	RETLW   0               ;RETURN
;
LD_RTM
	MOVF    MENTRY,W        ;LD IN RTM
	MOVWF   MTMR            ;       /
	MOVF    HENTRY,W        ;     /
	MOVWF   HTMR            ;   /
	CLRF    MSTMR           ;CLR TIME
	CLRF    STMR            ;  /
	GOTO    DEMKS_END_1     ;GO BACK
;
ENT_HR_10
	MOVF    NEW_KEY,W       ;SEE IF 0
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	GOTO    LD_HENTRY_0     ;LOAD 0
	DECFSZ  NEW_KEY,0       ;1 THE SKIP
	GOTO    IGNORE_KEY      ;ELSE IGNORE KEY
	BSF     HENTRY,4        ;SET TO 1
	BSF     ENTFLG,HR10     ;SET FLAG
	GOTO    SERV_COM_RET    ;GO GET NEXT
LD_HENTRY_0
	BCF     HENTRY,4        ;SET TO 0
	BSF     ENTFLG,HR10
	GOTO    SERV_COM_RET    ;
ENT_HRS
	MOVLW   HENTRY          ;USE INDIRECT ADDR.
	MOVWF   FSR             ;       /
	BTFSC   HENTRY,4        ;SEE IF 0
	GOTO    ALLOW0_2        ;YES THEN 0,1&2
	MOVLW   D'10'           ;SEE IF 0 - 9
	SUBWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,C        ;IF C THEN SKIP
	GOTO    IGNORE_KEY      ;ELSE IGNORE
ENT_LO_COM1
	BSF     ENTFLG,HR       ;SET FLAG
ENT_LO_COM
	MOVF    F0,W            ;LD HRS
	ANDLW   B'11110000'     ;MASK LO NIBL
	IORWF   NEW_KEY,W       ;OR NEW KEY
	MOVWF   F0              ;SAVE BACK
	GOTO    SERV_COM_RET    ;GET NEXT
ALLOW0_2
	MOVLW   D'3'            ;SEE IF 0 - 2
	SUBWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,C        ;<3 THEN SKIP
	GOTO    IGNORE_KEY
	GOTO    ENT_LO_COM1     ;       /
;
ENT_MIN_10
	MOVLW   MENTRY          ;DO INDIRECT ADDR.
	MOVWF   FSR             ;       /
	MOVLW   D'6'            ;ALLOW 0 - 5
	SUBWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,C        ;IF C THEN SKIP
	GOTO    IGNORE_KEY      ;ELSE IGNORE
	SWAPF   F0,W            ;SWAP AND GET
	ANDLW   B'11110000'     ;MASK LO NIBL
	IORWF   NEW_KEY,W       ;OR NEW KEY
	MOVWF   F0              ;SAVE BACK
	SWAPF   F0              ;SWAP BACK
	BSF     ENTFLG,MIN10
	GOTO    SERV_COM_RET    ;GET NEXT
;
ENT_MIN
	MOVLW   MENTRY          ;DO INDIRECT
	MOVWF   FSR             ;       /
	MOVLW   D'10'           ;ALLOW 0 - 9
	SUBWF   NEW_KEY,W       ;SEE IF >
	BTFSC   STATUS,C        ;NO THEN SKIP
	GOTO    IGNORE_KEY      ;ELSE IGNORE
	BSF     ENTFLG,MIN      ;SET FLAG
	GOTO    ENT_LO_COM      ;       /
;
ENT_AM_PM
	MOVLW   AM_PM_KEY       ;AM/PM KEY?
	XORWF   NEW_KEY,W       ;    /
	BTFSS   STATUS,Z        ;YES THEN SKIP
	GOTO    IGNORE_KEY
	BTFSS   HENTRY,AM_PM    ;TEST BIT
	GOTO    SETAMPM         ;ELSE SET
	BCF     HENTRY,AM_PM    ;CLEAR FLAG
	GOTO    SERV_COM_RET    ;GOTO END
SETAMPM
	BSF     HENTRY,AM_PM    ;SET FLAG
	GOTO    SERV_COM_RET
;
PAGE
;
SERV_SET_RTM
	MOVF    MTMR,W          ;TRANSFER TIME
	MOVWF   MENTRY          ;TO DATA ENTRY
	MOVF    HTMR,W          ;       /
	MOVWF   HENTRY          ;     /
SERV_COM
	MOVF    FLAG,W          ;SAVE IN W
	ANDLW   B'00000001'     ;ATM OR RTM MODE?
	MOVWF   ENTFLG          ;SAVE IN ENTFLG
	MOVLW   B'11110010'     ;FORCE 1S
	IORWF   FLAG            ;    /
	BCF     FLAG,0          ;   /
	RETLW   0
;
SERV_SET_ATM
	MOVF    MALARM,W        ;TRANSFER ALARM
	MOVWF   MENTRY          ;TO DATA ENTRY
	MOVF    HALARM,W        ;       /
	MOVWF   HENTRY          ;     /
	BSF     ALFLAG,ALONOF   ;SET FLAG
	GOTO    SERV_COM        ;GOTO COMMON
;
SERV_ALARM_ATM
	BTFSS   ALFLAG,ALONOF   ;TEST ON/OFF
	GOTO    SET_ALONOF      ;SET ON/OF FLG
	BCF     ALFLAG,ALONOF   ;CLEAR FLAG
	GOTO    SERV_ATM_COM    ;RET THRO COM
SET_ALONOF        
	BSF     ALFLAG,ALONOF   ;SET FLAG
SERV_ATM_COM
	BSF     FLAG,KEY_BEEP   ;BEEP
	MOVLW   B'11110000'     ;CLEAR SEC COUNT
	ANDWF   MIN_SEC         ;       /
	RETLW   0               ;RETURN
;
SERV_ALARM_RTM
	BSF     FLAG,KEY_BEEP   ;SET BEEP FLAG
	BSF     FLAG,0          ;SET TO ALARM TIME
	BCF     FLAG,1          ;       /
	MOVLW   D'05'           ;SAVE 5 IN MIN_SEC
	MOVWF   MIN_SEC         ;       /
	RETLW   0
;
SERV_SNOOZE
	MOVLW   0A0             ;SNOOZE FOR 10 MINS
	MOVWF   MIN_SEC         ;       /
	BSF     ALFLAG,SILNC    ;SET FLAG
CLR_AL_COM
	BSF     FLAG,KEY_BEEP   ;SET BEEP FLAG
	CLRF    AATMR           ;RESET AA TIMER
	CLRF    AAFLAG          ;CLEAR AA FLAGS
	BCF     ALFLAG,INAA     ;RESET INAA FLAG
	BSF     PORT_A,BEP      ;TURN OFF BEEPER
	RETLW   0               ;RET
;
CHK_AL_KEYS
	BTFSS   ALFLAG,ALONOF   ;ALARM ON?
	RETLW   1               ;NO THEN RET
	BTFSS   ALFLAG,INAL     ;IN ALARM?
	RETLW   1               ;NO THEN SKIP
	MOVLW   CLR_ALARM_KEY   ;CHECK IF CLR ALARM
	XORWF   NEW_KEY,W       ;       /
	BTFSC   STATUS,Z        ;NO THEN SKIP
	GOTO    CLR_ALARM       ;ELSE CLEAR ALARM
	MOVLW   SNOOZE_KEY      ;SEE IF SNOOZE HIT
	XORWF   NEW_KEY,W       ;       /
	BTFSS   STATUS,Z        ;YES THEN SKIP
	RETLW   1
	GOTO    SERV_SNOOZE
;
CLR_ALARM
	BCF     ALFLAG,INAL     ;CLEAR ALARM
	BCF     ALFLAG,SILNC    ;CLEAR SILENCE
	MOVLW   B'00001111'     ;CLEAR MINS
	ANDWF   MIN_SEC         ;       /
	GOTO    CLR_AL_COM
;
	ORG     600
;If the AA alarm is set, then this routine takes care of 
;the timing in sounding the alarm.
;
SOUND_AA
	BTFSS   ALFLAG,INAL     ;SKIP IF IN ALRM
	RETLW   0               ;ELSE RETURN
	BTFSC   ALFLAG,SILNC    ;SKIP IF NOT IN SIL
	RETLW   0               ;ELSE RET
	BTFSC   ENTFLG,INKEYBEP ;SKIP IF NOT IN KEY BEP
	GOTO    CHK_COLSN       ;CHK COLLISION
SND_AA_0
	BTFSS   ALFLAG,INAA     ;SKIP IF IN AA
SND_AA_1
	CALL    INIT_AA         ;INIT ALL
	BTFSS   AAFLAG,0        ;SKIP IF DONE
	GOTO    DO_CYCL0        ;DO FIRST CYCL
	BTFSS   AAFLAG,1        ;SKIP IF DONE
	GOTO    DO_CYCL1        ;ELSE 2ND CYCLE
	BTFSS   AAFLAG,2        ;SKIP IF DONE
	GOTO    DO_CYCL2        ;ELSE DO 3RD CYCLE
	BTFSS   AAFLAG,3        ;SKIP IF DONE
	GOTO    DO_CYCL3        ;DO CYCLE 4
	BTFSS   AAFLAG,4        ;SKIP IF DONE
	GOTO    DO_CYCL4        ;DO CYCLE 5
	BTFSS   AAFLAG,5        ;SKIP IF DONE
	GOTO    DO_CYCL5        ;DO CYCLE 6
	BTFSS   AAFLAG,6        ;SKIP IF DONE
	GOTO    DO_CYCL6        ;DO CYCLE 6
	BTFSS   AAFLAG,7        ;SKIP IF DONE
	GOTO    DO_CYCL7        ;DO CYCLE 7
	GOTO    SND_AA_1        ;GO BACK
;
INIT_AA
	CLRF    AAFLAG          ;CLEAR ALL FLAGS
	BSF     ALFLAG,INAA     ;SET IN AA FLAG
	GOTO    PUT_ON_100      ;ON 100 MSECS
;
DEC_AA_TMR
	DECF    AATMR           ;REDUCE TIMER
	MOVF    AATMR,W         ;GET IN W
	BTFSS   STATUS,Z        ;CHECK IF Z
	RETLW   1               ;NO THEN NZ
	RETLW   0               ;ELSE 0
;
DO_CYCL0
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0
	BSF     AAFLAG,0        ;SET DONE FLAG
PUT_OFF_100
	BSF     PORT_A,BEP      ;TURN OFF BEEPER
	MOVLW   D'20'           ;FOR 100 MSECS
	MOVWF   AATMR           ;       /
	RETLW   0
;
DO_CYCL1
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0
	BSF     AAFLAG,1        ;SET DONE FLAG
PUT_ON_100
	BCF     PORT_A,BEP      ;TURN ON BEEPER               
	MOVLW   D'20'           ;FOR 100 MSECS
	MOVWF   AATMR           ;       /
	RETLW   0
;
DO_CYCL2
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0               ;       /
	BSF     AAFLAG,2        ;SET DONE FLAG
	BSF     PORT_A,BEP      ;TURN OFF BEEPER
	MOVLW   D'100'          ;FOR 500 MSECS
	MOVWF   AATMR           ;       /
	RETLW   0
;
DO_CYCL3
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0               ;       /
	BSF     AAFLAG,3        ;SET DONE FLAG
	GOTO    PUT_ON_100      ;DO NEXT CYCLE
;
DO_CYCL4
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0               ;       /
	BSF     AAFLAG,4        ;SET DONE FLAG
	GOTO    PUT_OFF_100     ;DO NEXT CYCLE
;
DO_CYCL5
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0               ;       /
	BSF     AAFLAG,5        ;SET DONE FLAG
	GOTO    PUT_ON_100      ;DO NEXT CYCLE
;
DO_CYCL6
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0               ;       /
	BSF     AAFLAG,6        ;SET DONE FLAG
	BSF     PORT_A,BEP      ;TURN OFF BEEPER
	MOVLW   D'200'          ;FOR 1000 MSECS
	MOVWF   AATMR           ;       /
	RETLW   0
;
DO_CYCL7
	CALL    DEC_AA_TMR      ;REDUCE TIMER
	BTFSS   STATUS,Z        ;IF NZ THEN RET
	RETLW   0               ;       /
	BSF     AAFLAG,7        ;SET DONE FLAG
	GOTO    PUT_ON_100      ;DO NEXT CYCLE
;       
CHK_COLSN
	BTFSC   PORT_A,BEP      ;IF ON THEN SKIP
	GOTO    SND_AA_0        ;ELSE RET
	MOVF    AATMR,W         ;GET TIMER
	BTFSC   STATUS,Z        ;NZ THEN SKIP
	GOTO    LD_AAT_1        ;LOAD A 1 IN TMR        
	DECF    AATMR           ;REDUCE TIMER
	RETLW   0               ;RETURN
LD_AAT_1
	INCF    AATMR           ;INC TIMER
	RETLW   0               ;RET
;
	ORG     PIC57
SYS_RESET
	GOTO    START
;
	END



