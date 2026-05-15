MEMORY
{
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 2048k
    SRAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 512k
}

SECTIONS
{
    .text :
    {
        KEEP(*(.vectors))    /* 强制保留向量表在最前面 */
        *(.text*)
        *(.rodata*)
        . = ALIGN(4);
    } > FLASH

    .data :
    {
        _sdata = .;
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > SRAM AT > FLASH

    .bss :
    {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > SRAM
}
