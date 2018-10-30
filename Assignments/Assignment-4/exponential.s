   ;PRESERVE8
   ;thumb
		area appcode, CODE, READONLY
		export __main
		ENTRY
__main function
 
        MOV R0,#15			;Holding the Number of Terms in Series 'n' 
        MOV R1,#1			;Counting Variable 'i' 
        VLDR.F32 S0,=1		;Holding the sum of series elements 's' 
        VLDR.F32 S1,=1		;Temp Variable to hold the intermediate series elements 't' 
        VLDR.F32 S2,=4		;Holding 'x' Value 
LOOP1    CMP R1,R0			;Compare 'i' and 'n'  
        BLE LOOP			;if i < n goto LOOP 
        B stop				;else goto stop 
LOOP   VMUL.F32 S1,S1,S2	; t = t*x 
        VMOV.F32 S5,R1		;Moving the bit stream in R1('i') to S5(floating point register) 
        VCVT.F32.U32 S5,S5	;Converting the bitstream into unsigned fp Number 32 bit 
        VDIV.F32 S1,S1,S5	;Divide t by 'i' and store it back in 't' 
        VADD.F32 S0,S0,S1	;Finally add 's' to 't' and store it in 's' 
        ADD R1,R1,#1		;Increment the counter variable 'i' 
        B LOOP1				;Again goto comparision 
stop    B stop 
        ENDFUNC 
        END
