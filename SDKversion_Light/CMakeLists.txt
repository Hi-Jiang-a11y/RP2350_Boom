cmake_minimum_required(VERSION 3.19.8)

include(pico_sdk_import.cmake)

project(blink_project C CXX ASM)

pico_sdk_init()

add_executable(blink_main
    main.c
    blink.s
)

target_compile_options(blink_main PRIVATE
    -mcpu=cortex-m33
    -mthumb
)

set_source_files_properties(blink_v2.s PROPERTIES LANGUAGE ASM)

target_link_libraries(blink_main pico_stdlib)

pico_add_extra_outputs(blink_main)
