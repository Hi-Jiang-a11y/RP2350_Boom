.syntax unified
.cpu cortex-m33
.thumb

.section .text
.thumb_func
.global _start
_start:
    bl gpio_initialize

    @ --- 局部变量初始化 ---
    @ 我们打算在栈上存两个值：[sp, #0] 是当前亮度，[sp, #4] 是闪烁计数
    sub     sp, sp, #8          @ 在栈上开辟 8 字节空间
    movs    r0, #0
    str     r0, [sp, #0]        @ 亮度 = 0
    str     r0, [sp, #4]        @ 计数 = 0

main_loop:
    @ 读取局部变量
    ldr     r4, [sp, #0]        @ r4 = 亮度值 (0-100)

    @ --- 逻辑：点亮 LED ---
    bl      led_on

    @ 延时（对应亮度的脉冲宽度）
    mov     r0, r4
    bl      delay_unit

    @ --- 逻辑：熄灭 LED ---
    bl      led_off

    @ 延时（对应剩下的周期）
    movs    r1, #100
    subs    r0, r1, r4          @ r0 = 100 - 亮度
    bl      delay_unit

    @ --- 更新逻辑：改变亮度 ---
    ldr     r5, [sp, #4]        @ 读取计数
    adds    r5, r5, #1
    str     r5, [sp, #4]        @ 计数++

    cmp     r5, #50             @ 每 50 次循环改变一次亮度
    blt     main_loop

    movs    r5, #0              @ 重置计数
    str     r5, [sp, #4]

    adds    r4, r4, #10         @ 亮度增加
    cmp     r4, #110
    blt     store_brightness
    movs    r4, #0              @ 亮度归零
store_brightness:
    str     r4, [sp, #0]        @ 写回局部变量

    b       main_loop

@ --- 子程序：延时单元 ---
.thumb_func
delay_unit:
    @ r0 传入循环次数
    cbz     r0, delay_exit      @ 如果 r0 为 0 直接退出
delay_inner:
    ldr     r1, =2000           @ 这是一个基础延时常数
inner_loop:
    subs    r1, r1, #1
    bne     inner_loop
    subs    r0, r0, #1
    bne     delay_inner
delay_exit:
    bx      lr

@ --- 子程序：熄灭 LED ---
.thumb_func
led_off:
    ldr     r0, =0xd0000000     @ SIO 基地址
    ldr     r1, =(1 << 15)      @ GPIO 15
    str     r1, [r0, #0x020]    @ GPIO OUT CLR (偏移 0x20)
    bx      lr

@ (此处省略你之前的 gpio_initialize 和 led_on 函数)
