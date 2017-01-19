;*************************************************************************
	TITLE   "RS232 Communication Using PIC16C54"
;
;    Comments :
;               (1) Full Duplex
;               (2) Tested from 1200 to 9600 Baud( @ 8 Mhz )
;               (3) Tested from 1200 to 19200 Baud(@ 16 & 20 Mhz)
;
;       The User gets a total time as specified by the User Cycles
;       in the table ( or from equations ). The user routine has to
;       exactly use up this amount of time. After this time the User
;       routine has to give up the control to the Operating System.
;       If less than 52 uS is used, then the user should wait in a
;       delay loop, until exactly 52 uS.
;
;       Transmission :
;               Transmit Data is output on DX pin (Bit DX of Port_A).
;               In the user routine, the user should load the
;               data to be transmitted in the XmtReg and Set the
;               X_flag ( bsf FlagRX,X_flag ). This flag gets cleared
;               after the transmission.
;
;       Reception :
;               Data is received on pin DR ( bit DR of Port_A ).
;               The User should constantly check the "R_done" flag
;               to see if reception is over. If the reception is
;               in progress, R_flag is set to 1.
;               If the reception is over, "R_done" flag is set to 1.
;               The "R_done" flag gets reset to zero when a next start
;               bit is detected. So, the user should constantly check
;               the R_done flag, and if SET, then the received word
;               is in Register "RcvReg". This register gets cleared
;               when a new start bit is detected.
;
;    Program Memory :
;       Total Program Memory Locations Used ( except initialization
;       in "main" & User routine ) = 132 locations.
;
;    Data Memory :
;       Total Data memory locations (file registers used) = 6
;               2 File registers to hold Xmt Data & Rcv Data
;               1 File registers for Xmt/Rcv flag test bits
;               3 File registers for delay count & scratch pad
;
;    Stack :
;       Only one level of stack is used in the Operating System/RS232
;       routine. But this is freed as soon as the program returns to the
;       user routine.
;
;    RTCC :     Not Used
;    WDT  :     Not Used
;
	INCLUDE         "PICREG.H"
	INCLUDE         "RS232.H"
;
	ORG     0
;*************************************************************************
;
Delay   movlw   K0+1
	movwf   DlyCnt          ; Total Delay = 3K+6
redo    decfsz  DlyCnt,Same
	goto    redo
	retlw   0
;
Delay1  movwf   DlyCnt
redo_1  decfsz  DlyCnt,Same     ;
	goto    redo_1
	goto    User
;
Delay2  movwf   DlyCnt
redo_2  decfsz  DlyCnt,Same     ; Delay =   = 260 Cycles
	goto    redo_2
	goto    User_1
;
R_strt  btfsc   Port_A,DR       ; check for a Start Bit
	goto    ShellY          ; delay for 104/2 uS
	bcf     FlagRX,R_done   ; Reset Receive done flag
	bsf     FlagRX,R_flag   ; Set flag for Reception in Progress
	btfss   FlagRX,BitXsb
	bsf     FlagRX,A_flag   ; A_flag is for start bit detected in R_strt
	clrf    RcvReg          ; Clear all bits of RcvReg
	IF      R_Nbit
	movlw   8               ; 8 Data bits
	ELSE
	movlw   7               ; 7 data bits
	ENDIF
	movwf   Rcount
	goto    Shell           ; delay for 104+104/4
;
ShellY  btfss   FlagRX,BitXsb
	goto    Shell
	bsf     FlagRX,R_flag
	goto    Shell
;
R_next  bcf     STATUS,CARRY
	IF      R_MODE
	rrf     RcvReg,Same     ; to set if MSB first or LSB first
	ELSE
	rlf     RcvReg,Same
	ENDIF
	btfsc   Port_A,DR
	IF      R_MODE
	  IF      R_Nbit
	  bsf     RcvReg,MSB       ; Conditional Assembly
	  ELSE
	  bsf     RcvReg,MSB-1
	  ENDIF
	ELSE
	bsf     RcvReg,LSB
	ENDIF
	decfsz  Rcount,Same
	goto    Shell
	bcf     FlagRX,R_flag
	bsf     FlagRX,S_flag
	bsf     FlagRX,R_done
	goto    Shell
;
;       Reception Done
;
X_strt  bcf     Port_A,DX       ; Send Start Bit
	IF      X_Nbit
	movlw   8
	ELSE
	movlw   7
	ENDIF
	movwf   Xcount
	IF      X_MODE
	ELSE
	  IF    X_Nbit
	  ELSE
	  rlf   XmtReg,Same
	  ENDIF
	ENDIF
	goto    X_SB
;
X_next  bcf     STATUS,CARRY
	IF      X_MODE
	rrf     XmtReg,Same     ; Conditional Assembly
	ELSE                    ; to set if MSB first or LSB first
	rlf     XmtReg,Same
	ENDIF
	btfsc   STATUS,CARRY
	bsf     Port_A,DX
	btfss   STATUS,CARRY
	bcf     Port_A,DX
	decf    Xcount,Same
	goto    X_Data
;
X_SB_1  bcf     FlagRX,X_flag   ; Xmt flag = 0 -- transmission over
	movlw   9
	movwf   Xcount
	bsf     Port_A,DX       ; Send Stop Bit
	goto    X_Stop
