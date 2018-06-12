; This program takes ten readings
; from the ADC at 50 us intervals
; (assuming system clock is 12 MHz)
; and stores them in RAM, starting at
; address 30H.

CS EQU P3.1
WR EQU P3.6
RD EQU P3.7
DATA_LINES EQU P2
BUFFER EQU 30H
BUFFER_SIZE EQU 20

ORG 0
	JMP main
ORG 3
	JMP external0ISR
ORG 0BH
	JMP timer0ISR
ORG 30H
main:
	MOV R0, #BUFFER
	MOV R1, #BUFFER_SIZE
	CLR CS
	MOV TMOD, #2
	MOV TH0, #-50
	MOV TL0, #-50
	SETB TR0
	SETB ET0
	SETB EX0
	SETB IT0
	SETB EA
	JMP $

timer0ISR:
	CLR WR
	SETB WR
	RETI

external0ISR:
	CLR RD
	MOV @R0, DATA_LINES
	SETB RD
	INC R0
	DJNZ R1, endExternal0ISR
	SETB CS
	CLR TR0
endExternal0ISR:
	RETI
