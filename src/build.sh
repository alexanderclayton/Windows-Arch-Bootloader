# build script to automate build process


# run cmake to generate build files
# run make to compile and link bootloader

# Compile bootloader_stage1.asm
nasm -f bin bootloader_stage1.asm -o bootloader_stage1.bin

# Compile bootloader_stage2.c
gcc -ffreestanding -c -nostdlib -nostartfiles bootloader_stage2.c -o bootloader_stage2.o

# Link the object files
ld -T linker.ld bootloader_stage2.o -o bootloader_stage2.bin

# Generate disk image
dd if=/dev/zero of=disk.img bs=1024 count=1440 oflag=direct

# Write bootloader_stage1 to disk image
dd if=bootloader_stage1.bin of=disk.img bs=1 count=512 conv=notrunc
# objcopy -I binary -O binary --pad 0x200 --gap 0x100 bootloader_stage1.bin disk.img

# Write bootloader_stage2 to disk image
dd if=bootloader_stage2.bin of=disk.img bs=512 seek=2 conv=notrunc
# objcopy -I binary -O binary --pad 0x200 --gap 0x100 bootloader_stage2.bin disk.img

# # Remove intermediate object file
rm bootloader_stage1.bin bootloader_stage2.bin bootloader_stage2.o