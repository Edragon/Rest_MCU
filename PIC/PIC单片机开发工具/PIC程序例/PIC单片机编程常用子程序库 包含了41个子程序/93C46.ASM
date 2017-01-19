;********************************************************************
;*                      PICALC Directives Section                   *
;********************************************************************

	SUBTITL "93C46 3 WIRE INTERFACE ROUTINE"
	LIST     P=16C54,N=40,C=132


;********************************************************************
;*                      Register Assignments                        *
;********************************************************************

indir   equ     0x00            ;Use this register as source/destination for
				;indirect addressing.
pc      equ     0x02            ;PIC Program Counter.
status  equ     0x03            ;PIC Status Register.
fsr     equ     0x04            ;File Select Register.
serial  equ     0x05            ;Port used for 93C46 control.  Since Port A
				;is 4 bits wide, we'll use all of Port A.

				;The following three registers must be
				;located consecutively in memory.
cmd     equ     0x10            ;This register contains the 2 bit 93C46
				;command is the upper 2 bit positions and
				;memory address in the lower 6.
highb   equ     0x11            ;Used in read/write routines to store the
				;upper byte of a 16 bit 93C46 data word.
lowb    equ     0x12            ;Used in read/write routines to store the
				;lower byte of a 16 bit 93C46 data word.

cnthi   equ     0x13            ;Used as the upper byte of a sixteen bit loop
				;counter in RDYCHK routine.
cnt     equ     0x14            ;Used as the lower byte of a sixteen bit loop
				;counter in RDYCHK routine, and elsewhere as
				;an eight bit counter.

;********************************************************************
;*                      Bit Assignments                             *
;********************************************************************

carry   equ     0               ;Carry Flag of Status Register.
zflag   equ     2               ;Zero Flag of Status Register.

;For the 3 wire interface, connect the din and dout to the same
;i/o line of the PIC16C5X.
cs      equ     0               ;Port pin tied to CS on 93C46.
din     equ     1               ;Port pin tied to DI on 93C46.
dout    equ     1               ;Port pin tied to DO on 93C46.
clock   equ     2               ;Port pin tied to CLK on 93C46.

;********************************************************************
;*                      General Assignments                         *
;********************************************************************

no_err  equ     0               ;
error   equ     1               ;
tries   equ     0x04            ;After issuing a WRITE, ERASE, ERAL, or WRAL
				;command, the approximate number of machine
				;cycles X 256 to wait for the RDY status.
				;This value must be adjusted for operating
				;frequencies other than 4 MHz.

read    equ     0x80            ;93C46 Read command.
write   equ     0x40            ;93C46 Write command.
erase   equ     0xC0            ;93C46 Erase command.
ewen    equ     0x30            ;93C46 Erase/Write Enable command.
ewds    equ     0x00            ;93C46 Erase/Write Disable command.
eral    equ     0x20            ;92CXX Erase All command.
wral    equ     0x10            ;92CXX Write All command.

;********************************************************************
;*                      Macro Definitions                           *
;********************************************************************

sel     MACRO                   ;Selects the 93C46 device.
	bsf     serial,cs       ;Chip Select (CS) = '1' to select the device.
	ENDM

dsel    MACRO                   ;De-select the 93C46 device.
	bcf     serial,cs       ;Chip Select (CS) = '0' to de-select the
				;device.
	ENDM

strtbt  MACRO                   ;Issue the Start Bit to the 93C46.
	bsf     serial,din      ;Start Bit = '1'.
	clkit                   ;Clock it out.
	ENDM

clkit   MACRO                   ;Clocks a serial data bit into or out of the
				;93C46 device.
	bsf     serial,clock    ;Clock (CLK) = '1'.

	nop                     ;Adjust the number of nop instructions
				;between the assertion and de-assertion of
				;CLK in proportion to the PIC operating
				;frequency.  Refer to the 93C46 data for the
				;minimum CLK period.
				
	bcf     serial,clock    ;Clock (CLK) = '0'.
	ENDM

;********************************************************************
;*                      Power-On/Reset Entry Point                  *
;********************************************************************

reset_  org     0x1FF
	goto    main

;********************************************************************
;*                      93C46 Routines                              *
;********************************************************************
	org     0x000           ;Locate all subroutines in the lower half of
				;a Program Memory Page.

;********************************************************************
;*                      DOUT8                                       *
;********************************************************************
				;Dout8 will output 8 bits of data to the
				;93C46.  Before calling this routine, the FSR
				;must point to the byte being transmitted.

