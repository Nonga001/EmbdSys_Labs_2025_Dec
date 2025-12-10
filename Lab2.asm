ORG 0000H
    LJMP START

ORG 0030H
START:
    MOV SP, #7FH        ; Initialize stack pointer
    
    ; CRITICAL: Set Port 1 to OFF first, before configuring Port 0
    CLR P1.0
    CLR P1.1
    CLR P1.2
    CLR P1.3
    CLR P1.4
    CLR P1.5
    CLR P1.6
    CLR P1.7
    
    ; Now configure ports
    MOV P0, #0FFH       ; Configure Port 0 as input
    MOV P1, #0FFH       ; Ensure Port 1 is high (LEDs off in edsim51D)
    
    ; Small settling delay
    ACALL SHORT_DELAY
    
MAIN:
    MOV A, P0           ; Read Port 0 (keypad)
    MOV P1, A           ; Write directly to Port 1
    
    ACALL SHORT_DELAY   ; Small delay for stability
    SJMP MAIN
DEMO_BIT_ADDRESSABLE:
    ; Ensure all LEDs start OFF
    MOV P1, #00H
    ACALL LONG_DELAY
    
    ; Set individual bits using bit-addressable instructions
    SETB P1.0           ; Set bit 0 - LED 0 ON
    ACALL LONG_DELAY
    
    SETB P1.1           ; Set bit 1 - LED 1 ON
    ACALL LONG_DELAY
    
    SETB P1.2           ; Set bit 2 - LED 2 ON
    ACALL LONG_DELAY
    
    ; Clear a specific bit
    CLR P1.1            ; Clear bit 1 - LED 1 OFF
    ACALL LONG_DELAY
    
    ; Toggle operation
    CPL P1.0            ; Toggle bit 0 - LED 0 OFF
    ACALL LONG_DELAY
    CPL P1.0            ; Toggle bit 0 - LED 0 ON
    ACALL LONG_DELAY
    
    ; Bit move using Carry flag
    SETB P1.3           ; Set bit 3
    ACALL LONG_DELAY
    MOV C, P1.3         ; Copy bit 3 to Carry
    MOV P1.5, C         ; Copy Carry to bit 5 - LED 5 ON
    ACALL LONG_DELAY
    
    ; Conditional bit operation
    JB P1.0, LED0_IS_ON ; Test if bit 0 is set
    SETB P1.7           ; Won't execute
    SJMP DEMO_END
    
LED0_IS_ON:
    SETB P1.6           ; Set bit 6 because bit 0 was high
    ACALL LONG_DELAY
    
DEMO_END:
    ; Clear all LEDs before returning to main
    MOV P1, #00H
    ACALL LONG_DELAY
    RET

; ============================================================================
; Subroutine: DEBOUNCE_DELAY
; Description: Software button debouncing
;   Software sees: 10-20 separate button presses
; ============================================================================
DEBOUNCE_DELAY:
    PUSH 00H
    PUSH 01H
    MOV R7, #20
    
DEBOUNCE_OUTER:
    MOV R6, #200
    
DEBOUNCE_INNER:
    DJNZ R6, DEBOUNCE_INNER
    DJNZ R7, DEBOUNCE_OUTER
    
    POP 01H
    POP 00H
    RET

SHORT_DELAY:
    PUSH 00H
    MOV R7, #10
    
SHORT_LOOP:
    DJNZ R7, SHORT_LOOP
    POP 00H
    RET
LONG_DELAY:
    PUSH 00H
    PUSH 01H
    MOV R7, #100
    
LONG_OUTER:
    MOV R6, #255    
LONG_INNER:
    DJNZ R6, LONG_INNER
    DJNZ R7, LONG_OUTER
    
    POP 01H
    POP 00H
    RET

END