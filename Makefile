# Project setup
PROJ = cpu
BUILD = ./build
DEVICE = hx8k
PACKAGE = ct256
PINMAP = sigma.pcf

# Files
FILES = cpu.v
FILES += alu.v
FILES += reg.v
FILES += imem.v
FILES += imm.v
FILES += control.v
FILES += dmem.v
FILES += top.v
FILES += soc.v
FILES += spi.v
FILES += divider.v
FILES += word_decode.v

.PHONY: all clean prog

all: $(BUILD) $(BUILD)/$(PROJ).bin

$(BUILD):
	mkdir -p $@

$(BUILD)/$(PROJ).json: $(FILES) *.hex
	yosys -q -p "synth_ice40 -top top -json $(BUILD)/$(PROJ).json" $(FILES)

$(BUILD)/$(PROJ).asc: $(BUILD)/$(PROJ).json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(BUILD)/$(PROJ).json --pcf $(PINMAP) --asc $(BUILD)/$(PROJ).asc

$(BUILD)/$(PROJ).bin: $(BUILD)/$(PROJ).asc
	icepack $< $@

prog:   $(BUILD)/$(PROJ).bin
	iceprog -S $<

clean:
	rm -f build/*
