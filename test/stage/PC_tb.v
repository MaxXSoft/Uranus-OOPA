`timescale 1ns / 1ps

`include "tb.v"
`include "branch.v"

`define ADD_BRANCH_CHECK(src, dst, jump, taken)               \
    if (mod_pc == src && mod_is_branch_taken != taken) begin  \
      $display("MISS! (0x%8h)", mod_pc);                      \
      is_branch_in <= 1;                                      \
      is_jump_in <= jump;                                     \
      is_taken_in <= taken;                                   \
      is_miss_in <= 1;                                        \
      last_pht_index <= mod_pht_index;                        \
      inst_pc <= mod_pc;                                      \
      target_in <= dst;                                       \
    end

module PC_tb(
  input clk,
  input rst
);

  // generate tick counter
  `GEN_TICK(clk, rst);

  // modules
  reg is_branch_in, is_jump_in, is_taken_in, is_miss_in;
  reg[`GHR_BUS] last_pht_index;
  reg[31:0] inst_pc, target_in;
  wire is_branch_taken;
  wire[`GHR_BUS] pht_index_out;
  wire[31:0] pc_out;

  wire mod_is_branch_taken;
  wire[`GHR_BUS] mod_pht_index;
  wire[31:0] mod_pc;

  PC stage_pc(
    .clk                  (clk),
    .rst                  (rst),

    .is_branch_in         (is_branch_in),
    .is_jump_in           (is_jump_in),
    .is_taken_in          (is_taken_in),
    .is_miss_in           (is_miss_in),
    .last_pht_index       (last_pht_index),
    .inst_pc              (inst_pc),
    .target_in            (target_in),

    .flush                (0),
    .stall                (0),
    .exc_pc               (0),

    .is_branch_taken      (is_branch_taken),
    .pht_index_out        (pht_index_out),
    .pc_out               (pc_out)
  );

  PCIF pcif_mid(
    .clk                  (clk),
    .rst                  (rst),
    .flush                (0),
    .stall_current_stage  (0),
    .stall_next_stage     (0),
    .is_branch_taken_in   (is_branch_taken),
    .pht_index_in         (pht_index_out),
    .pc_in                (pc_out),
    .is_branch_taken_out  (mod_is_branch_taken),
    .pht_index_out        (mod_pht_index),
    .pc_out               (mod_pc)
  );

  // testbench
  always @(posedge clk) begin
    is_branch_in <= 0;
    is_jump_in <= 0;
    is_taken_in <= 0;
    is_miss_in <= 0;
    last_pht_index <= 0;
    inst_pc <= 0;
    target_in <= 0;

    `ADD_BRANCH_CHECK(32'hbfc00010, 32'hbfc00000, 0, 1);

    // `DISPLAY("mod_is_branch_taken ", mod_is_branch_taken);
    // `DISPLAY("mod_pht_index       ", mod_pht_index);
    `DISPLAY("*****  mod_pc  *****", mod_pc);
    if (`TICK >= 100) $finish;
  end

endmodule // PC_tb
