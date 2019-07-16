`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "segpos.v"

module ID(
  input                   rst,
  // from IF stage
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input   [`ADDR_BUS]     pc_in,
  input   [`INST_BUS]     inst_in,
  // regfile reader
  input                   reg_read_is_rsid_1,
  input                   reg_read_is_rsid_2,
  input   [`DATA_BUS]     reg_read_data_1,
  input   [`DATA_BUS]     reg_read_data_2,
  output                  reg_read_en_1_out,
  output                  reg_read_en_2_out,
  output  [`REG_ADDR_BUS] reg_read_addr_1_out,
  output  [`REG_ADDR_BUS] reg_read_addr_2_out,
  // regfile writer
  output                  reg_write_en,
  output  [`REG_ADDR_BUS] reg_write_addr,
  // to PC stage
  //
  // to ROB stage
  output  [`FUNCT_BUS]    funct,
  output                  operand_is_rsid_1,
  output                  operand_is_rsid_2,
  output  [`DATA_BUS]     operand_data_1,
  output  [`DATA_BUS]     operand_data_2,
);

  // extract information from instruction
  wire[`INST_OP_BUS] inst_op = inst_in[`SEG_OPCODE];
  wire[`REG_ADDR_BUS] inst_rs = inst_in[`SEG_RS];
  wire[`REG_ADDR_BUS] inst_rt = inst_in[`SEG_RT];
  wire[`REG_ADDR_BUS] inst_rd = inst_in[`SEG_RD];
  wire[`SHAMT_BUS] inst_shamt = inst_in[`SEG_SHAMT];
  wire[`FUNCT_BUS] inst_funct = inst_in[`SEG_FUNCT];
  wire[`HALF_DATA_BUS] inst_imm = inst[`SEG_IMM];
  wire[`JUMP_ADDR_BUS] inst_jump = inst[`SEG_JUMP];
  wire inst_is_cp0 = !inst[`SEG_EMPTY];

  // generate funct signal
  FunctGen funct_gen(
    .rst      (rst),
    .op       (inst_op),
    .funct_in (inst_funct),
    .rt       (inst_rt),
    .funct    (funct)
  );

  // generate operand_1, operand_2, reg_write_en and reg_write_addr
  RegGen reg_gen(
    .rst                (rst),
    .pc                 (pc_in),
    .op                 (inst_op),
    .rs                 (inst_rs),
    .rt                 (inst_rt),
    .rd                 (inst_rd),
    .imm                (inst_imm),
    .is_cp0             (inst_is_cp0),
    .funct              (funct),
    .reg_read_is_rsid_1 (reg_read_is_rsid_1),
    .reg_read_is_rsid_2 (reg_read_is_rsid_2),
    .reg_read_data_1    (reg_read_data_1),
    .reg_read_data_2    (reg_read_data_2),
    .reg_read_en_1      (reg_read_en_1_out),
    .reg_read_en_2      (reg_read_en_2_out),
    .reg_read_addr_1    (reg_read_addr_1_out),
    .reg_read_addr_2    (reg_read_addr_2_out),
    .reg_write_en       (reg_write_en),
    .reg_write_addr     (reg_write_addr),
    .operand_is_rsid_1  (operand_is_rsid_1),
    .operand_is_rsid_2  (operand_is_rsid_2),
    .operand_data_1     (operand_data_1),
    .operand_data_2     (operand_data_2)
  );

  // TODO

endmodule // ID
