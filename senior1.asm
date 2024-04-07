TITLE NATTAPONG PIMPISAN
SUBTTL 6310401327

STACK SEGMENT STACK
    DW 64 DUP(?)
STACK ENDS

DATA SEGMENT
    EMPLOYEE    DW  ?               ;จำนวนพนักงาน
    NUM         DB  4,?,4 DUP(?)    ;เก็บ input ตัวเลข
    TIME        DW  128 DUP(?)      ;เวลาในการทำงานทั้งหมด
    WAGE        DW  128 DUP(?)      ;ค่าแรง
    WEEK        DW  128 DUP(?)      ;จำนวนสัปดาห์
    DAY         DW  128 DUP(?)      ;จำนวนวัน
    HOUR        DW  128 DUP(?)      ;จำนวนชั่วโมง
    TNAME       DB  37,?,37 DUP(?)  ;ชื่อพนักงาน
    COUNT       DW  0
    LISTNAME    DB  512 DUP(?)      ;list ชื่อพนักงาน
    LENNAME     DW  128 DUP(?)      ;ความยาวชื่อพนักงาน
    TABTABLE    DB  "NAME		HOURS WORKED	WEEKS	DAYS	HOURS	WAGE(BAHT)",13,10,'$'
    OUTPUT      DB  55 DUP(?),13,10,'$'
DATA ENDS

CODE SEGMENT
    ASSUME SS:STACK, DS:DATA, CS:CODE
MAIN PROC
    ;initialize
    MOV AX,DATA
    MOV DS,AX

    ;รับจำนวนพนักงาน
    LEA DX,NUM
    CALL GET_NUMBER
    
    MOV EMPLOYEE,AX ;เก็บจำนวนพนักงานไว้ที่ EMPLOYEE

    MOV CX,AX       ;กำหนดรอบ loop
    MOV DI,0
NEXT1:
    CALL GET_NAME      ;รับ input ชื่อพนักงาน
    CALL STORE_NAME    ;เก็บชื่อไว้ใน list LISTNAME
    CALL STORE_TIME    ;เก็บเวลาการทำงานไว้ใน list TIME
    LOOP NEXT1

    ;display Table Title
    MOV AH,9
    LEA DX,TABTABLE
    INT 21H

    MOV DI,0
    MOV CX,EMPLOYEE
    MOV COUNT,0
L:
    CALL CAL_NUMBER
    LOOP L

    MOV AH,4CH
    INT 21H


MAIN ENDP

GET_NAME PROC           ;รับ input ชื่อพนักาน
    LEA DX,TNAME        ;DX point to TNAME
    MOV AH,0AH
    INT 21H
    MOV AL,TNAME + 1    ;AL = length name
    CBW                 ;AX = length name
    MOV LENNAME[DI],AX  ;store length for each name
    CALL NEXT_LINE 
    RET
GET_NAME ENDP

GET_NUMBER PROC         ;รับ input ตัวเลข
    MOV AH,0AH
    INT 21H
    CALL ATOB
    CALL NEXT_LINE
    RET
GET_NUMBER ENDP

STORE_NAME PROC         ;คัดลอกชื่อพนักงานแต่ละคนไว้ใน LISTNAME
    MOV BX,2            ;BX = index ของชื่อใน TNAME
    MOV SI,COUNT        ;SI = index แรกที่จะเก็บชื่อใน LISTNAME
    ADD COUNT,AX        ;Update Total Length
NEXT:
    MOV AL,TNAME[BX]
    MOV LISTNAME[SI],AL
    INC BX
    INC SI
    MOV AX,BX
    SUB AX,2
    CMP AX,LENNAME[DI]  
    JB NEXT
    RET
STORE_NAME ENDP

STORE_TIME PROC         ;รับจำนวนเวลาทำงานแต่ละคนเก็บไว้ที่ TIME
    LEA DX,NUM
    CALL GET_NUMBER
    MOV TIME[DI],AX
    MOV DAY[DI],AX
    ADD DI,2
    RET
STORE_TIME ENDP

CAL_NUMBER PROC
    CALL CLEARBUFF      ;Clear Output
    CALL NAMETOBUFF     ;Copy name to OUTPUT

    ;hour to OUTPUT
    LEA BX,OUTPUT[22]
    MOV AX,TIME[DI]
    CALL BTOA
    MOV OUTPUT[25],9H   ;ASCII of TAP

    CALL CAL_WEEK
    MOV BX,10000
    CALL CAL_WAGE
    ;week to OUTPUT
    LEA BX,OUTPUT[29]
    MOV AX,WEEK[DI]     ;Number to display
    CALL BTOA
    MOV OUTPUT[31],9H   ;ASCII of TAP

    CALL CAL_DAY
    MOV BX,1400
	CALL CAL_WAGE
	; day to OUTPUT
	LEA BX,OUTPUT[34]
	MOV	AX,DAY[DI]	    ;Number to display
	CALL BTOA
	MOV OUTPUT[36],9H	;ASCII of TAP
    
    CALL CAL_HOUR
    CALL CAL_WAGE

    LEA BX,OUTPUT[40]
    MOV AX,HOUR[DI]
    CALL BTOA
    MOV OUTPUT[44],9H
    ; wage to OUTPUT
	LEA BX,OUTPUT[52]
	MOV	AX,WAGE[DI]		; number to print
	CALL BTOA

	; display OUTPUT
	MOV AH,9H
	LEA DX,OUTPUT 			; offset of string
	INT 21H 				; display string

	ADD DI,2
    RET

CAL_NUMBER ENDP

CAL_WEEK PROC
	MOV DX,0
	MOV AX,TIME[DI]
	MOV BX,168
	IDIV BX				; hour/168
	MOV WEEK[DI],AX			; เก็บจำนวน week
	MOV DAY[DI],DX			; เก็บเศษ week
	RET
CAL_WEEK ENDP

CAL_DAY PROC
	MOV DX,0
	MOV AX,DAY[DI]
	MOV BX,24
	IDIV BX				; hour/24
	MOV DAY[DI],AX			; เก็บจำนวน day
	MOV HOUR[DI],DX			; เก็บเศษ day
	RET
CAL_DAY ENDP

CAL_HOUR PROC
    MOV DX,0
    MOV AX,HOUR[DI]
    MOV BX,50
    RET
CAL_HOUR ENDP

CAL_WAGE PROC
	IMUL BX
	ADD WAGE[DI],AX			; update WAGES
	RET
CAL_WAGE ENDP

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

BTOA PROC
	PUSH DI
	MOV DI,10 			; divide by 10
	NEXT3: 
	CWD
	DIV DI 				; (AX)/10
	ADD DX,'0' 			; convert to ASCII code
	DEC BX 
	MOV [BX],DL 			; store character in string
	CMP AX,0 			; finish?
	JNE NEXT3 			; no, get next digit
	POP DI
	RET
BTOA ENDP

NAMETOBUFF PROC			; copy name form LISTNAME to OUTPUT
	MOV SI,0
	MOV BX,COUNT
	MOV AX,LENNAME[DI]
	ADD COUNT,AX
NEXT4:
	MOV AL,LISTNAME[BX]
	MOV OUTPUT[SI],AL
	INC SI
	INC BX
	CMP BX,COUNT
	JB NEXT4
	RET
NAMETOBUFF ENDP

CLEARBUFF PROC				; clear buff
	MOV SI,0
	LEA BX,OUTPUT
NEXT5: 
	MOV BYTE PTR[BX],' '
	INC BX
	INC SI
	CMP SI,55
	JBE NEXT5
	RET
CLEARBUFF ENDP

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

CODE ENDS
    END MAIN