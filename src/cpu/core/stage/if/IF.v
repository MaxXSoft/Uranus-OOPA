`timescale 1ns / 1ps

`include "bus.v"
`include "exception.v"
`include "branch.v"

module IF(
  input               rst,
  // from PC stage
  input               is_branch_taken_in,
  input   [`GHR_BUS]  pht_index_in,
  input   [`ADDR_BUS] pc_in,
  // cache control
  input               cache_ready,
  input   [`DATA_BUS] cache_data_in,
  output              cache_read_en,
  output  [`ADDR_BUS] cache_addr_read,
  // control signals
  output              stall_request,
  // output signals
  output              is_branch_taken_out,
  output  [`GHR_BUS]  pht_index_out,
  output  [`ADDR_BUS] pc_out,
  output  [`INST_BUS] inst_out
);

  // check if PC is valid
  wire is_valid_pc;
  assign is_valid_pc = rst ? pc_in != `INVALID_PC : 0;

  // stall request when cache is not ready
  assign stall_request = rst ? !cache_ready : 0;

  // module output
  assign is_branch_taken_out = is_branch_taken_in;
  assign pht_index_out = pht_index_in;
  assign pc_out = is_valid_pc ? pc_in : 0;

  // cache control
  assign cache_read_en = is_valid_pc;
  assign cache_addr_read = pc_out;

  // instruction output
  reg[`INST_BUS] inst;
  assign inst_out = inst;

  always @(*) begin
    if (!rst) begin
      inst <= 0;
    end
    else if (cache_ready && is_valid_pc) begin
      inst <= cache_data_in;
    end
    else begin
      inst <= 0;
    end
  end

endmodule // IF
