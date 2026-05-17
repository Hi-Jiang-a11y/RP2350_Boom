# rp2350-riscv-blinky
Blinky assembly code in RP2350 RISC-V core

#### Prerequisites

We need to download RISC-V toolchain wherever you want and extract it:

```bash
TOOLCHAIN_FILE="riscv32-embecosm-ubuntu2204-gcc13.2.0"
wget https://buildbot.embecosm.com/job/riscv32-gcc-ubuntu2204-release/10/artifact/"$TOOLCHAIN_FILE".tar.gz
tar -xvf "$TOOLCHAIN_FILE".tar.gz
```

Then if it is everything right, set up PATH variable because we'll use this toolchain in compiling:
```bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOOLCHAIN_DIR="$SCRIPT_DIR/$TOOLCHAIN_FILE"
export PATH="$TOOLCHAIN_DIR/bin:$PATH"
```

#### Building

Before build, create CMake project build structure with toolchain:

```bash
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=cmake/riscv32-unknown-elf-toolchain.cmake
```

Build it with CMake:

```bash
cmake --build build
```

#### Debugging

I have a Raspberry Pi debug probe, so I can flash code to the SRAM via OpenOCD. To use the Raspberry Pi Debug Probe with OpenOCD, you need to use the Raspberry Pi's customized [openocd](https://github.com/raspberrypi/openocd) project. In this project directory you can start openocd with this command after compiling:

```bash
sudo src/openocd -s tcl -f interface/cmsis-dap.cfg -f target/rp2350-riscv.cfg -c "adapter speed 5000"
```

Then, source the toolchain again as we did above. Run toolchain's GDB in build directory:

```bash
riscv32-unknown-gdb blink.elf
```

In GDB terminal for running in SRAM:
```bash
target remote :3333
monitor reset halt
load
monitor reset run
```

If you'd like to debug in assembly, you can do these before `monitor reset run`:
```bash
x/10i $pc
stepi
```
