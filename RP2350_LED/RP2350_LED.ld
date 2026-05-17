MEMORY
{
    FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 32M
    SRAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 512k
}

SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        /* Vector Table */
        KEEP(*(.vectors))

        /* Valid IMAGE_DEF */
        KEEP(*(.image_def))

        /* Application Code */
        *(.text*)

        /* Read Only Data */
        *(.rodata*)
        . = ALIGN(4);
    } > FLASH

    /* 已初始化数据段 (从 Flash 拷贝到 SRAM) */
    .data :
    {
        . = ALIGN(4);
        *(.data*)
        . = ALIGN(4);
    } > SRAM AT > FLASH

    /* 未初始化数据段 */
    .bss :
    {
        . = ALIGN(4);
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
    } > SRAM
}
