// Sets up graphical mode, prepare for user interactions

// Second stage of bootloader
// Initializes display graphics
// handles user inputs with keyboard

void __attribute__((noreturn)) stage2_main()
{
    char debug_msg[] = "Stage 2 loaded successfully...\r\n";
    for (int i=0; debug_msg[i] != '\0'; ++i) {
        __asm__ volatile (
            "mov $0x0E, %%ah\n"     // AH = 0x0E (teletype function)
            "mov %0, %%al\n"        // AL = current character
            "int $0x10\n"           // BIOS interrupt to print character
            :
            : "r" (debug_msg[i])    // Input: character to print
            : "ah", "al"            // Clobbered registers
        );
    }

    __asm__ volatile ("hlt");       // Halt the CPU

    while (1) {}                    // Loop indefinitely to prevent unexpected behavior
}

