;
; 20160616_tiny10_I2C_1.asm
;
; Created: 6/16/2016 10:28:45 AM
; Author : kodera2t
;

.def data = R16
.def cnt = R17
.def cnt2 = R18
.def long_count = R19
.def display = R25

.def temp1 = R20
.def temp2 = R21

.def temp3 = R22
.def temp4 = R23
.def temp5 = R24
;.def temp6 = R25

.equ count_start = 0x04
.equ count_end = 0x01
.equ subnum = 0x01
.equ	SUB_COUNT	= 0x04

.equ long_delay =0xFF



; PB0: SDA, PB1: SCL

setup:
;	ldi temp1,0
;	out CLKPSR,temp1
; PB0 and PB1 are out, don't care receiving.
	ldi temp1, 0b11
	out DDRB, temp1
; as a initial, SDA and SCL are high
	ldi temp1, 0b11
	out PORTB, temp1
	ldi display,0x00
	rcall lcd_init; LCD initialize
	ldi display,0xFF
	rcall longdelay
	rcall longdelay
mainloop:
	inc display
	cpi display,10
	brne notclear
	ldi display,0
notclear:
	rcall longdelay





	
	rcall init
	rcall start
	ldi data,0x7C
	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0111; second line,last digit
	rcall writedata
	ldi data,0b1100_0000; cont data
	rcall writedata
	mov temp1, display
	ori temp1, 0b00110000
	mov data,temp1
	rcall writedata
/*	ldi data,0b00_0000
	rcall writedata
	ldi data,0x39
	rcall writedata*/
	rcall ends
	

    rjmp mainloop


delay:	; subroutine DELAY
	ldi	temp3, SUB_COUNT
SUB_COUNT1:
	ldi	temp4, COUNT_END
	ldi	temp5, COUNT_START
	;ldi	temp6, SUBNUM=0x01
COUNTER:
	dec	temp5
	cpse	temp5, temp4
	rjmp COUNTER	
	dec	temp3
	cpse	temp3,	temp4
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
	//ldi temp1, 0b11
	//out PORTB, temp1
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
;ack:
;	ldi temp1, 0b

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
	ldi data,0b1000_0000;cont command
	rcall writedata
	ldi data,0b1000_0000;address 0x00
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0100_1000; H
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_0101; e
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_1100; l
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_1100; l
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_1111; o
	rcall writedata

	ldi data,0b1000_0000; cont command
	rcall writedata
	ldi data,0b1100_0000; second line
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0100_0001; A
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0111_0100; t
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0111_0100; t
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_1001; i
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0110_1110; n
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0111_1001; y
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0011_0001; 1
	rcall writedata
	ldi data,0b1100_0000;cont data
	rcall writedata
	ldi data,0b0011_0000; 0
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