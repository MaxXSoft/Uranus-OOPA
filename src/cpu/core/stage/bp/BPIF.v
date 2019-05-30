`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module BPIF(
  input               clk,
  input               rst,
  input               flush,
  input               stall_current_stage,
  input               stall_next_stage,
  input               is_branch_taken_in,
  input   [`GHR_BUS]  current_pht_index_in,
  input   [`ADDR_BUS] next_pc_in,
  input   [`ADDR_BUS] current_pc_in,
  output              is_branch_taken_out,
  output  [`GHR_BUS]  current_pht_index_out,
  output  [`ADDR_BUS] next_pc_out,
  output  [`ADDR_BUS] current_pc_out
);

  PipelineDeliver #(1) ff_is_branch_taken(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_branch_taken_in, is_branch_taken_out
  );

  PipelineDeliver #(`GHR_WIDTH) ff_current_pht_index(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    current_pht_index_in, current_pht_index_out
  );

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_next_pc(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    next_pc_in, next_pc_out
  );

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_current_pc(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    current_pc_in, current_pc_out
  );

endmodule // BPIF
