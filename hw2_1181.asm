TITLE PHONBURIS NAENGNOI
SUBTTL 6410451181
STACK SEGMENT STACK
DW 64 DUP(?)

STACK ENDS

DATA SEGMENT
    RATE DW 1200 
    FRIEND DW 5 
    NET DW ?
    PAY DW ?
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

    FIRST PROC
        
        MOV AX,DATA ; initialize DS
        MOV DS,AX 
        
        MOV AX,FRIEND 
        MOV BX,RATE ; assign RATE to BX and we will use it as an operand
        
        ; AX : FRIEND, BX : RATE
        MUL BX ; multiply FRIEND with RATE (DX:AX = AX * BX)
        
        ; เก็บผลลัพธ์สําหรับราคาอาหารของทุกคนรวมกันไว้ใน NET (store 32 bits into NET)
        MOV [NET],AX
        MOV [NET+2],DX

        MOV BX,AX ; ฝาก AX ไว้ที่ BX เพราะต้อง decrease FRIEND และ convert friend from byte to word
        MOV AX,FRIEND 
        DEC AX ; จำนวนเพื่อนที่ต้องจ่าย (ยกเว้นเจ้าของวันเกิด)
        CBW
        MOV CX,AX ; MOV FRIEND to CX to use it as an operand
        MOV AX,BX ; MOV BX back to AX

        DIV CX ; (DX,AX)/CX
        MOV PAY,AX 

        MOV AH,4CH 
        INT 21H
    FIRST ENDP
CODE ENDS

END FIRST