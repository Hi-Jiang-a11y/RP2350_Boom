# Generic bare-metal RISC-V toolchain file for riscv32-unknown-elf-gcc
# Usage:
#   cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=cmake/riscv32-unknown-elf-toolchain.cmake

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv32)

# Cross-compiling: avoid try-run executables
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ---- Toolchain discovery / checks ----
find_program(RISCV_GCC riscv32-unknown-elf-gcc)

if(NOT RISCV_GCC)
  message(FATAL_ERROR
    "riscv32-unknown-elf-gcc not found in PATH.\n"
    "Fix: source your toolchain environment or add the toolchain 'bin' directory to PATH.\n"
    "Example:\n"
    "  export PATH=/opt/riscv/bin:$PATH\n"
  )
endif()

# Prefer GCC driver for ASM/C/CXX in embedded workflows
set(CMAKE_ASM_COMPILER "${RISCV_GCC}")
set(CMAKE_C_COMPILER   "${RISCV_GCC}")
set(CMAKE_CXX_COMPILER "${RISCV_GCC}")

# Optional binutils tools (nice to have)
find_program(CMAKE_OBJCOPY riscv32-unknown-elf-objcopy)
find_program(CMAKE_OBJDUMP riscv32-unknown-elf-objdump)
find_program(CMAKE_SIZE    riscv32-unknown-elf-size)

# Optional: keep CMake from searching host system paths for libs/includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
