`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module ROBLine(
  input                   clk,
  input                   rst,
  input                   write_en,
  // input signals
  input                   done_in,
  input                   reg_write_en_in,
  input   [`REG_ADDR_BUS] reg_write_addr_in,
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input                   is_inst_branch_in,
  input                   is_inst_jump_in,
  input                   is_inst_branch_taken_in,
  input                   is_inst_branch_determined_in,
  input   [`ADDR_BUS]     inst_branch_target_in,
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
  // output signals
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

  // storage
  reg                     done_out;
  reg                     reg_write_en_out;
  reg[`REG_ADDR_BUS]      reg_write_addr_out;
  reg                     is_branch_taken_out;
  reg[`GHR_BUS]           pht_index_out;
  reg                     is_inst_branch_out;
  reg                     is_inst_jump_out;
  reg                     is_inst_branch_taken_out;
  reg                     is_inst_branch_determined_out;
  reg[`ADDR_BUS]          inst_branch_target_out;
  reg                     is_delayslot_out;
  reg                     mem_write_flag_out;
  reg                     mem_read_flag_out;
  reg                     mem_sign_ext_flag_out;
  reg[3:0]                mem_sel_out;
  reg                     mem_write_is_ref_out;
  reg[`DATA_BUS]          mem_write_data_out;
  reg[`CP0_ADDR_BUS]      cp0_addr_out;
  reg                     cp0_read_flag_out;
  reg                     cp0_write_flag_out;
  reg                     cp0_write_is_ref_out;
  reg[`DATA_BUS]          cp0_write_data_out;
  reg[`EXC_TYPE_BUS]      exception_type_out;
  reg[`FUNCT_BUS]         funct_out;
  reg[`SHAMT_BUS]         shamt_out;
  reg                     operand_is_ref_1_out;
  reg                     operand_is_ref_2_out;
  reg[`DATA_BUS]          operand_data_1_out;
  reg[`DATA_BUS]          operand_data_2_out;
  reg[`ADDR_BUS]          pc_out;

  // write to storage
  always @(posedge clk) begin
    if (!rst) begin
      done_out <= 0;
      reg_write_en_out <= 0;
      reg_write_addr_out <= 0;
      is_branch_taken_out <= 0;
      pht_index_out <= 0;
      is_inst_branch_out <= 0;
      is_inst_jump_out <= 0;
      is_inst_branch_taken_out <= 0;
      is_inst_branch_determined_out <= 0;
      inst_branch_target_out <= 0;
      is_delayslot_out <= 0;
      mem_write_flag_out <= 0;
      mem_read_flag_out <= 0;
      mem_sign_ext_flag_out <= 0;
      mem_sel_out <= 0;
      mem_write_is_ref_out <= 0;
      mem_write_data_out <= 0;
      cp0_addr_out <= 0;
      cp0_read_flag_out <= 0;
      cp0_write_flag_out <= 0;
      cp0_write_is_ref_out <= 0;
      cp0_write_data_out <= 0;
      exception_type_out <= 0;
      funct_out <= 0;
      shamt_out <= 0;
      operand_is_ref_1_out <= 0;
      operand_is_ref_2_out <= 0;
      operand_data_1_out <= 0;
      operand_data_2_out <= 0;
      pc_out <= 0;
    end
    else if (write_en) begin
      done_out <= done_in;
      reg_write_en_out <= reg_write_en_in;
      reg_write_addr_out <= reg_write_addr_in;
      is_branch_taken_out <= is_branch_taken_in;
      pht_index_out <= pht_index_in;
      is_inst_branch_out <= is_inst_branch_in;
      is_inst_jump_out <= is_inst_jump_in;
      is_inst_branch_taken_out <= is_inst_branch_taken_in;
      is_inst_branch_determined_out <= is_inst_branch_determined_in;
      inst_branch_target_out <= inst_branch_target_in;
      is_delayslot_out <= is_delayslot_in;
      mem_write_flag_out <= mem_write_flag_in;
      mem_read_flag_out <= mem_read_flag_in;
      mem_sign_ext_flag_out <= mem_sign_ext_flag_in;
      mem_sel_out <= mem_sel_in;
      mem_write_is_ref_out <= mem_write_is_ref_in;
      mem_write_data_out <= mem_write_data_in;
      cp0_addr_out <= cp0_addr_in;
      cp0_read_flag_out <= cp0_read_flag_in;
      cp0_write_flag_out <= cp0_write_flag_in;
      cp0_write_is_ref_out <= cp0_write_is_ref_in;
      cp0_write_data_out <= cp0_write_data_in;
      exception_type_out <= exception_type_in;
      funct_out <= funct_in;
      shamt_out <= shamt_in;
      operand_is_ref_1_out <= operand_is_ref_1_in;
      operand_is_ref_2_out <= operand_is_ref_2_in;
      operand_data_1_out <= operand_data_1_in;
      operand_data_2_out <= operand_data_2_in;
      pc_out <= pc_in;
    end
  end

endmodule // ROBLine
