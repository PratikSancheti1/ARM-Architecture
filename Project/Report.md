# Intelligent Traffic light system on Cortex M4 using IR proximity Sensors

## Components

#### MSP432 
MSP-EXP432P401R development kit is a very convenient and easy to use evaluation kit for MSP432P401R microcontroller. 
It uses ARM Cortex M4F Processor.
The development kit includes on board debug probe for programming, debugging and energy measurements.
The device supports low power applications requiring increased CPU speed, memory and 32 bit performance. 
There is access to 40-pin  headers and a range of plug-in modules that enable technologies like wireless connectivity, graphical displays, 
sensors, etc. It has 2 buttons and 2 LEDs for user interaction and UART through 
In this project we have used Port 4 and Port 5 of the processor. The output LEDs are connected to port 4 and direction of the port is set.
Similarly, port 5 is set as input and we use 2 pins as input which is given by the IR sensor.

#### IR Proximity Sensor
We have used this sensor which has an infrared transmission LED and a photodiode. The signal is used as input which shows that a car is passing 
on the road.


#### SysTick (System Timer)
* This is used for setting the time using the SysTick registers. The CSR register i.e. the SysTick Control and Status Register which has enable 
bit(bit 0), a timer control (bit 2) which if set to 1 uses internal processor clock. The bit 16 is a count flag which is set to 1 when the 
count in the CVR becomes 0.
* The RVR register is reload value register which can contain any value from 0x00000000 to 0x00ffffff which depends upon the use.
* There is also a tickINT bit(bit 1) which enables SysTick exception request. When 1 it enables exception request when CVR count goes to 0.
* The CVR is the current value registers which holds current value.
* In this code we initialize all these 3 registers at the start.
* We set the RVR to the maximum value to get the maximum time period and again run a loop set the required time period between the traffic
light transitions.


#### The Main Function

* So, in the main function, we initialize the ports used and set their direction appropriately which is P4- output and P5- input.
* The LEDs are connected to P4 and the IR proximity sensors are connected to P5.
* After initializing the ports, the port address are given to registers and the current state value declared in the code (goN is the initial
state here).
* According to the current state the LEDs glow at first as the current state value is sent to the output.
* Now when an input comes from the proximity sensor, it is given to a register and after the delay in the state we see a change in the 
LED .

e.g. Here the initial state is North Green(goN) and East Red, so when the E road sensor gets an input, the state is changed to (waitN) which has
North Yellow and East Red, and after again a smaller time it quickly shifts to North Red and East Green.

* So, here we have used each state as constant (states goN, waitN, goE, waitE) which have the output values, wait time and next state 
stored as 4 byte constants each i.e. each state has 12 byte memory which is accessed in the main function using the offset at 
the correct time.

