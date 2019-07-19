`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "rob.v"

module ROB(
  input                   rst,
  // from ID stage
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
  // reorder buffer control
  input                   rob_can_write,
  input                   rob_write_addr,
  output                  rob_write_en,
  // stall request
  output                  stall_request,
  // to regfile
  output                  reg_write_en,
  output  [`REG_ADDR_BUS] reg_write_addr,
  output  [`ROB_ADDR_BUS] reg_write_ref_id,
  // to reorder buffer
  output                  done_out,
  output                  reg_write_en_out,
  output  [`REG_ADDR_BUS] reg_write_addr_out,
  output                  is_branch_taken_out,
  output  [`GHR_BUS]      pht_index_out,
  output                  is_inst_branch_out,
  output                  is_inst_jump_out,
  output                  is_inst_branch_taken_out,
  output                  is_inst_branch_determined_out,
  output  [`ADDR_BUS]     inst_branch_target_out,
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

  // indicate if input from ID is valid instruction information
  // rather than bubble in pipeline
  wire is_valid_inst_info = reg_write_en_in || is_inst_branch_in ||
                            mem_write_flag_in || mem_read_flag_in ||
                            cp0_read_flag_in || cp0_write_flag_in ||
                            |exception_type_in;

  // generate reorder buffer control signal
  assign rob_write_en = is_valid_inst_info && rob_can_write;

  // generate stall request
  assign stall_request = !rob_can_write;
  
  // generate regfile write signal
  assign reg_write_en = is_valid_inst_info && reg_write_en_in;
  assign reg_write_addr = reg_write_addr_in;
  assign reg_write_ref_id = rob_write_addr;

  // generate output to reorder buffer
  assign done_out = 0;
  assign reg_write_en_out = reg_write_en_in;
  assign reg_write_addr_out = reg_write_addr_in;
  assign is_branch_taken_out = is_branch_taken_in;
  assign pht_index_out = pht_index_in;
  assign is_inst_branch_out = is_inst_branch_in;
  assign is_inst_jump_out = is_inst_jump_in;
  assign is_inst_branch_taken_out = is_inst_branch_taken_in;
  assign is_inst_branch_determined_out = is_inst_branch_determined_in;
  assign inst_branch_target_out = inst_branch_target_in;
  assign is_delayslot_out = is_delayslot_in;
  assign mem_write_flag_out = mem_write_flag_in;
  assign mem_read_flag_out = mem_read_flag_in;
  assign mem_sign_ext_flag_out = mem_sign_ext_flag_in;
  assign mem_sel_out = mem_sel_in;
  assign mem_write_is_ref_out = mem_write_is_ref_in;
  assign mem_write_data_out = mem_write_data_in;
  assign cp0_addr_out = cp0_addr_in;
  assign cp0_read_flag_out = cp0_read_flag_in;
  assign cp0_write_flag_out = cp0_write_flag_in;
  assign cp0_write_is_ref_out = cp0_write_is_ref_in;
  assign cp0_write_data_out = cp0_write_data_in;
  assign exception_type_out = exception_type_in;
  assign funct_out = funct_in;
  assign shamt_out = shamt_in;
  assign operand_is_ref_1_out = operand_is_ref_1_in;
  assign operand_is_ref_2_out = operand_is_ref_2_in;
  assign operand_data_1_out = operand_data_1_in;
  assign operand_data_2_out = operand_data_2_in;
  assign pc_out = pc_in;

endmodule // ROB
