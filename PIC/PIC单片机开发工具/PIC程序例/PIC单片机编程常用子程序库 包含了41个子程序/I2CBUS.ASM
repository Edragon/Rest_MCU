	TITLE " TWO WIRE/I2C BUS INTERFACE WITH PIC16C5x "
;
	LIST P=16C54
;
;*****************************************************************************
;**  Two wire/I2C Bus READ/WRITE Sample Routines of Microchip's
;**  24Cxx / 85Cxx serial CMOS EEPROM interfacing to a 
;**  PIC16C54 8-bit CMOS single chip microcomputer
;**  Revsied Version 2.0 (4/2/92).
;**
;**     Part use = PIC16C54-XT/JW                                           
;**  Note:  1) All timings are based on a reference crystal frequency of 2MHz
;**            which is equivalent to an instruction cycle time of 2 usec.
;**         2) Address and literal values are read in octal unless otherwise
;**            specified.
;*****************************************************************************
;
;-----------------------------------------------------------------------------
;       Files Assignment
;-----------------------------------------------------------------------------
;
PC      EQU     2               ; Program counter
STAT    EQU     3               ; PIC status byte
FSR     EQU     4               ; File Select Register
RA      EQU     5               ; Port A use to select device address
RB      EQU     6               ; RB7 = SDA, RB6 = SCL
;
STATUS  EQU     08              ; Status register
FLAG    EQU     09              ; Common flag bits register
EEPROM  EQU     0A              ; Bit buffer
ERCODE  EQU     0B              ; Error code (to indicate bus status)
ADDR    EQU     10              ; Address register
DATAI   EQU     11              ; Stored data input register
DATAO   EQU     12              ; Stored data output register
SLAVE   EQU     13              ; Device address (1010xxx0)
TXBUF   EQU     14              ; TX buffer
RXBUF   EQU     15              ; RX buffer
COUNT   EQU     16              ; Bit counter
;
TIMER0  EQU     18              ; Delay timer0
TIMER1  EQU     19              ; Delay timer1
;
;
;-----------------------------------------------------------------------------
;                     Bit Assignments
;-----------------------------------------------------------------------------
;
; Status bits
;
Z       EQU     2
C       EQU     0
;
; FLAG Bits
;
ERROR   EQU     0               ; Error flag
;
; EEPROM Bits
;
DI      EQU     7               ; EEPROM input
DO      EQU     6               ; EEPROM output
;
; I2C Device Bits
;
SDA     EQU     7               ; RB7, data in/out
SCL     EQU     6               ; RB6, serial clock
;
;END FILES/BITS EQUATE
 PAGE
;
;-----------------------------------------------------------------------------
;       Two wire/I2C - CPU communication error status table and subroutine
;-----------------------------------------------------------------------------
;  input  :     W-reg   = error code
;  output :     ERCODE  = error code
;           FLAG(ERROR) = 1
;
;         code          error status mode
;       -------         ------------------------------------------------------
;           1   :       SCL locked low by device (bus is still busy)
;           2   :       SDA locked low by device (bus is still busy)
;           3   :       No acknowledge from device (no handshake)
;           4   :       SDA bus not released for master to generate STOP bit
;-----------------------------------------------------------------------------
;
;Subroutine to identify the status of the serial clock (SCL) and serial data
;(SDA) condition according to the error status table. Codes generated are
;useful for bus/device diagnosis.
;
ERR
	BTFSS   FLAG,ERROR      ; Remain as first error encountered
	MOVWF   ERCODE          ; Save error code
	BSF     FLAG,ERROR      ; Set error flag
	RETLW   0
;
;-----------------------------------------------------------------------------
;       START bus communication routine
;-----------------------------------------------------------------------------
;       input   : none
;       output  : initialize bus communication
;-----------------------------------------------------------------------------
;
;Generate START bit (SCL is high while SDA goes from high to low transition)
;and check status of the serial clock.
BSTART
	MOVLW   B'00111111'     ; Put SCL, SDA line in output state
	TRIS    RB
;***************************************************************************
	bsf     RB,SDA          ;make sure sda is high
;***************************************************************************
	BSF     RB,SCL          ; Set clock high
	MOVLW   1               ; Ready error status code 1
	BTFSS   RB,SCL          ; Locked?
	CALL    ERR             ; SCL locked low by device
	BCF     RB,SDA          ; SDA goes low during SCL high
	NOP                     ; Timing adjustment
	NOP
	NOP
	BCF     RB,SCL          ; Start clock train
	RETLW   0
;
;END SUB
 PAGE
