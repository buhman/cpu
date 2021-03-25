VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage

FLAGS =
FLAGS += -cc --exe
FLAGS += -Os
FLAGS += -Wall
FLAGS += --trace
FLAGS += --assert
FLAGS += --coverage

INPUT = -f input.vc -y .. cpu.v sim_main.cpp

######################################################################
default: run

run:
	@echo
	@echo "-- VERILATE ----------------"
	$(VERILATOR) $(FLAGS) $(INPUT)

	@echo
	@echo "-- BUILD -------------------"
	$(MAKE) -j -C obj_dir -f ../Makefile_obj

	@echo
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	obj_dir/Vcpu +trace

	@echo
	@echo "-- COVERAGE ----------------"
	@rm -rf logs/annotated
	$(VERILATOR_COVERAGE) --annotate logs/annotated logs/coverage.dat

	@echo
	@echo "-- DONE --------------------"

clean:
	-rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core
