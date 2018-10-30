     PRESERVE8
     THUMB
     AREA     appcode, CODE, READONLY
     EXPORT __main
	   ENTRY 
__main  FUNCTION

    VMOV.F32 S1, #4;x-Number to find e^x
    VMOV.F32 S2, #15;Number of terms been considered in e^x expansion
    VMOV.F32 S3, #1;count
    VMOV.F32 S4, #1; temp
    VMOV.F32 S5, #1; result
    VMOV.F32 S7, #1;register to hold one
  Loop 
	 VCMP.F32 S2, S3;Comparison done for excuting taylor series expansion of e^x for s2 number of terms
	 VMRS.F32 APSR_nzcv,FPSCR;Used to copy fpscr to apsr
	 BLT stop;
	 VDIV.F32 S6, S1, S3; temp1=x/count
	 VMUL.F32 S4, S4, S6; temp=temp*temp1;
	 VADD.F32 S5, S5, S4; result=result+temp;
	 VADD.F32 S3, S3, S7; incrementing count
	 B Loop; 
	 
stop B stop ; stop program
	 ENDFUNC
	 END
