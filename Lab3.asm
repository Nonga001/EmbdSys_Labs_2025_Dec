; Lab 3 - Analog-to-Digital Interaction (software simulation for edSim51DI)
; - Mock ADC value stored at RAM address 30h (ADC_DATA)
; - Filtered result stored at RAM address 31h (FILTERED)
; - Filter used: filtered = (3 * old + new) / 4  (smooths with 75% old, 25% new)
; - Filtered value shown on Port 2 (P2)
; - P1.7 blinks: ON = fixed short time, OFF = delay proportional to filtered value
;
; Usage in edSim51DI:
; - Edit internal RAM location 30h at runtime (simulate the potentiometer/ADC).
; - Observe P2 (binary value), and LED on P1.7 blinking with OFF-time ~ filtered value.

            ORG 0000H
            LJMP START

; RAM locations (internal memory)
ADC_DATA    EQU 030H    ; simulated ADC result (0..255) — change this via RAM editor
FILTERED    EQU 031H    ; stored filtered value

;-----------------------------------------
; Reset/start
;-----------------------------------------
START:
            ; initialize ports
            MOV P1, #0FFH    ; P1 as inputs default (we'll use P1.7 as LED output but writing to P1 is fine)
            MOV P2, #00H     ; P2 used to display filtered value (LEDs on simulator)
            MOV A, #00H
            MOV FILTERED, A  ; initialize filtered to 0

MAIN_LOOP:
            ; -------- read ADC (mock) ----------
            MOV A, ADC_DATA      ; A = new_sample (0..255)
            MOV R0, A            ; save new in R0

            ; -------- load old filtered value ----------
            MOV A, FILTERED      ; A = old
            MOV R1, A            ; R1 = old

            ; -------- compute sum = 3*old + new ----------
            ; A = R1 (old)
            MOV A, R1
            ADD A, R1            ; A = 2*old
            ADD A, R1            ; A = 3*old
            ADD A, R0            ; A = 3*old + new

            ; -------- divide by 4: (3*old + new)/4 ----------
            MOV B, #04H
            DIV AB               ; A = quotient = filtered
            ; (B receives remainder — ignored)

            ; store filtered
            MOV FILTERED, A

            ; show filtered value on Port 2 (binary LEDs)
            MOV P2, A

            ; -------- blink P1.7: ON fixed short time, OFF ~ filtered ----------
            ; ON time (short)
            SETB P1.7
            MOV R2, #0F0H        ; short-ish fixed on delay (change if needed)
ON_DELAY:
            DJNZ R2, ON_DELAY

            ; OFF time proportional to FILTERED
            CLR P1.7
            MOV A, FILTERED
            ; ensure minimum off delay (avoid zero causing long wrap-around behavior)
            JZ MIN_OFF
            MOV R3, A
            SJMP DO_OFF
MIN_OFF:
            MOV R3, #03H         ; minimum off delay (small visible off)
DO_OFF:
            DJNZ R3, DO_OFF

            ; small gap to allow UI / registers to update
            MOV R4, #20
GAP_DELAY:
            DJNZ R4, GAP_DELAY

            SJMP MAIN_LOOP

            END
