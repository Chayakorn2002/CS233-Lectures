TITLE CHAYAKORN CHIESUWIKARN
SUBTTL 6410450117

STACK SEGMENT STACK
    DW 64 DUP(?)
STACK ENDS

DATA SEGMENT
    ; FILE HANDLE
    FILENAME DB "0117.TXT", 0
    FILEHANDLE DW ?

    ; Each Person
    AMOUNT DB ? ; จำนวนคน
    DATE DB 10 DUP(?) ; วันที่
    
    ; Struct person
    LISTNAME DB 512 DUP(?) ; list ชื่อบุคคล

    ; Output Handle
    DATE_TITLE DB "TODAY’S DATE IS "
    OUTPUT_TITLE DB "NAME DATE OF BIRTH AGE"
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

    MAIN PROC      
        MOV AX,DATA ; initialize DS
        MOV DS,AX 
        MOV CX, 3 ; looped 3 times for 3 tables

    LOAD:
        CALL LOADER
        LOOP LOAD
        MOV AH,4CH ; จบการทำงาน
        INT 21H

    MAIN ENDP

    LOADER PROC 
        CALL TABLE_HANDLE
        CMP BYTE PTR[BX]+4, 'D' ; Check how the customer pay (The returned bx : TABLE...)
        JE CREDIT ; Credit card!
        JNE CASH ; Cash!

    CREDIT: 
        MOV DISCOUNT_PER,7 ; Credit card's discounting percent : 7 %
        LEA DX,CREDIT_MES ; Load offset to the output
        CALL OUTPUT
        JMP FOOD_HANDLE

    CASH:
        MOV DISCOUNT_PER,10 ; Credit card's discounting percent : 10 %
        LEA DX,CASH_MES ; Load offset to the output
        CALL OUTPUT

    FOOD_HANDLE:
        PUSH BX ; Keep BX in stack
        MOV AX,[BX] ; AX = food's price
        LEA BX,FOOD_MES
        CALL CONVERTER
        LEA DX,FOOD_MES ; DX = FOOD_MES (for outputing)
        CALL OUTPUT
        POP BX
    
    DRINK_HANDLE:
        PUSH BX ; Keep BX in stack
        MOV AX,[BX]+2 ; AX = drink's price
        LEA BX,DRINK_MES
        CALL CONVERTER
        LEA DX,DRINK_MES ; DX = DRINK_MES (for outputing)
        CALL OUTPUT
        POP BX 
    
    DISCOUNT_HANDLE:
        PUSH BX ; Keep BX in stack
        MOV AX,[BX] ; AX = food's price
        MUL DISCOUNT_PER ; DX,AX = food's price * discount rate
        MOV DI,100
        DIV DI ; DX,AX /= 100
        MOV DISCOUNT,AX ; AX = discount value
        LEA BX,DISCOUNT_MES 
        CALL CONVERTER
        LEA DX,DISCOUNT_MES ; DX = DISCOUNT_MES (for outputing)
        CALL OUTPUT
        POP BX 

    TOTAL_HANDLE:
        MOV AX,[BX] ; AX = food's price
        SUB AX,DISCOUNT ; Subtracting food's price with the discount value
        ADD AX,[BX]+2 ; Adding food's price with the drink's price

        LEA BX,TOTAL_MES
        CALL CONVERTER
        LEA DX,TOTAL_MES ; DX = TOTAL_MES (for outputing)
        CALL OUTPUT
        RET

    LOADER ENDP

    CONVERTER PROC

        MOV SI,16 ; offset of food's price
        MOV DI,10 ; temp value use to handle coverting

    CONVERT:
        CWD
        DIV DI ; DX,AX / DI
        ADD DX, '0' ; Convert DX to ASCII code
        MOV [BX][SI],DL ; replace the dup.. with ASCII value
        DEC SI ; moving to the next offset (right to left)
        CMP AX,0 
        JNE CONVERT ; loop until all the value have been converted
        RET

    CONVERTER ENDP

    TABLE_HANDLE PROC 

        CMP CX, 3;
        JE TABLE1_HANDLE ; CX = 3 / first 
        CMP CX, 2;
        JE TABLE2_HANDLE ; CX = 2 / second 
        CMP CX, 1;
        JE TABLE3_HANDLE ; CX = 1 / third 

    TABLE1_HANDLE:

        MOV DI,6 ; DI = 6
        LEA BX,TABLE_HEADER[DI] ; BX = TABLE_HEADER + 6
        MOV BYTE PTR[BX], '1' ; TABLE_HEADER + 6 (?) = 1
        LEA DX, TABLE_HEADER
        CALL OUTPUT     
        LEA BX,TABLE1
        JMP FINISH

    TABLE2_HANDLE:

        MOV DI,6 ; DI = 6
        LEA BX,TABLE_HEADER[DI] ; BX = TABLE_HEADER + 6
        MOV BYTE PTR[BX], '2' ; TABLE_HEADER + 6 (?) = 1
        LEA DX, TABLE_HEADER
        CALL OUTPUT     
        LEA BX,TABLE2
        JMP FINISH

    TABLE3_HANDLE:

        MOV DI,6 ; DI = 6
        LEA BX,TABLE_HEADER[DI] ; BX = TABLE_HEADER + 6
        MOV BYTE PTR[BX], '3' ; TABLE_HEADER + 6 (?) = 1
        LEA DX, TABLE_HEADER
        CALL OUTPUT     
        LEA BX,TABLE3
        JMP FINISH

    FINISH: 
        RET

    TABLE_HANDLE ENDP

    OUTPUT PROC

        SUB AX,AX ; Clear AX
        MOV AH,9 ; outputing string
        INT 21H
        RET
        
    OUTPUT ENDP

CODE ENDS

END MAIN