dout8   movlw   0x08            ;Initialize loop counter.
	movwf   cnt             ;

d_o_8   bcf     serial,din      ;Assume that the bit to be transfered is a
				;'0'.  Hence, de-assert DI.
	rlf     indir           ;Rotate the actual bit to be transferred into
				;the carry bit.
	btfsc   status,carry    ;Test the carry, if our assumption was
				;correct, skip the next instruction.
	bsf     serial,din      ;No, actual bit was a '1'.  Assert DI.
	clkit                   ;Clock the 93C46.
	decfsz  cnt             ;Repeat until cnt = 0.
	goto    d_o_8           ;Cnt still > 0.
	rlf     indir           ;Restore register to its original condition.
	retlw   no_err          ;Exit with good status.

;********************************************************************
;*                      DIN8                                        *
;********************************************************************
				;Din8 will input 8 bits of data from the
				;93C46.  Before calling this routine, the FSR
				;must point to the register being used to
				;hold the incomming data.
din8    movlw   0x08            ;Initialize loop counter.
	movwf   cnt             ;
;for the 3 wire interface the direction of the i/o line connected to
;din and dout has to converted from an output to an input.
	movlw   b'00000010'     ;convert RA1 to an input
	tris    serial          ;       /

d_i_8   clkit                   ;Clock a bit out of the 93C46.
	rlf     indir           ;Make room for the incomming bit in the
				;destination register.
	bcf     indir,0         ;Assume that the incomming bit is a '0' and
				;clear the LSB of the destination register.
	btfsc   serial,dout     ;Test the incomming bit, if our assumption
				;was correct, skip the next instruction.
	bsf     indir,0         ;No, actual bit is a '1'.  Set the LSB of the
				;destination register.
	decfsz  cnt             ;Repeat until cnt = 0.
	goto    d_i_8           ;Cnt still > 0
;for a 3 wire interface, convert the RA1 line back to an output
	movlw   0               ;make RA1 to an output
	tris    serial          ;       /
	retlw   no_err          ;Exit with good status.

;********************************************************************
;*                      RDYCHK                                      *
;********************************************************************
				;Rdychk will read the 93C46 READY/BUSY status
				;and wait for RDY status within the alloted
				;number of processor cycles.  If RDY status
				;is not present after this set period, the
				;routine will return with an error status.

rdychk  movlw   tries           ;Initialize time-out counter.
	movwf   cnthi           ;
	clrf    cnt             ;
;for a 3 wire interface, make the RA1 line an input
	movlw   b'00000010'     ;
	tris    serial
	dsel                    ;De-select the 93C46.

;       nop                     ;NOTE:  Check the 93C46 data sheet for
				;minimum CS low time.  Depending upon
				;processor frequency, a nop(s) may be
				;between the assertion and de-assertion of
				;Chip Select.

	sel                     ;Re-select the 93C46.
notrdy  btfsc   serial,dout     ;If DO is a '0', 93C46 has yet to completed
				;the last operation (still busy).
	goto    no_error        ;Otherwise RDY status is present within the
				;alloted time, and return with good status.
	decfsz  cnt             ;No, not yet ready.  Decrement the LSB of our
				;16 bit timer and check for expiration.
	goto    notrdy          ;Still some time left.  Try again.
	decfsz  cnthi           ;Least significant byte expired - decrement
				;and check for expiration of the MSB.
	goto    notrdy          ;Still some time left.  Try again.
;for a 3 wire interface, convert RA1 line back to an ouput
	movlw   0               ;convert RA1 to an output
	tris    serial          ;       /
	retlw   error           ;RDY status was not present in the alloted
				;time, return with error status.
no_error
;for a 3 wire interface, convert RA1 line back to an ouput
	movlw   0               ;convert RA1 to an output
	tris    serial          ;       /
	retlw   no_err


;********************************************************************
;*                      SEE                                         *
;********************************************************************

				;See will control the entire operation of a
				;93C46 device.  Prior to calling the routine,
				;load a valid command/memory address into
				;location cmd, and for WRITE or WRAL
				;commands, load registers highb and lowb with
				;16 bits of write data.  Upon exit, the W
				;register will contain the completion status.
				;Only 93C46 instructions which require a
				;status check can return with an error as the
				;completion status.  The values that denote
				;the completion status are defined as
				;variables 'error' and 'no_err' in the
				;general assignments section.

