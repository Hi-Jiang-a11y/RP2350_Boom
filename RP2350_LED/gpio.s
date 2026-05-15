.syntax unified
.cpu cortex-m33
.thumb

.section .text
.equ LED_PIN, 15
.equ LED_PIN_MASK, (1 << LED_PIN)
.equ LED_PAD_SETUP, 0x56

.global gpio_initialize
.global led_on

.thumb_func
gpio_initialize:
    @ 1. 解除 GPIO 和 Pads 的復位狀態
    ldr r0, =0x40020000              @ Resets 基地址
    ldr r1, =((1 << 6) | (1 << 9))   @ IO_BANK0 | PADS_BANK0
    ldr r3, [r0, #0x0]
    bics r3, r3, r1
    str r3, [r0, #0x0]

reset_wait:
    ldr r3, [r0, #0x8]              @ RESET_DONE
    tst r3, r1
    beq reset_wait

    @ 2. 設置 Pad 控制
    ldr r0, =0x40038000
    adds r0, r0, #0x04              @ 跳過 VOLTAGE_SELECT
    movs r1, #LED_PIN
    lsls r1, r1, #2
    adds r0, r0, r1
    ldr r1, =LED_PAD_SETUP
    str r1, [r0]

    @ 3. 設置 GPIO 功能 (SIO)
    ldr r0, =0x40028000             @ IO_BANK0 基地址
    movs r1, #LED_PIN
    lsls r1, r1, #3
    adds r0, r0, r1
    adds r0, r0, #0x04              @ CTRL 寄存器
    movs r1, #5
    str r1, [r0]

    @ 4. 設置 SIO 輸出使能
    ldr r0, =0xd0000000             @ SIO 基地址
    ldr r1, =LED_PIN_MASK
    str r1, [r0, #0x038]            @ GPIO_OE_SET
    bx lr

.thumb_func
led_on:
    ldr r0, =0xd0000000
    ldr r1, =LED_PIN_MASK
    str r1, [r0, #0x018]            @ GPIO_OUT_SET
    bx lr
