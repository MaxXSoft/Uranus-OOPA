#include "verilated.h"

// some magic
#define  XSTR(x)        #x
#define  STR(x)         XSTR(x)
#define  IDENT(x)       x
#define  INC(x)         STR(IDENT(MODULE_NAME).h)

#include INC(MODULE_NAME)

int main(int argc, const char *argv[]) {
  Verilated::commandArgs(argc, argv);
  MODULE_NAME* top = new MODULE_NAME;
  int reset = 0;
  while (!Verilated::gotFinish()) {
    top->rst = reset;
    if (!reset) reset = 1;
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
    top->clk = 0;
    top->eval();
  }
  delete top;
  return 0;
}