;
X_SB_2  bsf     Port_A,DX
	bcf     FlagRX,S_bit
	goto    X_Stop
;
;   End of Transmission
;
R0_X0   btfss   FlagRX,S_flag
	goto    User
	bcf     FlagRX,S_flag
	call    Delay
	movlw   K7+1
	goto    Delay1
;
R1_X0
	call    Delay
	movlw   K1+1            ; delay for 1st bit is 104+104/4
	movwf   DlyCnt
	IF      R_Nbit
	movlw   8               ; 8 Data bits
	ELSE
	movlw   7               ; 7 data bits
	ENDIF
	xorwf   Rcount,W
	btfsc   STATUS,Z_bit
	goto    redo_1
	movlw   K2+1
	goto    Delay1
;
R1_X1                           ; same as R0_X1
R0_X1   movlw   9
	subwf   Xcount,W
	btfsc   STATUS,Z_bit
	goto    X_strt
	movf    Xcount,Same     ; to check if All data bits Xmted
	btfss   STATUS,Z_bit
	goto    X_next
	IF      SB2
	  btfsc FlagRX,S_bit
	  goto  X_SB_2
	  bsf   FlagRX,S_bit
	  goto  X_SB_1
	ELSE
	  goto    X_SB_1
	ENDIF
;
;
X_SB    goto    cycle4
cycle4  goto    X_Data
;
X_Data  btfsc   FlagRX,A_flag
	goto    SbDly
	btfsc   FlagRX,BitXsb
	goto    ABC
	call    Delay
	movlw   K3+1
	goto    Delay2
;
SbDly   bcf     FlagRX,A_flag
	call    Delay
	movlw   K4+1
	goto    Delay2
;
ABC     bcf     FlagRX,BitXsb
	call    Delay
	goto    User_1
;
X_Stop
	btfsc   FlagRX,A_flag
	goto    SbDly
	btfsc   FlagRX,BitXsb
	goto    ABC
	call    Delay
	movlw   K5+1
	goto    Delay2
;
User_1  btfsc   FlagRX,R_flag
	goto    Sync_1          ; Reception already in progress
	btfsc   FlagRX,S_flag
	goto    Sync_3
	btfsc   Port_A,DR       ; check for a Start Bit
	goto    Sync_2          ; No Start Bit - goto User routine
	bcf     FlagRX,R_done   ; Reset Receive done flag
	bcf     FlagRX,R_flag
	bsf     FlagRX,BitXsb   ; Set flag for Reception in Progress
	clrf    RcvReg          ; Clear all bits of RcvReg
	IF      R_Nbit
	movlw   8               ; 8 Data bits
	ELSE
	movlw   7               ; 7 data bits
	ENDIF
	movwf   Rcount
	goto    User
;
Sync_3  bcf     FlagRX,S_flag
	movlw   K6+1
	goto    Delay1
;
Sync_1
Sync_2  goto    User
;
;*************************************************************************
;
Shell   btfsc   FlagRX,R_flag
	goto    Chek_X
	btfsc   FlagRX,X_flag
	goto    R0_X1
	goto    R0_X0            ; Case for R0_X0
Chek_X  btfsc   FlagRX,X_flag
	goto    R1_X1
	goto    R1_X0
;
;
;*************************************************************************
;       Operating System
;  The User routine after time = B/2, should branch Here
;
Op_Sys  btfss   FlagRX,R_flag
	goto    R_strt
	goto    R_next
;
;*************************************************************************
;
main    movlw   0EH             ; Bit 0 of Port A is Output
	tris    Port_A          ; Set Port_A.0 as output ( DX )
;                                 & Port_A.1 is input ( DR )
	bsf     Port_A,DX
	movlw   9
	movwf   Xcount          ; If Xcount == 9, Then send start bit
	clrf    FlagRX          ; Clear All flag bits.
	IF      SB2
	  bsf     FlagRX,S_bit    ; Set Xmt Stop bit flag(2 Stop Bits)
	ELSE
	  bcf     FlagRX,S_bit    ; Clear Xmt Stop bit flag
	ENDIF
	movlw   1FH               ; Prescaler = 4
	OPTION                    ; Set RTCC increment on internal Clock
	goto    Op_Sys
;
;*************************************************************************
;
;       *******************  User Routine  ***************
;  The User routine should use up time exactly = User time as given
;  in the Constants Table ( or by Equations for constants ).
;  At 9600, this 86 Clock Cycles. RTCC timer is used here to count
;  upto 86 cycles ( From 128-86 To 0 ) by examining Bit 7 of RTCC.
;
K_user  equ     .128+.6-.86
;
User    movlw   K_user
	movwf   RTCC
	btfsc   FlagRX,R_done
	goto    ErrChk
SetXmt  btfsc   FlagRX,X_flag
	goto    Op
	movlw   41H
	movwf   XmtReg
	bsf     FlagRX,X_flag   ; Enable Xmission
	goto    Op
;
ErrChk
	movlw   "Z"
	xorwf   RcvReg,W
	btfsc   STATUS,Z_bit
	goto    SetXmt
error   goto    error           ; Received word is not "Z"
;
Op      btfss   RTCC,MSB        ; Test for RTCC bit 7
	goto    Op              ; If Set, Then RTCC has incremented
Oflow   goto    Op_Sys          ; to 128.
;
; ***********************************************************
;
	ORG     PIC54
	goto    main

	END

