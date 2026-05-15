.syntax unified
.cpu cortex-m33
.thumb
.global start
start:

    @ Remove Reset Status
    ldr r0, =rst_base
    mov r1, #0x00000240
    ldr r2, [r0, #0x0]
    bics r2, r2, r1
    str r2, [r0, #0x0]

rst:
    @ Check if Resetting
    ldr r2, [r0, #0x8]
    tst r1, r2
    beq rst

    @ Pad Control Set (PAD Isolation in bit 8, added in rp2350)
    ldr r0, =0x40038040
    movs r1, #0x00000000
    str r1, [r0]

    @ GPIO_15 Ctrl Set
    ldr r0, =gpio15_ctrl
    mov r1, #5
    str r1, [r0, #0x0]

    @ GPIO_15 Output Set
    mov r1, #1
    lsl r1, r1, #15
    ldr r0, =sio_base
    str r1, [r0, #0x38]
    str r1, [r0, #0x18]
data:
    .equ rst_base, 0x40020000
    .equ gpio15_ctrl, 0x4002807c
    .equ sio_base, 0xd0000000
