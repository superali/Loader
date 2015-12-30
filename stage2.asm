org 0x0		; offset to 0, we will set segments later

bits 16		; we are still in real mode

 
jmp main	; jump to main

;*************************************************;
;	Prints a string
;	DS=>SI: 0 terminated string
;************************************************;

Print:
			lodsb		; load next byte from string from SI to AL
			or	al, al	; Does AL=0?
			jz	PrintDone	; Yep, null terminator found-bail out
			mov	ah,	0eh	; Nope-Print the character
			int	10h
			jmp	Print	; Repeat until null terminator found
PrintDone:
			ret		; we are done, so return

 
clear:
        mov al, 02h	
        mov ah, 00h
        int 10h	
        ret

shut_down:
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xf000
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret 
get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret

strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret	
;*************************************************;
;	Second Stage Loader Entry Point
;************************************************;

main: 
			push	cs	
			pop	ds

			mov	si, msg1
			call	Print
   mainloop:
                 mov si, prompt
                 call Print
               
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; yes, ignore it
 
   mov si, buffer
   mov di, cmd_i  ; 
   call strcmp
   jc .i
   
   mov si, buffer
   mov di, cmd_I  ; 
   call strcmp
   jc .i
   
   mov si, buffer
   mov di, cmd_helpl  ; "help" command
   call strcmp
   jc .help
 
  mov si, buffer
   mov di, cmd_helpu  ; "help" command
   call strcmp
   jc .help
   
   mov si, buffer
   mov di, cmd_cs1
   call strcmp
   jc .clearSCR

 mov si, buffer
   mov di, cmd_cs2
   call strcmp
   jc .clearSCR
   
    mov si, buffer
   mov di, cmd_cs3
   call strcmp
   jc .clearSCR
   
    mov si, buffer
   mov di, cmd_cs4
   call strcmp
   jc .clearSCR
   
   mov si, buffer
   mov di, cmd_re1
   call strcmp
   jc .reboot
   
   mov si, buffer
   mov di, cmd_re2
   call strcmp
   jc .reboot
   
   mov si, buffer
   mov di, cmd_re3
   call strcmp
   jc .reboot
   
   mov si, buffer
   mov di, cmd_re4
   call strcmp
   jc .reboot
    
   mov si, buffer
   mov di, cmd_shutl
   call strcmp
   jc shut_down
   
   mov si, buffer
   mov di,cmd_shutu
   call strcmp
   jc shut_down
      
   mov si,badcommand 
   call Print
   jmp mainloop
  
 .reboot:
   int 0x19
 .clearSCR:
  call clear   
   jmp mainloop

 .i:
   mov si, msg_i1
   call Print
   mov si, msg_i2
   call Print
   mov si, msg_i3
   call Print
 
   jmp mainloop
 
 .help:
   mov si, msg_help
   call Print
 
   jmp mainloop
        
		 
;*************************************************;
;	Data Section
;************************************************;
msg1 db 'ENTER commands or h for help',13,10,0
prompt           db '$>', 0 
msg_i1   db 'HI THIS IS A BASIC SIMPLE SIMULATION OF AN OPERATING SYSTEM PRESENTED AS A COURSE PROJECT',13,10,'STUDENTS :',13,10, 0
msg_i2   db'Ali Al-baiti ',13,10,'Hashed mohammed',13,10,'Hadi Mohammed',13,10,'Manal Omer',13,10,'Nehaia Mohsen',13,10,0
msg_i3  db'Supervisor : dr Khaled Aboud',13,10,'OS prperties :',13,10,'Type : 16 bit based os',13,10,'File System : FAT12',13,10,0
badcommand       db 'invalid command entered.', 0x0D, 0x0A, 0
cmd_i            db 'i', 0
cmd_I            db'I',0
cmd_helpu         db 'H', 0
cmd_helpl         db 'h', 0

msg_help db 'OS: Commands:',13,10,'i : information ',13,10,'h : HELP',13,10,'cs : clear screen',13,10,'re : reboot',13,10,'s :shut_down',13,10, 0
cmd_shutl     db 's',0
cmd_shutu     db 'S',0
cmd_cs1       db 'cs', 0
cmd_cs2       db 'CS', 0 
cmd_cs3       db 'cS', 0 
cmd_cs4       db 'Cs', 0  
cmd_re1       db 're',0
cmd_re2       db 'rE',0
cmd_re3       db 'Re',0
cmd_re4       db 'RE',0

buffer times 64 db 0
