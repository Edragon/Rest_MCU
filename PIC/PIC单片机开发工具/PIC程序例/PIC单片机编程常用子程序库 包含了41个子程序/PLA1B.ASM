;********************************************************************** 
; pla1b.asm :  
; This procedure implements a simple AND-OR PLA with: 
; 
;      8  inputs        := A7 A6 A5 A4 A3 A2 A1 A0 
;      24 product terms := P23 P22 ..... P0 
;      8  outputs       := Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 
; 
; The eight inputs are assumed to be connected to PORT RB such that 
; RB0 = A0, RB1 = A1, ... , RB7 = A7.
; The outputs are programmed to appear on port RC such that
; RC0 = Y0, RC1 = Y1, ... , RC7 = Y7.
;
; This implementation optimizes program memory usage over
; speed
;********************************************************************** 
;
; define RAM locations used:
;
input           equ     d"12"   ; RAM location 12 holds input
Y_reg           equ     d"13"   ; holds output result

Preg_a          equ     d"14"   ; Product terms P0 to P7. Preg_a<0> = P0
Preg_b          equ     d"15"   ; Product terms P8 to P15. Preg_b<0> = P8
Preg_c          equ     d"16"   ; Product terms P16 to P23. Preg_c<0> = P16

Pn_x                    equ     d"18"   ;
Pn_a                    equ     d"19"   ;
OR_a                    equ     d"20"   ;
OR_b                    equ     d"21"   ;
OR_c                    equ     d"22"   ;

; define some constants and file addresses:
;
bit0                    equ     0               ;       
bit1                    equ     1               ;       
bit2                    equ     2               ;       
bit3                    equ     3               ;       
bit4                    equ     4               ;       
bit5                    equ     5               ;       
bit6                    equ     6               ;       
bit7                    equ     7               ;
;
status          equ     3               ;
port_b          equ     6               ;
port_c          equ     7               ;
;       
; define the AND plane programming variables:
;
P0_x            equ     b"00000000"     ;
P0_a            equ     b"00001111"     ; 
P1_x            equ     b"00000001"     ;
P1_a            equ     b"00001111"     ; 
P2_x            equ     b"00000010"     ;
P2_a            equ     b"00001111"     ; 
P3_x            equ     b"00000011"     ;
P3_a            equ     b"00001111"     ; 
P4_x            equ     b"00000100"     ;
P4_a            equ     b"00001111"     ; 
P5_x            equ     b"00000101"     ;
P5_a            equ     b"00001111"     ; 
P6_x            equ     b"00000110"     ;
P6_a            equ     b"00001111"     ; 
P7_x            equ     b"00000111"     ;
P7_a            equ     b"00001111"     ; 
P8_x            equ     b"00001000"     ;
P8_a            equ     b"00001111"     ; 
P9_x            equ     b"00001001"     ;
P9_a            equ     b"00001111"     ; 
P10_x   equ     b"00001010"     ;
P10_a   equ     b"00001111"     ; 
P11_x   equ     b"00001011"     ;
P11_a   equ     b"00001111"     ;
P12_x   equ     b"00001100"     ;
P12_a   equ     b"00001111"     ; 
P13_x   equ     b"00001101"     ;
P13_a   equ     b"00001111"     ; 
P14_x   equ     b"00001110"     ;
P14_a   equ     b"00001111"     ; 
P15_x   equ     b"00001111"     ;
P15_a   equ     b"00001111"     ; 
P16_x   equ     b"00000000"     ;
P16_a   equ     b"00000000"     ; 
P17_x   equ     b"00000000"     ;
P17_a   equ     b"00000000"     ; 
P18_x   equ     b"00000000"     ;
P18_a   equ     b"00000000"     ; 
P19_x   equ     b"00000000"     ;
P19_a   equ     b"00000000"     ; 
P20_x   equ     b"00000000"     ;
P20_a   equ     b"00000000"     ; 
P21_x   equ     b"00000000"     ;
P21_a   equ     b"00000000"     ; 
P22_x   equ     b"00000000"     ;
P22_a   equ     b"00000000"     ; 
P23_x   equ     b"00000000"     ;
P23_a   equ     b"00000000"     ; 

; define OR plane programming variables:

OR_a0   equ     b"11101101"     ; for output Y0
OR_b0   equ     b"11010111"     ;
OR_c0   equ     b"00000000"     ;
OR_a1   equ     b"10011111"     ; for output Y1
OR_b1   equ     b"00100111"     ;
OR_c1   equ     b"00000000"     ;
OR_a2   equ     b"11111011"     ; for output Y2
OR_b2   equ     b"00101111"     ;
OR_c2   equ     b"00000000"     ;
OR_a3   equ     b"01101101"     ; for output Y3
OR_b3   equ     b"01111001"     ;
OR_c3   equ     b"00000000"     ;
OR_a4   equ     b"01000101"     ; for output Y4
OR_b4   equ     b"11111101"     ;
OR_c4   equ     b"00000000"     ;
OR_a5   equ     b"01110001"     ; for output Y5
OR_b5   equ     b"11011111"     ;
OR_c5   equ     b"00000000"     ;
OR_a6   equ     b"01111100"     ; for output Y6
OR_b6   equ     b"11101111"     ;
OR_c6   equ     b"00000000"     ;
OR_a7   equ     b"00000000"     ; for output Y7
OR_b7   equ     b"00000000"     ;
OR_c7   equ     b"00000000"     ;


		org             01ffh   ;
