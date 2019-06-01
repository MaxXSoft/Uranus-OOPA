`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module BP(
  input               rst,
  // from PC
  input   [`ADDR_BUS] pc_in,                  // current pc
  // from ID
  input               is_branch_in,           // is last inst a branch
  input               is_jump_in,             // is 'j' or 'jal'
  input               is_taken_in,            // is last branch taken
  input               is_miss_in,             // is last branch missed
  input   [`GHR_BUS]  last_pht_index,         // last index of PHT
  input   [`ADDR_BUS] inst_pc,                // last pc of instruction
  input   [`ADDR_BUS] target_in,              // last branch target
  // control signals of GHR
  input   [`GHR_BUS]  ghr_in,
  output              ghr_is_branch_out,
  output              ghr_is_taken_out,
  // control signals of PHT
  input               pht_is_taken_in,
  output              pht_is_last_branch_out,
  output              pht_is_last_taken_out,
  output  [`GHR_BUS]  pht_last_index_out,
  output  [`GHR_BUS]  pht_index_out,
  // control signals of BTB
  input               btb_is_branch_in,
  input               btb_is_jump_in,
  input   [`ADDR_BUS] btb_target_in,
  output              btb_is_branch_out,
  output              btb_is_jump_out,
  output  [`ADDR_BUS] btb_inst_pc_out,
  output  [`ADDR_BUS] btb_target_out,
  output  [`ADDR_BUS] btb_pc_out,
  // output signals of module
  output  [`ADDR_BUS] next_pc_out,            // to PC stage (directly)
  output              is_branch_taken,        // to IF stage
  output  [`GHR_BUS]  current_pht_index_out,  // to IF stage
  output  [`ADDR_BUS] current_pc_out          // to IF stage
);

  assign current_pc_out = pc_in;
  assign current_pht_index_out = pht_index_out;

  // signals to GHR
  assign ghr_is_branch_out = is_branch_in;
  assign ghr_is_taken_out = is_taken_in;

  // signals to PHT
  assign pht_is_last_branch_out = is_branch_in;
  assign pht_is_last_taken_out = is_taken_in;
  assign pht_last_index_out = last_pht_index;
  assign pht_index_out = pc_in[`GHR_WIDTH + 1:2] ^ ghr_in;  // Gshare

  // signals to BTB
  assign btb_is_branch_out = is_branch_in;
  assign btb_is_jump_out = is_jump_in;
  assign btb_inst_pc_out = inst_pc;
  assign btb_target_out = target_in;
  assign btb_pc_out = pc_in;

  // generate output signal
  reg [`ADDR_BUS] next_pc;
  assign is_branch_taken = btb_is_branch_in
      && (pht_is_taken_in || btb_is_jump_in);
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
