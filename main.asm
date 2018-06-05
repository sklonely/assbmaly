; put data in RAM
	MOV 30H, #30H
	MOV 31H, #0	; end of data marker


; 初始化LCD
	CLR P1.3		; RS = 0 進入指令模式
; LCD 4位元模式 set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		;

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear


; entry mode set
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear


; LCD顯示設定
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL delay		; wait for BF to clear

;主程式
start:

	MOV R0, #0			; clear R0 - the first key is key0
	CLR F0
	MOV P0,#11111111B

	; scan row0
	SETB P0.0			; set row3
	CLR P0.3			; clear row0
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)

	; scan row1
	SETB P0.3			; set row0
	CLR P0.2			; clear row1
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)

	; scan row2
	SETB P0.2			; set row1
	CLR P0.1			; clear row2
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)

	; scan row3
	SETB P0.1			; set row2
	CLR P0.0			; clear row3
	CALL colScan0		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)

	CALL delay
	JMP start			; | go back to scan row 0
						; | (this is why row3 is set at the start of the program
						; | - when the program jumps back to start, row3 has just been scanned)

; lcd輸出
finish:
	; send data
	CLR F0
	SETB P1.3		; clear RS - indicates that data is being sent to module
	MOV R1, #30H	; data to be sent to LCD is stored in 8051 RAM, starting at location 30H
loop:
	MOV A, @R1		; move data pointed to by R1 to A
	JZ start		; if A is 0, then end of data has been reached - jump out of loop
	ADD A,R0
	CALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
	JMP loop		; repeat				; program execution arrives here when key is found - do nothing
	RET

; column-scan subroutine
colScan:
	INC R0
	JNB P0.6, gotKey	; if col0 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.4, gotKey	; if col2 is cleared - key found
				; otherwise move to next key
	RET					; return from subroutine - key not found
; *0# 判斷
colScan0:
	MOV R0,#23H
	JNB P0.6, gotKey	; if col0 is cleared - key found
	MOV R0,#0				; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	MOV R0,#20H				; otherwise move to next key
	JNB P0.4, gotKey	; if col2 is cleared - key found
				; otherwise move to next key
	RET					; return from subroutine - key not found

gotKey:
	SETB F0				; key found - set F0
	RET					; and return from subroutine

sendCharacter:
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB P1.2			; |
	CLR P1.2			; | negative edge on E

	CALL delay			; wait for BF to clear
	RET
	
delay:
	MOV R2, #50
	DJNZ R2, $
	RET