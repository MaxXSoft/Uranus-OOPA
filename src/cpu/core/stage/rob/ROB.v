`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "rob.v"
`include "opgen.v"

module ROB(
  input                   rst,
  // from ID stage
  input                   reg_write_en_in,
  input   [`REG_ADDR_BUS] reg_write_addr_in,
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input   [`ADDR_BUS]     inst_branch_target_in,
  input                   mem_write_flag_in,
  input                   mem_read_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [3:0]           mem_sel_in,
  input   [`DATA_BUS]     mem_offset_in,
  input                   cp0_read_flag_in,
  input                   cp0_write_flag_in,
  input   [`CP0_ADDR_BUS] cp0_addr_in,
  input   [`EXC_TYPE_BUS] exception_type_in,
  input                   is_delayslot_in,
  input   [`OPGEN_BUS]    opgen_in,
  input   [`SHAMT_BUS]    shamt_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input   [`DATA_BUS]     operand_data_1_in,
  input   [`DATA_BUS]     operand_data_2_in,
  input   [`ADDR_BUS]     pc_in,
  // stall request
  output                  stall_request,
  // reorder buffer write channel
  output                  rob_write_en,
  input                   rob_can_write,
  input   [`ROB_ADDR_BUS] rob_write_addr_in,
  // reorder buffer write data
  output                  rob_write_reg_write_en,
  output  [`REG_ADDR_BUS] rob_write_reg_write_addr,
  output                  rob_write_is_branch_taken,
  output  [`GHR_BUS]      rob_write_pht_index,
  output  [`ADDR_BUS]     rob_write_inst_branch_target,
  output                  rob_write_mem_write_flag,
  output                  rob_write_mem_read_flag,
  output                  rob_write_mem_sign_ext_flag,
  output  [3:0]           rob_write_mem_sel,
  output  [`DATA_BUS]     rob_write_mem_offset,
  output                  rob_write_cp0_read_flag,
  output                  rob_write_cp0_write_flag,
  output  [`CP0_ADDR_BUS] rob_write_cp0_addr,
  output  [`EXC_TYPE_BUS] rob_write_exception_type,
  output                  rob_write_is_delayslot,
  output  [`OPGEN_BUS]    rob_write_opgen,
  output  [`SHAMT_BUS]    rob_write_shamt,
  output                  rob_write_operand_is_ref_1,
  output                  rob_write_operand_is_ref_2,
  output  [`DATA_BUS]     rob_write_operand_data_1,
  output  [`DATA_BUS]     rob_write_operand_data_2,
  output  [`ADDR_BUS]     rob_write_pc,
  // reorder buffer commit channel
  output                  rob_commit_en,
  input                   rob_can_commit,
  // reorder buffer commit data
  input                   rob_commit_reg_write_en,
  input   [`REG_ADDR_BUS] rob_commit_reg_write_addr,
  input   [`DATA_BUS]     rob_commit_reg_write_data,
  input   [`EXC_TYPE_BUS] rob_commit_exception_type,
  input                   rob_commit_is_delayslot,
  input   [`ADDR_BUS]     rob_commit_pc,
  // regfile write channel
  output                  reg_write_en,
  output  [`REG_ADDR_BUS] reg_write_addr,
  output  [`ROB_ADDR_BUS] reg_write_ref_id,
  // regfile commit channel
  output                  reg_commit_en,
  output  [`REG_ADDR_BUS] reg_commit_addr,
  output  [`DATA_BUS]     reg_commit_data,
  // to pipeline controller
  output  [`EXC_TYPE_BUS] exception_type_out,
  output                  is_delayslot_out,
  output  [`ADDR_BUS]     current_pc_out
);

  // generate stall request
  assign stall_request = !rob_can_write;

  // generate reorder buffer control signal
  assign rob_write_en = rob_can_write;

  // generate write data to reorder buffer
  assign rob_write_reg_write_en = reg_write_en_in;
  assign rob_write_reg_write_addr = reg_write_addr_in;
  assign rob_write_is_branch_taken = is_branch_taken_in;
  assign rob_write_pht_index = pht_index_in;
  assign rob_write_inst_branch_target = inst_branch_target_in;
  assign rob_write_mem_write_flag = mem_write_flag_in;
  assign rob_write_mem_read_flag = mem_read_flag_in;
  assign rob_write_mem_sign_ext_flag = mem_sign_ext_flag_in;
  assign rob_write_mem_sel = mem_sel_in;
  assign rob_write_mem_offset = mem_offset_in;
  assign rob_write_cp0_read_flag = cp0_read_flag_in;
  assign rob_write_cp0_write_flag = cp0_write_flag_in;
  assign rob_write_cp0_addr = cp0_addr_in;
  assign rob_write_exception_type = exception_type_in;
  assign rob_write_is_delayslot = is_delayslot_in;
  assign rob_write_opgen = opgen_in;
  assign rob_write_shamt = shamt_in;
  assign rob_write_operand_is_ref_1 = operand_is_ref_1_in;
  assign rob_write_operand_is_ref_2 = operand_is_ref_2_in;
  assign rob_write_operand_data_1 = operand_data_1_in;
  assign rob_write_operand_data_2 = operand_data_2_in;
  assign rob_write_pc = pc_in;

  // generate regfile write signals
  assign reg_write_en = reg_write_en_in;
  assign reg_write_addr = reg_write_addr_in;
  assign reg_write_ref_id = rob_write_addr_in;

  // generate exception info
  reg[`EXC_TYPE_BUS] exception_type_out;
  assign is_delayslot_out = rob_commit_is_delayslot;
  assign current_pc_out = rob_commit_pc;

  always @(*) begin
    if (!rst || !rob_can_commit) begin
      exception_type_out <= `EXC_TYPE_NULL;
    end
    else if (|rob_commit_pc[1:0]) begin
      exception_type_out <= `EXC_TYPE_IF;
    end
    else begin
      exception_type_out <= rob_commit_exception_type;
    end
  end

  // generate regfile commit signals
  // NOTE: circular logic
  wire is_exception = exception_type_out != `EXC_TYPE_NULL;
  assign rob_commit_en = rob_can_commit && !is_exception;

  // generate regfile commit signals
  assign reg_commit_en = rob_commit_en && rob_commit_reg_write_en;
  assign reg_commit_addr = rob_commit_reg_write_addr;
  assign reg_commit_data = rob_commit_reg_write_data;

endmodule // ROB
