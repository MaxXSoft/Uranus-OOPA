`ifndef OOPA_TEST_INCLUDE_TB_V_
`define OOPA_TEST_INCLUDE_TB_V_

`define GEN_TICK(clk, rst)              \
    integer tick;                       \
    always @(posedge clk) begin         \
      if (!rst) begin                   \
        tick <= 0;                      \
      end                               \
      else begin                        \
        tick <= tick + 1;               \
      end                               \
    end

`define DISPLAY(name, val) \
    $display("[%8h] %s = 0x%8h", tick, name, val)

`endif  // OOPA_TEST_INCLUDE_TB_V_
