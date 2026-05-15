@ RP2350 ARM Cortex-M33
.syntax unified
.cpu cortex-m33
.thumb

.equ ADRESSEPILE,    0x20082000
.equ LED_PIN,        25

.equ ATOMIC_XOR,     0x1000
.equ ATOMIC_SET,     0x2000
.equ ATOMIC_CLEAR,   0x3000

.equ SIO_BASE,       0xD0000000
.equ GPIO_OE_SET,    0x038
.equ GPIO_OUT_SET,   0x018
.equ GPIO_OUT_CLR,   0x020

.equ PADS_BANK0_BASE, 0x40038000
.equ IO_BANK0_BASE,   0x40028000
.equ GPIO_CTRL,       0x4
.equ GPIO_FUNC_SIO,   5


.section .vectors
    .word ADRESSEPILE          @ 0: 栈指针
    .word main + 1             @ 1: 复位向量 (Thumb 模式地址需+1)

.text
.global main
.thumb_func
main:
    bl initGpioLed
    mov r0, #5                 @ 闪5次
    bl ledEclats

loop_forever:
    b loop_forever


.align 4
blocembd:
    .int 0xffffded3           @ 魔数 (与RISC-V相同)
    .int 0x10210142           @ 架构标识: 0x10 代表 ARM Cortex-M33
    .int 0x00000344           @ ENTRY_POINT item
    .int 0x10000000
    .int ADRESSEPILE
    .int 0x000004FF
    .int 0x00000000
    .int 0xab123579


.thumb_func
initGpioLed:
    push {lr}
    
    mov r0, #LED_PIN
    mov r1, #1
    lsl r1, r1, r0            @ r1 = 1 << 25
    
    ldr r2, =SIO_BASE
    str r1, [r2, #GPIO_OE_SET] @ 设置输出使能

    @ PADS 配置
    ldr r2, =(PADS_BANK0_BASE + ATOMIC_SET)
    lsl r3, r0, #2            @ pin * 4
    add r2, r2, r3
    mov r4, #0x40             @ IE (Input Enable)
    str r4, [r2, #4]

    @ 清除隔离位
    ldr r2, =(PADS_BANK0_BASE + ATOMIC_CLEAR)
    add r2, r2, r3
    mov r4, #0x80             @ ISO bit
    str r4, [r2, #4]

    @ IO BANK 功能选择
    ldr r2, =IO_BANK0_BASE
    lsl r3, r0, #3            @ pin * 8
    add r2, r2, r3
    mov r4, #GPIO_FUNC_SIO
    str r4, [r2, #GPIO_CTRL]

    pop {pc}


.thumb_func
ledEclats:
    push {r4, r5, r6, lr}
    mov r4, r0                @ 闪烁次数
    mov r5, #1
    lsl r5, r5, #LED_PIN
    ldr r6, =SIO_BASE

1:
    str r5, [r6, #GPIO_OUT_SET] @ 点亮
    mov r0, #250
    bl attendre
    
    str r5, [r6, #GPIO_OUT_CLR] @ 熄灭
    mov r0, #250
    bl attendre
    
    subs r4, r4, #1
    bgt 1b
    
    pop {r4, r5, r6, pc}


.thumb_func
attendre:
    lsl r0, r0, #12           @ 延时常数
1:
    subs r0, r0, #1
    bne 1b
    bx lr
