`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "funct.v"

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
  //
);

  //

endmodule // ID
