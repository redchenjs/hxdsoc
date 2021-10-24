RISCV_PREFIX  ?= riscv64-elf-
RISCV_GCC     ?= $(RISCV_PREFIX)gcc
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy

C_SRCS = uart.c main.c

%.S: %.c
	$(RISCV_GCC) -static -march=rv32i -mabi=ilp32 -mcmodel=medany -nostdlib -nostartfiles -Tlink.ld $^ -S -o $@

all: $(C_SRCS)
	$(RISCV_GCC) -static -march=rv32i -mabi=ilp32 -mcmodel=medany -nostdlib -nostartfiles -Tlink.ld start.S $^ -o main.elf

	$(RISCV_OBJDUMP) main.elf -D > main.objdump

	$(RISCV_OBJCOPY) -O binary -R .rodata -R .data -R .bss main.elf main.iram
	sed '$ s/\x00*$$//' main.iram > main.iram.stripped
	mv main.iram.stripped main.iram

	$(RISCV_OBJCOPY) -O binary -j .rodata -j .data -j .bss main.elf main.dram
	sed '$ s/\x00*$$//' main.dram > main.dram.stripped
	mv main.dram.stripped main.dram

clean:
	rm -f main.S main.elf main.objdump main.iram main.dram main.out
