	NOLIST

; rev 1.2       4/06/92
;***************************************************************
; define special function registers:
 
	#define W 0
	#define w 0
	#define high    1
	#define low     0
	#define true    1
	#define false   0
	#define HIGH    1
	#define LOW     0
	#define TRUE    1
	#define FALSE   0
;
	#define LSB     0
	#define MSB     7
;
_INC    equ     1
_NO_INC equ     0
_LOW    equ     0
_HIGH   equ     1
;
	cblock 0x00
	       bit0,bit1,bit2,bit3,bit4,bit5,bit6,bit7
	endc

	cblock 0x00     ; define banks
	       bank0,bank1,bank2,bank3
	endc

	cblock 0x00             ; unbanked registers
	       indf0,fsr0,pcl,pclath,alusta,rtcsta,cpusta,intsta
	  indf1,fsr1,wreg,rtccl,rtcch,tblptrl,tblptrh,bsr
	endc

	cblock 0x10             ; bank0 registers
	       porta,ddrb,portb,rcsta,rcreg,txsta,txreg,spbrg
	endc

	cblock 0x10             ; bank1 registers       
			ddrc,portc,ddrd,portd,ddre,porte,pir,pie
	endc

	cblock 0x10             ; bank2 registers
		    tmr1,tmr2,tmr3l,tmr3h,pr1,pr2,pr3l,pr3h
	endc

ca1l    equ     0x16            ; alternate function def
ca1h    equ     0x17

	cblock  0x10     ; define bank3 variables
		     pw1dcl,pw2dcl,pw1dch,pw2dch,ca2l,ca2h,tcon1,tcon2
	endc

;***************************************************************
; define commonly used bits:

; ALUSTA bit definitions

	#define _carry  alusta,0
	#define _c      alusta,0
	#define _cy     alusta,0
	#define _dc     alusta,1
	#define _z      alusta,2
	#define _ov     alusta,3
	#define _fs0    alusta,4
	#define _fs1    alusta,5
	#define _fs2    alusta,6
	#define _fs3    alusta,7

; RTCSTA bit definitions

	#define _rtps0  rtcsta,1
	#define _rtps1  rtcsta,2
	#define _rtps2  rtcsta,3
	#define _rtps3  rtcsta,4
	#define _tc     rtcsta,5
	#define _rtedg  rtcsta,6
	#define _intedg rtcsta,7

; CPUSTA bit definitions

	#define _npd    cpusta,2
	#define _nto    cpusta,3
	#define _gint   cpusta,4
	#define _glintd cpusta,4
	#define _stkavl cpusta,5

; INTSTA bit definitions

	#define _intie  intsta,0
	#define _rtcie  intsta,1
	#define _rtxie  intsta,2
	#define _peie   intsta,3
	#define _intir  intsta,4
	#define _rtcir  intsta,5
	#define _rtxir  intsta,6
	#define _peir    intsta,7

; PIR Bit definitions

	#define _rbfl   pir,0
	#define _tbmt   pir,1
	#define _ca1ir pir,2
	#define _ca2ir pir,3
	#define _tm1ir pir,4
	#define _tm2ir pir,5
	#define _tm3ir pir,6
	#define _irb    pir,7

; PIE Bit definitions

	#define _rcie   pie,0
	#define _txie   pie,1
	#define _ca1ie pie,2
	#define _ca2ie pie,3
	#define _tm1ie pie,4
	#define _tm2ie pie,5
	#define _tm3ie pie,6
	#define _ieb    pie,7

; RCSTA bit definitions

	#define _rcd8   rcvsta,0
	#define _oerr  rcvsta,1
	#define _ferr   rcvsta,2
	#define _cren   rcvsta,4
	#define _sren   rcvsta,5
	#define _rc89  rcvsta,6
	#define _spen   rcvsta,7
	
; TXSTA bit definitions

	#define _txd8   txsta,0
	#define _trmt   txsta,1
	#define _sync   txsta,4
	#define _txen   txsta,5
	#define _tx89   txsta,6
	#define _csrc   txsta,7

; TCON1 bit definitions

	#define _tmr1c  tcon1,0
	#define _tmr2c  tcon1,1
	#define _tmr3c  tcon1,2
	#define _tmr16  tcon1,3
	#define _ca1ed0 tcon1,4
	#define _ca1ed1 tcon1,5
	#define _ca2ed0 tcon1,6
	#define _ca2ed1 tcon1,7

; TCON2 bit definitions

	#define _tmr1on  tcon2,0
	#define _tmr2on  tcon2,1
	#define _tmr3on  tcon2,2
	#define _ca1pr3  tcon2,3
	#define _pwm1on  tcon2,4
	#define _pwm2on  tcon2,5
	#define _ca1ovf  tcon2,6
	#define _ca2ovf  tcon2,7

	LIST


