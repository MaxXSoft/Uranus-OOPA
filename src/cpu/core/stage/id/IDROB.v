`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "opgen.v"
`include "regfile.v"

module IDROB(
  input                   clk,
  input                   rst,
  input                   flush,
  input                   stall_current_stage,
  input                   stall_next_stage,
  input                   reg_write_add_in,
  input                   reg_write_en_in,
  input   [`RF_ADDR_BUS]  reg_write_addr_in,
  input                   reg_write_lo_en_in,
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input   [`ADDR_BUS]     inst_branch_target_in,
  input                   mem_write_flag_in,
  input                   mem_read_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [3:0]           mem_sel_in,
  input   [`DATA_BUS]     mem_offset_in,
  input   [`EXC_TYPE_BUS] exception_type_in,
  input                   is_next_delayslot_in,
  input                   is_delayslot_in,
  input   [`OPGEN_BUS]    opgen_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input   [`DATA_BUS]     operand_data_1_in,
  input   [`DATA_BUS]     operand_data_2_in,
  input   [`ADDR_BUS]     pc_in,
  output                  reg_write_add_out,
  output                  reg_write_en_out,
  output  [`RF_ADDR_BUS]  reg_write_addr_out,
  output                  reg_write_lo_en_out,
  output                  is_branch_taken_out,
  output  [`GHR_BUS]      pht_index_out,
  output  [`ADDR_BUS]     inst_branch_target_out,
  output                  mem_write_flag_out,
  output                  mem_read_flag_out,
  output                  mem_sign_ext_flag_out,
  output  [3:0]           mem_sel_out,
  output  [`DATA_BUS]     mem_offset_out,
  output  [`EXC_TYPE_BUS] exception_type_out,
  output                  is_current_delayslot_out,
  output                  is_delayslot_out,
  output  [`OPGEN_BUS]    opgen_out,
  output                  operand_is_ref_1_out,
  output                  operand_is_ref_2_out,
  output  [`DATA_BUS]     operand_data_1_out,
  output  [`DATA_BUS]     operand_data_2_out,
  output  [`ADDR_BUS]     pc_out
);

  PipelineDeliver #(1) ff_reg_write_add(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_add_in, reg_write_add_out
  );

  PipelineDeliver #(1) ff_reg_write_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_en_in, reg_write_en_out
  );

  PipelineDeliver #(`RF_ADDR_BUS_WIDTH) ff_reg_write_addr(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_addr_in, reg_write_addr_out
  );

  PipelineDeliver #(1) ff_reg_write_lo_en(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    reg_write_lo_en_in, reg_write_lo_en_out
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

  PipelineDeliver #(`ADDR_BUS_WIDTH) ff_inst_branch_target(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    inst_branch_target_in, inst_branch_target_out
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

  PipelineDeliver #(`DATA_BUS_WIDTH) ff_mem_offset(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    mem_offset_in, mem_offset_out
  );

  PipelineDeliver #(`EXC_TYPE_BUS_WIDTH) ff_exception_type(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    exception_type_in, exception_type_out
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

  PipelineDeliver #(`OPGEN_WIDTH) ff_opgen(
    clk, rst, flush,
    stall_current_stage, stall_next_stage,
    opgen_in, opgen_out
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
