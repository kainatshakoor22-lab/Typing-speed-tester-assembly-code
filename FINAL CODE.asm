.model small              ;memory model (code + data 64KB)
.stack 100h               ;size 256 bytes

.data                     

titleMsg db 13,10,'TYPING SPEED TESTER',13,10,'$' 
infoMsg  db 13,10,'Type the text below and press ENTER:',13,10,'$'
para     db 'typing speed test in assembly language','$' 
newline  db 13,10,'$'

input    db 100 dup('$'); buffer to store typed characters

startTime dw ? 
endTime   dw ?
timeDiff  dw ?
words     dw 0 

msgTime  db 13,10,'Time taken (centiseconds): $'
msgWords db 13,10,'Words typed: $'
msgWPM   db 13,10,'Approx WPM: $'

.code                     
main proc                

   mov ax, @data          ; data segment load
   mov ds, ax             ; must to initilise ds

   ; ---- Display title ----
   mov ah, 09h            ; DOS function(string print)
   lea dx, titleMsg       ; title address 
   int 21h                ; interrupt call to print title

   lea dx, infoMsg        ; instruction message ka address
   int 21h                ; instruction print

   lea dx, para           ; paragraph ka address
   int 21h                ; paragraph print

   lea dx, newline        
   int 21h

   ; ---- Wait for ENTER ----
   mov ah, 01h            ; keyboard se ek key read 
   int 21h                ; ENTER press 

   ; ---- Start time ----
   mov ah, 2Ch            ; get time function
   int 21h                ; CH=hour, CL=min, DH=sec, DL=centisecond
   mov startTime, dx      ; centiseconds save in dx

   ; ---- Read typing input ----
   lea si, input          ; SI input buffer ke start pe
read_chars:
   mov ah, 01h            ; ek character read karo
   int 21h
   cmp al, 13             ; ENTER key check (ASCII 13)
   je input_done          ; agar ENTER ho to input end
   mov [si], al           ; typed char buffer me store
   inc si                 ; next position
   jmp read_chars         ; loop repeat

input_done:
   mov byte ptr [si], '$' ; string end symbol add

   ; ---- End time ----
   mov ah, 2Ch            ; again system time get
   int 21h
   mov endTime, dx        ; end time save

   ; ---- Time difference ----
   mov ax, endTime        ; end time AX me
   sub ax, startTime      ; start time minus
   mov timeDiff, ax       ; result timeDiff me

   ; ---- Count words ----
   lea si, input          ; buffer start
   mov words, 1           ; first word count se start

cnt_loop:
   mov al, [si]           ; current character
   cmp al, '$'            ; string end?
   je cnt_done            ; haan to loop end
   cmp al, ' '            ; space mila?
   jne cnt_next           ; nahi mila to next char
   inc words              ; space mila to word count++

cnt_next:
   inc si                 ; next character
   jmp cnt_loop           ; loop repeat

cnt_done:

   ; ---- Display time ----
   mov ah, 09h            ;take time from syastem
   lea dx, msgTime        ; time message
   int 21h

   mov ax, timeDiff       ; time value AX me
   call print_num         ; number print procedure

   ; ---- Display words ----
   mov ah, 09h
   lea dx, msgWords       ; words message
   int 21h

   mov ax, words          ; total words
   call print_num         ; print words

   ; ---- Display WPM (Corrected Logic) ----
   mov ah, 09h
   lea dx, msgWPM         ; WPM message
   int 21h

   mov ax, words          ; AX = words
   mov bx, 6000           ; 1 minute = 6000 centiseconds
   xor dx, dx             ; High bits clear karna zaroori hai
   mul bx                 ; DX:AX = words * 6000

   mov bx, timeDiff       ; BX = time taken
   cmp bx, 0              ; division by zero check
   jbe skip_wpm           ; agar zero ho to skip
   div bx                 ; AX = (words * 6000) / timeDiff

skip_wpm:
   call print_num         ; WPM print

   ; ---- Exit program ----
   mov ah, 4Ch            ; program terminate
   int 21h

main endp                 ; main end

; ------------------------
; Print number in AX
; ------------------------
print_num proc
   push ax                ; registers save
   push bx
   push cx
   push dx

   mov cx, 0              ; digit count
   mov bx, 10             ; base 10

pn_loop:
   xor dx, dx             ; DX clear
   div bx                 ; AX / 10
   push dx                ; remainder push
   inc cx                 ; digit count++
   cmp ax, 0              ; quotient zero?
   jne pn_loop            ; nahi to repeat

pn_print:
   pop dx                 ; digit pop
   add dl, '0'            ; ASCII convert
   mov ah, 02h            ; character print
   int 21h
   loop pn_print          ; all digits print

   pop dx                 ; registers restore
   pop cx
   pop bx
   pop ax
   ret
print_num endp

end main