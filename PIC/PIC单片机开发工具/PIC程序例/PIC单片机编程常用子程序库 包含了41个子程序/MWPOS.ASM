   TITLE " MicroWire Positioner "
;
;        mw8pos.asm 
;
;       LIST P=16C56
;        LIST F=INHX8M,P=16C56
;***************************************************************
; REV. A        Original release  1/10/92 srf
;
; **************************************************************
;
;REGISTER EQUATES
;
PNTR    EQU     00H             ; CONTENTS OF POINTER
FLAGS   EQU     19H             ; USE THIS VARIABLE LOCATION AS FLAGS
				; 0 BIT IS SIGN OF ERROR 1 IS NEGATIVE
				; 1 BIT IS SIGN OF ERROR ACCUMULATOR
				; 2 BIT IS SIGN OF THE DE/DE TERM
				; 3 BIT IS DIRECTION 0 IS CW
				; 4 BIT IS SIGN OF THE OLD ERROR
STATUS  EQU     03H
SWR     EQU     03H             ; STATUS WORD REGISTER
				; 0 = CARRY
				; 1 = DC
				; 2 = Z, SET IF RESULT IS ZERO
FSR     EQU     04H             ; FILE SELECT REGISTER
PORTA   EQU     05H             ; I/O REG (A0-A3), (A4-A7 DEF=0)
PORTB   EQU     06H             ; I/O REGISTER(B0-B7)
HI      EQU     07H             ; NUMBER OF HIGH MICROSECONDS
LO      EQU     08H             ; NUMBER OF LOW MICROSECONDS
PCNT    EQU     09H             ; PERCENT DUTYCYCLE REQUEST
HI_T    EQU     0AH             ; COUNTER FOR USECONDS LEFT/PULSE HI
LO_T    EQU     0BH             ; COUNTER FOR USECONDS LEFT/PULSE LO
ERROR   EQU     0CH             ; HOLDER FOR THE POSITIONAL ERROR
				; THIS IS AN 8 BIT MAGNITUDE WITH THE SIGN 
				; KEPT IN THE FLAG REGISTER (9BIT SIGNED)
SUMLO   EQU     0DH             ; PROGRESSIVE SUM OF THE PID TERMS
ACCUM   EQU     0EH             ; ERROR ACCUMULATOR
ERR_O   EQU     0FH             ; ERROR HISTORY USED FOR de/dt
				; THIS IS AN 8 BIT MAGNITUDE WITH THE SIGN
				; KEPT IN THE FLAG REGISTER (9BIT SIGNED)
POSR    EQU     10H             ; POSITIONAL REQUEST
POSA    EQU     11H             ; ACTUAL POSITION
CYCLES  EQU     12H             ; COUNTER FOR CYCLES OUT

mulcnd  equ     13H             ; 8 bit multiplicand
ACCaLO  EQU     13H             ; same location used for the add routine
mulplr  equ     14H             ; 8 bit multiplier
ACCbLO  EQU     14H             ; same location used for the add routine
H_byte  equ     15H             ; High byte of the 16 bit result
ACCaHI  EQU     15H             ; same location used for the add routine
L_byte  equ     16H             ; Low byte of the 16 bit result
ACCbHI  EQU     16H             ; same location used for the add routine
count   equ     17H             ; loop counter
SUMHI   EQU     18H             ; HIGH BYTE OF THE LOOP SUM


; PORT ASSIGNMENTS AND CONSTANTS

PWMCW   EQU     0               ; CLOCKWISE PWM OUTPUT BIT
PWMCCW  EQU     1               ; COUNTERCLOCKWISE PWM OUTPUT BIT
CARRY   EQU     0               ; CARRY BIT IN THE STATUS REGISTER
Z       EQU     2               ; THE ZERO BIT OF THE STATUS REGISTER
Same    equ     1               ;
ER_SGN  EQU     0               ; SIGN BIT FOR THE ERROR IN FLAG REGISTER
AC_SGN  EQU     1               ; SIGN BIT FOR THE ERROR ACCUMULATOR
DE_SGN  EQU     2               ; SIGN BIT FOR DE/DT
OER_SGN EQU     4               ; SIGN BIT FOR THE OLD ERROR
KP      EQU     30              ; PROPORTIONAL GAIN
KI      EQU     2               ; INTEGRAL GAIN
KD      EQU     20              ; DIFFERENTIAL GAIN
DIR     EQU     3               ; THE DIRECTION FLAG
CSN     EQU     7               ; CHIP SELECT NOT ON A/D
BV      EQU     6               ; DATA LINE FOR THE A/D
CK      EQU     5               ; CLOCK LINE FOR THE A/D
MWDO    EQU     2               ; MICROWIRE DATA OUT FROM POSITIONER
MWDI    EQU     1               ; MICROWIRE DATA IN TO POSITIONER
MWCS    EQU     0               ; MICROWIRE CHIP SELECT TO POSITIONER
MWCK    EQU     3               ; MICROWIRE CLOCK IN TO POSITIONER


