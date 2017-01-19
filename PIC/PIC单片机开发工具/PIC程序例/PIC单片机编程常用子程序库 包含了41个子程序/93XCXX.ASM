		TITLE        "R/W EEPROM"
LIST  P = 16C54
;Serial Eprom interface to PIC16C5X.
;REV 2.0        8/26/92.
;
;Define Equates:
;       
	PIC54   EQU     1FFH
;
PAGE
;
	ORG     0
START
	goto    main            ;run test program
;
PAGE
;
TRUE    EQU     1
FALSE   EQU     0
S93C46  EQU     FALSE
S93LC46 EQU     FALSE
S93C56  EQU     FALSE
S93LC56 EQU     FALSE
S93C66  EQU     TRUE
S93LC66 EQU     FALSE
wire3   equ     TRUE
org8    EQU     FALSE
;
IF      S93LC46
	IF      org8
	LC468   EQU     TRUE
	XC46    EQU     FALSE
	H16     EQU     FALSE
	H8      EQU     FALSE
	ELSE
	LC468   EQU     FALSE
	XC46    EQU     TRUE
	H16     EQU     FALSE
	H8      EQU     FALSE
	ENDIF
ELSE
ENDIF
IF      S93C46
	LC468   EQU     FALSE
	XC46    EQU     TRUE
	H16     EQU     FALSE
	H8      EQU     FALSE
ENDIF
IF      S93C56 + S93C66 + S93LC56 + S93LC66
	IF      org8
	H8      EQU     TRUE
	H16     EQU     FALSE
	LC468   EQU     FALSE
	XC46    EQU     FALSE
	ELSE
	H16     EQU     TRUE
	H8      EQU     FALSE
	LC468   EQU     FALSE
	XC46    EQU     FALSE
	ENDIF
ELSE
ENDIF



;********************************************************************
;*                      Register Assignments                        *
;********************************************************************

indir   equ     0       ;Use this register as source/destination
			;for indirect addressing.
pc      equ     2       ;PIC Program Counter.
status  equ     3       ;PIC Status Register.
fsr     equ     4       ;File Select Register.
serial  equ     5       ;Port used for 93CX6 control. 
			;The following four registers must be
			;located consecutively in memory.
cmd     equ     1a      ;This register contains the 4 bit
			;command op code for 93CX6 as follows:
			;bit 7 msb of command op code
			;bit 6 next bit of op code
			;bit 5 next bit of op code
			;bit 4 lsb of op code
			;bit 3 A8 of address in case of
			;56/66 in 8 bit mode.
addr    equ     1b      ;memory address of lower 7/8 bits
highb   equ     1c      ;Used in read/write routines to store the
			;upper byte of a 16 bit data word,
			;or the data in a 8 bit data word
lowb    equ     1d      ;Used in read/write routines to store the
			;lower byte of a 16 bit data word,
			;or not used in 8 bit data word.

cnthi   equ     1e      ;Used as the upper byte of a sixteen bit
			;loop counter in RDYCHK routine.
cnt     equ     1f      ;Used as the lower byte of a sixteen bit 
			;loop counter in RDYCHK routine, and 
			;elswhere as an eight bit counter.
temp_cmd equ    1e      ;doubles as a temp register for cmd        
temp_addr equ   1f      ;doubles as a temp register for addr

;********************************************************************
;*                      Bit Assignments                             *
;********************************************************************

carry   equ     0               ;Carry Flag of Status Register.
zflag   equ     2               ;Zero Flag of Status Register.

cs      equ     2               ;Port pin tied to CS on 93CX6.
din     equ     1               ;Port pin tied to DI on 93CX6.
dout    equ     1               ;Port pin tied to DO on 93CX6.
clock   equ     3               ;Port pin tied to CLK on 93CX6.

;********************************************************************
;*                      General Assignments                         *
;********************************************************************

no_err  equ     0               
error   equ     1               
tries   equ     20      ;After issuing a WRITE, ERASE, ERAL, or WRAL
			;command, the approximate number of machine
			;cycles X 256 to wait for the RDY status.
			;This value must be adjusted for operating
			;frequencies other than 4 MHz.

