;*************************************************************************
;                       RS232 Communication Parameters
;
;
X_MODE  equ     1       ; If ( X_MODE==1) Then transmit LSB first
;                         if ( X_MODE==0) Then transmit MSB first ( CODEC like )
R_MODE  equ     1       ; If ( R_MODE==1) Then receive LSB first
;                         if ( R_MODE==0) Then receive MSB first ( CODEC like )
X_Nbit  equ     1       ; if ( X_Nbit==1) # of data bits ( Transmission ) is 8 else 7
R_Nbit  equ     1       ; if ( R_Nbit==1) # of data bits ( Reception ) is 8 else 7
;
SB2     equ     0       ; if SB2 = 0 then 1 Stop Bit
;                       ; if SB2 = 1 then 2 Stop Bit
;***********************************************************************
;       Transmit & Receive Test Bit Assignments
;
X_flag  equ     0       ; Bit 0 of FlagRX
R_flag  equ     2       ; Bit 1 of FlagRX
S_flag  equ     3       ; Bit 2 of FlagRX
BitXsb  equ     4       ; Bit 3 of FlagRX
A_flag  equ     5
S_bit   equ     6       ; Xmt Stop Bit Flag( for 2/1 Stop bits )
;
R_done  equ     1       ; When Reception complete, this bit is SET
X_done  equ     X_flag  ; When Xmission complete, this bit is Cleared
;
DX      equ     0       ; Transmit Pin ( Bit 0 of Port A )
DR      equ     1       ; Reciive Pin ( Bit 1 of Port A )
;
;************************  Data RAM Assignments  **********************
;
	ORG     08H     ; Dummy Origin
;
RcvReg  RES     1       ; Data received
XmtReg  RES     1       ; Data to be transmitted
Xcount  RES     1       ; Counter for #of Bits Transmitted
Rcount  RES     1       ; Counter for #of Bits to be Received
DlyCnt  RES     1       ; Counter for Delay constant
FlagRX  RES     1       ; Transmit & Receive test flag hold register
;______________________________________________________________
;    Constants       19200   9600    4800    2400    1200
;  ( @ 20 Mhz )
;______________________________________________________________
;       K0            0      13       57     143      317*
;       K1           49      98      184     358*     705*
;       K2           34      60      103     191      364*
;       K3           27      53       96     184      357*
;       K4           29      55       98     186      359*
;       K5           30      56       99     187      360*
;       K6            0       0        0       0        0
;       K7           56     104      190     365*     712*
;
;    User Cycles    118     260      521     1042     2083
; *************************************************************
;
;
;______________________________________________________________
;    Constants       19200   9600    4800    2400    1200
;  ( @ 8 Mhz )
;______________________________________________________________
;       K0            --      0        5      39      109
;       K1            --     39       80     150      288*
;       K2            --     27       51      86      155
;       K3            --     21       44      80      148
;       K4            --     23       46      82      150
;       K5            --     24       47      83      151
;       K6            --      0        0       0        0
;       K7            --     45       86     156      295*
;
;    User_Cycles      --     86      208     416      832
; *************************************************************
;
;______________________________________________________________
;    Constants       19200   9600    4800    2400    1200
;  ( @ 4 Mhz )
;______________________________________________________________
;       K0            --      --       0       5       39
;       K1            --      --      39      80      150
;       K2            --      --      27      51       86
;       K3            --      --      21      44       80
;       K4            --      --      23      46       82
;       K5            --      --      24      47       83
;       K6            --      --       0       0        0
;       K7            --      --      45      86      156
;
;    User_Cycles      --      --      86     208      416
; *************************************************************

;
; The constants marked " * " are >255. To implement these constants
; in delay loops, the delay loop should be broken into 2 or more loops.
; For example, 357 = 255+102. So 2 delay loops, one with 255 and
; the other with 102 may be used.
;*************************************************************************
;       Set Delay Constants for 9600 Baud @ CLKIN = 8 Mhz
;
K0      EQU     .0
K1      EQU     .39
K2      EQU     .27
K3      EQU     .21
K4      EQU     .23
K5      EQU     .24
K6      EQU     .0
K7      EQU     .45
;
;*************************************************************************

