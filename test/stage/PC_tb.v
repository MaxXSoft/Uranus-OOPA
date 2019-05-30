`timescale 1ns / 1ps

`include "tb.v"

module PC_tb(
  input clk,
  input rst
);

  // generate tick counter
  `GEN_TICK(clk, rst);

  // modules
  reg [31:0] next_pc;
  wire [31:0] pc_out;
  wire [31:0] mod_pc_out;

  PC pc(
    .rst      (rst),
    .next_pc  (next_pc),
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
    if (!rst) begin
      next_pc <= 32'hbfc00120;
    end
    else begin
      next_pc <= next_pc + 4;
    end

    `DISPLAY("mod_pc_out", mod_pc_out);
    if (tick >= 10) $finish;
  end

endmodule // PC_tb
