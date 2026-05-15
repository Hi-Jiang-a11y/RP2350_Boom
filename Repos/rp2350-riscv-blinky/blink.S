    .option norvc            # keep it simple while learning (no compressed)
    .text
    .globl _start

    # --- Constants from RP2350 datasheet ---
    .equ IO_BANK0_BASE,   0x40028000
    .equ PADS_BANK0_BASE, 0x40038000
    .equ SIO_BASE,        0xD0000000

    .equ LED_GPIO,        25

    # IO_BANK0 GPIO25_CTRL = IO_BANK0_BASE + 0x0CC
    .equ GPIO25_CTRL,     (IO_BANK0_BASE + 0x0CC)

    # PADS_BANK0 GPIO25 = PADS_BANK0_BASE + 0x68
    .equ PADS_GPIO25,     (PADS_BANK0_BASE + 0x68)
    .equ PADS_ISO_BIT,    (1 << 8)

    # SIO registers
    .equ SIO_GPIO_OUT_XOR, (SIO_BASE + 0x028)
    .equ SIO_GPIO_OE_SET,  (SIO_BASE + 0x038)

_start:
    # ------------------------------------------------------------
    # 1) Pad control: clear ISO bit for GPIO25
    #    (datasheet: ISO=1 after reset; clear once configured)
    # ------------------------------------------------------------
    lui     t0, %hi(PADS_GPIO25)
    lw      t1, %lo(PADS_GPIO25)(t0)
    li      t2, ~PADS_ISO_BIT
    and     t1, t1, t2
    sw      t1, %lo(PADS_GPIO25)(t0)

    # ------------------------------------------------------------
    # 2) GPIO function select: set GPIO25 to SIO_25 (FUNCSEL=0x05)
    #    Write only FUNCSEL bits (low 5 bits) for a clean start.
    # ------------------------------------------------------------
    lui     t0, %hi(GPIO25_CTRL)
    li      t1, 0x05                  # FUNCSEL = SIO_25
    sw      t1, %lo(GPIO25_CTRL)(t0)

    # ------------------------------------------------------------
    # 3) Enable output for GPIO25 via SIO GPIO_OE_SET
    # ------------------------------------------------------------
    li      t0, SIO_GPIO_OE_SET
    li      t1, (1 << LED_GPIO)
    sw      t1, 0(t0)

loop:
    # ------------------------------------------------------------
    # 4) Toggle GPIO25 via SIO GPIO_OUT_XOR
    # ------------------------------------------------------------
    li      t0, SIO_GPIO_OUT_XOR
    li      t1, (1 << LED_GPIO)
    sw      t1, 0(t0)

    # ------------------------------------------------------------
    # 5) crude delay loop (adjust count to taste)
    # ------------------------------------------------------------
    li      t2, 400000
delay:
    addi    t2, t2, -1
    bnez    t2, delay

    j       loop

