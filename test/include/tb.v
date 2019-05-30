`ifndef OOPA_TEST_INCLUDE_TB_V_
`define OOPA_TEST_INCLUDE_TB_V_

`define GEN_CLK_RST_TICK(clk, rst)      \
    reg clk, rst;                       \
    initial begin                       \
      clk = 0;                          \
      rst = 0;                          \
      tick = 0;                         \
      #7 rst = 1;                       \
    end                                 \
    always begin                        \
      #5 clk = ~clk;                    \
    end

`define DISPLAY(name, val, fmt="0x%8h") \
    $display({"[%t] %s = ", fmt}, $time, name, val)

`endif  // OOPA_TEST_INCLUDE_TB_V_
