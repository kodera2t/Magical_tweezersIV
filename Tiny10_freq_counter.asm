;
; 20160619_Tiny10_freq_counter.asm
;
; Created: 6/19/2016 8:21:50 PM
; Author : kodera2t
;



.def data = R16
.def cnt = R17
.def cnt2 = R18
.def long_count = R19
.def free3 = R20

.def temp1 = R21
.def temp2 = R22

.def temp3 = R23
.def free1 = R24
.def free2 = R25


.equ count_start = 0x02
.equ count_end = 0x01
.equ subnum = 0x01
.equ SUB_COUNT	= 0x02
.equ one_v = 0b00110011
.equ two_v = 0b01100110
.equ thr_v = 0b10011001
.equ for_v = 0b11001100
.equ p_one = 0b101
.equ p_two = 0b1010
.equ p_three = 0b1111
.equ p_four= 0b10100
.equ p_five = 0b11001
.equ p_six = 0b11110
.equ p_seven = 0b100011
.equ p_eight = 0b101000
.equ p_nine = 0b101101

.equ long_delay =0xFF



; PB0: SDA, PB1: SCL, PB2:A/D input

setup:
;	ldi temp1,0
;	out CLKPSR,temp1
; PB0 and PB1 are out, don't care receiving.
	ldi temp1, 0b011
	out DDRB, temp1
; as a initial, SDA and SCL are high
	ldi temp1, 0b11
	out PORTB, temp1

	ldi temp1, (1<<CS02)+(1<<CS01)+(0<<CS00)
	out TCCR0B, temp1; setup T0(PB2) as counter input (rising count)




	rcall lcd_init; LCD initialize
	rcall longdelay	
	rcall init_for_disp

//////////// dangerous? maximum clock setting (aroung 15MHz)//////////
	; setting clock divider change enable
    LDI temp1, 0xD8
	LDI temp2, 0x00
	OUT CCP, temp1
	; selecting internal 8MHz oscillator
	OUT CLKMSR, temp2
	LDI temp1, 0xD8
	LDI temp3, (0<<CLKPS3)+(0<<CLKPS2)+(0<<CLKPS1)+(0<<CLKPS0);
	OUT CCP, temp1
	; setting clock divider change enable
	OUT CLKPSR, temp3; k (disable div8)
	ldi temp2, 0x4A ;calibration point
	; initial clock setting
	OUT OSCCAL, temp2
;//////////////////////////////////////////////////////////////////////




mainloop:
	rcall clearcount
	rcall longdelay

/*
; reading A/D result in free1
	in    free1,ADCL
	mov free2, free1
	ldi free3, 0x00
*/
	in temp2, TCNT0L
	in free1, TCNT0H ; reading 16bit counter
	mov free2, free1
	ldi free3, 0x00
; first digit determination

	cpi free1, for_v
	brsh fourvol
	cpi free1, thr_v
	brsh threevol
	cpi free1, two_v
	brsh twovol
	cpi free1, one_v
	brsh onevol
	rjmp zerovol



fourvol:
	ldi free2, 4
	subi free1, for_v
	rjmp done

threevol:
	ldi free2, 3
	subi free1, thr_v
	rjmp done

twovol:
	ldi free2, 2
	subi free1, two_v
	rjmp done

onevol:
	ldi free2, 1
	subi free1, one_v
	rjmp done

zerovol:
	ldi free2, 0


done:




;first digit display
	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0000; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	mov temp1, free2
	ori temp1, 0b00110000
	mov data,temp1
	rcall writedata
	rcall ends



; second digit check


	cpi free1, p_nine
	brsh nine
	cpi free1, p_eight
	brsh eight
	cpi free1, p_seven
	brsh seven
	cpi free1, p_six
	brsh six
	cpi free1, p_five
	brsh five
	cpi free1, p_four
	brsh four
	cpi free1, p_three
	brsh three
	cpi free1, p_two
	brsh two
	cpi free1, p_one
	brsh one
	rjmp zero



nine:
	ldi free2, 9
	subi free1, p_nine
	rjmp done2
eight:
	ldi free2, 8
	subi free1, p_eight
	rjmp done2
seven:
	ldi free2, 7
	subi free1, p_seven
	rjmp done2
six:
	ldi free2, 6
	subi free1, p_six
	rjmp done2
five:
	ldi free2, 5
	subi free1, p_five
	rjmp done2
four:
	ldi free2, 4
	subi free1, p_four
	rjmp done2
three:
	ldi free2, 3
	subi free1, p_three
	rjmp done2
two:
	ldi free2, 2
	subi free1, p_two
	rjmp done2
one:
	ldi free2, 1
	subi free1, p_one
	rjmp done2


zero:
	ldi free2, 0


