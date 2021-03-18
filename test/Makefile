ARCH = -march=rv32i -mabi=ilp32
CFLAGS = -ffreestanding -nostdlib -mpreferred-stack-boundary=3 -Og

TARGET = riscv32-unknown-elf-
CC = $(TARGET)gcc
AS = $(TARGET)as
LD = $(TARGET)ld
OBJCOPY = $(TARGET)objcopy
OBJDUMP = $(TARGET)objdump

all: $(I)

%.o: %.s Makefile
	$(AS) $(ARCH) $< -o $@

%.o: %.c Makefile
	$(CC) $(ARCH) $(CFLAGS) $< -o $@

%.elf: %.o
	$(LD) -T sections.lds $< -o $@

%.bin: %.elf %.dump
	$(OBJCOPY) -O binary $< $@

%.imem: %.bin
	python binhex.py $< 256 > $@

clean:
	rm -f *.o *.elf *.bin *.out *.imem *.hex

%.dump: %.elf
	$(OBJDUMP) --disassembler-options=numeric,no-aliases -d $<

hex: $(F)
	cat $(F)

.SUFFIXES:
.INTERMEDIATE:
.PRECIOUS: %.elf %.imem
.PHONY: all clean %.dump