;***** MACROS **********************************************
;
CLKUP   MACRO                   ; clock up macro for the microwire
	BSF     PORTB,CK        ; data acquisition from the a/d
	NOP     
	ENDM

CLKDN   MACRO                   ; clock down macro for the microwire
	BCF     PORTB,CK        ; data acquisition from the a/d
	NOP
	ENDM

GET_BIT MACRO                   ; ** FOR RECEIVING A/D DATA **
	BCF     SWR,CARRY
	BSF     PORTB,CK        ; SET CLOCK BIT HIGH
	BTFSC   PORTB,BV        ; LOOK AT DATA COMMING IN
	BSF     SWR,CARRY       ; SET THE CARRY FOR A 1 
	RLF     POSA            ; ROTATE THE W REG LEFT
	BCF     PORTB,CK        ; SET THE CLOCK LOW
	NOP                     ; DELAY
	ENDM

	GOTO    CLRREG

;***** MATH ROUTINES ****************************************
;

; **** 8 BIT MULTIPLY ********
; *****************************         Begin Multiplier Routine
mpy_S   clrf    H_byte
	clrf    L_byte
	movlw   8
	movwf   count
	movf    mulcnd,w
	bcf     STATUS,CARRY    ; Clear the carry bit in the status Reg.
loop    rrf     mulplr
	btfsc   STATUS,CARRY
	addwf   H_byte,Same
	rrf     H_byte,Same
	rrf     L_byte,Same
	decfsz  count
	goto    loop
	retlw   0

; ******************************
; DOUBLE PRECISION ADD AND SUBTRACT ( ACCb-ACCa->ACCb )

D_sub   call    neg_A           ; At first negate ACCa, then add

;****************
; Double Precision Addition ( ACCb+ACCa->ACCb )

D_add   movf    ACCaLO,W
	addwf   ACCbLO          ; add lsb
	btfsc   STATUS,CARRY    ; add in carry
	incf    ACCbHI
	movf    ACCaHI,W        
	addwf   ACCbHI          ; add msb
	retlw   00
;
;
neg_A   comf    ACCaLO          ; negate ACCa
	incf    ACCaLO
	btfsc   STATUS,Z
	decf    ACCaHI
	comf    ACCaHI
	retlw   00

; ********************************************
; divide by 16 and limit to 100 Decimal

SHIFT   MACRO
	BCF     SWR,CARRY
	RRF     L_byte
	BCF     SWR,CARRY
	RRF     H_byte
	BTFSC   SWR,CARRY
	BSF     L_byte,7
	ENDM

DIV_LMT
	SHIFT
	SHIFT
	SHIFT
	SHIFT

LMT100  
	MOVLW   1H              ; SUBTRACT 1 FROM THE HIGH BYTE TO SEE
	SUBWF   H_byte,0        ; IF THERE IS ANYTHING THERE, IF NOT,
	BTFSS   SWR,CARRY       ; THEN LEAVE THE LOW BYTE ALONE
	GOTO    L8_E            ; OTHERWISE GIVE THE LOW BYTE A FULL
	MOVLW   64H             ; COUNT AND IT WILL HAVE BEEN LIMITED
	MOVWF   L_byte          ; TO 100
	GOTO    LMT_EXIT
L8_E
	MOVLW   64H             ; LIMIT THE MAGNITUDE OF THE VALUE TO 
	SUBWF   L_byte,0        ; 100 DECIMAL
	BTFSS   SWR,CARRY
	GOTO    LMT_EXIT        
	MOVLW   64H
	MOVWF   L_byte
LMT_EXIT
	RETLW   00
