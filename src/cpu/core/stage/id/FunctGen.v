`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "regimm.v"

module FunctGen(
  input                   rst,
  input   [`INST_OP_BUS]  op,
  input   [`FUNCT_BUS]    funct_in,
  input   [`REG_ADDR_BUS] rt,
  output  [`FUNCT_BUS]    funct
);

  reg[`FUNCT_BUS] funct_out;
  assign funct = rst ? funct_out : `FUNCT_NOP;

  // generate 'funct' signal for the function unit to perform operations
  always @(*) begin
    case (op)
      `OP_SPECIAL: funct_out <= funct_in;
      `OP_SPECIAL2: begin
        case (funct_in)
          `FUNCT_MADD: funct_out <= `FUNCT2_MADD;
          `FUNCT_MADDU: funct_out <= `FUNCT2_MADDU;
          `FUNCT_MUL: funct_out <= `FUNCT2_MUL;
          `FUNCT_MSUB: funct_out <= `FUNCT2_MSUB;
          `FUNCT_MSUBU: funct_out <= `FUNCT2_MSUBU;
          `FUNCT_CLZ: funct_out <= `FUNCT2_CLZ;
          `FUNCT_CLO: funct_out <= `FUNCT2_CLO;
          default: funct_out <= `FUNCT_NOP;
        endcase
      end
      `OP_ORI: funct_out <= `FUNCT_OR;
      `OP_ANDI: funct_out <= `FUNCT_AND;
      `OP_XORI: funct_out <= `FUNCT_XOR;
      `OP_LUI: funct_out <= `FUNCT_OR;
      `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW,
      `OP_SB, `OP_SH, `OP_SW, `OP_ADDI: funct_out <= `FUNCT_ADD;
      `OP_ADDIU: funct_out <= `FUNCT_ADDU;
      `OP_SLTI: funct_out <= `FUNCT_SLT;
      `OP_SLTIU: funct_out <= `FUNCT_SLTU;
      `OP_JAL: funct_out <= `FUNCT_OR;
      `OP_REGIMM: begin
        case (rt)
          `REGIMM_BLTZAL, `REGIMM_BGEZAL: funct_out <= `FUNCT_OR;
          default: funct_out <= `FUNCT_NOP;
        endcase
      end
      default: funct_out <= `FUNCT_NOP;
    endcase
  end

endmodule // FunctGen
