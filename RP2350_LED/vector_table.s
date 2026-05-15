.syntax unified
.cpu cortex-m33
.thumb

.section .vectors, "ax"
.align 4

.equ STACK_TOP_ADDRESS, 0x20082000

.global vector_initialization
vector_initialization:
    .word STACK_TOP_ADDRESS          @ 棧頂地址
    .word stack_initialization       @ 復位處理函數
