; Initializes the CPU and loads stage 2 of the bootloader

; First stage of the bootloader
; Executes immediately after the BIOS/UEFI loads MBR into memory
; Loads Second stage of bootloader from disk to memory
; Transitions control to second stage



[BITS 16]           ; Tells assembler code should be assembled for 16-bit mode.  BIOS operates in 16- bit real mode
[ORG 0x7C00]        ; Sets starting address to 0x7C00

; stage2_segment equ 0x1000   ; Segment address for stage 2
; stage2_offset equ 0x0000    ; Offset address for stage 2

start:
    ;initialize CPU, disable interrupts, set up segment registers and stack
    cli             ; Disable interrupts
    xor ax, ax      ; Clears the 'AX' register (sets 'AX' to 0)
    mov ds, ax      ; Sets the Data Segment register to 0
    mov fs, ax      ; Sets the Flat Segment register to 0
    mov ss, ax      ; Sets the Stack Segment register to 0
    mov sp, 0xFFFC  ; Setup stack pointer

    ;Print debug message
    mov si, cpu_msg
    call print_string

    ; Load Stage 2
    ; mov ax, stage2_segment    ; Segment address for stage 2
    mov cx, 0x1000              ; 16 bit register to hold 0x1000 value
    mov es, cx                  ; Set Extra Segment register to 0x1000
    mov bx, 0x0000              ; Offset address for stage 2

    mov ch, 0x00                ; Cylinder number (0)
    mov cl, 0x03                ; Sector number
    mov dh, 0x00                ; Head number

    mov ah, 0x02                ; BIOS interrupt for disk read
    mov al, 0x01                ; Number of sectors to read
    int 0x13                    ; BIOS interrupt to read sector from disk

    ; Print debug message before jumping to stage 2
    mov si, load_stage_2_msg
    call print_string

    jmp 0x1000:0x0000           ; Jumpt to stage 2 entry point

; load_sectors:
;     ; Handle BIOS interrupt to read sectors from the disk into memory
;     pusha           ; Save all registers (pushes all general-purpose registers into the stack)
;     mov ah, 0x02    ; BIOS read sectors function
;     mov al, dh      ; Number of sectors to read
;     ; push dx         ; Save dx (drive number and sector count)
;     ; push dh         ; Save dh (number of sectors to read)
;     int 0x13        ; BIOS interrupt (0x13 to perform disk read)
;     jc disk_error   ; Jump to disk_error label if carry flag is set (error)
;     ; pop dh          ; Restore dh (number of sectors to read)
;     ; pop dx          ; Restore dx (drive number and sector count)
;     popa            ; Restore all registers
;     ; Debug message after successful read
;     mov si, read_success_msg
;     call print_string
;     ret

; disk_error:
;     ; Handle disk error
;     ;Display error message
;     mov si, disk_error_msg  ; Load address of error message string
;     call print_string       ; Call a procedure to print the error message string
;     jmp $                   ; infinite loop to prevent further execution

print_string:
    pusha                   ; Save all registers
    mov ah, 0x0E            ; BIOS teletype output function
; iterate over error message string, printing characters
.loop:
    lodsb                   ; Load byte from SI into AL and increment SI
    cmp al, 0               ; Check for end of string (null byte)
    je .done                ; If end of string, exit loop
    int 0x10                ; Call BIOS interrupt to display character
    jmp .loop               ; Repeat for next character
.done:
    popa                    ; Restore all registers
    ret

cpu_msg:
    db 'CPU initialized...', 0

load_stage_2_msg:
    db 'Loaded stage 2...', 0

; read_success_msg:
;     db 'Stage 2 loaded...', 0

; disk_error_msg:
;     db 'Disk Error occurred in Stage 1!', 0     ; Error message string, terminated with null

; Boot signature
times 510-($-$$) db 0   ; Fill remaining bytes (up to 510) with zeroes, ensuring exactly 512 bytes
dw 0xAA55               ; Boot signature (required for BIOS to recognize as valid bootloader)
