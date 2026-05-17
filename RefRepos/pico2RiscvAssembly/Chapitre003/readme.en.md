## Chapter 3
Using the SDK greatly simplifies programming in RISCV assembly, but we will now look at programming without using SDK functions.

To begin, we will blink the integrated LED, as this does not require a USB connection.

In the program, we start by defining the necessary GPIO constants.

At the end of the main section, we define a mandatory data block that indicates that the uf2 file is a RISCV file, the stack address, and the address of the instruction that must be executed first.

This block must be placed within the first 4096 characters of the .text section

(see Chapters 5.9 and 5.9.5, "Minimum Viable Image Metadata," of the datasheet).

In the main program, we find two calls: one to initialize the GPIO LED and the other to turn the LED on and off.

Now we need to compile the program without the SDK. To do this, we create a memmap.ld file that specifies the memory regions to the linker, and a makefile that launches the compiler, then the linker, and finally picotool, which creates the uf2 file.

Here is its content:
```
ARMGNU ?= "C:\MainA\Tools\tools\bin\riscv32-unknown-elf"

AOPS = -mabi=ilp32

all: chap3.uf2

chap3.uf2: chap3.elf 
C:\MainA\Tools\picotool uf2 convert chap3.elf chap3.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000

chap3.o: chap3.s 
$(ARMGNU)-as $(AOPS) chap3.s -o chap3.o


chap3.elf: chap3.o 
$(ARMGNU)-ld -T memmap.ld chap3.o -o chap3.elf -M >chap3_map.txt
$(ARMGNU)-objdump -D chap3.elf > chap3.list

```

To retrieve the picotool executable, simply go to the build directory of a previous program compiled with the SDK, located in the \_deps\picotool directory, and copy picotool.exe.

You must modify the paths of the as, ld, and picotool executables to your own paths.

You will notice that our program is loaded at address 0x10000000.

The compilation is launched with make (if you don't have it, you will need to download it from the internet).

After correcting any errors, simply copy the uf2 file onto the pico2 to see the LED flash 5 times.
