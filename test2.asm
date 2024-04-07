; Set up file handle and buffer
.model small
.stack 100h
.data
  filename db "0117", 0
  filehandle dw ?
  buffer db 50 dup (?)

; Define the record structure for a person's data
struct person
  name db 35 dup (?)
  birthday db 10 dup (?)
endstruct

; Define the data segment
.data
  count dw ?
  people person 100 dup (?)

; Define the code segment
.code
  main proc
    ; Set up file handle
    call open_file

    ; Read the number of people
    call read_count
    ; Read each person's data
    call read_people

    ; Write the data to the file
    call write_people

    ; Close the file
    call close_file

    ; Terminate the program
    call exit_program
  main endp

; Open the output file
open_file proc
    mov ah, 3Ch ; create or open file
    lea dx, filename ; address of filename string
    mov cx, 0 ; read/write mode
    int 21h ; call DOS interrupt
    mov filehandle, ax ; save file handle
    ret
open_file endp

; Read the number of people from the user
read_count proc
    mov ah, 1 ; input character from keyboard
    int 21h ; call DOS interrupt
    sub al, '0' ; convert character to number
    mov count, ax ; save count
    ret
read_count endp

; Read the data for each person from the user
read_people proc
    mov bx, offset people
    mov cx, count
    read_loop:
        ; Read the name
        call read_string
        ; Copy the name into the person struct
        mov di, bx
        mov si, offset buffer+1 ; skip the length byte
        mov cx, 35
        rep movsb
        ; Read the birthday
        call read_string
        ; Copy the birthday into the person struct
        mov di, bx+35
        mov si, offset buffer+1 ; skip the length byte
        mov cx, 10
        rep movsb
        ; Move to the next person struct
        add bx, sizeof.person
        loop read_loop
    ret
read_people endp

; Write the data for each person to the output file
write_people proc
    mov ah, 40h ; write to file
    mov bx, filehandle
    mov cx, count
    mov dx, offset people
    int 21h ; call DOS interrupt
    ret
write_people endp

; Close the output file
close_file proc
    mov ah, 3Eh ; close file
    mov bx, filehandle
    int 21h ; call DOS interrupt
    ret
close_file endp

; Read a string from the user
read_string proc
    mov ah, 0Ah ; buffered input
    lea dx, buffer
    int 21h ; call DOS interrupt
    ret
read_string endp

; Terminate the program
exit_program proc
    mov ah, 4Ch ; terminate with return code
    xor al, al ; return code of 0
    int 21h ; call DOS interrupt
    ret
exit_program endp
end