read    equ     b'10000000'     ;read command op code
write   equ     b'01000000'     ;write command op code
erase   equ     b'11000000'     ;erase command op code
ewen    equ     b'00110000'     ;erase enable command op code
ewds    equ     b'00000000'     ;erase disable command op code
eral    equ     b'00100000'     ;erase all command op code
wral    equ     b'00010000'     ;write all command op code

;********************************************************************
;*                      Macro Definitions                           *
;********************************************************************

sel     MACRO                   ;Selects the 93CX6 device.
	bsf     serial,cs       ;Chip Select (CS) = '1' to select
	ENDM                    ;the device                

dsel    MACRO                   ;De-select the 93CX6 device.
	bcf     serial,cs       ;Chip Select (CS) = '0' to de-select
				;the device.
	ENDM

strtbt  MACRO                   ;Issue the Start Bit to the 93CX6.
	bsf     serial,din      ;Start Bit = '1'.
	clkit                   ;Clock it out.
	ENDM

clkit   MACRO                   ;Clocks a serial data bit into or out
				;of the 93CX6 device.
	bsf     serial,clock    ;Clock (CLK) = '1'.

	nop             ;Adjust the number of nop instructions
			;between the assertion and de-assertion of
			;CLK in proportion to the PIC operating
			;frequency.  Refer to the 93CX6 data for the
			;minimum CLK period.
				
	bcf     serial,clock    ;Clock (CLK) = '0'.
	ENDM
;
PAGE
;********************************************************************
;*                      DOUTx                                       *
;********************************************************************
;doutxx, outputs up to 11 bits of op code/data, depending on whether
;a 46/56/66 serial eeprom is being used. The number of bits over 8 are
;saved in the cmd register and the rest in the addr register. Before
;calling this routine the cmd and the addr registers should be loaded
;as follows:
;cmd reg.bits 7|6|5|4|3|2|1|0
;--------------|-|-|-|-|-|-|-|
;             X|X|X|X|X|X|X|Y| --> not used
;             X|X|X|X|X|X|Y|X| --> mot used
;             X|X|X|X|X|Y|X|X| --> not used
;             X|X|X|X|Y|X|X|X| --> 9th bit of address if necessary
;             X|X|X|Y|X|X|X|X| --> lsb of command op code
;             X|X|Y|X|X|X|X|X| --> 3rd bit of command op code
;             X|Y|X|X|X|X|X|X| --> 2nd bit of command op code
;             Y|X|X|X|X|X|X|X| --> msb of command op code
;
;addr reg. 6/7/8 bits of address if necessary.

IF      H8
dout11
	bcf     serial,din
	rlf     indir           ;rotate thru carry
	btfsc   status,carry    ;set?        
	bsf     serial,din      ;yes, set output to 1
	clkit                   ;clk data
ENDIF
IF      H16+H8
dout10
	rlf     indir           ;rotate thru carry
	bcf     serial,din      ;set output to 0
	btfsc   status,carry    ;set?
	bsf     serial,din      ;else set output to 1
	clkit                   ;clk data
ENDIF
IF      H8+H16+LC468
dout9
	rlf     indir           ;rotate thru carry
	bcf     serial,din      ;set output to 0
	btfsc   status,carry    ;set?
	bsf     serial,din      ;else set output to 1
	clkit                   ;clk data
	incf    fsr             ;inc pointer
ENDIF
dout8
	movlw   8               ;Initialize loop counter.
	movwf   cnt             
;
d_o_8   bcf     serial,din      ;Assume that the bit to be transfered is a
				;'0'.  Hence, de-assert DI.
	rlf     indir           ;Rotate the actual bit to be transferred into
				;the carry bit.
	btfsc   status,carry    ;Test the carry, if our assumption was
				;correct, skip the next instruction.
	bsf     serial,din      ;No, actual bit was a '1'.  Assert DI.
	clkit                   ;Clock the 93CX6.
	decfsz  cnt             ;Repeat until cnt = 0.
	goto    d_o_8           ;Cnt still > 0.
	rlf     indir           ;Restore register to its original condition.
	bcf     serial,din      ;make sure din is low        
	retlw   no_err          ;Exit with good status.

