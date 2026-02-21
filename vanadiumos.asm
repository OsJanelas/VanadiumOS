[BITS 16]
[ORG 0x7C00]

start:
    mov ax, 0
    mov ds, ax
    mov es, ax
    
    mov si, msg_welcome
    call print_string

shell_loop:
    mov si, prompt
    call print_string

    mov di, buffer
    call read_line

    mov si, cmd_hello
    mov di, buffer
    call strcmp
    jc run_hello

    mov si, cmd_about
    mov di, buffer
    call strcmp
    jc show_about

    mov si, cmd_hardware
    mov di, buffer
    call strcmp
    jc show_hardware

    mov si, cmd_echo
    mov di, buffer
    call strcmp
    jc show_echo

    mov si, cmd_dir
    mov di, buffer
    call strcmp
    jc show_dir

    mov si, msg_unknown
    call print_string
    jmp shell_loop

; ---------------------------------------------------------
; FUNCTIONS
; ---------------------------------------------------------

show_about:
    mov si, txt_about
    call print_string
    jmp shell_loop

show_dir:
    mov si, txt_dir
    call print_string
    jmp shell_loop

show_echo:
    mov si, txt_echo_demo
    call print_string
    jmp shell_loop

show_hardware:
    mov si, txt_hw_header
    call print_string

    int 12h
    call printint
    mov si, txt_kb
    call print_string
    
    mov si, txt_cpu
    call print_string
    jmp shell_loop

; ANIMATION
run_hello:
    mov ax, 0x0013
    int 0x10
    mov ax, 0xA000
    mov es, ax
    mov bl, 0
.anim_loop:
    xor di, di
    inc bl
.draw:
    mov ax, di
    xor dx, dx
    mov cx, 320
    div cx
    xor al, dl
    add al, bl
    mov [es:di], al
    inc di
    cmp di, 64000
    jne .draw

    mov ah, 0x01
    int 0x16
    jz .anim_loop
    
    mov ax, 0x0003
    int 0x10
    jmp shell_loop

; ---------------------------------------------------------
; UTILS
; ---------------------------------------------------------

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done: ret

read_line:
    mov cx, 0
.next_char:
    mov ah, 0x00
    int 0x16
    cmp al, 13
    je .end
    mov ah, 0x0E
    int 0x10
    stosb
    inc cx
    jmp .next_char
.end:
    mov al, 0
    stosb
    mov si, newline
    call print_string
    ret

strcmp:
    pusha
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .notequal
    or al, al
    jz .equal
    inc si
    inc di
    jmp .loop
.notequal:
    popa
    clc
    ret
.equal:
    popa
    stc
    ret

printint:
    add ax, '0'
    mov ah, 0x0E
    int 0x10
    ret

; ---------------------------------------------------------
; DATA
; ---------------------------------------------------------
msg_welcome db 'VanadiumOS 1.0', 13, 10, 0
prompt      db '> ', 0
newline     db 13, 10, 0
msg_unknown db 'UNKNOWN COMAND', 13, 10, 0

cmd_hello    db 'hello', 0
cmd_about    db 'about', 0
cmd_dir      db 'dir', 0
cmd_hardware db 'hardware', 0
cmd_echo     db 'echo', 0

txt_about    db 'VanadiumOS 1.0 Dev: OsJanelas', 13, 10, 0
txt_dir      db 'C:', 13, 10, 'XOR', 13, 10, 'SYS', 13, 10, 0
txt_hw_header db 'RAM: ', 0
txt_kb       db ' KB detecteds.', 13, 10, 0
txt_cpu      db 'CPU: Itel', 13, 10, 0
txt_echo_demo db 'Use: echo [text] -> (In work)', 13, 10, 0

buffer times 64 db 0

times 510-($-$$) db 0
dw 0xAA55