TITLE CHAYAKORN CHIESUWIKARN
SUBTTL 6410450117
STACK SEGMENT STACK
DW 64 DUP(?)

STACK ENDS

DATA SEGMENT
    RATE DW 1200D ; ผู้ตรวจอาจเปลี่ยนราคาได้
    FRIEND DB 5D ; ผู้ตรวจอาจเปลี่ยนจํานวนได้
    NET DW ?
    PAY DW ?
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STACK

    FIRST PROC
        
        MOV AX,DATA ; initialize DS
        MOV DS,AX 
        
        MOV AL,FRIEND ; copy ค่าจาก FRIEND มาเก็บที่ AL
        CBW ; convert FRIEND จาก byte เป็น word
        MOV BX,RATE ; assign RATE to BX and we will use it as an operand
        
        ; AX : FRIEND, BX : RATE
        MUL BX ; multiply FRIEND with RATE (DX:AX = AX * BX)
        
        ; เก็บผลลัพธ์สําหรับราคาอาหารของทุกคนรวมกันไว้ใน NET (store 32 bits into NET)
        MOV [NET],AX
        MOV [NET+2],DX

        MOV BX,AX ; ฝาก AX ไว้ที่ BX เพราะต้อง decrease FRIEND และ convert friend from byte to word
        MOV AL,FRIEND 
        DEC AL ; จำนวนเพื่อนที่ต้องจ่าย (ยกเว้นเจ้าของวันเกิด)
        CBW
        MOV CX,AX ; MOV FRIEND to CX to use it as an operand
        MOV AX,BX ; MOV BX back to AX

        DIV CX ; (DX,AX)/CX
        MOV PAY,AX ; ค่าอาหารที่เพื่อนแต่ละคนต้องจ่าย ยกเว้นเจ้าของวันเกิด โดยตัดเศษสตางค์ทิ้ง

        MOV AH,4CH ; จบการทำงาน
        INT 21H
    FIRST ENDP
CODE ENDS

END FIRST