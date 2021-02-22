;
; Door_Locker.asm
; May 2020
; Author : Gregório da Luz
;

.include "m328pdef.inc" 
.cseg 
.org 0
	jmp start 
.org INT0addr 
	jmp button_D2
.org INT1addr 
	jmp button_D3

.org 0x32
.def counter = r20
; main program start
start:
	cli
	ldi counter, 0

	ldi r16, high(RAMEND) 
	out sph, r16
	ldi r16, low(RAMEND)
	out spl, r16

	;output for the leds
	ldi r16, 0xff 
	out ddrb, r16		

	;Set Int rising edge
	ldi r16, (1<<isc00)|(1<<isc01)|(1<<isc10)|(1<<isc11)
	sts eicra, r16

	;pull up resistors portd  
	ldi r16, 0x0f 
	out portd, r16

	; Clear intf flag
	ldi r16, (1<<intf0)|(1<<intf1)
	out eifr, r16
	;Enable Int
	ldi r16, (1<<int0)|(1<<int1)
	out eimsk, r16
	sei
restart:
	;enable Sleep mode idle		
	in r16, smcr
	ori r16, (1<<SE)
	out smcr, r16 
	sleep
	rjmp restart 

;Button
button_D2:
	cli
	inc counter
	nop
	ldi r16, 0x01
	cp r16,counter
	breq continue
	ldi r16, 0x02
	cp r16,counter
	breq continue
	ldi r16, 0x03
	cp r16,counter
	breq zero
	ldi r16, 0x04
	cp r16,counter
	breq leds

button_D3:
	cli
	inc counter
	nop
	ldi r16, 1
	cp r16, counter
	breq zero
	ldi r16, 2
	cp r16, counter
	breq zero
	ldi r16, 3
	cp r16, counter
	breq continue
	ldi r16, 4
	cp r16, counter
	breq zero

zero:
	;pin 5 has a yellow led showing when a button was wrong 
	;wrong button demands user to start combination lock from the beginning
	ldi r16, 0x10
	out portb, r16
	call wait
	call wait
	ldi r16, 0x00
	out portb, r16
	ldi counter, 0
	; Clear intf flag
	ldi r16, (1<<intf0)|(1<<intf1)
	out eifr, r16
	reti

continue:
	; Clear intf flag
	call wait
	ldi r16, (1<<intf0)|(1<<intf1)
	out eifr, r16
	reti

leds:
	ldi r17, 0x0f
	ldi r16, 0x00 
	out portb, r17
	call wait
	call wait
	out portb, r16
	call wait
	call wait
	out portb, r17
	call wait
	call wait
	out portb, r16
	call wait
	call wait
	out portb, r17
	call wait
	out portb, r16
	ldi counter, 0
	; Clear intf flag
	ldi r16, (1<<intf0)|(1<<intf1)
	out eifr, r16
	reti
	
;delay
wait:
push r16
push r17
push r18 		
ldi r16,8
out_loop2: ldi r17, 250
	out_loop1: ldi r18, 250				   
		in_loop:  	
			dec r18								   
		brne in_loop ; repeat it 250 times  	
		dec r17
	brne out_loop1 ; repeat it 250 times 
	dec r16 
brne out_loop2 ; repeat it 13 times
pop r18
pop r17
pop r16
ret
