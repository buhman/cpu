#include <memory>
#include <verilated.h>
#include <fstream>

#include "Vcpu.h"

extern "C" {
  #include "../sim/execute.h"
};

typedef struct {
  std::string filename;
  void * buf;
  size_t size;
} f_buf_t;

int main(int argc, char** argv, char** env) {
    if (false && argc && argv && env) {}

    Verilated::mkdir("logs");

    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    contextp->debug(0);
    contextp->randReset(2);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vcpu> top{new Vcpu{contextp.get(), "cpu"}};

    top->clk = 1;
    top->external_int = 0;

    /*
    int res;
    int pc;
    int int_reg[32];
    int mem;
    int dmem;
    res = execute_step(&pc, int_reg, &mem, &dmem);
    */

    char imem[4096];
    char dmem[8192];
    std::vector<f_buf_t> dmem_imem = {
      {"../../aoc2020/day12/part1.bin", imem, 4096},
      {"../../aoc2020/day12/input.txt", dmem, 8192}
    };

    for (std::vector<f_buf_t>::iterator it = dmem_imem.begin() ; it != dmem_imem.end(); ++it) {
      std::ifstream ifs;
      ifs.open(it->filename, std::ifstream::in);
      if (!ifs.good()) {
        std::cerr << "ifs.open: " << it->filename << "\n";
        return -1;
      }
      ifs.readsome((char*)it->buf, it->size);
      if (ifs.rdstate() & std::ifstream::failbit) {
        std::cerr << "ifs.read: " << it->filename << "\n";
        return -1;
      }
      ifs.close();
    }

    int ret;
    int pc, last_pc;
    int int_reg[32];

    int stop = 0;

    while (!contextp->gotFinish()) {
    //while (1) {
        contextp->timeInc(1);

        top->eval();

        if (top->clk && top->instret) {
          std::cerr << "cpuA pc=" << std::hex << top->pc << "\n";
          ret = execute_step(&pc, int_reg, imem, dmem);
          std::cerr << "cpuS pc=" << std::hex << pc << "\n";
          if (stop == 0 && top->pc != pc) {
            std::cerr << "contextp->time: " << std::dec << contextp->time() << "\n";
            stop = contextp->time() + 20;
          }
        }

        if (stop > 0 && contextp->time() > stop) {
          break;
        }

        top->clk = !top->clk;
    }

    top->final();

#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    return 0;
}
