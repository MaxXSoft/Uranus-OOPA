`timescale 1ns / 1ps

`include "tb.v"

module PC_tb();

  // clock & reset generator
  `GEN_CLK_RST_TICK(clk, rst);

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
  initial begin
    #00 next_pc = 32'hbfc00120;
    `DISPLAY("next_pc", next_pc);
    #10 next_pc = 32'hbfc00124;
    `DISPLAY("next_pc", next_pc);
    #10 next_pc = 32'hbfc00128;
    `DISPLAY("next_pc", next_pc);
    #20 $stop;
  end

endmodule // PC_tb