see     movlw   cmd             ;Load W with the location of the cmd
				;register.
	movwf   fsr             ;Transfer that information into the File
				;Select Register.  The fsr now points to
				;location cmd.
	sel                     ;Select the 93C46.
	strtbt                  ;Send a start bit.
	call dout8              ;Transmit the 2 bit command and six bit
				;address.
	btfsc   cmd,6           ;Check for a WRITE or ERASE command.
	goto    see2            ;Yes, parse the command further.
	btfsc   cmd,7           ;Check for a READ command.
	goto    read_           ;Yes, process READ command.
	btfsc   cmd,5           ;Check for a EWEN or ERAL command.
	goto    see3            ;Yes, parse the command further.
	btfsc   cmd,4           ;Check for a WRAL command.
	goto    write_          ;Yes, process WRITE/WRAL command.

exit_   dsel                    ;No further processing required; 93C46
				;command completed.
	retlw   no_err          ;Return with good completion status.

see2    btfss   cmd,7           ;Check for a ERASE command.
	goto    write_          ;No, process WRITE command.
exit2_  call    rdychk          ;ERASE command requires a status check.
	dsel                    ;De-select the 93C46.
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
				;the incomming 93C46 data word.
	call    din8            ;Input the upper byte.
	incf    fsr             ;Increment the File Select Register to point
				;to the register receiving the lower byte.
	call    din8            ;Input 8 more bits.
	goto    exit_           ;No further processing required, exit now.

write_  incf    fsr             ;Increment the File Select Register to point
				;to the upper byte of the 16 bit 93C46 data
				;word to be transmitted.
	call    dout8           ;Output that byte.
	incf    fsr             ;Increment the File Select Register to point
				;to the lower byte.
	call    dout8           ;Output the lower byte of the 16 bit 93C46
				;data word.
	goto    exit2_          ;Exit with a status check.

;********************************************************************
;*                      Test Program                                *
;********************************************************************
	main                    ;We've include a sample program to exercise
				;the PIC to 93C46 interface using a simple
				;erase, write and varify routine.
	
	clrf    serial          ;Clear the port tied to the 93C46 device.
	movlw   b'11110100'     ;Intialize the data direction register for
	tris    serial          ;that port.
	
	movlw   ewen            ;Load W with the Erase/Write Enable command.
	movwf   cmd             ;Transfer W into cmd register.
	call    see             ;Enable the 93C46 device.

	movlw   eral            ;Load W with the Erase All command.
	movwf   cmd             ;Transfer W into cmd register.
	call    see             ;Erase the 93C46.
	xorlw   error           ;Check completion status.
	btfsc   status, zflag   ;Test for error condition.
	goto    errloop         ;Yes, bad completion status, error-out.

				;Write loop:
loopcnt equ     0x1F            ;Define an unused location for our test
				;program loop counter.
tstptrn equ     0xAA            ;Define the test pattern to be written.

	movlw   .64             ;Initialize that counter.
	movwf   loopcnt         ;
	movlw   write           ;Load W with the Write command.
	movwf   cmd             ;Transfer W into cmd register.
	movlw   tstptrn         ;Intialize the 93C46 data registers with
				;write data.
	movwf   highb           ;
	movwf   lowb            ;
test1   call    see             ;Write data word into 93C46 device.
	xorlw   error           ;Check completion status.
	btfsc   status,zflag    ;Test for error condition.
	goto    errloop         ;Yes, bad completion status, error-out.
	incf    cmd             ;No, increment the 6 bit memory address
				;field.
	decfsz  loopcnt         ;Have we written all 64 locations?
	goto    test1           ;No, write another location.

				;Read loop:

	movlw   .64             ;Initialize loop counter.
	movwf   loopcnt         ;
	movlw   read            ;Load W with the Read command.
	movwf   cmd             ;Transfer W into cmd register.
test2   call    see             ;Read addressed data word from 93C46 device.
	movlw   tstptrn         ;Load W with the pattern written.
	subwf   highb,0         ;Verify the data read against what was
				;written.
	btfss   status,zflag    ;Same?
	goto    errloop         ;No, error-out.
	movlw   tstptrn         ;Repeat with the lower byte read.
	subwf   lowb,0          ;
	btfss   status,zflag    ;Same?
	goto    errloop         ;No, error-out.
	incf    cmd             ;Yes, both byte correct, increment the 6 bit
				;memory address field.
	decfsz  loopcnt         ;Have we read all 64 locations?
	goto    test2           ;No, read another location.

allok   goto    allok           ;Home safe!

errloop goto    errloop         ;Bad news!

	END                     ;Thats all folks!

