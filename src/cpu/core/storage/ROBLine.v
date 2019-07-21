`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "opgen.v"

module ROBLine(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  input                   write_reg_write_en_in,
  input   [`REG_ADDR_BUS] write_reg_write_addr_in,
  input                   write_is_branch_taken_in,
  input   [`GHR_BUS]      write_pht_index_in,
  input   [`ADDR_BUS]     write_inst_branch_target_in,
  input                   write_mem_write_flag_in,
  input                   write_mem_read_flag_in,
  input                   write_mem_sign_ext_flag_in,
  input   [3:0]           write_mem_sel_in,
  input   [`DATA_BUS]     write_mem_offset_in,
  input                   write_cp0_read_flag_in,
  input                   write_cp0_write_flag_in,
  input   [`CP0_ADDR_BUS] write_cp0_addr_in,
  input   [`EXC_TYPE_BUS] write_exception_type_in,
  input                   write_is_delayslot_in,
  input   [`OPGEN_BUS]    write_opgen_in,
  input   [`SHAMT_BUS]    write_shamt_in,
  input                   write_operand_is_ref_1_in,
  input                   write_operand_is_ref_2_in,
  input   [`DATA_BUS]     write_operand_data_1_in,
  input   [`DATA_BUS]     write_operand_data_2_in,
  input   [`ADDR_BUS]     write_pc_in,
  // update channel
  input                   update_en,
  input   [`DATA_BUS]     update_reg_write_data_in,
  input   [`EXC_TYPE_BUS] update_exception_type_in,
  // output signals
  output                  done_out,
  output                  reg_write_en_out,
  output  [`REG_ADDR_BUS] reg_write_addr_out,
  output  [`DATA_BUS]     reg_write_data_out,
  output                  is_branch_taken_out,
  output  [`GHR_BUS]      pht_index_out,
  output  [`ADDR_BUS]     inst_branch_target_out,
  output                  mem_write_flag_out,
  output                  mem_read_flag_out,
  output                  mem_sign_ext_flag_out,
  output  [3:0]           mem_sel_out,
  output  [`DATA_BUS]     mem_offset_out,
  output                  cp0_read_flag_out,
  output                  cp0_write_flag_out,
  output  [`CP0_ADDR_BUS] cp0_addr_out,
  output  [`EXC_TYPE_BUS] exception_type_out,
  output                  is_delayslot_out,
  output  [`OPGEN_BUS]    opgen_out,
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
  reg[`DATA_BUS]          reg_write_data_out;
  reg                     is_branch_taken_out;
  reg[`GHR_BUS]           pht_index_out;
  reg[`ADDR_BUS]          inst_branch_target_out;
  reg                     mem_write_flag_out;
  reg                     mem_read_flag_out;
  reg                     mem_sign_ext_flag_out;
  reg[3:0]                mem_sel_out;
  reg[`DATA_BUS]          mem_offset_out;
  reg                     cp0_read_flag_out;
  reg                     cp0_write_flag_out;
  reg[`CP0_ADDR_BUS]      cp0_addr_out;
  reg[`EXC_TYPE_BUS]      exception_type_out;
  reg                     is_delayslot_out;
  reg[`OPGEN_BUS]         opgen_out;
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
      reg_write_data_out <= 0;
      is_branch_taken_out <= 0;
      pht_index_out <= 0;
      inst_branch_target_out <= 0;
      mem_write_flag_out <= 0;
      mem_read_flag_out <= 0;
      mem_sign_ext_flag_out <= 0;
      mem_sel_out <= 0;
      mem_offset_out <= 0;
      cp0_read_flag_out <= 0;
      cp0_write_flag_out <= 0;
      cp0_addr_out <= 0;
      exception_type_out <= 0;
      is_delayslot_out <= 0;
      opgen_out <= 0;
      shamt_out <= 0;
      operand_is_ref_1_out <= 0;
      operand_is_ref_2_out <= 0;
      operand_data_1_out <= 0;
      operand_data_2_out <= 0;
      pc_out <= 0;
    end
    else if (update_en) begin
      done_out <= 1;
      reg_write_data_out <= update_reg_write_data_in;
      exception_type_out <= update_exception_type_in;
    end
    else if (write_en) begin
      done_out <= 0;
      reg_write_en_out <= write_reg_write_en_in;
      reg_write_addr_out <= write_reg_write_addr_in;
      reg_write_data_out <= 0;
      is_branch_taken_out <= write_is_branch_taken_in;
      pht_index_out <= write_pht_index_in;
      inst_branch_target_out <= write_inst_branch_target_in;
      mem_write_flag_out <= write_mem_write_flag_in;
      mem_read_flag_out <= write_mem_read_flag_in;
      mem_sign_ext_flag_out <= write_mem_sign_ext_flag_in;
      mem_sel_out <= write_mem_sel_in;
      mem_offset_out <= write_mem_offset_in;
      cp0_read_flag_out <= write_cp0_read_flag_in;
      cp0_write_flag_out <= write_cp0_write_flag_in;
      cp0_addr_out <= write_cp0_addr_in;
      exception_type_out <= write_exception_type_in;
      is_delayslot_out <= write_is_delayslot_in;
      opgen_out <= write_opgen_in;
      shamt_out <= write_shamt_in;
      operand_is_ref_1_out <= write_operand_is_ref_1_in;
      operand_is_ref_2_out <= write_operand_is_ref_2_in;
      operand_data_1_out <= write_operand_data_1_in;
      operand_data_2_out <= write_operand_data_2_in;
      pc_out <= write_pc_in;
    end
  end

endmodule // ROBLine
