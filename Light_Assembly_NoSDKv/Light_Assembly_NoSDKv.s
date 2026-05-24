.syntax unified
.align 4
.cpu cortex-m33
.thumb

.section .image_def, "a"
image_def:
    .word 0xffffded3
    .word 0x10210142
    .word 0x000001ff
    .word 0x00000000
    .word 0xab123579

.section .vectors, "ax"
.equ STACK_TOP_ADDRESS, 0x20082000
.global vector_initialization
vector_initialization:
    .word STACK_TOP_ADDRESS                         @ 栈顶地址
    .word stack_initialization                      @ Reset Handler (含 Thumb 位)


.section .text

@ 初始化
.global stack_initialization
.thumb_func
stack_initialization:
    ldr     r0, =STACK_TOP_ADDRESS
    mov     sp, r0                                  @ 设置 MSP
    b       _start                                  @ 跳转至主程序

@ ---------------------------------------------------------
@ 定义常数
@ ---------------------------------------------------------
.equ LED_PIN, 15
.equ LED_PIN_MASK, (1 << LED_PIN)
.equ LED_PAD_SETUP, 0x36

@ ---------------------------------------------------------
@ 主程序入口
@ ---------------------------------------------------------
.thumb_func
.global _start
_start:
    @ 初始化 GPIO （解除复位、设置多路复用、设置输出）
    bl gpio_initialize

    @ 点亮 LED
    bl led_on

stay_on:
    b stay_on

@ ---------------------------------------------------------
@ 子函数：点亮 LED
@ ---------------------------------------------------------
.thumb_func
led_on:
    ldr r0, =0xd0000000                             @ SIO 寄存器基地址
    ldr r1, =LED_PIN_MASK
    str r1, [r0, #0x018]
    bx lr

@ ---------------------------------------------------------
@ 子函数：GPIO 初始化
@ ---------------------------------------------------------
.thumb_func
gpio_initialize:

    @ 解除 GPIO 和 Pads 的復位狀態
    ldr r0, =0x40020000                             @ Resets 寄存器基地址
    ldr r1, =(1 << 6)                               @ IO_BANK0 位
    ldr r2, =(1 << 9)                               @ PADS_BANK0 位
    orrs r1, r1, r2

    ldr r3, [r0, #0x0]                              @ 读取当前 RESET 寄存器
    bics r3, r3, r1                                 @ 清除复位 (Release)
    str r3, [r0, #0x0]

    @ 等待复位完成
reset_wait:
    ldr r3, [r0, #0x8]                              @ 读取 RESET_DONE 寄存器
    tst r3, r1                                      @ 检查对应位是否变为 1
    beq reset_wait

    @ 設置 Pad 控制
    ldr r0, =0x40038000
    adds r0, r0, #0x04                              @ 跳 VOLTAGE_SELECT
    movs r1, #LED_PIN
    lsls r1, r1, #2
    adds r0, r0, r1
    ldr r1, =LED_PAD_SETUP
    str r1, [r0]

    @ 设置 GPIO 功能为 SIO (Function 5)
    ldr r0, =0x40028000                             @ IO_BANK0 基地址
    movs r1, #LED_PIN
    lsls r1, r1, #3
    adds r0, r0, r1
    adds r0, r0, #0x04                              @ 指向 CTRL 寄存器
    movs r1, #5                                     @ 选擇 F5 (SIO)
    str r1, [r0]

    @ 设置 SIO 輸出使能
    ldr r0, =0xd0000000                             @ SIO 基地址
    ldr r1, =LED_PIN_MASK
    str r1, [r0, #0x038]                            @ GPIO_OE_SET (使能输出)
    bx lr
