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
light transitions 


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
