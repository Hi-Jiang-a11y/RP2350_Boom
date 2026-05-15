.syntax unified
.cpu cortex-m33
.thumb

.section .text
.global stack_initialization

.thumb_func
stack_initialization:
    ldr     r0, =0x20082000
    mov     sp, r0                   @ 設置堆疊指針
    bl      _start                   @ 跳轉至 main.s 中的主程式
