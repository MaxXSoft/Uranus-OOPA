`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "branch.v"

`define ADD_BRANCH_CHECK(src, dst, jump, taken)               \
    if (mod_pc == src && mod_is_branch_taken != taken) begin  \
      $display("MISS! (0x%8h)", mod_pc);                      \
      is_branch_in <= 1;                                      \
      is_jump_in <= jump;                                     \
      is_taken_in <= taken;                                   \
      last_pht_index <= mod_pht_index;                        \
      inst_pc <= mod_pc;                                      \
      target_in <= dst;                                       \
      flush <= 1;                                             \
      exc_pc <= dst;                                          \
    end

module PC_tb(
  input clk,
  input rst
);

  // generate tick counter
  `GEN_TICK(clk, rst);

  // modules
  reg is_branch_in, is_jump_in, is_taken_in, flush, stall;
  reg[`GHR_BUS] last_pht_index;
  reg[`ADDR_BUS] inst_pc, target_in, exc_pc;
  wire is_branch_taken;
  wire[`GHR_BUS] pht_index_out;
  wire[`ADDR_BUS] pc_out;

  wire mod_is_branch_taken;
  wire[`GHR_BUS] mod_pht_index;
  wire[`ADDR_BUS] mod_pc;

  PC stage_pc(
    .clk                  (clk),
    .rst                  (rst),

    .is_branch_in         (is_branch_in),
    .is_jump_in           (is_jump_in),
    .is_taken_in          (is_taken_in),
    .last_pht_index       (last_pht_index),
    .inst_pc              (inst_pc),
    .target_in            (target_in),

    .flush                (flush),
    .stall                (stall),
    .exc_pc               (exc_pc),

    .is_branch_taken      (is_branch_taken),
    .pht_index_out        (pht_index_out),
    .pc_out               (pc_out)
  );

  PCIF pcif_mid(
    .clk                  (clk),
    .rst                  (rst),
    .flush                (flush),
    .stall_current_stage  (stall),
    .stall_next_stage     (stall),
    .is_branch_taken_in   (is_branch_taken),
    .pht_index_in         (pht_index_out),
    .pc_in                (pc_out),
    .is_branch_taken_out  (mod_is_branch_taken),
    .pht_index_out        (mod_pht_index),
    .pc_out               (mod_pc)
  );

  // testbench
  always @(*) begin
    is_branch_in <= 0;
    is_jump_in <= 0;
    is_taken_in <= 0;
    last_pht_index <= 0;
    inst_pc <= 0;
    target_in <= 0;
    flush <= 0;
    stall <= 0;
    exc_pc <= 0;

    `ADD_BRANCH_CHECK(32'hbfc00010, 32'hbfc00000, 0, 1);

    // just check if stall signal is working properly
    if (`TICK >= 32'h4a && `TICK <= 32'h4e) stall <= 1;

    // `DISPLAY("mod_is_branch_taken ", mod_is_branch_taken);
    // `DISPLAY("mod_pht_index       ", mod_pht_index);
    `DISPLAY("*****  mod_pc  *****", mod_pc);
    `END_AT_TICK(100);
  end

endmodule // PC_tb