;
;THE ROUTINE CALCTIMES DOES THE FOLLOWING: PCNT = DUTY CYCLE IN %
; 100 - PCNT --> LO  AND PCNT --> HI. ZERO VALUES IN EITHER LO OR HI
;ARE FORCED TO 1.
CALCTIMES
	MOVF    PCNT,W          ; PUT REQUESTED % INTO W REGISTER
	MOVWF   HI              ; COPY ON MICROSECONDS IN TO HI TIME
	MOVLW   64H
	MOVWF   LO
	MOVF    PCNT,0
	SUBWF   LO,1            ; LEAVE 100-HI TIME IN LO TIME
	MOVF    HI,0            ; INSPECT THE HIGH TIME
	BTFSC   SWR,2           ; IF ITS IS ZERO
	INCF    HI,1            ; INCREMENT IT
	MOVF    LO,0            ; INSPECT THE LO TIME
	BTFSC   SWR,2           ; IF ITS ZERO
	INCF    LO,1            ; INCREMENT IT
	RETLW   00


;*******************************************************************
BEGIN
	NOP             ; STUBBED BEGINNING     


;****CHECKING THE LIMIT SWITCHES AND CHECKING FOR MW***************
; This will check the switch inputs for closure and will terminate
; pulsing is one is closed.  It doesn't distinguish between the switches
; so they are not dedicated to cw end and ccw end.  

SW_TRAP
	CLRWDT
	BTFSS   PORTB,2         ; THIS WILL TEST ALL THREE OF THE 
	GOTO    SW_TRAP         ; SWITCH INPUTS.  IF ANY ONE IS
	BTFSS   PORTB,3         ; SET THEN EXECUTION OF THE CODE
	GOTO    SW_TRAP         ; WILL BE LIMITED TO LOOKING FOR
	BTFSS   PORTB,4         ; IT TO BE CLEARED
	GOTO    SW_TRAP
	

;****RECEIVING THE POSITIONAL REQUEST*******************************
; The host system that wishes to send positional requests to the positioner
; servo makes its desire known by setting the chip select to the positioner 
; low.  It then monitors the busy (Data Out) line from the positioner.  When
; the positioner sets the busy line high, the host may begin sending its 8 bit
; request.  The data bits should be valid on the rising edge of the clock.  
; After 8 bits have been received by the positioner it will begin operation 
; to send the system to the received position.  It can be interrupted at any
; point during the positioning process by the host sending a new command.  The
; opportunity to update the command is issued every 100 pwm pulses (every 50
; milliseconds).  
; If the host sends a zero positional command the positioner will stop the 
; system and remain inactive.
; If the host does not successfully complete a microwire transmission of 8
; data bits the watchdog timer will trip and reset the system to an inactive
; "stopped" state.


REC_MW
	MOVLW   0BH             ; RESET THE PORT FOR THREE INPUTS
	TRIS    PORTA           ; AND ONE OUTPUT
	BCF     PORTA,MWDO      ; SET THE DATA OUT LOW FOR BUSY
	MOVLW   20H
	MOVWF   count
WATCH_CS
	BTFSS   PORTA,MWCS      ; CHECK FOR INCOMMING REQUESTS  
	GOTO    REC_CMD         ; RECEIVE A NEW POSITION REQUEST
	DECFSZ  count,1 
	GOTO    WATCH_CS
	GOTO    REC_EXIT        ; NO REQUEST WAS MADE IN THE TIME ALLOTED
REC_CMD
	BSF     PORTA,MWDO      ; SET THE DATA OUT HIGH FOR "OK TO SEND"
	MOVLW   8H              ; SET TO RECEIVE 8 BITS
	MOVWF   count
WAIT_UP
	BTFSS   PORTA,MWCK      ; WAIT FOR A RISING EDGE
	GOTO    WAIT_UP
	BCF     SWR,CARRY       ; RESET THE CARRY TO A DEFAULT ZERO
	BTFSC   PORTA,MWDI      ; READ THE DATA IN              
	BSF     SWR,CARRY       ; SET THE CARRY FOR A ONE
	RLF     POSR,1          ; ROTATE THE BIT INTO THE POSITION REQ.
	DECFSZ  count,1         ; DECREMENT THE BIT COUNTER
	GOTO    WAIT_DN         ; WAIT FOR THE FALLING EDGE
	GOTO    REC_EXIT        ; LAST BIT RECEIVED
WAIT_DN
	BTFSC   PORTA,MWCK      ; CHECK THE INCOMMING CLOCK
	GOTO    WAIT_DN         ; IF IT IS STILL HIGH WAIT FOR IT TO GO LOW
	GOTO    WAIT_UP         ; IF IT GOES LOW GO BACK TO RECEIVE NEXT BIT

