`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "opgen.v"

module II(
  input                   rst,
  // from ROB stage
  input                   can_issue_in,
  input   [`ROB_ADDR_BUS] rob_addr_in,
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input   [`ADDR_BUS]     inst_branch_target_in,
  input                   mem_write_flag_in,
  input                   mem_read_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [3:0]           mem_sel_in,
  input   [`DATA_BUS]     mem_offset_in,
  input   [`EXC_TYPE_BUS] exception_type_in,
  input   [`OPGEN_BUS]    opgen_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input   [`DATA_BUS]     operand_data_1_in,
  input   [`DATA_BUS]     operand_data_2_in,
  input   [`ADDR_BUS]     pc_in,
  // to pipeline controller
  output                  stall_request,
  // write channel enable signals
  output                  int_wen,
  output                  mdu_wen,
  output                  lsu_wen,
  output                  bru_wen,
  // write channel data signals
  output  [`EXC_TYPE_BUS] exception_type_out,
  output  [`OPGEN_BUS]    opgen_out,
  output                  operand_is_ref_1_out,
  output                  operand_is_ref_2_out,
  output  [`DATA_BUS]     operand_data_1_out,
  output  [`DATA_BUS]     operand_data_2_out,
  // RS Int commit channel
  //
  // RS MDU commit channel
  //
  // RS LSU commit channel
  //
  // RS BRU commit channel
  //
);

  // output signals to reservation station
  reg int_wen, mdu_wen, lsu_wen, bru_wen;

  // generate write enable of reservation stations
  always @(*) begin
    if (!rst || !can_issue_in) begin
      {int_wen, mdu_wen, lsu_wen, bru_wen} <= 4'b0000;
    end
    else begin
      case (opgen_in)
        `OPGEN_NOP, `OPGEN_ADD, `OPGEN_SUB, `OPGEN_SLT, `OPGEN_SLTU,
        `OPGEN_AND, `OPGEN_NOR, `OPGEN_OR, `OPGEN_XOR,
        `OPGEN_SLL, `OPGEN_SRA, `OPGEN_SRL,
        `OPGEN_CLZ, `OPGEN_CLO, `OPGEN_MOVZ, `OPGEN_MOVN: begin
          {int_wen, mdu_wen, lsu_wen, bru_wen} <= 4'b1000;
        end
        `OPGEN_DIV, `OPGEN_DIVU, `OPGEN_MULT, `OPGEN_MULTU,
        `OPGEN_MSUB, `OPGEN_MSUBU, `OPGEN_MUL: begin
          {int_wen, mdu_wen, lsu_wen, bru_wen} <= 4'b0100;
        end
        `OPGEN_MEM: begin
          {int_wen, mdu_wen, lsu_wen, bru_wen} <= 4'b0010;
        end
        `OPGEN_BEQ, `OPGEN_BNE,
        `OPGEN_BGEZ, `OPGEN_BGTZ, `OPGEN_BLEZ, `OPGEN_BLTZ,
        `OPGEN_J, `OPGEN_JR: begin
          {int_wen, mdu_wen, lsu_wen, bru_wen} <= 4'b0001;
        end
        default: begin
          {int_wen, mdu_wen, lsu_wen, bru_wen} <= 4'b0000;
        end
      endcase
    end
  end

  // generate data to reservation stations
  assign exception_type_out = exception_type_in;
  assign opgen_out = opgen_in;
  assign operand_is_ref_1_out = operand_is_ref_1_in;
  assign operand_is_ref_2_out = operand_is_ref_2_in;
  assign operand_data_1_out = operand_data_1_in;
  assign operand_data_2_out = operand_data_2_in;

endmodule // II
