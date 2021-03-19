#include <memory>
#include <verilated.h>

#include "Vcpu.h"

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

    while (!contextp->gotFinish()) {
    //while (1) {
        contextp->timeInc(1);

        if (top->clk) {
          VL_PRINTF("[%" VL_PRI64 "d]\n", contextp->time());
        }

        top->eval();

        if (top->clk) {
          VL_PRINTF("if: pc=%03x next_pc=%03x ins=%08x\n", top->cpu__DOT__cpu_fetch__DOT__pc, top->cpu__DOT__cpu_fetch__DOT__next_pc, top->cpu__DOT__cpu_fetch__DOT__pc);
          VL_PRINTF("id: pc=%03x ins=%08x flush=%d\n", top->cpu__DOT__if_id___05Fpc, top->cpu__DOT____Vtogcov__if_id___05Fins, top->cpu__DOT__pipe_flush);
          VL_PRINTF("ex: pc=%03x\n", top->cpu__DOT__id_ex___05Fpc);
          VL_PRINTF("mb: pc=%03x\n", top->cpu__DOT__ex_mb___05Fpc);
          VL_PRINTF("wb: pc=%03x\n", (top->cpu__DOT__mb_wb___05Fpc_4 - 4));
        }

        if (contextp->time() > 20)
          break;

        top->clk = !top->clk;
    }

    top->final();

#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    return 0;
}
