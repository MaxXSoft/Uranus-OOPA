`timescale 1ns / 1ps

`include "bus.v"
`include "exception.v"
`include "branch.v"

module PC(
  input               clk,
  input               rst,
  // from ID
  input               is_branch_in,     // is last inst a branch
  input               is_jump_in,       // is 'j' or 'jal'
  input               is_taken_in,      // is last branch taken
  input               is_miss_in,       // is last branch missed
  input   [`GHR_BUS]  last_pht_index,   // last index of PHT
  input   [`ADDR_BUS] inst_pc,          // last pc of instruction
  input   [`ADDR_BUS] target_in,        // last branch target
  // output signals of module
  output              is_branch_taken,
  output  [`GHR_BUS]  pht_index_out,
  output  [`ADDR_BUS] pc_out
);

  // PC register
  reg[`ADDR_BUS] pc;
  assign pc_out = pc;

  // GHR
  wire[`GHR_BUS] ghr_out;

  GHR ghr_reg(
    .clk              (clk),
    .rst              (rst),
    .is_branch        (is_branch_in),
    .is_taken         (is_taken_in),
    .ghr_out          (ghr_out)
  );

  // PHT
  wire[`GHR_BUS] pht_index;
  wire pht_is_taken;
  assign pht_index = pc[`GHR_WIDTH + 1:2] ^ ghr_out;  // Gshare
  assign pht_index_out = pht_index;

  PHT pht(
    .clk              (clk),
    .rst              (rst),
    .is_last_branch   (is_branch_in),
    .is_last_taken    (is_taken_in),
    .last_index       (last_pht_index),
    .index            (pht_index),
    .is_taken_out     (pht_is_taken)
  );

  // BTB
  wire btb_is_branch, btb_is_jump;
  wire[`ADDR_BUS] btb_target;

  BTB btb(
    .clk              (clk),
    .rst              (rst),
    .is_branch_in     (is_branch_in),
    .is_jump_in       (is_jump_in),
    .inst_pc          (inst_pc),
    .target_in        (target_in),
    .pc_in            (pc),
    .is_branch_out    (btb_is_branch),
    .is_jump_out      (btb_is_jump),
    .target_out       (btb_target)
  );

  // generate next PC
  reg[`ADDR_BUS] next_pc;
  assign is_branch_taken = btb_is_branch && (pht_is_taken || btb_is_jump);

  always @(*) begin
    if (!rst) begin
      next_pc <= `INIT_PC + 4;
    end
    else if (is_miss_in) begin
      next_pc <= target_in;
    end
    else if (is_branch_taken) begin
      next_pc <= btb_target;
    end
    else begin
      next_pc <= pc + 4;
    end
  end

  // generate current PC
  always @(posedge clk) begin
    if (!rst) begin
      pc <= `INIT_PC;
    end
    else begin
      pc <= next_pc;
    end
  end

endmodule // PC
