`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module IDROB(
  input                   clk,
  input                   rst,
  input                   flush,
  input                   stall_current_stage,
  input                   stall_next_stage,
  input                   reg_write_en_in,
  input   [`REG_ADDR_BUS] reg_write_addr_in,
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input                   is_inst_branch_in,
  input                   is_inst_jump_in,
  input                   is_inst_branch_taken_in,
  input                   is_inst_branch_determined_in,
  input   [`ADDR_BUS]     inst_branch_target_in,
  input                   is_next_delayslot_in,
  input                   is_delayslot_in,
  input                   mem_write_flag_in,
  input                   mem_read_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [3:0]           mem_sel_in,
  input                   mem_write_is_ref_in,
  input   [`DATA_BUS]     mem_write_data_in,
  input   [`CP0_ADDR_BUS] cp0_addr_in,
  input                   cp0_read_flag_in,
  input                   cp0_write_flag_in,
  input                   cp0_write_is_ref_in,
  input   [`DATA_BUS]     cp0_write_data_in,
  input   [`EXC_TYPE_BUS] exception_type_in,
  input   [`FUNCT_BUS]    funct_in,
  input   [`SHAMT_BUS]    shamt_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input   [`DATA_BUS]     operand_data_1_in,
  input   [`DATA_BUS]     operand_data_2_in,
  input   [`ADDR_BUS]     pc_in,
  output                  reg_write_en_out,
  output  [`REG_ADDR_BUS] reg_write_addr_out,
  output                  is_branch_taken_out,
  output  [`GHR_BUS]      pht_index_out,
  output                  is_inst_branch_out,
  output                  is_inst_jump_out,
  output                  is_inst_branch_taken_out,
  output                  is_inst_branch_determined_out,
  output  [`ADDR_BUS]     inst_branch_target_out,
  output                  is_current_delayslot_out,
  output                  is_delayslot_out,
  output                  mem_write_flag_out,
  output                  mem_read_flag_out,
  output                  mem_sign_ext_flag_out,
  output  [3:0]           mem_sel_out,
  output                  mem_write_is_ref_out,
  output  [`DATA_BUS]     mem_write_data_out,
  output  [`CP0_ADDR_BUS] cp0_addr_out,
  output                  cp0_read_flag_out,
  output                  cp0_write_flag_out,
  output                  cp0_write_is_ref_out,
  output  [`DATA_BUS]     cp0_write_data_out,
  output  [`EXC_TYPE_BUS] exception_type_out,
  output  [`FUNCT_BUS]    funct_out,
  output  [`SHAMT_BUS]    shamt_out,
  output                  operand_is_ref_1_out,
  output                  operand_is_ref_2_out,
  output  [`DATA_BUS]     operand_data_1_out,
  output  [`DATA_BUS]     operand_data_2_out,
  output  [`ADDR_BUS]     pc_out
);

  PipelineDeliver #(1) ff_reg_write_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_en_in, reg_write_en_out
  );

  PipelineDeliver #(`REG_ADDR_BUS_WIDTH) ff_reg_write_addr(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_addr_in, reg_write_addr_out
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

  PipelineDeliver #(1) ff_is_inst_branch(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_inst_branch_in, is_inst_branch_out
  );

  PipelineDeliver #(1) ff_is_inst_jump(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_inst_jump_in, is_inst_jump_out
  );

  PipelineDeliver #(1) ff_is_inst_branch_taken(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_inst_branch_taken_in, is_inst_branch_taken_out
  );

  PipelineDeliver #(1) ff_is_inst_branch_determined(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_inst_branch_determined_in, is_inst_branch_determined_out
  );

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_inst_branch_target(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    inst_branch_target_in, inst_branch_target_out
  );

  PipelineDeliver #(1) ff_is_current_delayslot(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_next_delayslot_in, is_current_delayslot_out
  );

  PipelineDeliver #(1) ff_is_delayslot(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    is_delayslot_in, is_delayslot_out
  );

  PipelineDeliver #(1) ff_mem_write_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_write_flag_in, mem_write_flag_out
  );

  PipelineDeliver #(1) ff_mem_read_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_read_flag_in, mem_read_flag_out
  );

  PipelineDeliver #(1) ff_mem_sign_ext_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_sign_ext_flag_in, mem_sign_ext_flag_out
  );

  PipelineDeliver #(4) ff_mem_sel(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_sel_in, mem_sel_out
  );

  PipelineDeliver #(1) ff_mem_write_is_ref(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_write_is_ref_in, mem_write_is_ref_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_mem_write_data(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_write_data_in, mem_write_data_out
  );

  PipelineDeliver #(`CP0_ADDR_BUS_WIDTH) ff_cp0_addr(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_addr_in, cp0_addr_out
  );

  PipelineDeliver #(1) ff_cp0_read_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_read_flag_in, cp0_read_flag_out
  );

  PipelineDeliver #(1) ff_cp0_write_flag(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_write_flag_in, cp0_write_flag_out
  );

  PipelineDeliver #(1) ff_cp0_write_is_ref(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_write_is_ref_in, cp0_write_is_ref_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_cp0_write_data(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    cp0_write_data_in, cp0_write_data_out
  );

  PipelineDeliver #(`EXC_TYPE_BUS_WIDTH) ff_exception_type(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    exception_type_in, exception_type_out
  );

  PipelineDeliver #(`FUNCT_BUS_WIDTH) ff_funct(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    funct_in, funct_out
  );

  PipelineDeliver #(`SHAMT_BUS_WIDTH) ff_shamt(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    shamt_in, shamt_out
  );

  PipelineDeliver #(1) ff_operand_is_ref_1(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    operand_is_ref_1_in, operand_is_ref_1_out
  );

  PipelineDeliver #(1) ff_operand_is_ref_2(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    operand_is_ref_2_in, operand_is_ref_2_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_operand_data_1(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    operand_data_1_in, operand_data_1_out
  );

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_operand_data_2(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    operand_data_2_in, operand_data_2_out
  );

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_pc(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    pc_in, pc_out
  );

endmodule // IDROB
