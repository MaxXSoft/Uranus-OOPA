`timescale 1ns / 1ps

`include "bus.v"
`include "exception.v"

module PC(
  input               clk,
  input               rst,
  input   [`ADDR_BUS] next_pc,
  output  [`ADDR_BUS] pc_out
);

  // PC register
  reg [`ADDR_BUS] pc;
  assign pc_out = pc;

  always @(posedge clk) begin
    if (!rst) begin
      pc <= `INIT_PC;
    end
    else begin
      pc <= next_pc;
    end
  end

endmodule // PC
