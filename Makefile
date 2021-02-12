# Project setup
PROJ = cpu
BUILD = ./build
DEVICE = hx8k
PACKAGE = ct256
PINMAP = sigma.pcf

# Files
FILES = cpu.v alu.v reg.v imem.v imm.v control.v dmem.v top.v soc.v spi.v divider.v

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
