; Assume the following:
; - The present date is stored in present_date as a string in the format "dd/mm/yyyy"
; - The number of people to process is stored in num_people
; - The name and birthdate of each person are stored in an array of records
; - Each record contains the following fields:
;   - name: a 35-byte character array for the person's name
;   - birthdate: a 10-byte character array for the person's birthdate in the format "dd/mm/yyyy"
; - The output file is named "output.txt"

data segment
    present_date db 10, ?, 0         ; Present date in "dd/mm/yyyy" format
    num_people   dw ?                ; Number of people to process
    people       db 35, 10 dup(?)    ; Array of people's names
                 db 10, 35 dup(?)    ; Array of people's birthdates
    output_file  db 'output.txt', 0  ; Output file name
data ends

code segment
assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax                      ; Initialize data segment

    ; Open output file
    mov ah, 3ch                     ; DOS function to create or open a file
    lea dx, output_file             ; Load output file name
    mov cx, 0                       ; Access mode: write-only
    int 21h                         ; Call DOS interrupt
    jc error                        ; Jump to error handler if carry flag is set
    mov [output_handle], ax         ; Save file handle

    ; Process each person
    mov cx, [num_people]            ; Load number of people to process
    lea si, people                  ; Load address of people array
    process_loop:
        ; Read name and birthdate
        mov ah, 0ah                 ; DOS function to read a string into a buffer
        lea dx, [si]                ; Load address of name buffer
        int 21h                     ; Call DOS interrupt
        lea dx, [si + 35]           ; Load address of birthdate buffer
        int 21h                     ; Call DOS interrupt

        ; Calculate age
        lea di, [si + 35]           ; Load address of birthdate buffer
        call calculate_age          ; Call subroutine to calculate age

        ; Write result to output file
        mov ah, 40h                 ; DOS function to write to a file
        mov bx, [output_handle]     ; Load file handle
        lea dx, [si]                ; Load address of name buffer
        mov cx, 35                  ; Number of bytes to write (name)
        int 21h                     ; Call DOS interrupt
        lea dx, [si + 35]           ; Load address of age buffer
        mov cx, 2                   ; Number of bytes to write (age)
        int 21h                     ; Call DOS interrupt

        ; Move to next record
        add si, 45                  ; Each record is 45 bytes long (35 for name, 10 for birthdate)
        loop process_loop

    ; Close output file
    mov ah, 3eh                     ; DOS function to close a file
    mov bx, [output_handle]         ; Load file handle
    int 21h                         ; Call DOS interrupt

    ; Exit program
    mov ah, 4ch                     ;