begin   goto            main            ;

		org             000h            ;
; define macro to evaluate 1 product (AND) term:
;
main            call            pla88   ;
		goto            main            ;
;

EVAL_P  MACRO   Preg_x,bit_n,Pn_x,Pn_a
		movf            input,W         ;
		xorlw   Pn_x            ;
		andlw   Pn_a            ;
		btfsc   status,bit2     ; skip if zero bit not set
		bsf             Preg_x,bit_n    ; product term = 1
		ENDM


; define macro to load OR term constants:
;
EVAL_Y  MACRO   OR_an,OR_bn,OR_cn,bit_n
		movlw   OR_an   ; load constants
		movwf   OR_a            ;
		movlw   OR_bn   ;
		movwf   OR_b            ;
		movlw   OR_cn   ;
		movwf   OR_c            ;
		call            EVAL1   ;
		btfss   status,bit2     ;
		bsf             Y_reg,bit_n     ;
		ENDM

; define procedure to evaluate 1 output (OR) term:
;
EVAL1   movf            Preg_a,W        ;
		andwf   OR_a,1  ;

		movf            Preg_b,W        ;
		andwf   OR_b,1  ;

		movf            Preg_c,W        ;
		andwf   OR_c,W  ;

		iorwf   OR_a,W  ;
		iorwf   OR_b,W  ;
		retlw   0               ;  W = 1 implies Yn = 1

; now the  PLA evaluation procedure:
;
pla88   movlw   0ffh            ;
		tris            6               ; port_b = input
		movf            port_b,W        ; read input
		movwf   input   ; store input in a register
		clrf            Preg_a  ; clear Product register a
		clrf            Preg_b  ; clear Product register b
		clrf            Preg_c  ; clear Product register c
		clrf            Y_reg   ; clear output register

and_pl  EVAL_P  Preg_a,bit0,P0_x,P0_a
		EVAL_P  Preg_a,bit1,P1_x,P1_a
		EVAL_P  Preg_a,bit2,P2_x,P2_a
		EVAL_P  Preg_a,bit3,P3_x,P3_a
		EVAL_P  Preg_a,bit4,P4_x,P4_a
		EVAL_P  Preg_a,bit5,P5_x,P5_a
		EVAL_P  Preg_a,bit6,P6_x,P6_a
		EVAL_P  Preg_a,bit7,P7_x,P7_a

		EVAL_P  Preg_b,bit0,P8_x,P8_a
		EVAL_P  Preg_b,bit1,P9_x,P9_a
		EVAL_P  Preg_b,bit2,P10_x,P10_a
		EVAL_P  Preg_b,bit3,P11_x,P11_a
		EVAL_P  Preg_b,bit4,P12_x,P12_a
		EVAL_P  Preg_b,bit5,P13_x,P13_a
		EVAL_P  Preg_b,bit6,P14_x,P14_a
		EVAL_P  Preg_b,bit7,P15_x,P15_a

		EVAL_P  Preg_c,bit0,P16_x,P16_a
		EVAL_P  Preg_c,bit1,P17_x,P17_a
		EVAL_P  Preg_c,bit2,P18_x,P18_a
		EVAL_P  Preg_c,bit3,P19_x,P19_a
		EVAL_P  Preg_c,bit4,P20_x,P20_a
		EVAL_P  Preg_c,bit5,P21_x,P21_a
		EVAL_P  Preg_c,bit6,P22_x,P22_a
		EVAL_P  Preg_c,bit7,P23_x,P23_a

or_pl   EVAL_Y          OR_a0,OR_b0,OR_c0,bit0
		EVAL_Y          OR_a1,OR_b1,OR_c1,bit1
		EVAL_Y          OR_a2,OR_b2,OR_c2,bit2
		EVAL_Y          OR_a3,OR_b3,OR_c3,bit3
		EVAL_Y          OR_a4,OR_b4,OR_c4,bit4
		EVAL_Y          OR_a5,OR_b5,OR_c5,bit5
		EVAL_Y          OR_a6,OR_b6,OR_c6,bit6
		EVAL_Y          OR_a7,OR_b7,OR_c7,bit7

; Y_reg now contains 8 output values:
wr_out  clrw                                    ;
		tris            7                       ; port_c = output
		movf            Y_reg,W         ;
		movwf   port_c          ; Y_reg -> port_c
		retlw   0                       ;

ZZZ             nop             

	END
