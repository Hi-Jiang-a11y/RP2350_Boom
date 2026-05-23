cmake_minimum_required(VERSION 3.19.8)

include(pico_sdk_import.cmake)

project(Light_Assembly_SDKv C CXX ASM)

pico_sdk_init()

add_executable(Light_Assembly_SDKv
    main.c
    Light_Assembly_SDKv.s
)

target_compile_options(Light_Assembly_SDKv PRIVATE
    -mcpu=cortex-m33
    -mthumb
)

set_source_files_properties(Light_Assembly_SDKv.s PROPERTIES LANGUAGE ASM)

target_link_libraries(Light_Assembly_SDKv pico_stdlib)

pico_add_extra_outputs(Light_Assembly_SDKv)