REC_EXIT
	BCF     PORTA,MWDO      ; SET THE BUSY FLAG


;********** CHECK FOR THE DISABLE REQUEST *************************
; Position 0 is considered a request to not drive the system.  In this way
; the positioner will come up from a reset in a safe state and will not
; try to move the system to some arbitrary location.

MOVE?
	MOVF    POSR,W          ; CHECK THE REQUESTED POSTION
	BTFSC   SWR,Z           ; IF IT IS ZERO THEN WAIT FOR A NON-ZERO
	GOTO    BEGIN           ; REQUEST BY BRANCHING BACK TO THE BEGINNING

;****READING THE A/D VALUES*****************************************
;
; Read the positional a/d channel (1) and store the value in the actual
; position variable (POSA).
; This is written in line to minimize the use of variables

READ_POS
	CLRF    POSA            ; CLEAN THE POSITION ACTUAL HOLDER
	BCF     PORTB,CSN       ; SET THE CHIP SELECT LOW TO A/D
	MOVLW   1CH             ; SET THE DATA LINE TO OUTPUT
	TRIS    PORTB           ; FOR SENDING SET-UP BITS
	BSF     PORTB,BV        ; SET FOR "START" BIT
	NOP
	CLKUP                   ; CLOCK IN THE START BIT
	CLKDN                   ; "
	CLKUP                   ; CLOCK IN SINGLE-ENDED
	CLKDN                   ; "
	CLKUP                   ; CLOCK IN CHANNEL 1
	CLKDN                   ; TO THE MUX 
	MOVLW   5CH             ; SET THE DATA LINE TO INPUT
	TRIS    PORTB           ; TO RECEIVE DATA BITS FROM A/D
	CLKUP                   ; CLOCK UP TO LET MUX SETTLE
	CLKDN                   ; CLOCK DN TO LET MUX SETTLE
	GET_BIT                 ; GET BIT 7
	GET_BIT                 ; BIT 6
	GET_BIT                 ; BIT 5
	GET_BIT                 ; BIT 4
	GET_BIT                 ; BIT 3
	GET_BIT                 ; BIT 2
	GET_BIT                 ; BIT 1
	GET_BIT                 ; BIT 0
	BSF     PORTB,CSN       ; DESELECT THE CHIP


;****************** CALCULATING THE PID TERMS ***********************

;****CALCULATE THE ERROR*******
; The error is very simply the signed difference between where the
; system is and where it is supposed to be at a particular instant
; in time.  It is formed by subtracting the actual position from the 
; requested position (Position requested - Position actual).  This 
; difference is then used to determine the proportional,integral and 
; differential term contributions to the output.

C_ERR
	MOVF    POSA,0          ; LOAD THE ACTUAL POSITION INTO W
	SUBWF   POSR,0          ; SUBTRACT IT FROM THE REQUESTED POSITION
	BTFSC   SWR,CARRY       ; CHECK THE CARRY BIT TO DETERMINE THE SIGN
	GOTO    PLS_ER          ; ITS POSATIVE  (POSR>POSA)
	GOTO    MNS_ER          ; ITS NEGATIVE  (POSA>POSR)

PLS_ER
	MOVWF   ERROR           ; SAVE THE DIFFERENCE IN "ERROR"
	BCF     FLAGS,ER_SGN    ; SET THE SIGN FLAG TO INDICATE POSATIVE
	GOTO    CE_EXIT

MNS_ER  
	MOVF    POSR,0          ; RE-DO THE SUBTRACTION
	SUBWF   POSA,0          ; ACTUAL - REQUESTED
	MOVWF   ERROR           ; STORE THE DIFFERENCE IN "ERROR"
	BSF     FLAGS,ER_SGN    ; SET THE SIGN FLAG FOR NEGATIVE
	
CE_EXIT
	CLRF    SUMLO           ; CLEAN OLD VALUES OUT TO PREPARE
	CLRF    SUMHI           ; FOR THIS CYCLES SUMMATION

;****CALCULATE THE PROPORTIONAL TERM******
; The proportional term is the error times the proportional gain term.
; This term simply gives you more output drive the farther away you are
; from where you want to be (error)*Kp.
; The proportional gain term is a signed term between -100 and 100  The
; more proportional gain you have the lower your system following error
; will be.  The higher your proportional gain, the more integral and 
; differential term gains you will have to add to make the system stable.
; The sum is being carried as a 16 bit signed value.

