    LJMP START
    ORG 100H

START:
    LCALL LCD_CLR
    CLR C
    MOV R0, #0
    MOV R1, #0

    LCALL WAIT_KEY
    MOV R0, A
    LCALL WRITE_HEX

LOOP:
    LCALL WAIT_KEY
    CJNE A, #10, ODEJMOWANIE 
    CLR A

DOD:
    MOV A, #'+'     ;dodawanie
    LCALL WRITE_DATA

    LCALL WAIT_KEY
    MOV R1, A
    LCALL WRITE_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    MOV A, R1
    ADD A, R0
    MOV R0, A

LOOP2:
    LCALL BCD
    CLR A

LOOP3:
    LCALL WAIT_KEY
    CJNE A, #10, KLIK_B
    ; plus

    LCALL LCD_CLR
    MOV A, R0
    LCALL BCD

    SJMP DOD
    NOP

BCD:
    MOV B, #10
    DIV AB
    SWAP A
    ADD A, B
    LCALL WRITE_HEX
    RET

BCD_DZIELENIE:
    MOV R1, B
    LCALL BCD
    MOV A, #'R'
    LCALL WRITE_DATA
    MOV A, R1
    LCALL WRITE_HEX
    RET

DODAWANIE:
    CJNE A, #10, LOOP
    LJMP DOD
    RET

KLIK_B:
    CJNE A, #11, KLIK_C
    ; minus

    LCALL LCD_CLR
    MOV A, R0
    LCALL BCD
    
    MOV A, #11
    LJMP ODEJMOWANIE

    RET

ODEJMOWANIE:
    CJNE A, #11, MNOZENIE
    CLR A
    ; odejmowanie

    MOV A, #'-'
    LCALL WRITE_DATA

    LCALL WAIT_KEY
    MOV R1, A
    LCALL WRITE_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    MOV B, R1
    MOV A, R0
    CLR C
    SUBB A, B
    JC UJEMNA

    MOV R0, A

    LJMP LOOP2

    RET


DZIELENIE:
    CJNE A, #13, DODAWANIE
    CLR A

    ; dzielenie

    MOV A, #'/'
    LCALL WRITE_DATA

    LCALL WAIT_KEY
    MOV R1, A
    LCALL WRITE_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    MOV B, R1
    MOV A, R0

    MOV A, B
    LJMP DZIELENIE_ZERO

KLIK_C:
    CJNE A, #12, KLIK_D

    ; mnozenie
    LCALL LCD_CLR
    MOV A, R0
    LCALL BCD
    
    MOV A, #12
    LJMP MNOZENIE
    RET

DZIEL_DALEJ:
    MOV A, R0
    DIV AB
    MOV R0, A
    LCALL BCD_DZIELENIE

    LJMP LOOP3

    ;dzielenie tu zrobic
    RET

DZIELENIE_ZERO:
    CJNE A, #0, DZIEL_DALEJ
    LCALL BLAD

    LCALL LCD_CLR
    MOV A, R0
    LCALL BCD
    LJMP DZIELENIE

MNOZENIE:
    CJNE A, #12, DZIELENIE
    CLR A

    ; mnozenie

    MOV A, #'*'
    LCALL WRITE_DATA

    LCALL WAIT_KEY
    MOV R1, A
    LCALL WRITE_HEX

    MOV A, #'='
    LCALL WRITE_DATA

    MOV B, R0
    MOV A, R1
    MUL AB
    MOV R0, A

    LJMP LOOP2
    RET

UJEMNA:
    CPL A
    INC A

    MOV R1, A

    MOV A, #'-'
    LCALL WRITE_DATA

    MOV A, R1
    CLR C
    LCALL BCD

    MOV A, #20
    LCALL DELAY_100MS

    LCALL BLAD
    
    LJMP START
    RET

KLIK_D:
    CJNE A, #13, KLIK_A
    ; podziel

    LCALL LCD_CLR
    MOV A, R0
    LCALL BCD ; tutaj lcall do A tylko
    
    MOV A, #13
    LJMP DZIELENIE

    RET

KLIK_A:
    LJMP DOD
    RET

BLAD:
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

    MOV A, #20
    LCALL DELAY_100MS

    RET