;                       RS-232 Communication With PIC16C54
;
;        Half Duplex Asynchronous Communication
;
;        This program has been tested at Bauds from 1200 to 19200 Baud
;        ( @ 8,16,20 Mhz CLKIN )
;
;       As a test, this program will echo back the data that has been
;       received.
;
;
	INCLUDE         "PICREG.H"
;*****************  Communication Parameters   **************************
;
X_MODE  equ     1       ; If ( X_MODE==1) Then transmit LSB first
;                         if ( X_MODE==0) Then transmit MSB first ( CODEC like )
R_MODE  equ     1       ; If ( R_MODE==1) Then receive LSB first
;                         if ( X_MODE==0) Then receive MSB first ( CODEC like )
X_Nbit  equ     1       ; if (X_Nbit==1) # of data bits ( Transmission ) is 8 else 7
R_Nbit  equ     1       ; if (R_Nbit==1) # of data bits ( Reception ) is 8 else 7
;
Sbit2   equ     0       ; if Sbit2 = 0 then 1 Stop Bit else 2 Stop Bits
;
;*************************************************************************
X_flag  equ     PA0     ; Bit 5 of F3 ( PA0 )
R_flag  equ     PA1     ; Bit 6 of F3 ( PA1 )
;
DX      equ     0       ; Transmit Pin ( Bit 0 of Port A )
DR      equ     1       ; Reciive Pin ( Bit 1 of Port A )
;
;
BAUD_1  equ     .68     ; 3+3X = CLKOUT/Baud
BAUD_2  equ     .67     ; 6+3X = CLKOUT/Baud
BAUD_3  equ     .34     ; 3+3X = 0.5*CLKOUT/Baud
BAUD_4  equ     .86     ; 3+3X = 1.25*CLKOUT/Baud
BAUD_X  equ     .66     ; 11+3X = CLKOUT/Baud
BAUD_Y  equ     .66     ; 9 +3X = CLKOUT/Baud
;
;************************  Data RAM Assignments  **********************
;
	ORG     08H     ; Dummy Origin
;
RcvReg  RES     1      ; Data received
XmtReg  RES     1      ; Data to be transmitted
Count   RES     1      ; Counter for #of Bits Transmitted
DlyCnt  RES     1
;***********************************************************************
;
	ORG     0
;
Talk    clrf    RcvReg          ; Clear all bits of RcvReg
	btfsc   Port_A,DR       ; check for a Start Bit
	goto    User            ; delay for 104/2 uS
	call    Delay4          ; delay for 104+104/4
;***************************************************************
;       Receiver
;
Rcvr
	IF      R_Nbit
	movlw   8               ; 8 Data bits
	ELSE
	movlw   7               ; 7 data bits
	ENDIF
;
	movwf   Count
R_next  bcf     STATUS,CARRY
	IF      R_MODE
	rrf     RcvReg,Same     ; to set if MSB first or LSB first
	ELSE
	rlf     RcvReg,Same
	ENDIF
	btfsc   Port_A,DR
;
	IF      R_MODE
	  IF      R_Nbit
	  bsf     RcvReg,MSB       ; Conditional Assembly
	  ELSE
	  bsf     RcvReg,MSB-1
	  ENDIF
	ELSE
	bsf     RcvReg,LSB
	ENDIF
;
	call    DelayY
	decfsz  Count,Same
	goto    R_next
;****************************************************
R_over  movf    RcvReg,0        ; Send back What is Just Received
	movwf   XmtReg
;****************************************************
;       Transmitter
;
Xmtr
	IF      X_Nbit
	movlw   8
	ELSE
	movlw   7
	ENDIF
	movwf   Count
;
	IF      X_MODE
	ELSE
	  IF    X_Nbit
	  ELSE
	  rlf   XmtReg,Same
	  ENDIF
	ENDIF
;
	bcf     Port_A,DX       ; Send Start Bit
	call    Delay1
X_next  bcf     STATUS,CARRY
;
	IF      X_MODE
	rrf     XmtReg,Same     ; Conditional Assembly
	ELSE                    ; to set if MSB first or LSB first
	rlf     XmtReg,Same
	ENDIF
;
	btfsc   STATUS,CARRY
	bsf     Port_A,DX
	btfss   STATUS,CARRY
	bcf     Port_A,DX
	call    DelayX
	decfsz  Count,Same
	goto    X_next
	bsf     Port_A,DX       ; Send Stop Bit
	call    Delay1
;
	IF      Sbit2
	bsf     Port_A,DX
	call    Delay1
	ENDIF
;
	goto    Talk            ; Back To Reception & Transmision
;
;   End of Transmission
;
DelayY  movlw   BAUD_Y
	goto    save
DelayX  movlw   BAUD_X
	goto    save
Delay4  movlw   BAUD_4
	goto    save
Delay1  movlw   BAUD_1            ; 104 uS for 9600 baud
	goto    save
Delay2  movlw   BAUD_2
save    movwf   DlyCnt
redo_1  decfsz  DlyCnt,Same
	goto    redo_1
	retlw   0
;
main    movlw   0EH             ; Bit 0 of Port A is Output
	tris    Port_A          ; Set Port_A.0 as output ( DX )
	bsf     Port_A,DR
;
	goto    Talk
;
;
User    movlw   BAUD_3
	movwf   DlyCnt
redo_2  decfsz  DlyCnt,Same
	goto    redo_2
	goto    Talk            ; Loop Until Start Bit Found
;
;
	ORG     PIC54
	goto    main
;
	END