C_PROP
	MOVF    ERROR,0         ; LOAD THE ERROR TERM INTO W
	MOVWF   mulcnd          ; MULTIPLY IT BY THE PROPORTIONAL GAIN
	MOVLW   KP              ; KP AND THEN SCALE IT DOWN BY DIVIVING
	MOVWF   mulplr          ; IT DOWN BY 16. IF IT IS STILL OVER 
	CALL    mpy_S           ; 255 THEN LIMIT IT TO 255
	CALL    DIV_LMT

RESTORE_SGN
	BTFSS   FLAGS,ER_SGN    ; IF THE ERROR SIGN IS NEGATIVE THEN
	GOTO    ADDPROP         ; PUT THE SIGN INTO THE LOW BYTE
	COMF    L_byte,1
	INCF    L_byte,1

ADDPROP
	MOVF    L_byte,W        ; SAVE THE PROPORTIONAL PART
	ADDWF   SUMLO,1         ; IN THE SUM
	BTFSC   SWR,CARRY       ; IF THE ADDITION CARRIED OUT THEN
	INCF    SUMHI,1         ; INCREMENT THE HIGH BYTE
	MOVLW   0               ; THEN 
	BTFSC   SUMLO,7         ; SIGN EXTEND TO THE UPPER
	MOVLW   0FF             ; BYTE 
	ADDWF   SUMHI,1



;****CALCULATE THE INTEGRAL TERM******
; The integral term is an accumulation of the error thus far.  Its purpose
; is to allow even a small error to effect a large change.  It does this 
; by adding a small number into an accumulator each cycle through the program.
; Thusly even a small error that exist for a while will build up to a large
; enough number to effect an output sufficient to move the system.  The effect 
; that this integral accumulator has is modulated by the integral gain term KI.
; The integral of the error over time is multiplied be KI and the result is its
; contribution to the final summation for determining the output value.  This 
; term helps to insure the long-term accuracy of the system is good.  A certain
; amount is necessary for this purpose but too much will cause oscillations.
; The integral is bounded in magnitude for two purposes.  The first is so that
; it never rolls over and changes sign.  The second is that it may saturate on 
; long moves forcing an excessively large overshoot to "de-integrate" the error
; accumulated during the first of the move

C_INT
	MOVF    ERROR,W         ; MOVE THE ERROR INTO THE W REG
	BTFSC   SWR,Z           ; AND CHECK TO SEE IF IT IS ZERO
	GOTO    ADDINT          ; IF SO THEN DONT CHANGE THE ACCUMULATOR
	BTFSC   FLAGS,ER_SGN    ; TEST THE FLAGS TO FIND THE POLARITY
	GOTO    MNS_1           ; OF THE ERROR .. 0 POSATIVE 1 NEGATIVE
PLS_1   
	MOVLW   KI              ; IF POSATIVE ADD ONE TO
	ADDWF   ACCUM,1         ; THE ERROR ACCUMULATOR
	GOTO    LMTACM          ; THEN LIMIT IT TO +/-100
MNS_1   
	MOVLW   KI              ; IF NEGATIVE THEN SUBTRACT ONE
	SUBWF   ACCUM,1         ; FROM THE ERROR ACCUMULATOR
LMTACM
	BTFSC   ACCUM,7         ; CHECK THE SIGN BIT OF THE ERROR ACCUMULATOR
	GOTO    M_LMT           ; AND DO A POSATIVE OR NEGATIVE LIMIT
P_LMT
	MOVLW   9CH             ; FOR THE POSATIVE LIMIT ADD 156 TO THE
	ADDWF   ACCUM,0         ; NUMBER AND SEE IF YOU GENERATE A CARRY
	BTFSS   SWR,CARRY       ; BY CHECKING THE CARRY FLAG
	GOTO    ADDINT          ; IF NOT THEN ITS O.K.
	MOVLW   64H             ; IF SO THEN FORCE THE ACCUMULATOR TO 
	MOVWF   ACCUM           ; 100 DECIMAL
	GOTO    ADDINT
M_LMT
	MOVLW   9CH             ; FOR THE NEGATIVE LIMIT SUBTRACT 156 FROM
	SUBWF   ACCUM,0         ; THE NUMBER AND SEE IF YOU GENERATE A
	BTFSC   SWR,CARRY       ; NON-CARRY CONDITION INDICATING A ROLL-OVER
	GOTO    ADDINT          ; IF NOT THEN LEAVE THE ACCUMULATOR ALONE
	MOVLW   9CH             ; IF SO THEN LIMIT IT TO -100 BY
	MOVWF   ACCUM           ; FORCING THAT VALUE IN THE ACCUMULATOR

