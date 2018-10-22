     AREA     appcode, CODE, READONLY
     export __main	 
	 ENTRY 
__main  function
	          MOV r0 , #27   ;first number
	          MOV r1 , #56    ;second number
              MOV r2 , #16 	  ;third number  			  
              CMP r0 , r1
              IT HI
              MOVHI r1 , r0   ;if value in r0>r1, move value in r0 to r1 
			  CMP r1 , r2
			  IT HI 
			  MOVHI r2 , r1    ;if value in r1>r2, move value in r1 to r2
			  MOV r3 , r2      ; largest number is seen in r3    
STOP		      B STOP  ; stop program
        endfunc
      end
