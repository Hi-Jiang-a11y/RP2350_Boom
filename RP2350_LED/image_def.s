.syntax unified
.cpu cortex-m33
.thumb

.section .image_def, "a"
.align 4
image_def:
    .word 0xffffded3
    .word 0x10210142
    .word 0x000001ff
    .word 0x00000000
    .word 0xab123579
