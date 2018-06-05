KEYDATA EQU 30H ;	指標
MOV DPTR,#TABLE

;紀錄: 卡在 若先做MOV	@R1,A 則#按鍵無效，若沒做 則KEYDATA資料可能不能被載入
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
				RET
			ELSE:				;ELSE: 
		DJNZ R3,SEDLOOP_9_1;從9掃到0
		
		CJNE	A,#11,ELSE0;判斷是不是0不是則跳轉
			MOV 	A,#0;
			MOVC 	A,@A+DPTR
			MOV		KEYDATA,#0
			MOV		@R1,A
			CLR F0
			RET 
		ELSE0:;當結果都不是就不做事
			RET
	
	

DISPLAY:
	
	
TABLE:	;鍵盤
	DB	C0H;0
	DB	F9H;1
	DB	A4H;2
	DB	B0H;3
	DB	99H;4
	DB	92H;5
	DB	82H;6
	DB	F8H;7
	DB	80H;8	
	DB	90H;9
