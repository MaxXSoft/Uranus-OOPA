`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"

module MMU_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg[`ADDR_BUS]  addr_in;
  // output signals
  wire            is_cached;
  wire[`ADDR_BUS] addr_out;

  MMU mmu(
    .rst        (rst),
    .addr_in    (addr_in),
    .is_cached  (is_cached),
    .addr_out   (addr_out)
  );

  always @(posedge clk) begin
    if (!rst) begin
      addr_in <= 0;
    end
    else begin
      addr_in <= 0;
      case (`TICK)
        0: begin
          addr_in <= 32'h7FFF_FFFF;
        end
        1: begin
          $display("kuseg");
          addr_in <= 32'h9FFF_FFFF;
        end
        2: begin
          $display("kseg0");
          addr_in <= 32'hBFFF_FFFF;
        end
        3: begin
          $display("kseg1");
          addr_in <= 32'hDFFF_FFFF;
        end
        4: begin
          $display("kseg2");
          addr_in <= 32'hFFFF_FFFF;
        end
        5: begin
          $display("kseg3");
        end
      endcase
    end
    `DISPLAY("addr_in  ", addr_in);
    `DISPLAY("is_cached", is_cached);
    `DISPLAY("addr_out ", addr_out);
    $display("");
    `END_AT_TICK(5);
  end

endmodule