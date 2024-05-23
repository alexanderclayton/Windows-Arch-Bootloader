/* Controls the memory layout and entry point of the bootloader */

/* Defines entry point
Specify memory layout of code */

OUTPUT_FORMAT(binary)          /* Outputs raw binary file */
ENTRY(stage2_main)             /* Set entry point to stage2_main in bootloader_stage2.c */

SECTIONS
{
    .text 0x1000 : {           /* Contains actual machine code executed by CPU */
        *(.text)                /* Stage 2 loaded at 0x1000:0000 = 0x10000 */                  
    }
    .data : {                   /* Contains initialized data (string, constants, global variables that are initialized with a value) */
        *(.data)
    }
    .bss : {                    /* Contains uninitialized data (variables not initialized with a value). Reserves space for variables that will be initialized later */
        *(.bss)
    }
}


