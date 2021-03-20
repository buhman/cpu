# Project setup
PROJ = cpu
BUILD = ./build
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

.PHONY: all clean prog test ice40 ecp5

all: $(BUILD) ice40

ice40: $(BUILD)/$(PROJ)-ice40.asc
ecp5: $(BUILD)/$(PROJ)-ecp5.config

$(BUILD):
	mkdir -p $@

$(BUILD)/$(PROJ)-ecp5.json: $(FILES)
	yosys -Q -p "synth_ecp5 -top top -json $@" $^

$(BUILD)/$(PROJ)-ecp5.config: $(BUILD)/$(PROJ)-ecp5.json
	nextpnr-ecp5 \
		--no-print-critical-path-source \
		--um5g-85k --speed 8 \
		--json $< \
		--textcfg $@

$(BUILD)/$(PROJ)-ice40.json: $(FILES)
	yosys -q -p "synth_ice40 -top top -json $@" $^

$(BUILD)/$(PROJ)-ice40.asc: $(BUILD)/$(PROJ)-ice40.json
	nextpnr-ice40 \
		--freq 33 \
		--no-print-critical-path-source \
		--hx8k --package ct256 \
		--pcf $(PINMAP) --pcf-allow-unconstrained \
		--json $< \
		--asc $@

$(BUILD)/$(PROJ)-ice40.bin: $(BUILD)/$(PROJ).asc
	icepack $< $@

prog-ice40:   $(BUILD)/$(PROJ)-ice40.bin
	iceprog -S $<

clean:
	rm -f build/*

test:
	make -C ../aoc2020
	iverilog -D IVERILOG -o soc.out $(FILES) soc_tb.v
	vvp soc.out
