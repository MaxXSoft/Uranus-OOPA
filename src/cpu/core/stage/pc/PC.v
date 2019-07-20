`timescale 1ns / 1ps

`include "bus.v"
`include "exception.v"
`include "branch.v"

module PC(
  input               clk,
  input               rst,
  // control signals
  input               flush,
  input               stall,
  input   [`ADDR_BUS] exc_pc,
  // branch info
  input               is_branch_in,     // is last inst a branch/jump
  input               is_jump_in,       // is 'j' or 'jal'
  input               is_taken_in,      // is last branch taken
  input   [`GHR_BUS]  last_pht_index,   // last index of PHT
  input   [`ADDR_BUS] inst_pc,          // last PC of instruction
  input   [`ADDR_BUS] target_in,        // last branch target
  // output signals
  output              is_branch_taken,
  output  [`GHR_BUS]  pht_index_out,
  output  [`ADDR_BUS] pc_out
);

  // PC registers
  reg[`ADDR_BUS] pc_reg, pc_out_reg;
  assign pc_out = pc_out_reg;

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
  assign pht_index = pc_out[`GHR_WIDTH + 1:2] ^ ghr_out;  // Gshare
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
    .pc_in            (pc_out),
    .is_branch_out    (btb_is_branch),
    .is_jump_out      (btb_is_jump),
    .target_out       (btb_target)
  );

  // generate next PC
  reg[`ADDR_BUS] next_pc;
  assign is_branch_taken = btb_is_branch && (pht_is_taken || btb_is_jump);

  always @(*) begin
    if (flush) begin
      next_pc <= exc_pc;
    end
    else if (stall) begin
      next_pc <= pc_reg;
    end
    else if (is_branch_taken) begin
      next_pc <= btb_target;
    end
    else begin
      next_pc <= pc_reg + 4;
    end
  end

  // generate current PC
  always @(posedge clk) begin
    if (!rst) begin
      pc_reg <= `INIT_PC + 4;
      pc_out_reg <= `INIT_PC;
    end
    else if (flush) begin
      pc_reg <= next_pc;
      // fully reset when there is an exception
      // otherwise (misprediction) produce a delay slot
      pc_out_reg <= is_branch_in ? inst_pc + 4 : `INVALID_PC;
    end
    else if (!stall) begin
      // TODO:
      // if there is a stall signal,
      // check if the same instruction has been executed multiple times
      pc_reg <= next_pc;
      pc_out_reg <= pc_reg;
    end
  end

endmodule // PC
