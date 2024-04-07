TITLE CHAYAKORN CHIESUWIKARN
SUBTTL 6410450117

STACK SEGMENT STACK
    DW 64 DUP(?)
STACK ENDS

DATA SEGMENT
    ; FILE HANDLE
    FILENAME DB "0117.TXT", 0
    FILEHANDLE DW ?

    ; MAIN input
    AMOUNT DB ? ; จำนวนคน
    NUM DB 4,?,4 DUP(?) ; ATOB Handle

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
        MOV AX,DATA ; DS initialize
        MOV DS,AX
        
        LEA DX,AMOUNT
        CALL AMOUNT_INPUT
        
        MOV AMOUNT,AX 
        
        CALL DATE_INPUT
        
        MOV CX,AX
        MOV DI,0
    NEXT1:
        CALL DATE_INPUT

    
    MAIN ENDP
    
    AMOUNT_INPUT PROC
        MOV AH, 0AH
        INT 21H 
        CALL ATOB
        CALL NEXT_LINE
        RET
    AMOUNT_INPUT ENDP
    
    ATOB PROC
        PUSH CX
        PUSH DI
        MOV CH,0
        MOV CL,NUM + 1
        LEA DI,NUM + 2
        MOV AX,0
    NEXT2:
        MOV SI,10
        MUL SI          ;DX:AX = AX * 10
        MOV BX,0
        MOV BL,[DI]     ;Get ASCII Code
        SUB BX,30H
        ADD AX,BX       ;Update Partial Result
        INC DI
        LOOP NEXT2
        POP DI
        POP CX
        RET
    ATOB ENDP

    NEXT_LINE PROC
        PUSH AX
        PUSH DX
        MOV AH,2
        MOV DL,10
        INT 21H
        MOV DL,13
        INT 21H
        POP DX
        POP AX
        RET
    NEXT_LINE ENDP
END MAIN