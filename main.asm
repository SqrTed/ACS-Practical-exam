bits 32 ; assembling for the 32 bits architecture

; declare the EntryPoint (a label defining the very first instruction of the program)
global start        

; declare external functions needed by our program
extern exit,scanf,printf,fopen,fclose,fread,fprintf            
import exit msvcrt.dll    
import scanf msvcrt.dll
import printf msvcrt.dll
import fopen msvcrt.dll
import fread msvcrt.dll
import fclose msvcrt.dll
import fprintf msvcrt.dll

; our data is declared here (the variables needed by our program)
segment data use32 class=data
    ; ...
    file resb 20
    char db 0
    format db "%s",0
    format_int db "%d",0
    acces_1 db "r",0
    acces_2 db "a",0
    output db "output.txt",0
    temporary resb 60
    text resb 100
    msg_1 db "Please insert the file: ",0
    msg_2 db "Please insert the special character: ",0
    msg_3 db "Please insert n: ",0
    msg_error db "Error during opening file!!!",0
    descriptor_1 dd 0
    descriptor_2 dd 0
    len db 0
    n db 0
    
; our code starts here
segment code use32 class=code
    start:
        ; ...
        
        ;print the filename msg_1
        push dword msg_1
        call [printf]
        add esp, 4*1
        
        ;reading the filename
        push dword file
        push dword format
        call [scanf]
        add esp, 4*2
        
        ;print the char msg
        push dword msg_2
        call [printf]
        add esp, 4*1
        
        ;read the character
        push dword char
        push dword format
        call [scanf]
        add esp, 4*2
        
        ;print n msg
        push dword msg_3
        call [printf]
        add esp, 4*1
        
        push dword n
        push dword format_int
        call [scanf]
        add esp, 4*2
        
        ;open the input file
        push dword acces_1
        push dword file
        call [fopen]
        add esp, 4*2
        
        mov [descriptor_1],eax ;saving the descriptor
        cmp eax,0 ;see if it is an error
        je open_error
        
        ;open the output file
        push dword acces_2
        push dword output
        call [fopen]
        add esp, 4*2
        
        mov [descriptor_2],eax
        
        mov ecx,1
        repeta:
            
            ;read from file
            push dword [descriptor_1]
            push dword 50
            push dword 1
            push dword temporary
            call [fread]
            add esp, 4*4
                        
            cmp eax,0 ;in case we are done with the reading jump out of loop
            je stop
            
            ;preparations for solving
            mov [len],al ;going to use a loop that counts how many characters does a word have
            xor ecx,ecx ;clear ecx
            mov cl,[len] ;initialize ecx for loop
            mov esi, temporary ;move in esi the temporary string address
            mov edi, text ;move in edi the address of the string which we will save the edited result
            cld ;clear dir flag
            xor ebx,ebx ;clear ebx and edx registers
            xor edx,edx
            
            jmp check ;jump to the chek loop
            
            back:            
            push dword text
            push dword [descriptor_2]
            call [fprintf]
            add esp, 4*2
            
            mov ecx,2
            
        loop repeta
        stop:
        jmp ending;jump over the error printing
        
        check:;check what we have read
                lodsb ;load char into al
                cmp eax,' ' ;see if it is space
                je solve ;if it i we check and edit based of its number of digits
                inc ebx ;inc ebx otherwise and keeps counting
                jmp next
                solve: ;check and edit based of its number of digits
                    xor edx,edx;clear edx
                    mov dl,[n] ;put the minimum numbers of chars
                    cmp ebx,edx ;compare
                    jge word_done ;if it is ok we jump to out of solve loop
                    sub edx,ebx ;find how many special chars to add 
                    push ecx ;save ecx for later
                    mov ecx,edx ;initialize chars loop
                    chars:;stocks in text aditional special chars
                        mov eax,[char]
                        stosb
                        dec edx
                        cmp edx,0
                        jne end_chars
                        mov ecx,1
                        end_chars:
                    loop chars 
                    pop ecx
                    word_done:
                    mov eax,' '
                    mov ebx,0
                next:
                stosb
            loop check
        jmp back
        
        jmp ending;jump over the error printing
        
        open_error:
        push dword msg_error
        call [printf]
        add esp, 4
        
        ending:
        push dword [descriptor_1]
        call [fclose]
        add esp, 4
        
        push dword [descriptor_2]
        call [fclose]
        add esp, 4
        
        ; exit(0)
        push    dword 0      ; push the parameter for exit onto the stack
        call    [exit]       ; call exit to terminate the program
        ;mod acces, nume_fisier, fopen
        ;descriptor, fclose
        ;descriptor, cate elemente citim, dimensiunea, variabla in care se face citirea, fread
        ;const, var,..., format, descriptor, fprintf
        ;descriptor, fclose