done2:

	lsl free1
	;lsl free1


; second digit
	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0010; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	mov temp1, free2
	ori temp1, 0b00110000
	mov data,temp1
	rcall writedata
	rcall ends	

	; third digit
	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0011; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	mov temp1, free1
	ori temp1, 0b00110000
	mov data,temp1
	rcall writedata
	rcall ends	


    rjmp mainloop



delay:	; subroutine DELAY
	ldi	temp1, SUB_COUNT
SUB_COUNT1:
	ldi	temp2, COUNT_END
	ldi	temp3, COUNT_START
COUNTER:
	dec	temp3
	cpse	temp3, temp2
	rjmp COUNTER	
	dec	temp1
	cpse	temp1,	temp2
	rjmp	SUB_COUNT1
	ret

start:
	ldi temp1, 0b10
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay
	ret
	;cl, da
ends:
	ldi temp1,0b10
	out PORTB, temp1
	rcall delay
	ldi temp1,0b11
	out PORTB, temp1
	rcall delay
	ret

init:
	ldi temp1, 0b11
	out PORTB, temp1
	rcall delay
	ret
	;cl da
bit_high:
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b01
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b11
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b01
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay

	ret
	;cl=1 da=0
bit_low:
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b10
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay
	ldi temp1, 0b00
	out PORTB, temp1
	rcall delay
	ret
	;cl da


; writing data is stored in data
writedata:
	ldi cnt,0x00
	ldi cnt2,0xF
rep:
	mov temp2, data
	andi temp2,0b10000000
	cpi temp2, 0b10000000
	breq highbit
	rcall bit_low
	rjmp sendend
highbit:
	rcall bit_high
sendend:
	lsl data
	inc cnt
	cpi cnt,8
	brne rep
	ldi temp1, 0b11
	out PORTB, temp1

small_loop:
	dec cnt2
	rcall delay
	cpi cnt2,0x00
	brne small_loop
	ret


lcd_init:
	rcall init
	rcall start
	ldi data,0x7C
	rcall writedata
	ldi data,0b1000_0000
	rcall writedata
	ldi data,0x38
	rcall writedata
	ldi data,0b0000_0000
	rcall writedata
	ldi data,0x39
	rcall writedata
	rcall ends

	rcall start
	ldi data,0x7C
	rcall writedata
	ldi data,0b1000_0000
	rcall writedata
	ldi data,0x14
	rcall writedata
	ldi data,0b0000_0000
	rcall writedata
	ldi data,0x73
	rcall writedata
	rcall ends

	rcall start
	ldi data,0x7C
	rcall writedata
	ldi data,0b1000_0000
	rcall writedata
	ldi data,0x55
	rcall writedata
	ldi data,0b1000_0000
	rcall writedata
	ldi data,0x6c
	rcall writedata
	ldi data,0b1000_0000;cont
	rcall writedata
	ldi data,0x38
	rcall writedata
	ldi data,0b1000_0000;cont
	rcall writedata
	ldi data,0x0c
	rcall writedata
	ldi data,0b1000_0000;cont
	rcall writedata
	ldi data,0x01
	rcall writedata
	rcall ends
	ret

longdelay:
	ldi long_count,long_delay
localloop:
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	rcall delay
	dec long_count
	cpi long_count,0x00
	brne localloop
	ret

init_for_disp:
	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0101; second line,last digit
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	ldi data, 0b01001101 ;M
	rcall writedata
	rcall ends

	;rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0001; second line,last digit
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	ldi data, 0b00101110 ; dot (.)
	rcall writedata
	rcall ends


	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0110; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	ldi data, 0b0100_1000 ;H
	rcall writedata
	rcall ends

	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0111; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	ldi data, 0b0111_1010 ;z
	rcall writedata
	rcall ends	

/*	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0001; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	mov temp1, free2
	ori temp1, 0b00100000 ;space
	mov data,temp1
	rcall writedata
	rcall ends*/

/*	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0000; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	mov temp1, free2
	ori temp1, 0b00100000 ;space
	mov data,temp1
	rcall writedata
	rcall ends

	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0101; second line,
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	ldi temp1, 0x0
	ori temp1, 0b00110000
	mov data,temp1
	rcall writedata
	rcall ends

	*/




	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1000_0000; first line
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0100_0110; F
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0111_0010; r
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_0101; e
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0111_0001; q
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0111_0101; u
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_0101; e
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_1110; n
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0011_1010; :
	rcall writedata
	rcall ends


	ret

clearcount:
	ldi temp1, 0x00
	out	TCNT0H, temp1
	out TCNT0L, temp1; counter reset to zero
	ldi temp1, TOV0<<1
	out TIFR0, temp1; overflow reset
	ret