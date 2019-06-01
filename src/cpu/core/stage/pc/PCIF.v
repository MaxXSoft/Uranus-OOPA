`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module PCIF(
  input               clk,
  input               rst,
  input               flush,
  input               stall_current_stage,
  input               stall_next_stage,
  input               is_branch_taken_in,
  input   [`GHR_BUS]  pht_index_in,
  input   [`ADDR_BUS] pc_in,
  output              is_branch_taken_out,
  output  [`GHR_BUS]  pht_index_out,
  output  [`ADDR_BUS] pc_out
);

  PipelineDeliver #(1) ff_is_branch_taken(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_branch_taken_in, is_branch_taken_out
  );

  PipelineDeliver #(`GHR_WIDTH) ff_pht_index(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    pht_index_in, pht_index_out
  );

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_pc(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    pc_in, pc_out
  );

endmodule // PCIF
