`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "opgen.v"
`include "funct.v"
`include "regimm.v"
`include "cp0.v"

module OpGen(
  input                   rst,
  input   [`INST_OP_BUS]  op,
  input   [`FUNCT_BUS]    funct_in,
  input   [`REG_ADDR_BUS] rs,
  input   [`REG_ADDR_BUS] rt,
  output  [`OPGEN_BUS]    opgen
);

  reg[`OPGEN_BUS] opgen_out;
  assign opgen = rst ? opgen_out : `OPGEN_NOP;

  // generate 'opgen' signal for the function unit to perform operations
  always @(*) begin
    case (op)
      // R-type 1
      `OP_SPECIAL: begin
        case (funct_in)
          `FUNCT_ADD, `FUNCT_ADDU: opgen_out <= `OPGEN_ADD;
          `FUNCT_SUB, `FUNCT_SUBU: opgen_out <= `OPGEN_SUB;
          `FUNCT_SLT: opgen_out <= `OPGEN_SLT;
          `FUNCT_SLTU: opgen_out <= `OPGEN_SLTU;
          `FUNCT_DIV: opgen_out <= `OPGEN_DIV;
          `FUNCT_DIVU: opgen_out <= `OPGEN_DIVU;
          `FUNCT_MULT: opgen_out <= `OPGEN_MULT;
          `FUNCT_MULTU: opgen_out <= `OPGEN_MULTU;
          `FUNCT_AND: opgen_out <= `OPGEN_AND;
          `FUNCT_NOR: opgen_out <= `OPGEN_NOR;
          `FUNCT_OR: opgen_out <= `OPGEN_OR;
          `FUNCT_XOR: opgen_out <= `OPGEN_XOR;
          `FUNCT_SLLV, `FUNCT_SLL: opgen_out <= `OPGEN_SLL;
          `FUNCT_SRAV, `FUNCT_SRA: opgen_out <= `OPGEN_SRA;
          `FUNCT_SRLV, `FUNCT_SRL: opgen_out <= `OPGEN_SRL;
          `FUNCT_JR, `FUNCT_JALR: opgen_out <= `OPGEN_JR;
          `FUNCT_MFHI, `FUNCT_MFLO,
          `FUNCT_MTHI, `FUNCT_MTLO: opgen_out <= `OPGEN_OR;
          `FUNCT_MOVZ: opgen_out <= `OPGEN_MOVZ;
          `FUNCT_MOVN: opgen_out <= `OPGEN_MOVN;
          // SYSCALL, BREAK and other instructions
          default: opgen_out <= `OPGEN_NOP;
        endcase
      end
      // R-type 2
      `OP_SPECIAL2: begin
        case (funct_in)
          `FUNCT_MADD: opgen_out <= `OPGEN_MADD;
          `FUNCT_MADDU: opgen_out <= `OPGEN_MADDU;
          `FUNCT_MSUB: opgen_out <= `OPGEN_MSUB;
          `FUNCT_MSUBU: opgen_out <= `OPGEN_MSUBU;
          `FUNCT_MUL: opgen_out <= `OPGEN_MUL;
          `FUNCT_CLZ: opgen_out <= `OPGEN_CLZ;
          `FUNCT_CLO: opgen_out <= `OPGEN_CLO;
          default: opgen_out <= `OPGEN_NOP;
        endcase
      end
      // I-type, regimm
      `OP_REGIMM: begin
        case (rt)
          `REGIMM_BLTZ, `REGIMM_BLTZAL: opgen_out <= `OPGEN_BLTZ;
          `REGIMM_BGEZ, `REGIMM_BGEZAL: opgen_out <= `OPGEN_BGEZ;
          default: opgen_out <= `OPGEN_NOP;
        endcase
      end
      // co-processor 0
      `OP_CP0: begin
        case (rs)
          `CP0_MFC0, `CP0_MTC0: opgen_out <= `OPGEN_OR;
          // ERET and other instructions
          default: opgen_out <= `OPGEN_NOP;
        endcase
      end
      // I-type, imm
      `OP_ADDI, `OP_ADDIU: opgen_out <= `OPGEN_ADD;
      `OP_SLTI: opgen_out <= `OPGEN_SLT;
      `OP_SLTIU: opgen_out <= `OPGEN_SLTU;
      `OP_ANDI: opgen_out <= `OPGEN_AND;
      `OP_LUI, `OP_ORI: opgen_out <= `OPGEN_OR;
      `OP_XORI: opgen_out <= `OPGEN_XOR;
      // branch
      `OP_BEQ: opgen_out <= `OPGEN_BEQ;
      `OP_BNE: opgen_out <= `OPGEN_BNE;
      `OP_BGTZ: opgen_out <= `OPGEN_BGTZ;
      `OP_BLEZ: opgen_out <= `OPGEN_BLEZ;
      // jump
      `OP_J, `OP_JAL: opgen_out <= `OPGEN_J;
      // memory accessing
      `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW,
      `OP_SB, `OP_SH, `OP_SW: opgen_out <= `OPGEN_MEM;
      default: opgen_out <= `OPGEN_NOP;
    endcase
  end

endmodule // OpGen