ADDINT
	MOVF    ACCUM,W         ; ADD THE INTEGRAL ACCUMULATOR TO
	ADDWF   SUMLO,1         ; THE LOW BYTE OF THE SUM
	BTFSC   SWR,CARRY       ; TEST FOR OVERFLOW, IF SO THEN
	INCF    SUMHI,1         ; INCREMENT THE HI BYTE
	MOVLW   0               ; LOAD 0 INTO THE W REGISTER
	BTFSC   ACCUM,7         ; IF THE INTEGRAL ACCUMULATOR WAS NEGATIVE
	COMF    W,W             ; COMPLEMENT THE 0 TO GET SIGN FOR HIGH BYTE
	ADDWF   SUMHI,1         ; ADD INTO THE HIGH BYTE OF THE SUM

	
U_DEXIT                         ; EXIT POINT FOR THE UP/DOWN CONTROL OF ACCUM
	


;****CALCULATING THE DIFFERENTIAL TERM**************************
; The differential term examines the error and determines how much
; it has changed since the last cycle.  It does this by subtracting the
; old error from the new error.  Since the cycle time is relatively fixed
; we can use it as the "dt" of the desired "de/dt".  This derivative of the 
; error is then multiplied by the differential gain term KD and becomes the 
; differential term contribution for the final summation.

; First, create the "de" term by doing a signed subtaction of new error
; minus the old error. (new_error - old_error)

C_DIFF
	MOVF    ERROR,W         ; LOAD THE NEW ERROR INTO REGISTER
	BTFSS   FLAGS,ER_SGN
	GOTO    LO_BYTE
	COMF    ERROR,1         ; CORRECT THE VALUE TO BE 16 BIT
	INCF    ERROR,W
	COMF    ERROR,1         ; RESTORE IT FOR FUTURE USE TO 8 BIT MAGNITUDE
LO_BYTE
	MOVWF   ACCbLO          ; FOR SUBTRACTION
	MOVLW   00
	BTFSC   FLAGS,ER_SGN    ; SIGN EXTEND THE UPPER BYTE
	MOVLW   0FF
	MOVWF   ACCbHI
	MOVF    ERR_O,W         ; LOAD THE OLD ERROR INTO OTHER REGISTER
	BTFSS   FLAGS,OER_SGN
	GOTO    LO_BYTEO
	COMF    ERR_O,1         ; CORRECT THE VALUE TO BE 16 BIT
	INCF    ERR_O,W
LO_BYTEO
	MOVWF   ACCaLO          ; FOR SUBTRACTION
	MOVLW   00
	BTFSC   FLAGS,OER_SGN   ; SIGN EXTEND THE UPPER BYTE
	MOVLW   0FF
	MOVWF   ACCaHI
	CALL    D_sub           ; PERFORM THE SUBTRACTION

STRIP_SGN
	BTFSC   ACCbHI,7        ; TEST THE SIGN OF THE RESULT
	GOTO    NEG_ABS
	GOTO    POS_ABS
NEG_ABS
	BSF     FLAGS,DE_SGN    ; ITS NEGATIVE SO SET THE FLAG AND
	COMF    ACCbLO,1        ; COMPLEMENT THE VALUE
	INCF    ACCbLO,W
	MOVWF   ERR_O   
	GOTO    MULT_KD
POS_ABS
	BCF     FLAGS,DE_SGN    ; ITS POSATIVE SO SET RESET THE FLAG
	MOVF    ACCbLO,W        ; AND SAVE THE VALUE
	MOVWF   ERR_O

; Then multiply by Kd

MULT_KD
	MOVF    ERR_O,W
	MOVWF   mulcnd          ; MOVE THE DE/DT TERM INTO THE MULCND REG.
	MOVLW   KD              ; MOVE THE DIFFERENTIAL GAIN TERM INTO
	MOVWF   mulplr          ; MULPLR TO MULTIPLY THE DE/DT
	CALL    mpy_S           ; DO THE MULTIPLICATION
	CALL    DIV_LMT         ; SCALE AND LIMIT TO 100

