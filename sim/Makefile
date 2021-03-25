CFLAGS = -O0 -g -Wall -Wextra -Werror -Wpedantic

TARGET =
CC = $(TARGET)gcc
AS = $(TARGET)as
AS = $(TARGET)ar
LD = $(TARGET)ld
OBJCOPY = $(TARGET)objcopy
OBJDUMP = $(TARGET)objdump

OBJS = decode.o execute.o control.o
HEADERS = $(wildcard *.h)

all: sim.a

%.o: %.c $(HEADERS) Makefile
	$(CC) $(ARCH) $(CFLAGS) -c $< -o $@

sim.a: $(OBJS)
	$(AR) -crs $@ $^

execute_test: execute_test.o $(OBJS)
	$(CC) $^ -o $@

clean:
	rm -f *.o *.elf *.bin *.out *.imem *.hex

%.dump: %.elf
	$(OBJDUMP) --disassembler-options=numeric,no-aliases -d $<

hex: $(F)
	cat $(F)

.SUFFIXES:
.INTERMEDIATE:
.PHONY: all clean %.dump
