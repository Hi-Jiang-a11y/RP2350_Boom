cmake_minimum_required(VERSION 3.20)

project(blink_asm LANGUAGES ASM)

add_executable(blink.elf
  blink.S
)

# Match your command:
# riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -nostdlib -nostartfiles -ffreestanding blink.S -T link.ld -o blink.elf
target_compile_options(blink.elf PRIVATE
  -march=rv32imac
  -mabi=ilp32
  -ffreestanding
)

target_link_options(blink.elf PRIVATE
  -march=rv32imac
  -mabi=ilp32
  -nostdlib
  -nostartfiles
  -T${CMAKE_SOURCE_DIR}/link.ld
)

# Nice-to-have outputs (optional, but common in embedded flows)
if(CMAKE_OBJCOPY)
  add_custom_command(TARGET blink.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:blink.elf> ${CMAKE_CURRENT_BINARY_DIR}/blink.bin
    COMMENT "Generating blink.bin"
  )
endif()

if(CMAKE_SIZE)
  add_custom_command(TARGET blink.elf POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:blink.elf>
    COMMENT "Size report"
  )
endif()