;********************************************************************
;*                      DIN8                                        *
;********************************************************************
				;Din8 will input 8 bits of data from the
				;93CX6.  Before calling this routine, the FSR
				;must point to the register being used to
				;hold the incomming data.
din8    
IF      wire3
;set up the RA1 as a input before proceeding        
	movlw   b'00000010'     ;set up porta
	tris    serial          ;
ENDIF
	movlw   8               ;Initialize loop counter.
	movwf   cnt             ;

d_i_8   
	rlf     indir           ;Make room for the incomming bit in the
				;destination register.
	bcf     indir,0         ;Assume that the incomming bit is a '0' and
				;clear the LSB of the destination register.
	clkit                   ;Clock a bit in the 93CX6.
	btfsc   serial,dout     ;Test the incomming bit, if our assumption
				;was correct, skip the next instruction.
	bsf     indir,0         ;No, actual bit is a '1'.  Set the LSB of the
				;destination register.
	decfsz  cnt             ;Repeat until cnt = 0.
	goto    d_i_8           ;Cnt still > 0.
IF      wire3
;setup RA1 back to output
	movlw   0               ;set RA1 as output
	tris    serial          ;      / 
ENDIF
	retlw   no_err          ;Exit with good status.

;********************************************************************
;*                      RDYCHK                                      *
;********************************************************************
				;Rdychk will read the 93CX6 READY/BUSY status
				;and wait for RDY status within the alloted
				;number of processor cycles.  If RDY status
				;is not present after this set period, the
				;routine will return with an error status.

rdychk  
IF      wire3
;set up RA1 as a input before proceeding        
	movlw   b'00000010'     ;set up porta
	tris    serial          ;
ENDIF
	movlw   tries           ;Initialize time-out counter.
	movwf   cnthi           ;
	clrf    cnt             ;
	dsel                    ;De-select the 93CX6.

;       nop                     ;NOTE:  Check the 93CX6 data sheet for
				;minimum CS low time.  Depending upon
				;processor frequency, a nop(s) may be
				;between the assertion and de-assertion of
				;Chip Select.

	sel                     ;Re-select the 93CX6.
notrdy  btfsc   serial,dout     ;If DO is a '0', 93CX6 has yet to completed
				;the last operation (still busy).
	goto    rdynoerr        ;skip to no error
	decfsz  cnt             ;No, not yet ready.  Decrement the LSB of our
				;16 bit timer and check for expiration.
	goto    notrdy          ;Still some time left.  Try again.
	decfsz  cnthi           ;Least significant byte expired - decrement
				;and check for expiration of the MSB.
	goto    notrdy          ;Still some time left.  Try again.
IF      wire3
;setup RA1 back to output
	movlw   0               ;set RA1 as output
	tris    serial          ;      / 
ENDIF
	retlw   error           ;RDY status was not present in the alloted
				;time, return with error status.
rdynoerr
IF      wire3
;setup RA1 back to output
	movlw   0               ;set porta as output
	tris    serial          ;      / 
ENDIF
	retlw   no_err

;********************************************************************
;*                      SEE                                         *
;********************************************************************

				;See will control the entire operation of a
				;93CX6 device.  Prior to calling the routine,
				;load a valid command/memory address into
				;location cmd, and for WRITE or WRAL
				;commands, load registers highb and lowb with
				;16 bits of write data.  Upon exit, the W
				;register will contain the completion status.
				;Only 93CX6 instructions which require a
				;status check can return with an error as the
				;completion status.  The values that denote
				;the completion status are defined as
				;variables 'error' and 'no_err' in the
				;general assignments section.

see     
	movf    cmd,w           ;save cmd
	movwf   temp_cmd
	movf    addr,w          ;save addr
	movwf   temp_addr       ;
	movlw   cmd             ;Load W with the location of the cmd
				;register.
	movwf   fsr             ;Transfer that information into the File
				;Select Register.  The fsr now points to
				;location cmd.
	sel                     ;Select the 93CX6.
	strtbt                  ;Send a start bit.
;
	btfsc   cmd,7           ;bit 7 = 0?
IF      XC46
	goto    sca8            ;xfer 8 bit cmd/adr
ENDIF
IF      LC468
	goto    sca9            ;xfer 9 bit cmd/adr