## The code for intelligent traffic light 
```assembly

		AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
    



; Use a pointer implementation of a Moore finite state machine to operate
; a traffic light.

; east facing red light connected to P4.5
; east facing yellow light connected to P4.4
; east facing green light connected to P4.3
; north facing red light connected to P4.2
; north facing yellow light connected to P4.1
; north facing green light connected to P4.0
; north facing car detector connected to P5.1 (1=car present)
; east facing car detector connected to P5.0 (1=car present)


P4IN      EQU 0x40004C21  ; Port 4 Input
P4OUT     EQU 0x40004C23  ; Port 4 Output
P4DIR     EQU 0x40004C25  ; Port 4 Direction
P4REN     EQU 0x40004C27  ; Port 4 Resistor Enable
P4SEL0    EQU 0x40004C2B  ; Port 4 Select 0
P4SEL1    EQU 0x40004C2D  ; Port 4 Select 1
P5IN      EQU 0x40004C40  ; Port 5 Input
P5OUT     EQU 0x40004C42  ; Port 5 Output
P5DIR     EQU 0x40004C44  ; Port 5 Direction
P5REN     EQU 0x40004C46  ; Port 5 Resistor Enable
P5SEL0    EQU 0x40004C4A  ; Port 5 Select 0
P5SEL1    EQU 0x40004C4C  ; Port 5 Select 1

        ;AREA    |.text|, CODE, READONLY, ALIGN=2
        ;THUMB
        EXPORT  __main
;Linked data structure
;Put in ROM
OUT   EQU 0    ;offset for output
WAIT  EQU 4    ;offset for time
NEXT  EQU 8    ;offset for next
goN   DCD 0x21 ;North green, East red
      DCD 300  ;3 sec
      DCD goN,waitN,goN,waitN
waitN DCD 0x22 ;North yellow, East red
      DCD 50   ;0.5 sec
      DCD goE,goE,goE,goE
goE   DCD 0x0C ;North red, East green
      DCD 300  ;3 sec
      DCD goE,goE,waitE,waitE
waitE DCD 0x14 ;North red, East yellow
      DCD 50   ;0.5 sec
      DCD goN,goN,goN,goN

__main function
    BL   SysTick_Init   ; enable SysTick

    ; initialize P4.5-P4.0 and make them GPIO outputs
    LDR  R1, =P4SEL0          
    LDRB R0, [R1]             
    BIC  R0, R0, #0x3F    ; configure light pins as GPIO
    STRB R0, [R1]         
    LDR  R1, =P4SEL1    
    LDRB R0, [R1]      
    BIC  R0, R0, #0x3F   ; configure light pins as GPIO
    STRB R0, [R1]                   
    ; make light pins out
    LDR  R1, =P4DIR            
    LDRB R0, [R1]          
    ORR  R0, R0, #0x3F   ; output direction
    STRB R0, [R1]           

    ; initialize P5.1-P5.0 and make them inputs
    LDR  R1, =P5SEL0        
    LDRB R0, [R1]          
    BIC  R0, R0, #0x03   ; configure car detector pins as GPIO
    STRB R0, [R1]          
    LDR  R1, =P5SEL1       
    LDRB R0, [R1]          
    BIC  R0, R0, #0x03   ; configure car detector pins as GPIO)
    STRB R0, [R1]     
    ; make car detector pins in
    LDR  R1, =P5DIR    
    LDRB R0, [R1]    
    BIC  R0, R0, #0x03   ; input direction
    STRB R0, [R1]       

    LDR  R4, =goN       ; state pointer
    LDR  R5, =P5IN      ; 0x40004C40 (8 bits)
    LDR  R6, =P4OUT     ; 0x40004C23 (8 bits)
FSM LDRB R1, [R6]       ; R1 = [R6] = 8-bit contents of register P4OUT
    BIC  R1, R1, #0x3F  ; R1 = P4OUT&~0x3F (clear light output value field)
    LDRB R0, [R4, #OUT] ; R0 = R4->OUT = 8-bit output value for the current state
    ORR  R0, R1, R0     ; R0 = (P4OUT&~0x3F)|(R4->OUT)
    STRB R0, [R6]       ; [R6] = R0 (set lights to current state's OUT value)
    LDR  R0, [R4, #WAIT]; R0 = R4->WAIT = 32-bit time delay for the current state
    BL   SysTick_Wait10ms
    LDRB R0, [R5]       ; R0 = [R5] = 8-bit contents of register P5IN
    AND  R0, R0, #0x03  ; ignore bits of P5IN not connected to sensors
    LSL  R0, R0, #2     ; 4 bytes/address
    ADD  R0, R0, #NEXT  ; 8,12,16,20
    LDR  R4, [R4, R0]   ; R4 = R4->NEXT[P5IN&0x03] (go to next state based on inputs)
    B    FSM

    ALIGN                           ; make sure the end of this section is aligned

; Provide functions that initialize the SysTick module, wait at least a
; designated number of clock cycles, and wait approximately a multiple
; of 10 milliseconds using busy wait.  After a power-on-reset, the
; MSP432 gets its clock from the internal digitally controlled
; oscillator, which is set to 3 MHz by default.  One distinct advantage
; of the MSP432 is that it has low-power clock options to reduce power
; consumption by reducing clock frequency.  This matters for the
; function SysTick_Wait10ms(), which will wait longer than 10 ms if the
; clock is slower.

SYSTICK_STCSR         EQU 0xE000E010  ; SysTick Control and Status Register
SYSTICK_STRVR         EQU 0xE000E014  ; SysTick Reload Value Register
SYSTICK_STCVR         EQU 0xE000E018  ; SysTick Current Value Register

;------------SysTick_Init------------
; Initialize SysTick with busy wait running at bus clock.
; Input: none
; Output: none
; Modifies: R0, R1
SysTick_Init
    ; disable SysTick during setup
    LDR  R1, =SYSTICK_STCSR         ; R1 = &SYSTICK_STCSR (pointer)
    MOV  R0, #0                     ; ENABLE = 0; TICKINT = 0
    STR  R0, [R1]
    ; maximum reload value
    LDR  R1, =SYSTICK_STRVR         ; R1 = &SYSTICK_STRVR (pointer)
    LDR  R0, =0x00FFFFFF            ; R0 = 0x00FFFFFF = 2^24-1
    STR  R0, [R1]
    ; any write to current clears it
    LDR  R1, =SYSTICK_STCVR         ; R1 = &SYSTICK_STCVR (pointer)
    MOV  R0, #0                     ; R0 = 0
    STR  R0, [R1]
    ; enable SysTick with no interrupts
    LDR  R1, =SYSTICK_STCSR         ; R1 = &SYSTICK_STCSR (pointer)
    MOV  R0, #0x00000005            ; R0 = ENABLE and CLKSOURCE bits set; TICKINT bit cleared
    STR  R0, [R1]
    BX   LR                         ; return

;------------SysTick_Wait------------
; Time delay using busy wait.
; Input: R0  delay parameter in units of the core clock (units of 333 nsec for 3 MHz clock)
; Output: none
; Modifies: R0, R1, R2, R3
SysTick_Wait
; method #1: set Reload Value Register, clear Current Value Register, poll COUNTFLAG in Control and Status Register
    LDR  R1, =SYSTICK_STRVR         ; R1 = &SYSTICK_STRVR (pointer)
    SUB  R0, R0, #1                 ; subtract 1 because SysTick counts from STRVR to 0
    STR  R0, [R1]                   ; [R1] = number of counts to wait
    LDR  R1, =SYSTICK_STCVR         ; R1 = &SYSTICK_STCVR (pointer)
    MOV  R2, #0                     ; any write to CVR clears it and COUNTFLAG in CSR
    STR  R0, [R1]                   ; [R1] = 0
    LDR  R1, =SYSTICK_STCSR         ; R1 = &SYSTICK_STCSR (pointer)
SysTick_Wait_loop
    LDR  R3, [R1]                   ; R3 = SYSTICK_STCSR (value)
    ANDS R3, R3, #0x00010000        ; is COUNTFLAG set?
    BEQ  SysTick_Wait_loop          ; if not, keep polling

    BX   LR                         ; return

;------------SysTick_Wait10ms------------
; Time delay using busy wait.  This assumes 3 MHz system clock.
; Input: R0  number of times to wait 10 ms before returning
; Output: none
; Modifies: R0
DELAY10MS             EQU 30000     ; clock cycles in 10 ms (assumes 3 MHz clock)
SysTick_Wait10ms
    PUSH {R4, LR}                   ; save current value of R4 and LR
    MOVS R4, R0                     ; R4 = R0 = remainingWaits
    BEQ  SysTick_Wait10ms_done      ; R4 == 0, done
SysTick_Wait10ms_loop
    LDR  R0, =DELAY10MS             ; R0 = DELAY10MS
    BL   SysTick_Wait               ; wait 10 ms
    SUBS R4, R4, #1                 ; R4 = R4 - 1; remainingWaits--
    BHI  SysTick_Wait10ms_loop      ; if(R4 > 0), wait another 10 ms
SysTick_Wait10ms_done
    POP  {R4, LR}                   ; restore previous value of R4 and LR
    BX   LR                         ; return

    ALIGN                           ; make sure the end of this section is aligned
    ;END                             ; end of file

	ENDFUNC
	END                             ; end of file
```
