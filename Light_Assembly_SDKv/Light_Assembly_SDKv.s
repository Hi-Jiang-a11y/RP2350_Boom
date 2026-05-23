.syntax unified
.cpu cortex-m33
.thumb

.global start
start:
    @ 1. 解除复位 (IO_BANK0 和 PADS_BANK0)
    ldr r0, =0x40020000                 @ RESETS 基地址
    ldr r1, =((1 << 6) | (1 << 9))      @ 构造掩码 (bit 6, bit 9)

    ldr r2, [r0, #0x0]                  @ 读取 RESET 寄存器
    bics r2, r2, r1                     @ 清除对应位以解除复位
    str r2, [r0, #0x0]

reset_wait:
    ldr r2, [r0, #0x8]                  @ 读取 RESET_DONE 寄存器
    tst r2, r1                          @ 检查是否完成
    beq reset_wait

    @ 2. 物理引脚配置 (Pad Control)
    ldr r0, =0x40038040                 @ 直接指向 PADS_BANK0: GPIO15 寄存器 (0x40038000 + 0x04 + 15*4)
    movs r1, #0x36                      @ 12mA Drive, 清除 bit8(isolation)
    str r1, [r0]

    @ 3. 设置引脚复用功能 (GPIO Control -> SIO)
    ldr r0, =0x4002807c                 @ 直接指向 IO_BANK0: GPIO15_CTRL (0x40028000 + 15*8 + 4)
    movs r1, #0x5                       @ funct 5: SIO
    str r1, [r0]

    @ 4. SIO 配置与点亮
    ldr r0, =0xd0000000                 @ SIO 基地址
    ldr r1, =(1 << 15)                  @ GPIO 15 掩码

    str r1, [r0, #0x038]                @ GPIO_OE_SET: 设置为输出
    str r1, [r0, #0x018]                @ GPIO_OUT_SET: 拉高电平 (点亮)
