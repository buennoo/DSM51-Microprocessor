LED EQU P1.7
BRZEK EQU P1.5
; Timer 0
T0_G EQU 0 ;GATE
T0_C EQU 0 ;COUNTER/-TIMER
T0_M EQU 1 ;MODE (0..3)
TIM0 EQU T0_M+T0_C*4+T0_G*8

; Timer 1
T1_G EQU 0 ;GATE
T1_C EQU 0 ;COUNTER/-TIMER
T1_M EQU 0 ;MODE (0..3)
TIM1 EQU T1_M+T1_C*4+T1_G*8

TMOD_SET EQU TIM0+TIM1*16
TH0_SET EQU 256-180
TL0_SET EQU 0

	LJMP START

    ; obsluga przerwania
    ORG 0BH

    MOV TH0, #TH0_SET
    DJNZ R6, NO_5SEC
	LCALL ZMIEN_LED
    LCALL BRZECZYK

NO_5SEC:
        RETI

	ORG 100H

START:
	LCALL LCD_CLR

MINUTA:
    ; pierwsza liczba
	LCALL WAIT_KEY

    MOV R2, #0  ; do if'a potem

    MOV R5, A
    LCALL SPRAWDZANIE
    MOV A, R5

	MOV B,#10 
	MUL AB 
	MOV R1, A

    ; druga liczba
	LCALL WAIT_KEY 
	ADD A, R1
	MOV R2, A
	MOV R1, A

	MOV A, R2
	MOV R3, A
	LCALL BCD
	MOV A, #':'
    LCALL WRITE_DATA

SEKUNDA:
	LCALL WAIT_KEY

    MOV R2, #2  ; do if'a potem
    ; sprawdzenie < 60
    MOV R5, A
    LCALL SPRAWDZANIE
    MOV A, R5

	MOV B,#10 
	MUL AB 
	MOV R1,A 

	LCALL WAIT_KEY 
	ADD A, R1
	MOV R2, A
	MOV R1, A

	MOV A, R2
	MOV R4, A
	LCALL BCD
	MOV A, #10
    LCALL DELAY_100MS

	LCALL LCD_CLR

	MOV TMOD, #TMOD_SET
	MOV TH0, #TH0_SET
	MOV TL0, #TL0_SET

	SETB TR0 ; start
	CPL LED
    MOV R6, #100
    
    SETB EA ; globalne przerwania
    SETB ET0    ; przerwania dla Timera 0


LOOP: 
	MOV R7, #20 ; odczekaj czas 20*50ms=1s

ODLICZANIE:
	JNB TF0, $ ; czekaj na odliczenie 50ms
	MOV TH0,#TH0_SET ; 180 cykli
	CLR TF0 
	DJNZ R7, ODLICZANIE ; odczekanie 1 sekundy

	; wyswietlanie sekund
	INC R4
	MOV A, R4
	LCALL WYSWIETL

	MOV A, R4
	CJNE A, #60, LOOP

	; wyswietlanie minut
	INC R3
	MOV A, #0
	MOV R4, A
	LCALL WYSWIETL
	MOV A, R3
	CJNE A, #60, LOOP

	MOV A, #0
	MOV R3, A
	MOV R4, A
	LCALL WYSWIETL

	LJMP LOOP
	RET

WYSWIETL:
    LCALL LCD_CLR

	; minuta 
    MOV A,R3
    LCALL BCD

    MOV A,#':'
    LCALL WRITE_DATA

	; sekunda
    MOV A,R4
    LCALL BCD
    RET

ZMIEN_LED:
    MOV R6, #100    ; co 5 sek
	CPL LED
	RET

BRZECZYK:
    CPL BRZEK
    MOV R2, #40 ; 2 sekundy brzeczyk
DZWIEK:
	JNB TF0, $ ; czekaj na odliczenie 50ms
	MOV TH0,#TH0_SET ; 180 cykli
	CLR TF0 

    DJNZ R2, DZWIEK
    CPL BRZEK
    RET

SPRAWDZANIE:
	CJNE A, #0, SPRAWDZ_1
	RET

SPRAWDZ_1:
	CJNE A, #1, SPRAWDZ_2
	RET

SPRAWDZ_2:
	CJNE A, #2, SPRAWDZ_3
	RET

SPRAWDZ_3:
	CJNE A, #3, SPRAWDZ_4
	RET

SPRAWDZ_4:
	CJNE A, #4, SPRAWDZ_5
	RET

SPRAWDZ_5:
	CJNE A, #5, BLAD
	RET
    
BLAD:
	MOV A,#5
    LCALL DELAY_100MS
    LCALL LCD_CLR
    MOV A, #'E'
    LCALL WRITE_DATA
    MOV A, #'R'
    LCALL WRITE_DATA
    MOV A, #'R'
    LCALL WRITE_DATA
    MOV A, #'O'
    LCALL WRITE_DATA
    MOV A, #'R'
    LCALL WRITE_DATA

    MOV A, #10
    LCALL DELAY_100MS
    
    ; if A == 2 to skok do sekundy, jesli nie to do startu
    MOV A, R2
    CJNE A, #0, BLAD_SEK

	LJMP START
    RET

BLAD_SEK:
    LCALL LCD_CLR

	MOV A, R3
	LCALL BCD
	MOV A, #':'
    LCALL WRITE_DATA
    LJMP SEKUNDA
    RET

BCD:
    MOV B,#10
    DIV AB
    SWAP A
    ADD A,B
    LCALL WRITE_HEX
	RET
    NOP