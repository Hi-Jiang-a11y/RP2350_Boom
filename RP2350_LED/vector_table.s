.syntax unified
.cpu cortex-m33
.thumb

.section .vectors, "ax"
.align 4

.global vector_initialization
vector_initialization:
    .word 0x20082000          @ 栈顶地址
    .word _start              @ Rest Handler 地址
