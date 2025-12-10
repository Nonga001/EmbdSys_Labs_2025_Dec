; Lab 1 - 8051 Assembly Fundamentals
; Objectives:
; 1. Toggle P1.0 at ~1 Hz
; 2. Count to 1000 using R1:R0
; 3. Subroutine to blink P1.0 and P1.1 sequentially

            ORG 0000h
            LJMP START       ; Jump to main program

; -------------------------------------------------
; Program Start
; -------------------------------------------------
START:
            MOV SP, #70h     ; Initialize stack pointer
            MOV P1, #0FFh    ; Set all P1 pins high (LEDs off if active low)


MAIN_LOOP:
            CPL P1.0         ; Toggle P1.0 LED
            ACALL DELAY_500MS ; Wait ~500 ms

            ; Increment 16-bit counter R1:R0
            INC R0
            JNZ SKIP_INC_HIGH
            INC R1
SKIP_INC_HIGH:

            ; Check if counter reached 1000 (0x03E8)
            MOV A, R1
            CJNE A, #03h, CONTINUE
            MOV A, R0
            CJNE A, #0E8h, CONTINUE
            SJMP HALT        ; Stop program after 1000 iterations

CONTINUE:
            ACALL BlinkTwoLEDs ; Optional: blink two LEDs sequentially
            SJMP MAIN_LOOP

; -------------------------------------------------
; Subroutine: BlinkTwoLEDs
; -------------------------------------------------
BlinkTwoLEDs:
            SETB P1.0
            ACALL DELAY_SHORT
            CLR P1.0
            ACALL DELAY_SHORT

            SETB P1.1
            ACALL DELAY_SHORT
            CLR P1.1
            ACALL DELAY_SHORT
            RET

; -------------------------------------------------
; Delays
; -------------------------------------------------
DELAY_SHORT:         ; Short delay (~50ms)
            MOV R2, #3
SHORT_LOOP1:
            MOV R3, #255
SHORT_LOOP2:
            DJNZ R3, SHORT_LOOP2
            DJNZ R2, SHORT_LOOP1
            RET

DELAY_500MS:         ; Approx. 500ms delay
            MOV R4, #5
DELAY_LOOP:
            ACALL DELAY_SHORT
            DJNZ R4, DELAY_LOOP
            RET

; -------------------------------------------------
; Halt Program
; -------------------------------------------------
HALT:
            SJMP HALT        ; Infinite loop - program stops here

            END
