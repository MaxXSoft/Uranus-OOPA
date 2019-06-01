`timescale 1ns / 1ps

`include "tb.v"

module PC_tb(
  input clk,
  input rst
);

  // generate tick counter
  `GEN_TICK(clk, rst);

  // modules
  wire [31:0] pc_out;
  wire [31:0] mod_pc_out;

  PC pc_stage(
    .clk      (clk),
    .rst      (rst),
    .next_pc  (mod_pc_out + 4),
    .pc_out   (pc_out)
  );

  PCBP pcbp(
    .clk                  (clk),
    .rst                  (rst),
    .flush                (0),
    .stall_current_stage  (0),
    .stall_next_stage     (0),
    .pc_in                (pc_out),
    .pc_out               (mod_pc_out)
  );

  // testbench
  always @(posedge clk) begin
    `DISPLAY("mod_pc_out  ", mod_pc_out);
    if (`TICK >= 10) $finish;
  end

endmodule // PC_tb
