MEMORY
{
    FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 16M
    SRAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 520K
}

SECTIONS
{
    .text :
    {
        KEEP(*(.vectors))
        KEEP(*(.image_def))
        *(.text*)
    } > FLASH

    .bss :
    {
        *(.bss*)
    } > SRAM

    .data :
    {
        *(.data*)
    } > SRAM
}
