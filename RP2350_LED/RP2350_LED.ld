MEMORY
{
    /* RP2350 的 Flash 通常映射到 0x10000000 */
    FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 512k
    /* RP2350 有 520KB SRAM，通常从 0x20000000 开始 */
    SRAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 512k
}

SECTIONS
{
    /* 代码段 */
    .text :
    {
        . = ALIGN(4);
        /* 1. 中断向量表必须放在 0x10000000 */
        KEEP(*(.vectors))

        /* 2. RP2350 的 Image Definition 紧随其后 */
        KEEP(*(.image_def))

        /* 3. 其余代码 */
        *(.text*)

        /* 4. 只读数据 */
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

    /* 定义栈顶符号，供向量表使用 */
    /* 注意：你代码中硬编码了 0x20082000，
       这里也可以定义符号供汇编引用：__stack_top = ORIGIN(SRAM) + LENGTH(SRAM); 
    */
}
