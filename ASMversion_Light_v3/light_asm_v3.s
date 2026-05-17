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
    .word STACK_TOP_ADDRESS                         @ 棧頂地址
    .word stack_initialization                      @ 復位處理函數 (含 Thumb 位)


.section .text

@ 堆疊與程式入口初始化
.global stack_initialization
.thumb_func
stack_initialization:
    ldr     r0, =STACK_TOP_ADDRESS
    mov     sp, r0                                  @ 設置堆疊指針
    b       _start                                  @ 跳轉至主程式

@ ---------------------------------------------------------
@ 定義常數
@ ---------------------------------------------------------
.equ LED_PIN, 15
.equ LED_PIN_MASK, (1 << LED_PIN)
.equ LED_PAD_SETUP, 0x56                            @ 4mA, 下拉, 施密特輸入

@ ---------------------------------------------------------
@ 主程式入口
@ ---------------------------------------------------------
.thumb_func
.global _start
_start:
    @ 第一步：初始化 GPIO 硬體（解除復位、設置多路複用、設置輸出）
    bl gpio_initialize

    @ 第二步：點亮 LED
    bl led_on

    @ 第三步：進入死循環，保持點亮狀態，不執行後續閃爍動作
stay_on:
    b stay_on

@ ---------------------------------------------------------
@ 子程式：點亮 LED
@ ---------------------------------------------------------
.thumb_func
led_on:
    ldr r0, =0xd0000000                             @ SIO 寄存器基地址
    ldr r1, =LED_PIN_MASK
    str r1, [r0, #0x018]                            @ GPIO OUT SET (將對應位設置為 1)
    bx lr

@ ---------------------------------------------------------
@ 子程式：GPIO 初始化
@ ---------------------------------------------------------
.thumb_func
gpio_initialize:
@    push {lr}

    @ 1. 解除 GPIO 和 Pads 的復位狀態
    ldr r0, =0x40020000                             @ Resets 寄存器基地址
    ldr r1, =(1 << 6)                               @ IO_BANK0 位
    ldr r2, =(1 << 9)                               @ PADS_BANK0 位
    orrs r1, r1, r2

    ldr r3, [r0, #0x0]                              @ 讀取當前 RESET 寄存器
    bics r3, r3, r1                                 @ 清除復位位 (Release)
    str r3, [r0, #0x0]

    @ 等待復位完成
reset_wait:
    ldr r3, [r0, #0x8]                              @ 讀取 RESET_DONE 寄存器
    tst r3, r1                                      @ 檢查對應位是否變為 1
    beq reset_wait

    @ 2. 設置 Pad 控制（電氣屬性）
    ldr r0, =0x40038000
    adds r0, r0, #0x04                              @ 跳過 VOLTAGE_SELECT
    movs r1, #LED_PIN
    lsls r1, r1, #2                                 @ 每個引腳佔 4 字節
    adds r0, r0, r1
    ldr r1, =LED_PAD_SETUP
    str r1, [r0]

    @ 3. 設置 GPIO 功能為 SIO (Function 5)
    ldr r0, =0x40028000                             @ IO_BANK0 基地址
    movs r1, #LED_PIN
    lsls r1, r1, #3                                 @ 每個 GPIO 佔 8 字節
    adds r0, r0, r1
    adds r0, r0, #0x04                              @ 指向 CTRL 寄存器
    movs r1, #5                                     @ 選擇 F5 (SIO)
    str r1, [r0]

    @ 4. 設置 SIO 輸出使能
    ldr r0, =0xd0000000                             @ SIO 基地址
    ldr r1, =LED_PIN_MASK
    str r1, [r0, #0x038]                            @ GPIO_OE_SET (使能輸出)
@    pop {pc}
    bx lr