;
;-----------------------------------------------------------------------------
;       STOP bus communication routine
;-----------------------------------------------------------------------------
;       Input   :       None
;       Output  :       Bus communication, STOP condition
;-----------------------------------------------------------------------------
;
;Generate STOP bit (SDA goes from low to high during SCL high state)
;and check bus conditions.
;
BSTOP
;****************************************************************************
	MOVLW   B'00111111'     ; Put SCL, SDA line in output state
	TRIS    RB
;****************************************************************************
	BCF     RB,SDA          ; Return SDA to low
	BSF     RB,SCL          ; Set SCL high
	nop
	nop
	nop
	MOVLW   1               ; Ready error code 1
	BTFSS   RB,SCL          ; High?
	CALL    ERR             ; No, SCL locked low by device
	BSF     RB,SDA          ; SDA goes from low to high during SCL high
	MOVLW   4               ; Ready error code 4
	BTFSS   RB,SDA          ; High?
	CALL    ERR             ; No, SDA bus not release for STOP
	RETLW   0
;
;END SUB
;
;-----------------------------------------------------------------------------
;       Serial data send from PIC to serial EEPROM, bit-by-bit subroutine
;-----------------------------------------------------------------------------
;       Input   :       None
;       Output  :       To (DI) of serial EEPROM device
;-----------------------------------------------------------------------------
;
BITIN
	MOVLW   B'10111111'     ; Force SDA line as input
	TRIS    RB
	BSF     RB,SDA          ; Set SDA for input
	BCF     EEPROM,DI
	BSF     RB,SCL          ; Clock high
	MOVLW   1
	BTFSC   RB,SCL          ; Skip if SCL  is high
	GOTO    BIT1
	BTFSS   FLAG,ERROR      ; Remain as first error encountered
	MOVWF   ERCODE          ; Save error code
	BSF     FLAG,ERROR      ; Set error flag
BIT1
	BTFSC   RB,SDA          ; Read SDA pin
	BSF     EEPROM,DI       ; DI = 1
	NOP                     ; Delay
	BCF     RB,SCL          ; Return SCL to low     
	RETLW   0
;
;END SUB
 PAGE
;
;-----------------------------------------------------------------------------
;       Serial data receive from serial EEPROM to PIC, bit-by-bit subroutine
;-----------------------------------------------------------------------------
;       Input   :       EEPROM file
;       Output  :       From (DO) of serial EEPROM device to PIC
;-----------------------------------------------------------------------------
;
BITOUT
	MOVLW   B'00111111'     ; Set SDA, SCL as outputs
	TRIS    RB
	BTFSS   EEPROM,DO
	GOTO    BIT0
	BSF     RB,SDA          ; Output bit 0
	MOVLW   2
	BTFSC   RB,SDA          ; Check for error code 2
	GOTO    CLK1
	BTFSS   FLAG,ERROR      ; Remain as first error encountered
	MOVWF   ERCODE          ; Save error code
	BSF     FLAG,ERROR      ; Set error flag
	GOTO    CLK1            ; SDA locked low by device
;
BIT0
	BCF     RB,SDA          ; Output bit 0
	NOP                     ; Delay
	NOP
	NOP
CLK1
	BSF     RB,SCL
	MOVLW   1               ; Error code 1
	BTFSC   RB,SCL          ; SCL locked low?
	GOTO    BIT2            ; No.
	BTFSS   FLAG,ERROR      ; Yes.
	MOVWF   ERCODE          ; Save error code
	BSF     FLAG,ERROR      ; Set error flag
BIT2
	NOP
	NOP
	BCF     RB,SCL          ; Return SCL to low
	RETLW   0
;
;END SUB
 PAGE
;
;
;-----------------------------------------------------------------------------
;       RECEIVE         DATA    subroutine
;-----------------------------------------------------------------------------
;       Input   :       None
;       Output  :       RXBUF = Receive 8-bit data
;-----------------------------------------------------------------------------
;
RX
	MOVLW   .8              ; 8 bits of data
	MOVWF   COUNT
	CLRF    RXBUF
;
RXLP
	RLF     RXBUF           ; Shift data to buffer
	SKPC
	BCF     RXBUF,0         ; carry ---> f(0)
	SKPNC
	BSF     RXBUF,0
	CALL    BITIN
	BTFSC   EEPROM,DI
	BSF     RXBUF,0         ; Input bit =1
	DECFSZ  COUNT           ; 8 bits?
	GOTO    RXLP
	BSF     EEPROM,DO       ; Set acknowledge bit = 1
	CALL    BITOUT          ; to STOP further input
	RETLW   0
