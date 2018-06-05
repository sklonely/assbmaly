KEYDATA EQU 30H
SECAN_E:;只掃描#有才往下掃
	CLR F0
	SETB P0.3			;掃描線重製
	SETB P0.2			;掃描線重製
	SETB P0.1			;掃描線重製
	
	CLR P0.0
	JNB P0.4, gotKey_E
	JMP SECAN_E
gotKey_E:
	SETB F0
	JMP SECAN
;--------------------------------------------------------------
SECAN:

	MOV R0, #0			; clear R0 - the first key is key0
	CLR F0
	
	SETB P0.3			;掃描線重製
	SETB P0.2			;掃描線重製
	SETB P0.1			;掃描線重製
	SETB P0.0			;掃描線重製
		
	; scan row3
	SETB P0.0			
	CLR P0.3			
	CALL colScan		
			 
						

	; scan row2
	SETB P0.3			
	CLR P0.2			
	CALL colScan		
			
						

	; scan row1
	SETB P0.2			
	CLR P0.1			
	CALL colScan		
	JB F0, finish		
						

	; scan row0
	SETB P0.1			
	CLR P0.0			
	CALL colScan		
	JB F0, finish		
			
finish:
	;接下來要做的事情 要用CALL
	;沒掃描到舊再次掃描		
	JMP SECAN_E
; column-scan subroutine
colScan:
	INC R0
	JNB P0.6, gotKey	; if col0 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.4, gotKey	; if col2 is cleared - key found			; otherwise move to next key
	RET					; return from subroutine - key not found
gotKey:
	SETB F0				; key found - set F0
	MOV KEYDATA,R0
	RET					; and return from subroutine