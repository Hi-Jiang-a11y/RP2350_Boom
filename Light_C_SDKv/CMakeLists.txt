cmake_minimum_required(VERSION 3.19.8)

include(pico_sdk_import.cmake)

project(Light_C_SDKv C CXX)

pico_sdk_init()

add_executable(light_main
    main.c
)

target_compile_options(light_main PRIVATE
    -mcpu=cortex-m33
    -mthumb
)

target_link_libraries(light_main
    pico_stdlib
)

pico_add_extra_outputs(light_main)