RE_SGN
	BTFSS   FLAGS,DE_SGN    ; IF THE DE SIGN IS NEGATIVE THEN
	GOTO    SAVE_DIFF       ; PUT THE SIGN INTO THE LOW BYTE
	COMF    L_byte,1
	INCF    L_byte,1
SAVE_DIFF
	MOVF    L_byte,W
	BTFSC   SWR,Z
	GOTO    ROLL_ER
	MOVWF   ERR_O

; ADD THE DIFF TERM INTO THE SUMM ***************

ADDDIF
	MOVLW   00
	BTFSC   FLAGS,DE_SGN    ; PUT THE KD*(DE/DT) TERM INTO THE 
	MOVLW   0FF             ; REGISTERS TO ADD. AND 
	MOVWF   ACCbHI          ; SIGN EXTEND THE UPPER BYTE
	MOVF    ERR_O,W
	MOVWF   ACCbLO
	MOVF    SUMLO,W         ; LOAD THE CURRENT SUM INTO THE
	MOVWF   ACCaLO          ; REGISTERS TO ADD
	MOVF    SUMHI,W
	MOVWF   ACCaHI
	CALL    D_add           ; ADD IN THE DIFFERENTIAL TERM
	MOVF    ACCbLO,W        ; SAVE THE RESULTS BACK
	MOVWF   SUMLO           ; INTO SUMLO AND HI
	MOVF    ACCbHI,W
	MOVWF   SUMHI

ROLL_ER
	MOVF    ERROR,W         ; TAKE THE CURRENT ERROR
	MOVWF   ERR_O           ; AND PUT IT IN THE ERROR HISTORY
	BCF     FLAGS,OER_SGN   ; SAVE THE CURRENT ERROR SIGN 
	BTFSC   FLAGS,ER_SGN    ; IN THE OLD ERROR SIGN FOR 
	BSF     FLAGS,OER_SGN   ; NEXT TIME THROUGH

	
;****SET UP THE DIRECTION FOR THE BRIDGE*********************
;
; After the sum of all the components has been made, the sign of the
; sum will determine which way the bridge should be powered.
; If the sum is negative the bridge needs to be set to drive ccw; if the
; sum is posative then the bridge needs to be set to drive cw.  This
; is purely a convention and depends upon the polarity the motor and feedback
; element are hooked up in.

SET_DIR
	BCF     FLAGS,DIR       ; SET FOR DEFAULT CLOCKWISE
	BTFSC   SUMHI,7         ; LOOK AT THE SIGN BIT, IF IT IS SET
	BSF     FLAGS,DIR       ; THEN SET FOR CCW BRIDGE DRIVE


;**** SCALE THE NUMBER TO BETWEEN 0 AND 100% **********************

; After the direction is set the request for duty cycle is limited to between 
; 0 and 100 percent inclusive.  This value is passed to the dutycycle setting
; routine by loading it in the variable "PCNT".


L_SUMM
	BTFSS   SUMHI,7         ; CHECK TO SEE IF IT IS NEGATIVE
	GOTO    POS_LM          
	COMF    SUMHI,1
	COMF    SUMLO,1
	INCF    SUMLO,1

POS_LM  
	MOVLW   1H              ; SUBTRACT 1 FROM THE HIGH BYTE TO SEE
	SUBWF   SUMHI,0         ; IF THERE IS ANYTHING THERE, IF NOT,
	BTFSS   SWR,CARRY       ; THEN LEAVE THE LOW BYTE ALONE
	GOTO    LB_L            ; OTHERWISE GIVE THE LOW BYTE A FULL
	MOVLW   64H             ; COUNT AND IT WILL HAVE BEEN LIMITED
	MOVWF   SUMLO           ; TO 100
	GOTO    LP_EXIT         ; GOTO LIMIT PERCENT EXIT
LB_L
	MOVLW   64H             ; LIMIT THE MAGNITUDE OF THE VALUE TO 
	SUBWF   SUMLO,0         ; 100 DECIMAL
	BTFSS   SWR,CARRY
	GOTO    LP_EXIT
	MOVLW   64H
	MOVWF   SUMLO   

LP_EXIT
	MOVF    SUMLO,W         ; STORE THE LIMITED VALUE IN
	MOVWF   PCNT            ; THE PERCENT DUTYCYCLE REQUEST


;**********************************************************
; PWM GENERATING ROUTINE
;
; The important thing here is not to have to do too many decisions or 
; calculations while you are generating the 100 or so pulses.  These will
; take time and limit the minimum or maximum duty cycle.

