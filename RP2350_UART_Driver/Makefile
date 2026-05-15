# 项目名称
NAME = uart_asm

# 工具链
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
# RP2350 推荐使用 picotool，Arch 官方仓库或 AUR 均可安装
PICOTOOL = picotool
OBJDUMP_FLAGS = -x -d -s
# 参数设置
# 显式指定 m33 架构
AS_FLAGS = -mcpu=cortex-m33 -mthumb --warn --fatal-warnings -g
# 链接器参数去掉 -mthumb，保持纯净
LD_FLAGS = -nostdlib -g

LD_SCRIPT = linker.ld

OUTPUT_DIR = bin
DUMP_DIR = dump

# 自动搜寻当前目录下的所有 .s 文件
S_FILES = $(wildcard *.s)
O_FILES = $(patsubst %.s,$(OUTPUT_DIR)/%.o,$(S_FILES))

.PHONY: all clean flash

all: $(OUTPUT_DIR) $(DUMP_DIR) $(OUTPUT_DIR)/$(NAME).uf2

# 创建目录
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

$(DUMP_DIR):
	mkdir -p $(DUMP_DIR)

# 编译阶段
$(OUTPUT_DIR)/%.o: %.s
	$(AS) $(AS_FLAGS) $< -o $@

# 链接与二进制转换阶段
$(OUTPUT_DIR)/$(NAME).bin: $(LD_SCRIPT) $(O_FILES)
	$(LD) $(LD_FLAGS) -T $(LD_SCRIPT) $(O_FILES) -o $(OUTPUT_DIR)/$(NAME).elf
	$(OBJDUMP) $(OBJDUMP_FLAGS) $(OUTPUT_DIR)/$(NAME).elf > $(OUTPUT_DIR)/$(NAME).elf.dump
	# 为每个中间文件生成 dump，方便分析汇编逻辑
	@$(foreach obj,$(O_FILES),$(OBJDUMP) $(OBJDUMP_FLAGS) $(obj) > $(DUMP_DIR)/$(notdir $(obj)).dump;)
	$(OBJCOPY) -O binary $(OUTPUT_DIR)/$(NAME).elf $(OUTPUT_DIR)/$(NAME).bin

# 使用 picotool 生成适用于 RP2350 的 UF2
$(OUTPUT_DIR)/$(NAME).uf2: $(OUTPUT_DIR)/$(NAME).bin
	$(PICOTOOL) uf2 convert $(OUTPUT_DIR)/$(NAME).bin $(OUTPUT_DIR)/$(NAME).uf2

# 烧录（如果已连接开发板且在 BOOTSEL 模式）
flash: $(OUTPUT_DIR)/$(NAME).uf2
	$(PICOTOOL) load $(OUTPUT_DIR)/$(NAME).uf2

clean:
	rm -Rf $(OUTPUT_DIR)
	rm -Rf $(DUMP_DIR)
