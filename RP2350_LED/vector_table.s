.syntax unified
.cpu cortex-m33
.thumb

.section .vectors, "ax"
.align 4

.global vector_initialization
vector_initialization:
    .word 0x20082000          @ 棧頂地址
    .word _start              @ 下一条指令的地址
