;**************************  PIC16C5X Header    *************************
PIC54   equ     1FFH    ; Define Reset Vectors
PIC55   equ     1FFH
PIC56   equ     3FFH
PIC57   equ     7FFH
;
RTCC    equ     1
PC      equ     2
STATUS  equ     3       ; F3 Reg is STATUS Reg.
FSR     equ     4
;
Port_A  equ     5
Port_B  equ     6       ; I/O Port Assignments
Port_C  equ     7
;
;*************************************************************************
;
;                       ; STATUS REG. Bits
CARRY   equ     0       ; Carry Bit is Bit.0 of F3
C       equ     0
DCARRY  equ     1
DC      equ     1
Z_bit   equ     2       ; Bit 2 of F3 is Zero Bit
Z       equ     2
P_DOWN  equ     3
PD      equ     3
T_OUT   equ     4
TO      equ     4
PA0     equ     5
PA1     equ     6
PA2     equ     7
;
Same    equ     1
W       equ     0
;
LSB     equ     0
MSB     equ     7
;
TRUE    equ     1
YES     equ     1
FALSE   equ     0
NO      equ     0
;
;*************************************************************************

