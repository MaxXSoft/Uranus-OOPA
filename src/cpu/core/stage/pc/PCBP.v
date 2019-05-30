`timescale 1ns / 1ps

`include "bus.v"

module PCBP(
  input               clk,
  input               rst,
  input               flush,
  input               stall_current_stage,
  input               stall_next_stage,
  input   [`ADDR_BUS] pc_in,
  output  [`ADDR_BUS] pc_out
);

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_pc(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    pc_in, pc_out
  );

endmodule // PCBP
