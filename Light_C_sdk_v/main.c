#include "pico/stdlib.h"        // include pico-sdk 的标准库头文件

int main() {
    gpio_init(15);              // 初始化 GPIO15
    gpio_set_dir(15, GPIO_OUT); // 设置为 输出模式
    gpio_put(15, 1);            // 输出高电平
    while (1);                  // 死循环
}
