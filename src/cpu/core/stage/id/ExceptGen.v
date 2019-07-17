`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "regimm.v"
`include "cp0.v"

module ExceptGen(
  input                   rst,
  // instruction info
  input   [`INST_OP_BUS]  op,
  input   [`REG_ADDR_BUS] rs,
  input   [`REG_ADDR_BUS] rt,
  input   [`FUNCT_BUS]    funct,
  input                   is_eret,
  // exception info
  output  [`EXC_TYPE_BUS] exception_type
);

  // generate exception signals
  reg invalid_inst_flag, overflow_inst_flag;
  reg syscall_flag, break_flag, eret_flag;

  assign exception_type = rst ? {
    eret_flag, /* ADE */ 1'b0,
    syscall_flag, break_flag, /* TP */ 1'b0,
    overflow_inst_flag, invalid_inst_flag, /* IF */ 1'b0
  } : 0;

  always @(*) begin
    if (!rst) begin
      invalid_inst_flag <= 0;
      overflow_inst_flag <= 0;
      syscall_flag <= 0;
      break_flag <= 0;
      eret_flag <= 0;
    end
    else begin
      if (is_eret) begin
        invalid_inst_flag <= 0;
        overflow_inst_flag <= 0;
        syscall_flag <= 0;
        break_flag <= 0;
        eret_flag <= 1;
      end
      else begin
        case (op)
          `OP_SPECIAL: begin
            case (funct)
              `FUNCT_SLL, `FUNCT_SRL, `FUNCT_SRA, `FUNCT_SLLV,
              `FUNCT_SRLV, `FUNCT_SRAV, `FUNCT_JR, `FUNCT_JALR,
              `FUNCT_MOVN, `FUNCT_MOVZ,
              `FUNCT_MFHI, `FUNCT_MTHI, `FUNCT_MFLO, `FUNCT_MTLO,
              `FUNCT_MULT, `FUNCT_MULTU, `FUNCT_DIV, `FUNCT_DIVU,
              `FUNCT_ADDU, `FUNCT_SUBU, `FUNCT_AND, `FUNCT_OR,
              `FUNCT_XOR, `FUNCT_NOR, `FUNCT_SLT, `FUNCT_SLTU: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
              `FUNCT_ADD, `FUNCT_SUB: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 1;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
              `FUNCT_SYSCALL: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 0;
                syscall_flag <= 1;
                break_flag <= 0;
                eret_flag <= 0;
              end
              `FUNCT_BREAK: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 1;
                eret_flag <= 0;
              end
              default: begin
                invalid_inst_flag <= 1;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
            endcase
          end
          `OP_SPECIAL2: begin
            case (funct)
              `FUNCT2_CLZ, `FUNCT2_CLO,
              `FUNCT2_MUL,
              `FUNCT2_MADD, `FUNCT2_MADDU,
              `FUNCT2_MSUB, `FUNCT2_MSUBU: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
              default: begin
                invalid_inst_flag <= 1;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
            endcase
          end
          `OP_REGIMM: begin
            case (rt)
              `REGIMM_BLTZ, `REGIMM_BLTZAL, `REGIMM_BGEZ,
              `REGIMM_BGEZAL: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
              default: begin
                invalid_inst_flag <= 1;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
            endcase
          end
          `OP_CP0: begin
            case (rs)
              `CP0_MFC0, `CP0_MTC0: begin
                invalid_inst_flag <= 0;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
              default: begin
                invalid_inst_flag <= 1;
                overflow_inst_flag <= 0;
                syscall_flag <= 0;
                break_flag <= 0;
                eret_flag <= 0;
              end
            endcase
          end
          `OP_J, `OP_JAL, `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
          `OP_ADDIU, `OP_SLTI, `OP_SLTIU, `OP_ANDI, `OP_ORI,
          `OP_XORI, `OP_LUI, `OP_LB, `OP_LH, `OP_LW, `OP_LBU,
          `OP_LHU, `OP_SB, `OP_SH, `OP_SW: begin
            invalid_inst_flag <= 0;
            overflow_inst_flag <= 0;
            syscall_flag <= 0;
            break_flag <= 0;
            eret_flag <= 0;
          end
          `OP_ADDI: begin
            invalid_inst_flag <= 0;
            overflow_inst_flag <= 1;
            syscall_flag <= 0;
            break_flag <= 0;
            eret_flag <= 0;
          end
          default: begin
            invalid_inst_flag <= 1;
            overflow_inst_flag <= 0;
            syscall_flag <= 0;
            break_flag <= 0;
            eret_flag <= 0;
          end
        endcase
      end
    end
  end

endmodule // ExceptGen
