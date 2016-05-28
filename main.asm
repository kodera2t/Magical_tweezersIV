;
; Attiny10_magical_battery_checker.asm
;
; Created: 5/28/2016 10:09:19 AM
; Author : kodera2t
;


; Replace with your application code
.def r_temp1 = R16
.def r_temp2 = R17
.def r_temp3 = R18
.def status = R23
.def temp3 = R19
.def temp4 = R20
.def temp5 = R21
.def temp6 = R22


.equ lv_1 = 0x3A ; values for voltage comparison
.equ lv_2 = 0x80 ; these values are considering diode brige voltage down.
.equ lv_3 = 0xFF
.equ count_start = 0xfe
.equ count_end = 0x01
.equ subnum = 0x01
.equ	SUB_COUNT	= 0x18;256
    
	setup:                
		   ldi	r_temp1, ((1<<ADEN)+(1<<ADSC)+(1<<ADATE)+(1<<ADIE)+(0<<ADIF)+(1<<ADPS2)+(1<<ADPS1)+(0<<ADPS2))
	       out   ADCSRA,r_temp1       ;starting A/D conversion (free running mode)
		   ;ldi	r_temp1, ((0<<REFS0)+(0<<ADLAR)+(1<<MUX1)+(1<<MUX0)) ; Vcc as analogue reference
		   ldi	r_temp1, (1<<MUX1)+(0<<MUX0) ; selecting PB2 for A/D input
	       out   ADMUX,r_temp1 ; setting PB2 for A/D input
		   ldi	r_temp1, (0<<DDB2)+(1<<DDB1)+(1<<DDB0)
		   out	DDRB, r_temp1 ; PB0, 1 for LED output (PB2 for input)
		   ldi	r_temp1, 1<<ADC2D
		   out	DIDR0, r_temp1
		   ldi r_temp1, (1<<PB0)+(1<<PB1)
		   out PORTB, r_temp1
		   in	status, SREG


	main: ; main loop start!
	out	SREG, status
	in    r_temp1,ADCL        ;reading A/D result

	in	status, SREG
	cpi r_temp1, lv_1 ; comparing measured result with lv_1=0x5D
	brlo s_vchk_1 ; if the measured value is lower than 0x2b, jump to s_vchk_10

	cpi r_temp1, lv_2 ; comparing measured result with lv_1=0x9A
	brlo s_vchk_2

	cpi r_temp1, lv_3 ; comparing measured result with lv_1=0xFF
	brlo s_vchk_3

	rcall delay
	rcall delay

	ldi r_temp3, 0b011 ;all LED are off (negative logic)
	out PORTB, r_temp3
	rjmp main ; closing main loop

s_vchk_1:
	ldi r_temp3, 0b011 ;all LED are off (negative logic)
	out PORTB, r_temp3
	rcall delay
	rjmp 0x00
	ret ; return to main loop

s_vchk_2:
	ldi r_temp3, 0b001 ;PB0 is on
	out PORTB, r_temp3
	rcall delay
	rjmp 0x00
	ret ; return to main loop


s_vchk_3:
	ldi r_temp3, 0b010 ; PB0, 1 are on
	out PORTB, r_temp3
	rcall delay
	rjmp 0x00
	ret ; return to main loop

	DELAY:	; subroutine DELAY
	LDI	temp3, SUB_COUNT
SUB_COUNT1:
	LDI	temp4, COUNT_END
	LDI	temp5, COUNT_START
	LDI	temp6, SUBNUM
COUNTER:
	SUB	temp5, temp6
	CPSE	temp5, temp4
	RJMP COUNTER	
	SUB	temp3, temp6
	CPSE	temp3,	temp4
	RJMP	SUB_COUNT1
	RET