WHICH_DIR
	BTFSC   FLAGS,DIR       ; CHECK THE DIRECTION FLAG
	GOTO    GOCCW           ; DO CCW PULSES FOR 1
	GOTO    GOCW            ; DO CW PULSES FOR 0


GOCW
	BCF     PORTB,PWMCCW    ; SET THE BRIDGE FOR CW MOVE
	MOVLW   64H             ; 
	MOVWF   CYCLES          ; SET UP CYCLES COUNTER FOR 100 PULSES
	CALL    CALCTIMES       ; CALCULATE THE HI AND LO TIMES
		
RLDCW
	MOVF    HI,0            ; RE LOAD THE HI TIMER
	MOVWF   HI_T            ; WITH THE CALCULATED TIME
	MOVF    LO,0            ; RE LOAD THE LO TIMER 
	MOVWF   LO_T            ; WITH THE CALCULATED TIME
	CLRWDT                  ; TAG THE WATCHDOG TIMER

CWHI    
	BSF     PORTB,PWMCW     ; SET THE CLOCKWISE PWMBIT HIGH
	DECFSZ  HI_T,1          ; DECREMENT THE HI USEC. COUNTER
	GOTO    CWHI            ; DO ANOTHER LOOP
CWLO    
	BCF     PORTB,PWMCW     ; SET THE CLOCKWISE PWM BIT LOW
	DECFSZ  LO_T,1          ; DECREMENT THE LO USEC. COUNTER
	GOTO    CWLO            ; DO ANOTHER LOOP
	DECFSZ  CYCLES,1        ; DECREMENT THE NUMBER OF CYCLES LEFT
	GOTO    RLDCW           ; DO ANOTHER PULSE      
	GOTO    BEGIN           ; DO ANOTHER MAIN SYSTEM CYCLE


GOCCW
	BCF     PORTB,PWMCW     ; SET THE BRIDGE FOR CCW MOVE
	MOVLW   64H             ;
	MOVWF   CYCLES          ; SET UP CYCLE COUNTER FOR 100 PULSES
	CALL    CALCTIMES       ; CALCULATE THE HI AND LO TIMES
RLDCCW
	MOVF    HI,0            ; RE LOAD THE HI TIMER
	MOVWF   HI_T            ; WITH THE CALCULATED TIME
	MOVF    LO,0            ; RE LOAD THE LO TIMER 
	MOVWF   LO_T            ; WITH THE CALCULATED TIME
	CLRWDT                  ; TAG THE WATCHDOG

CCWHI   
	BSF     PORTB,PWMCCW    ; SET THE COUNTERCLOCKWISE PWM BIT HIGH
	DECFSZ  HI_T,1          ; DECREMENT THE HI USEC. COUNTER
	GOTO    CCWHI           ; DO ANOTHER LOOP
CCWLO
	BCF     PORTB,PWMCCW    ; SET THE COUNTERCLOCKWISE PWM BIT LOW
	DECFSZ  LO_T,1          ; DECREMENT THE LO USEC. COUNTER
	GOTO    CCWLO           ; DO ANOTHER LOOP
	DECFSZ  CYCLES,1        ; DECREMENT THE NUMBER OF CYCLES LEFT
	GOTO    RLDCCW          ; DO ANOTHER PULSE      
	GOTO    BEGIN           ; DO ANOTHER MAIN SYSTEM CYCLE





	;************* START VECTOR ********************

CLRREG                          ;INITIALIZE REGISTERS

	MOVLW   0BH             ; SET PORT A FOR 3 INPUTS AND
	TRIS    PORTA           ; AN OUTPUT
	MOVLW   1CH             ; SET PORT B FOR INPUTS AND OUTPUTS
	TRIS    PORTB           ; THIS SETTING FOR SENDING TO A/D
	CLRW                    ; CLEAR THE W REGISTER
	OPTION                  ; STORE THE W REG IN THE OPTION REG
	MOVLW   08H             ; STARTING REGISTER TO ZERO
	MOVWF   FSR             ;
GCLR
	CLRF    00              ;
	INCFSZ  FSR             ; SKIP AFTER ALL REGISTERS
	GOTO    GCLR            ; HAVE BEEN INITIALIZED
	GOTO    BEGIN           ; START AT THE BEGINING OF THE PROGRAM
	
	ORG     01FF            ;
	GOTO    CLRREG          ; START VECTOR


	END
	MOVLW  00
	BTFSC   FLAG
