;******************************************************
;       sm.asm:
;       Routine, demonstrating how to implement a stack 
;       manager capable of handling more than 2 
;       subsequent subroutine calls.
;       Note: Since this is a demo, NOP has been used 
;       where normally the body of the subroutine would 
;       reside.
;******************************************************
;
        PC      EQU     2
FSR     EQU     4
;
        ORG     8
STACK   RES     5       ;define stack size = 5.
;
        ORG     01FF
        GOTO    START
;
        ORG     0
;
INIT    MOVLW   STACK   ;load "stack" as indirect pointer
        MOVWF   FSR     ;       /
        GOTO    START   ;      / 
;
;******************************************************
;define NCALL as a MACRO used instead of the 
;mnemonic CALL.
;
NCALL   MACRO   LABEL   
        MOVF    PC,W    ;save PC on "stack"
        MOVWF   0       ;       /
        INCF    FSR     ;Inc. "stack"  pointer.
        GOTO    LABEL   ;jump to routine
        ENDM
;
;return from subroutine NCALL
;
RETURN  DECF    FSR     ;point to last "stack" location
        MOVLW   3       ;add 3 and output value from FSR
        ADDWF   0,W     ;       /
        MOVWF   PC      ;load in PC as next executable 
;                       instruction
;
;******************************************************
;
PAGE
;
START   NOP
        NCALL   TOM
        NOP     ;body of main routine
        NOP     ;       /
        SLEEP
;
TOM     NOP
        NCALL   DICK
        NOP     ;body of routine TOM
        GOTO    RETURN
;
DICK    NOP
        NCALL   HARRY
        NOP     ;body of routine DICK
        GOTO    RETURN
;
HARRY   NOP     ;body of routine HARRY
        NOP     ;       /
        GOTO    RETURN
;
;
        END