ENDIF
IF      H16     
	goto    sca10           ;xfer 10 bit cmd/adr
ENDIF
IF      H8
	goto    sca11           ;xfer 11 bit cmd/adr
ENDIF

;        goto    set_cmd_addr    ;no then set cmd/addr
	btfss   cmd,6           ;bit 6 = 0 ?   
IF      XC46
	goto    sc8             ;xfer 8 bit cmd/adr
ENDIF
IF      LC468
	goto    sc9             ;xfer 9 bit cmd/adr
ENDIF   
IF      H16     
	goto    sc10            ;xfer 10 bit cmd/adr
ENDIF
IF      H8
	goto    sc11            ;xfer 11 bit cmd/adr
ENDIF
;        goto    set_cmd         ;yes then set cmd
IF      XC46
	goto    sca8            ;xfer 8 bit cmd/adr
ENDIF
IF      LC468
	goto    sca9            ;xfer 9 bit cmd/adr
ENDIF
IF      H16     
	goto    sca10           ;xfer 10 bit cmd/adr
ENDIF
IF      H8
	goto    sca11           ;xfer 11 bit cmd/adr
ENDIF

;        goto    set_cmd_addr    ;else set cmd/addr
see1
	movf    temp_cmd,w      ;retore cmd     
	movwf   cmd             ;       /
	movf    temp_addr,w     ;restore addr
	movwf   addr            ;       /
	btfsc   cmd,6           ;Check for a WRITE or ERASE command.
	goto    see2            ;Yes, parse the command further.
	btfsc   cmd,7           ;Check for a READ command.
	goto    read_           ;Yes, process READ command.
	btfsc   cmd,5           ;Check for a EWEN or ERAL command.
	goto    see3            ;Yes, parse the command further.
	btfsc   cmd,4           ;Check for a WRAL command.
	goto    write_          ;Yes, process WRITE/WRAL command.

exit_   dsel                    ;No further processing required; 93CX6
				;command completed.
;
	retlw   no_err          ;Return with good completion status.

see2    btfss   cmd,7           ;Check for a ERASE command.
	goto    write_          ;No, process WRITE command.
exit2_  call    rdychk          ;ERASE command requires a status check.
	dsel                    ;De-select the 93CX6.
	addwf   pc              ;Compute completion status from results of
				;status check.
	retlw   no_err          ;Return with good completion status.
	retlw   error           ;Return with bad completion status.

see3    btfsc   cmd,4           ;Check for a EWEN command.
	goto    exit_           ;Yes, no further processing required, exit
				;now.
	goto    exit2_          ;No, ERAL command which requires a status
				;check.

read_   incf    fsr             ;Increment the File Select Register to point
				;to the register receiving the upper byte of
				;the incomming 93CX6 data word.
	call    din8            ;Input the upper byte.
IF      org8
ELSE
	incf    fsr             ;Increment the File Select Register to point
				;to the register receiving the lower byte.
	call    din8            ;Input 8 more bits.
ENDIF
	goto    exit_           ;No further processing required, exit now.

write_  incf    fsr             ;Increment the File Select Register to point
				;to the upper byte of the 16 bit 93CX6 data
				;word to be transmitted.
	call    dout8           ;Output that byte.
IF      org8
ELSE
	incf    fsr            ;Increment the File Select Register to point
			       ;to the lower byte.
	call    dout8          ;Output the lower byte of the 16 bit 93CX6
			       ;data word.
ENDIF
	goto    exit2_          ;Exit with a status check.

;
;
IF      XC46
sca8
	movlw   b'11000000'     ;clr all but hi 2
	andwf   cmd,w           ;save in w
	iorwf   addr            ;mask in addr.
	incf    fsr             ;inc FSR
	call    dout8           ;output
	goto    see1            ;return
ENDIF
IF      LC468
;
sca9
	bcf     addr,7          ;clr hi of addr
	btfsc   cmd,6           ;xfer cmd's bit 6
	bsf     addr,7          ;to addr's bit 7
	call    dout9           ;output
	goto    see1            ;return
ENDIF
IF      H16
;
sca10   
	call    dout10          ;output cmd reg
	goto    see1            ;return
