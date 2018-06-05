DELAY: 
		MOV 	R7,#0 ;delay parameter 
$1: 	MOV 	R6,#0 ; 
		DJNZ 	R6,$ ; 
		DJNZ 	R7,$1 ; 
		RET ; 