; ECE-222 Lab ... Winter 2013 term 
; Lab 3 sample code 
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				ENTRY  
__MAIN

				LDR			R10, =LED_BASE_ADR				; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports
ProgramStart	MOV 		R3, #0xB0000000					; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 				; Turn off five LEDs on port 2 
				MOV         R6, #0							; Initialize R6 to 0
				MOV 		R5, #0							; Initialize R5 to 0 
				MOV         R0, #0							; Initialize R0 to 0
				BL          SimpleCounter           		; Branch Links to SimpleCounter Subroutine which counts from 0 to 255

SimpleCounter	
				MOV         R6, #0x00000100         		; Initialize second counter variable
				MOV			R3, #0x0						; Initialize first counter variable
startcounting   BL DISPLAY_NUM								; Starts looping from 0 to 255
				MOV R0, #1000								; Initialize 0.1 second delay between numbers
				BL DELAY									; Branch Link to Delay
				ADD R3, #1									; Increment the first counter to display the next number
				SUBS R6, #1									; Subtract the second counter by 1 and set the flag
				BNE startcounting							; If the Z status bit is not set then continue looping
				BEQ ProgramStart							; If the Z status bit is set then go back to ProgramStart subroutine to repeat the process

; Display the number in R3 onto the 8 LEDs
DISPLAY_NUM		STMFD		R13!,{R1, R2, R3, R7, R6, R14}  ; Place appropriate variables on stack
				
				MOV 		R5, #0							; Initialize R5 to zero
				MOV			R6, #0					        ; Initialize R6 to zero
				BFI         R6, R3, #0, #5					; Extract the first 5 bits from R3(corresponding to port2) starting at bit0 into R6
				RBIT        R6, R6							; Reverse the bits 
				LSR         R6, #25							; Shift it right 25 times to leave place for bit 0 and bit 1 of port 2
			         
				EOR         R6, #0xFFFFFFFF					; Exclusive or with #0xFFFFFFFF. We do this because it is active low ie: 0 is on and 1 is off 
				STR         R6, [R10, #0x40]				; Take the base LED address stored in R10 and add the offset to switch on port2 LEDS
				
				
				MOV 		R6, #0							; Initialize R6 to zero
				LSR			R3, #5							; Shift R3 to the right 5 times in order to move the port 1 bits to the most significant position
				BFI         R6, R3, #0, #1 					; Get Bit0 from the modified R3. This is in reality corresponding to Port1.31
				
				LSL         R3, #1							; Shift it left by 1 in order to make room for the 30th bit 
				ADD         R6, R3							; Add both of them which now gives us bit 28 to bit 31
				RBIT        R6, R6							; Reverse the bits 
				
				EOR         R6, #0xFFFFFFFF					; Exclusive or with #0xFFFFFFFF. We do this because it is active low ie: 0 is on and 1 is off
				STR         R6, [R10, #0x20]				; Take the base LED address stored in R10 and add the offset to switch on port1 LEDS
				

				LDMFD		R13!,{R1, R2, R3, R7, R6, R15}  ; Return from the Stack to calling routine
				
DELAY			STMFD		R13!,{R2, R14}					; Place appropriate variables on stack
				MOV         R2, #0							; Initialize R2 to 0
				MOV        R2, #0x0043  					; Initialize R2 to #0x0043 which is the 0.1 ms delay
				MUL         R0, R2							; Multiply R0 with R2 to get a 0.1 second delay between numbers
MultipleDelay   TEQ         R0, #0							; Start testing if R0 is 0
                SUB         R0, #1							; Subtract 1 from R0
				BEQ         exitDelay						; If Z status bit is set then delay subroutine is completed and you return from stack
				BNE         MultipleDelay					; If Z status bit is not set delay subroutine is still not complete and continue looping
				
exitDelay		LDMFD		R13!,{R2, R15}					; Return from stack to calling routine


LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
TEST_LABEL		EQU     0x186A0			; change to 186A0
FIO2PIN         EQU     0x2009c054
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]


				ALIGN 

				END 