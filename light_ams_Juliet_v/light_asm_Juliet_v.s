.syntax unified
.align 4
.cpu cortex-m33
.thumb

@ ---------------------------------------------------------
@ Image Definition Section (RP2350 / Cortex-M33 啟動必備)
@ ---------------------------------------------------------
.section .image_def, "a"
image_def:
    .word 0xffffded3
    .word 0x10210142
    .word 0x000001ff
    .word 0x00000000
    .word 0xab123579

@ ---------------------------------------------------------
@ 中斷向量表初始化
@ ---------------------------------------------------------
.section .vectors, "ax"
    .word 0x20001000
    .word _start

@ ---------------------------------------------------------
@ 程式碼段
@ ---------------------------------------------------------
.section .text
.global _start
.thumb_func
_start:
    @ 1. 解除复位 (IO_BANK0 和 PADS_BANK0)
    ldr r0, =0x40020000       @ RESETS 基地址
    ldr r1, =(1 << 6 | 1 << 9) @ 构造掩码 (bit 6 & 9)

    ldr r2, [r0, #0x0]        @ 读取 RESET 寄存器
    bics r2, r2, r1           @ 清除对应位以解除复位
    str r2, [r0, #0x0]

reset_wait:
    ldr r2, [r0, #0x8]        @ 读取 RESET_DONE 寄存器
    tst r2, r1                @ 检查是否完成
    beq reset_wait

    @ 2. 物理引脚配置 (Pad Control)
    ldr r0, =0x40038040       @ 直接指向 PADS_BANK0: GPIO15 寄存器 (0x40038000 + 0x04 + 15*4)
    movs r1, #0x56            @ 4mA, 下拉, 开启施密特输入
    str r1, [r0]

    @ 3. 设置引脚复用功能 (GPIO Control -> SIO)
    ldr r0, =0x4002807c       @ 直接指向 IO_BANK0: GPIO15_CTRL (0x40028000 + 15*8 + 4)
    movs r1, #5               @ 功能 5: SIO
    str r1, [r0]

    @ 4. SIO 配置与点亮
    ldr r0, =0xd0000000       @ SIO 基地址
    ldr r1, =(1 << 15)        @ GPIO 15 掩码

    str r1, [r0, #0x038]      @ GPIO_OE_SET: 设置为输出
    str r1, [r0, #0x018]      @ GPIO_OUT_SET: 拉高电平 (点亮)