ENDIF                
;
IF      H8
sca11
	bcf     cmd,5           ;xfer cmd's bit 3 to
	btfsc   cmd,3           ;cmd's bit 5
	bsf     cmd,5           ;       /
	call    dout11          ;output
	goto    see1            ;return
;
ENDIF
;
;
;
IF      XC46
sc8
	movf    cmd,w           ;get command
	movwf   addr            ;save in addr
	incf    fsr             ;inc pointer
	call    dout8           ;output
	goto    see1            ;return
;
ENDIF
IF      LC468
sc9     
	rlf     cmd,w           ;rotate cmd left
	movwf   addr            ;save in addr
	call    dout9           ;xfer 9 bits
	goto    see1            ;return
ENDIF
IF      H16
;
sc10    
	rlf     cmd             ;rotate cmd
	rlf     cmd,w           ;left twice
	movwf   addr            ;save in addr
	clrf    cmd             ;clear command
	call    dout10          ;xfer 10 bits
	goto    see1            ;return
ENDIF
;
IF      H8
sc11
	bcf     addr,7          ;xfer cmd's bit 4
	btfsc   cmd,4           ;to addr's bit 7
	bsf     addr,7          ;       /
	call    dout11          ;xfer 11 bits
	goto    see1            ;return
ENDIF
;********************************************************************
;*                      Test Program                                *
;********************************************************************
	main                    ;We've include a sample program to exercise
				;the PIC to 93C66 interface using a simple
				;erase, write and verify routine.
				;8 bit organization has been used
				;with a 3 wire interface.
	
	clrf    serial          ;Clear the port tied to the 93C66 device.
	movlw   b'11110000'     ;Intialize the data direction register for
	tris    serial          ;that port.
	
	movlw   ewen            ;Load W with the Erase/Write Enable command.
	movwf   cmd             ;Transfer W into cmd register.
	call    see             ;Enable the 93C66 device.

	movlw   eral            ;Load W with the Erase All command.
	movwf   cmd             ;Transfer W into cmd register.
	call    see             ;Erase the 93C66.
	xorlw   error           ;Check completion status.
	btfsc   status, zflag   ;Test for error condition.
	goto    errloop         ;Yes, bad completion status, error-out.

				;Write loop:
tstptrn equ     0xAA            ;Define the test pattern to be written.

	movlw   write           ;Load W with the Write command.
	movwf   cmd             ;Transfer W into cmd register.
	movlw   tstptrn         ;Intialize the 93C66 data registers with
				;write data.
	movwf   highb           ;load in high byte only
				;since 8 bit low byte is ignored
	clrf    addr            ;start at addr 0
test1   call    see             ;Write data word into 93C66 device.
	xorlw   error           ;Check completion status.
	btfsc   status,zflag    ;Test for error condition.
	goto    errloop         ;Yes, bad completion status, error-out.
	incfsz  addr            ;No, increment the 8 bit memory address
				;field.
	goto    test1           ;write another location
	btfss   cmd,3           ;see if all done
	goto    wrt_nxt_pg      ;no then write next page
	goto    read_tst        ;read written data
wrt_nxt_pg
	bsf     cmd,3           ;set page bit
	goto    test1           ;No, write another location.

				;Read loop:
read_tst
	movlw   read            ;Load W with the Read command.
	movwf   cmd             ;Transfer W into cmd register.
test2   call    see             ;Read addressed data word from 93C66 device.
	movlw   tstptrn         ;Load W with the pattern written.
	subwf   highb,w         ;Verify the data read against what was
				;written.
	btfss   status,zflag    ;Same?
	goto    errloop         ;No, error-out.
	incfsz  addr            ;Yes, both byte correct, increment the 8 bit
				;memory address field.
	goto    test2           ;do next byte
	btfss   cmd,3           ;check page bit
	goto    rd_nxt_pg       ;no then chk next page
	goto    allok           ;all done!!!
rd_nxt_pg
	bsf     cmd,3           ;set page bit
	goto    test2           ;No, read another location.

allok   goto    allok           ;Home safe!
;
;
errloop
	goto    errloop
;
;
;
;KEY DEFINITIONS
;
	ORG     PIC54
SYS_RESET
	GOTO    START
;
	END



