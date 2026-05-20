cmake_minimum_required(VERSION 3.19.8)

include(pico_sdk_import.cmake)

project(Light_C_sdk_v C CXX)

pico_sdk_init()

add_executable(Light_main
    main.c
)

target_link_libraries(Light_main
    pico_stdlib
)

pico_add_extra_outputs(Light_main)
