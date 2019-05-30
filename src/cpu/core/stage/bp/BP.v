`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module BP(
  input               rst,
  // from PC
  input   [`ADDR_BUS] pc_in,
  // from ID
  input               is_branch_in,     // set if is a branch inst
  input               is_jump_in,       // set if is 'j' or 'jal'
  input               is_miss_in,       // set if current branch missed
  input   [`GHR_BUS]  last_pht_index,   // last index of PHT
  input   [`ADDR_BUS] inst_pc,          // last pc of instruction
  input   [`ADDR_BUS] target_in,        // last branch target
  // control signals of GHR
  input   [`GHR_BUS]  ghr_in,
  // control signals of PHT
  input               pht_is_taken_in,
  output  [`GHR_BUS]  pht_index_out,
  // control signals of BTB
  input               btb_is_branch_in,
  input               btb_is_jump_in,
  input   [`ADDR_BUS] btb_target_in,
  // output signals of module
  output              is_branch_taken,  // to IF stage
  output  [`ADDR_BUS] next_pc_out,      // to PC stage
  output  [`ADDR_BUS] current_pc_out    // to IF stage
);

  assign current_pc_out = pc_in;

  // PHT index generator (Gshare)
  assign pht_index_out = pc_in[`GHR_WIDTH + 1:2] ^ ghr_in;

  // generate output signal
  reg [`ADDR_BUS] next_pc;
  assign is_branch_taken = btb_is_branch_in && pht_is_taken_in;
  assign next_pc_out = next_pc;

  always @(*) begin
    if (!rst) begin
      next_pc <= pc_in + 4;
    end
    else if (is_miss_in) begin
      next_pc <= target_in;
    end
    else if (is_branch_taken) begin
      next_pc <= btb_target_in;
    end
    else begin
      next_pc <= pc_in + 4;
    end
  end

endmodule // BP
