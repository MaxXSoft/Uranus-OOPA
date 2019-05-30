`timescale 1ns / 1ps

`include "bus.v"
`include "exception.v"

module PC(
  input               rst,
  input   [`ADDR_BUS] next_pc,
  output  [`ADDR_BUS] pc_out
);

  assign pc_out = !rst ? `INIT_PC : next_pc;

endmodule // PC