;
;END SUB
;
;-----------------------------------------------------------------------------
;       TRANSMIT        DATA    subroutine
;-----------------------------------------------------------------------------
;       Input   :       TXBUF
;       Output  :       Data X'mitted to EEPROM device
;-----------------------------------------------------------------------------
;
TX
	MOVLW   .8
	MOVWF   COUNT
;
TXLP
	BCF     EEPROM,DO       ; Shift data bit out.
	BTFSC   TXBUF,7         ; If shifted bit = 0, data bit = 0
	BSF     EEPROM,DO       ; Otherwise data bit = 1
	CALL    BITOUT          ; Serial data out
	RLF     TXBUF           ; Rotate TXBUF left
	SKPC                    ; f(6) ---> f(7)
	BCF     TXBUF,0         ; f(7) ---> carry
	SKPNC                   ; carry ---> f(0)
	BSF     TXBUF,0
	DECFSZ  COUNT           ; 8 bits done?
	GOTO    TXLP            ; No.
	CALL    BITIN           ; Read acknowledge bit
	MOVLW   3
	BTFSC   EEPROM,DI       ; Check for acknowledgement
	CALL    ERR             ; No acknowledge from device
	RETLW   0
;
;END SUB
 PAGE
;
;-----------------------------------------------------------------------------
;       BYTE-WRITE, write one byte to EEPROM device
;-----------------------------------------------------------------------------
;       Input   :       DATAO= data to be written
;                       ADDR    = destination address
;                       SLAVE   = device address (1010xxx0)
;       Output  :       Data written to EEPROM device
;-----------------------------------------------------------------------------
;
	ORG     080             ; The location for BYTE-WRITE routine can be
;                               ; assigned anywhere between (377-777) octal.
WRBYTE
	MOVF    SLAVE,W         ; Get SLAVE address
	MOVWF   TXBUF           ; to TX buffer
	CALL    BSTART          ; Generate START bit
	CALL    TX              ; Output SLAVE address
	MOVF    ADDR,W          ; Get WORD address
	MOVWF   TXBUF           ; into buffer
	CALL    TX              ; Output WORD address
	MOVF    DATAO,W         ; Move DATA 
	MOVWF   TXBUF           ; into buffer
	CALL    TX              ; Output DATA and detect acknowledgement
	CALL    BSTOP           ; Generate STOP bit
	goto    wrt_end
;
;
;
;-----------------------------------------------------------------------------
;       BYTE-READ, read one byte from serial EEPROM device
;-----------------------------------------------------------------------------
;       Input   :       ADDR    = source address
;                       SLAVE   = device address (1010xxx0)
;       Output  :       DATAI   = data read from serial EEPROM
;-----------------------------------------------------------------------------
;
	ORG     0C0             ; The location for BYTE-READ routine can be
;                               ; assigned anywhere between (377-777) octal.
RDBYTE
	MOVF    SLAVE,W         ; Move SLAVE address 
	MOVWF   TXBUF           ; into buffer (R/W = 0)
	CALL    BSTART          ; Generate START bit
	CALL    TX              ; Output SLAVE address. Check ACK.
	MOVF    ADDR,W          ; Get WORD address
	MOVWF   TXBUF
	CALL    TX              ; Output WORD address. Check ACK.
	CALL    BSTART          ; START READ (if only one device is
	MOVF    SLAVE,W         ; connected to the I2C bus)
	MOVWF   TXBUF
	BSF     TXBUF,0         ; Specify READ mode (R/W = 1)
	CALL    TX              ; Output SLAVE address
	CALL    RX              ; READ in data and acknowledge
	CALL    BSTOP           ; Generate STOP bit
	MOVF    RXBUF,W         ; Save data from buffer
	MOVWF   DATAI           ; to DATAI file.
	goto    rd_end
;
;Test program to read and write ramdom
start
	movlw   0AE             ;set A2=A1=A0=1
	movwf   SLAVE           ;       /
	movlw   2               ;set r/w loc. = 2
	movwf   ADDR            ;       /
	movlw   55              ;write 55 to SEEPROM
	movwf   DATAO           ;       /
	goto    WRBYTE          ;write a byte
wrt_end
	call    delay           ;wait for write
				;operation (internal)
	goto    RDBYTE          ;read back data
rd_end
	movlw   55              ;test if read
	xorwf   DATAI,W         ;correct?
	btfss   STAT,Z          ;yes then skip
wrong   
	goto    wrong
correct
	goto    correct
;
;At 2.0Mhz, delay = approx. 3mS.
delay
	clrf    1F              ;clear last location
dly1
	nop
	nop
	nop
	decfsz  1F              ;reduce count
	goto    dly1            ;loop
	retlw   0
;
	org     0x1FF
	goto    start
;
	END
