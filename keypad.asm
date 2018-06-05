KEYDATA	 	EQU 30H;KEY TEMP
KEYDATA0 	EQU 40H;KEY DATA0
KEYDATA1 	EQU 41H;KEY DATA1
KEYDATA2 	EQU 42H;KEY DATA2
KEYDATA3 	EQU 43H;KEY DATA3

;七段顯示變數--------------------------------------------------------------
MOV KEYDATA0,#192
MOV KEYDATA1,#192
MOV KEYDATA2,#192
MOV KEYDATA3,#192
MOV R1,#40H;多功用計數器 初始設定: 指標指在 KEYDATA0上
;--------------------------------------------------------------
MOV DPTR,#TABLE
;--------------------------------------------------------------
SECAN:;主程式
	
	CALL DISPLAY
	MOV R0,#0			; clear R0 - the first key is key0
	CLR F0
	
	SETB P0.3			;掃描線重製
	SETB P0.2			;掃描線重製
	SETB P0.1			;掃描線重製
	SETB P0.0			;掃描線重製
		
	; scan row3
	SETB P0.0			
	CLR P0.3			
	CALL colScan		
	JB F0, finish	 
						

	; scan row2
	SETB P0.3			
	CLR P0.2			
	CALL colScan		
	JB F0, finish
						

	; scan row1
	SETB P0.2			
	CLR P0.1			
	CALL colScan		
			
	JB F0, finish	;若鍵盤旗標有東西則跳轉到FINISH
	
	SETB P0.1			
	CLR P0.0			
	CALL colScan
	JB F0, finish
		
	JMP SECAN		;若鍵盤旗標沒東西則回SECAN繼續掃描

;--------------------------------------------------------------
finish:;若掃描到有東西則做裡面
	;接下來要做的事情 要用CALL
	CALL SED;將資料存到4個站存器中 
	;做完回到SECAN
	JMP SECAN
;--------------------------------------------------------------
colScan:;col掃描
	INC R0
	JNB P0.6, gotKey	
	INC R0				
	JNB P0.5, gotKey	
	INC R0				
	JNB P0.4, gotKey	
	RET					
gotKey:;掃描中得到值
	SETB F0				; 找到值 將旗標 立起
	MOV KEYDATA,R0
	RET					; and return from subroutine
;--------------------------------------------------------------
SED:;七段顯示轉換函數(KEYDATA需要是數字)
	;先掃描有沒有按#鍵
	SETB P0.3			;掃描線重製
	SETB P0.2			;掃描線重製
	SETB P0.1			;掃描線重製
	CLR P0.0			;掃描線 掃描
	JNB P0.4, gotKey_E;若沒有則RET
		CLR F0
	RET
	gotKey_E:;若有則開始 轉換成輸出的HEX
		MOV R3,#9	;迴圈從九開始
		SEDLOOP_9_1:	;迴圈判斷9~1
			MOV 	A,KEYDATA
			CJNE 	A,03H,ELSE	;IF(A=R3):PRINT;	P.S.03H是R3的位置
				MOV 	A,R3
				MOVC 	A,@A+DPTR
				MOV		@R1,A
				MOV	KEYDATA,#0
				CLR F0
				CALL COUNERTADD;將地址+1
				RET
			ELSE:				;ELSE: 
		DJNZ R3,SEDLOOP_9_1;從9掃到1
		
		CJNE	A,#11,ELSE0;判斷是不是0不是則跳轉
			MOV 	A,#0;
			MOVC 	A,@A+DPTR
			MOV		KEYDATA,#0
			MOV		@R1,A
			CLR F0
			CALL COUNERTADD;將地址+1
			RET 
		ELSE0:;當結果都不是就不做事
			RET
;--------------------------------------------------------------
COUNERTADD:
	MOV 	A,R1
	CJNE	A,#43H,ADD_COUNTER_1;ELSE:
		MOV 	R1,#40H
		;MOV 	@R1,KEYDATA
		RET
	ADD_COUNTER_1:;IF(A!=43):
		INC 	A
		MOV 	R1,A
		;MOV 	@R1,KEYDATA
	RET
;--------------------------------------------------------------
DISPLAY:
	
	MOV P3,#11111111B		
	MOV P1, KEYDATA0
	CALL delay
	
	MOV P3,#11110111B		
	MOV P1, KEYDATA1
	CALL delay
	
	MOV P3,#11101111B				
	MOV P1, KEYDATA2
	CALL delay
	
	MOV P3,#11100111B		
	MOV P1, KEYDATA3
	CALL delay
	
	RET		

;--------------------------------------------------------------
delay:
	MOV R0, #2
	DJNZ R0, $
	RET
;--------------------------------------------------------------
TABLE:	;鍵盤
	DB C0H
	DB F9H
	DB A4H
	DB B0H
	DB 99H
	DB 92H
	DB 82H
	DB F8H
	DB 80H
	DB 90H
	