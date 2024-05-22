; Initializes the CPU and loads stage 2 of the bootloader

; First stage of the bootloader
; Executes immediately after the BIOS/UEFI loads MBR into memory
; Loads Second stage of bootloader from disk to memory
; Transitions control to second stage



[BITS 16]           ; Tells assembler code should be assembled for 16-bit mode.  BIOS operates in 16- bit real mode
[ORG 0x7C00]        ; Sets starting address to 0x7C00

start:
    ;initialize CPU, disable interrupts, set up segment registers and stack
    cli             ; Disable interrupts
    xor ax, ax      ; Clears the 'AX' register (sets 'AX' to 0)
    mov ds, ax      ; Sets the Data Segment register to 0
    mov es, ax      ; Sets the Extra Segment register to 0
    mov ss, ax      ; Sets the Stack Segment register to 0
    mov sp, 0x7C00  ; Setup stack

    ; Load Stage 2
    mov bx, 0x1000  ; Load address for Stage 2
    mov dh, 1       ; Number of sectors to load (1)
    mov dl, 0x80    ; Drive number (first hard disk)
    mov cx, 2       ; Start reading at sector 2 (sector 1 is the first stage bootloader)
    call load_sectors

load_sectors:
    ;Handle BIOS interrupt to read sectors from the disk into memory
    pusha           ; Save all registers (pushes all general-purpose registers into the stack)
    mov ah, 0x02    ; BIOS read sectors function
    int 0x13        ; BIOS interrupt (0x13 to perform disk read)
    jc disk_error   ; Jump to disk_error label if carry flag is set (error)
    popa            ; Restore all registers
    ret

disk_error:
    ; Handle disk error
    ;Display error message
    mov si, disk_error_msg  ; Load address of error message string
    call print_string       ; Call a procedure to print the error message string
    ;Halt the CPU
    hlt

disk_error_msg:
    db 'Disk Error!', 0     ; Error message string, terminated with null

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

; Boot signature
times 510-($-$$) db 0   ; Fill remaining bytes (up to 510) with zeroes, ensuring exactly 512 bytes
dw 0xAA55               ; Boot signature (required for BIOS to recognize as valid bootloader)
