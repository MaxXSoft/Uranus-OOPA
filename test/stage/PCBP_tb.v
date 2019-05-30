`timescale 1ns / 1ps

`include "tb.v"
`include "branch.v"

module PCBP_tb(
  input clk,
  input rst
);

  // generate tick counter
  `GEN_TICK(clk, rst);

  // modules
  wire [31:0] pc_pc_out;
  wire [31:0] bp_pc_in;
  wire [31:0] mod_next_pc;

  PC pc(
    .rst      (rst),
    .next_pc  (mod_next_pc),
    .pc_out   (pc_pc_out)
  );

  PCBP pcbp(
    .clk                  (clk),
    .rst                  (rst),
    .flush                (0),
    .stall_current_stage  (0),
    .stall_next_stage     (0),
    .pc_in                (pc_pc_out),
    .pc_out               (bp_pc_in)
  );

  reg is_branch_in, is_jump_in, is_taken_in, is_miss_in;
  reg [`GHR_BUS] last_pht_index;
  reg [31:0] inst_pc, target_in;
  wire is_branch_taken;
  wire [`GHR_BUS] current_pht_index_out;
  wire [31:0] next_pc_out, current_pc_out;

  wire mod_is_branch_taken;
  wire [`GHR_BUS] mod_current_pht_index;
  wire [31:0] mod_current_pc;

  wire [`GHR_BUS] ghr_in;
  wire ghr_is_branch_out;
  wire ghr_is_taken_out;

  wire pht_is_taken_in;
  wire pht_is_last_branch_out;
  wire pht_is_last_taken_out;
  wire [`GHR_BUS] pht_last_index_out;
  wire [`GHR_BUS] pht_index_out;

  wire btb_is_branch_in;
  wire btb_is_jump_in;
  wire [31:0] btb_target_in;
  wire btb_is_branch_out;
  wire btb_is_jump_out;
  wire [31:0] btb_inst_pc_out;
  wire [31:0] btb_target_out;
  wire [31:0] btb_pc_out;

  BP bp(
    .rst                    (rst),
    .pc_in                  (bp_pc_in),
    .is_branch_in           (is_branch_in),
    .is_jump_in             (is_jump_in),
    .is_taken_in            (is_taken_in),
    .is_miss_in             (is_miss_in),
    .last_pht_index         (last_pht_index),
    .inst_pc                (inst_pc),
    .target_in              (target_in),

    .ghr_in                 (ghr_in),
    .ghr_is_branch_out      (ghr_is_branch_out),
    .ghr_is_taken_out       (ghr_is_taken_out),

    .pht_is_taken_in        (pht_is_taken_in),
    .pht_is_last_branch_out (pht_is_last_branch_out),
    .pht_is_last_taken_out  (pht_is_last_taken_out),
    .pht_last_index_out     (pht_last_index_out),
    .pht_index_out          (pht_index_out),

    .btb_is_branch_in       (btb_is_branch_in),
    .btb_is_jump_in         (btb_is_jump_in),
    .btb_target_in          (btb_target_in),
    .btb_is_branch_out      (btb_is_branch_out),
    .btb_is_jump_out        (btb_is_jump_out),
    .btb_inst_pc_out        (btb_inst_pc_out),
    .btb_target_out         (btb_target_out),
    .btb_pc_out             (btb_pc_out),

    .is_branch_taken        (is_branch_taken),
    .current_pht_index_out  (current_pht_index_out),
    .next_pc_out            (next_pc_out),
    .current_pc_out         (current_pc_out)
  );

  BPIF bpif_stage(
    .clk                    (clk),
    .rst                    (rst),
    .flush                  (0),
    .stall_current_stage    (0),
    .stall_next_stage       (0),
    .is_branch_taken_in     (is_branch_taken),
    .current_pht_index_in   (current_pht_index_out),
    .next_pc_in             (next_pc_out),
    .current_pc_in          (current_pc_out),
    .is_branch_taken_out    (mod_is_branch_taken),
    .current_pht_index_out  (mod_current_pht_index),
    .next_pc_out            (mod_next_pc),
    .current_pc_out         (mod_current_pc)
  );

  GHR ghr_reg(
    .clk                    (clk),
    .rst                    (rst),
    .is_branch              (ghr_is_branch_out),
    .is_taken               (ghr_is_taken_out),
    .ghr_out                (ghr_in)
  );

  PHT pht(
    .clk                    (clk),
    .rst                    (rst),
    .is_last_branch         (pht_is_last_branch_out),
    .is_last_taken          (pht_is_last_taken_out),
    .last_index             (pht_last_index_out),
    .index                  (pht_index_out),
    .is_taken_out           (pht_is_taken_in)
  );

  BTB btb(
    .clk                    (clk),
    .rst                    (rst),
    .is_branch_in           (btb_is_branch_out),
    .is_jump_in             (btb_is_jump_out),
    .inst_pc                (btb_inst_pc_out),
    .target_in              (btb_target_out),
    .pc_in                  (btb_pc_out),
    .is_branch_out          (btb_is_branch_in),
    .is_jump_out            (btb_is_jump_in),
    .target_out             (btb_target_in)
  );

  // testbench
  always @(posedge clk) begin
    if (!rst) begin
      is_branch_in <= 0;
      is_jump_in <= 0;
      is_taken_in <= 0;
      is_miss_in <= 0;
      last_pht_index <= 0;
      inst_pc <= 0;
      target_in <= 0;
    end
    else begin
      // TODO
    end

    `DISPLAY("mod_is_branch_taken", mod_is_branch_taken);
    `DISPLAY("mod_current_pht_index", mod_current_pht_index);
    `DISPLAY("mod_next_pc", mod_next_pc);
    `DISPLAY("mod_current_pc", mod_current_pc);
    if (tick >= 10) $finish;
  end

endmodule // PCBP_tb
