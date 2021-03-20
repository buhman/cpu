# Project setup
PROJ = cpu
BUILD = ./build
DEVICE = hx8k
PACKAGE = ct256
PINMAP = sigma.pcf

# Files
FILES =
FILES += branch_predict.v
FILES += control.v
FILES += cpu.v
FILES += csr_reg.v
FILES += decode.v
FILES += dmem.v
FILES += dmem_decode.v
FILES += dmem_encode.v
FILES += execute.v
FILES += fetch.v
FILES += hazard.v
FILES += imem.v
FILES += int_alu.v
FILES += int_reg.v
FILES += jump.v
FILES += mem_branch.v
FILES += writeback.v
FILES += top.v

.PHONY: all clean prog test

all: $(BUILD) $(BUILD)/$(PROJ).bin

$(BUILD):
	mkdir -p $@

$(BUILD)/$(PROJ).json: $(FILES)
	yosys -q -p "synth_ice40 -top top -json $(BUILD)/$(PROJ).json" $(FILES)

$(BUILD)/$(PROJ).asc: $(BUILD)/$(PROJ).json
	nextpnr-ice40 \
		--no-print-critical-path-source \
		--$(DEVICE) --package $(PACKAGE) \
		--json $(BUILD)/$(PROJ).json \
		--pcf $(PINMAP) --pcf-allow-unconstrained \
		--asc $(BUILD)/$(PROJ).asc

$(BUILD)/$(PROJ).bin: $(BUILD)/$(PROJ).asc
	icepack $< $@

prog:   $(BUILD)/$(PROJ).bin
	iceprog -S $<

clean:
	rm -f build/*

test:
	make -C ../aoc2020
	iverilog -D IVERILOG -o soc.out $(FILES) soc_tb.v
	vvp soc.out
