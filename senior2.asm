SSEG SEGMENT STACK
    DW 64 DUP(?)
SSEG ENDS

DSEG SEGMENT
    FILENAME DB "DATA.TXT",0
    HANDLE DW ? ; c pointer

    STG DB 3 DUP(?), '$'
    NAMEPER DB 20 DUP(?), '$' 
    HEI DW ? ; height
    WEI DW ? ; weight
    PER DW 0
    THEI DW 0 ; total height
    TWEI DW 0 ; total weight
    
    LINE DB "        NAME         HEIGHT(CENTIMETERS) WEIGHT(KILOGRAMS) CHARACTERISTIC",13,10,'$'
    STG_OW DB "OVERWEIGHT",'$'
    STG_NM DB "NORMAL",'$'
    STG_SK DB "SKINNY",'$'
    STG_AVH DB "AVERAGE HEIGHT IS ",'$'
    STG_AVW DB "AVERAGE WEIGHT IS ",'$'
    STG_HU DB " CENTIMETERS",13,10,'$'
    STG_WU DB " KILOGRAMS",13,10,'$'
DSEG ENDS

CSEG SEGMENT
ASSUME DS:DSEG,CS:CSEG,SS:SSEG

MAIN PROC
    MOV AX,DSEG
    MOV DS,AX

    MOV AH,9
    LEA DX,LINE
    INT 21H

    MOV AH,3DH
    MOV AL,0
    LEA DX,FILENAME
    INT 21H ; AX = address of file
    MOV HANDLE,AX

    READ_FILE:  MOV AH,3FH
                MOV BX,HANDLE
                MOV CX,20
                LEA DX,NAMEPER
                INT 21H

                MOV AH,3FH
                MOV CX,3
                LEA DX,STG
                INT 21H
                CALL ATOB
                MOV THEI,AX
                ADD THEI,AX

                MOV AH,3FH
                MOV CX,3
                LEA DX,STG
                INT 21H
                CALL ATOB
                MOV WEI,AX
                ADD TWEI,AX

                MOV AX,HEI
                MOV CX,0
                CMP AX,CX
                JE READ_EXIT ; เตรียมออก
                JMP READ_CON
    
    READ_EXIT:  MOV AX,WEI
                MOV CX,0
                CMP AX,CX
                JE READ_DONE ; ออกแล้ว
                JMP READ_CON

    READ_CON:   CALL PRINTLN
    
                ADD PER,1
                MOV AH,3FH
                MOV CX,2
                LEA DX,STG
                INT 21H
                JMP READ_FILE

    READ_DONE:  MOV AH,2 ; ขึ้นบรรทัดใหม่
                MOV DL,13 ; carriage return (move cursor to front)
                INT 21H ; พิมพ์ 1 character 
                MOV DL,10 ; line feed (new line)
                INT 21H ; พิมพ์ 1 character

                MOV AH,9
                LEA DX,STG_AVH
                INT 21H

                MOV AX,THEI
                CWD
                MOV BX,PER
                DIV BX
                CALL BTOA

                MOV AH,9
                LEA DX,STG_HU
                INT 21H

                MOV AH,9
                LEA DX,STG_AVW
                INT 21H

                MOV AX,TWEI
                CWD
                MOV BX,PER
                DIV BX
                CALL BTOA

                MOV AH,9
                LEA DX,STG_WU
                INT 21H
    
                MOV AH,3EH
                MOV BX,HANDLE
                INT 21H

                MOV AH,4CH
                INT 21H

MAIN ENDP

ATOB PROC ; procedure ทำหน้าที่แปลงสตริงจาก ASCII เป็น binary แล้วเอาไปเก็บใน AX
    PUSH BX
    LEA SI,STG ; เก็บ offset ของสตริง
    MOV CX,3 ; เก็บความยาวของสตริง
    MOV AX,0 ; เก็บค่าเริ่มต้น
    ATOB_NEXT:  MOV DI,10
                MUL DI ; DX:AX=AX*10
                MOV BX,0
                MOV BL,[SI] ; get ASCII code

                CMP BL,'0' ; 30H
                JL ATOB_SKIP
                CMP BL,'9' ; 39H
                JG ATOB_SKIP

                SUB BX,'0' ; 0-9
                ADD AX,BX ; update partial result
    ATOB_SKIP:  INC SI
                LOOP ATOB_NEXT
    POP BX
    RET
ATOB ENDP

BTOA PROC ; procedure ทำหน้าที่แปลงตัวเลขจาก binary เป็น ASCII แล้วเอาไปเก็บใน NUM
    PUSH BX
    ; เหมือนกับในสไลด์ แค่เปลี่ยนแปลงให้ใช้กับค่าบวกทั้งหมด ไม่มีค่าลบ
    LEA BX,STG ; เก็บ offset ของสตริงที่จะเก็บตัวเลข
    MOV CX,3 ; ใส่ช่องว่าง
    BTOA_FILL:  MOV BYTE PTR[BX],' '
                INC BX
                LOOP BTOA_FILL
    PUSH AX ; AX = the number to display
    MOV DI,10 ; divide by 10
    JMP BTOA_NEXT
    BTOA_NEXT:  MOV DX,0
                DIV DI ; (AX)/10
                ADD DX,'0' ; convert to ASCII code
                DEC BX
                MOV [BX],DL ; store character in string
                CMP AX,0 ; finish?
                JNE BTOA_NEXT ; no, get next digit
    POP AX ; get original number
    JMP BTOA_DONE
    BTOA_DONE:  MOV AH,9 ; mode: display string
                LEA DX,STG ; offset of string to display
                INT 21H ; display string
                POP BX
            RET
BTOA ENDP

PRINTLN PROC
    PUSH BX

    MOV AH,9
    LEA DX,NAMEPER
    INT 21H

    MOV CX,8
    CALL PADDING

    MOV AX,HEI
    CALL BTOA

    MOV CX,16
    CALL PADDING

    MOV AX,WEI
    CALL BTOA

    MOV CX,11
    CALL PADDING

    CALL CHARACTER
    MOV AH,9
    INT 21H

    MOV AH,2 ; ขึ้นบรรทัดใหม่
    MOV DL,13 ; carriage return (move cursor to front)
    INT 21H ; พิมพ์ 1 character 
    MOV DL,10 ; line feed (new line)
    INT 21H ; พิมพ์ 1 character

    POP BX
    RET
PRINTLN ENDP

CHARACTER PROC
    PUSH BX

    MOV AX,WEI
    MOV BX,HEI
    ; find overweight (W > H-107)
    ; W > H-107 
    MOV CX,107

    SUB BX,CX
    CMP AX,BX
    JG OVERWEIGHT

    MOV AX,WEI
    MOV BX,HEI
    ; find skinny (W < H-113)
    ; W < H-113 
    MOV CX,113

    SUB BX,CX
    CMP AX,BX
    JL SKINNY

    ; normal
    LEA DX,STG_NM
    JMP CALC_DONE

    OVERWEIGHT: LEA DX,STG_OW
                JMP CALC_DONE

    SKINNY: LEA DX,STG_SK
            JMP CALC_DONE

    CALC_DONE:  POP BX
                RET
CHARACTER ENDP


PADDING PROC ; procedure ทำหน้าที่ใส่ช่องว่าง CX ตัวเพื่อจัดรูปค่าที่พิมพ์ออก
    MOV AH,2 ; mode: display character
    PAD:    MOV DL,' ' ; pad CX spaces
            INT 21H ; display character
            LOOP PAD
    RET
PADDING ENDP

CSEG ENDS
END MAIN