extern fim
extern recebeFiltro
global filtro_assembly

section .bss
    filtro: resb 32
    sinal: resb 32
    saida: resb 32
    soma: resb 1
    aux: resb 32
    y: resb 3
    tamanho_filtro: resb 1
    tamanho_sinal: resb 1
    tamanho_saida: resb 1

section .data
    arquivo: db 'arquivo.txt'

section .text
    
filtro_assembly:    
    mov eax, [esp + 4]
    mov [tamanho_filtro], eax
    mov eax, [esp + 8]
    mov [tamanho_sinal], eax
    
tamanho_da_saida:
    xor eax, eax
    mov ah, [tamanho_sinal]
    mov al, [tamanho_filtro]
    sub ah, al
    inc ah
    mov [tamanho_saida], ah

    mov ebx, arquivo	
    mov eax, 5
    mov ecx, 0
    mov edx, 0777
    int 80h

    test eax, eax
    jns file_read

file_read: 
	push eax
	mov edx, [tamanho_sinal]
	mov eax, 2
	mul edx
	mov edx, eax
	pop eax
    mov ebx, eax
    mov eax, 0x03
    mov ecx, aux
    int 80h


    mov ecx, 0
    mov ecx, [tamanho_sinal]
    mov edx, 0
    mov eax, 0
    mov ebx, 0
    mov esi, 0
    mov edi, 0

convert_sinal:
    push ax    
    mov di, [aux+esi]
    and di, 0FFh
    cmp di, 0Ah
    jne n_enter
	cmp di, 0h
	je recebe_filtro
    inc esi
    mov [sinal+edx], ax
    inc edx
    mov ax, 0
    loop convert_sinal
    jmp recebe_filtro

n_enter:
    mov ax, di
    pop bx
    sub al, '0'
    push ax
    mov al, 10
    push dx
    mul bx
    pop dx
    mov bl, al    
    pop ax
    add al, bl
    inc esi
    loop convert_sinal

;FIM LER ARQUIVO

recebe_filtro:
	xor ecx, ecx
	mov cl, [tamanho_filtro]
	mov ebx, 0
	
loop_recebe:
	push ecx
	call recebeFiltro
	pop ecx
	mov [filtro+ebx], al
	inc ebx
	loop loop_recebe
    
filtragem:
    xor ecx, ecx
    xor eax, eax
    mov cl, [tamanho_sinal];
    mov al, [tamanho_filtro];
    sub ecx, eax
    add ecx, 1; loop 1
    xor eax, eax
    xor ebx, ebx
    xor edx, edx; dh = i, dl = j
    
L1:
    push ecx
    xor ecx, ecx
    mov cl, [tamanho_filtro]; loop 2
    mov eax, 0
    mov [soma], eax;  zera a soma
    mov dl, 0 ; j
    
L2:
    movzx eax, dh
    add al, dl	
    mov eax, [sinal + eax] ;eax = sinal[i + j]
    movzx ebx, dl
    mov ebx, [filtro + ebx]; ebx = filtro[j]
    
    push edx ;salva edx
    mul ebx ; eax = ebx * eax
    pop edx; recupera edx
    mov ebx, [soma]
    add ebx, eax
    mov [soma], ebx; soma += eax        
    inc dl
    loop L2
    pop ecx
    mov eax, [soma]
    movzx ebx, dh 
    mov [saida + ebx], eax; [saida + i] = soma ----------------
    inc dh
    loop L1
    
    xor ecx, ecx
    mov ecx, [tamanho_saida]
    mov edx, 0
IMP_NUMERO:   
   push ecx
   push edx
   mov eax, 0
   mov al, [saida + edx]
   cmp eax, 9
         
   jg CONVERSAO_HEX_ASCII
   
   
   add eax, 30h
   mov [y], eax
   mov eax, ' '
   mov [y + 1], eax
   mov eax, 0ah
   mov [y + 2], eax
    
   jmp IMP_Y

CONVERSAO_HEX_ASCII:

   mov ecx, 9
   mov ebx, eax

WHILE2:

   mov eax, 10
   mul ecx      
   
   cmp ebx, eax 
   jge IMP
         
   loop WHILE2

IMP:

    add ecx, 30h
    mov [y], ecx
    sub ebx, eax
    add ebx, 30h
    mov [y + 1], ebx
    mov eax, 0ah
    mov [y + 2], eax

IMP_Y:
    mov eax, 4
    mov ebx, 1
    mov ecx, y
    mov edx, 3
    int 80h
    pop edx
    inc edx
    pop ecx    
    loop IMP_NUMERO

	leave
	jmp fim