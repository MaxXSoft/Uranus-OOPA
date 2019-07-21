`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "regimm.v"
`include "cp0.v"

module RegGen(
  input                     rst,
  // instruction info
  input   [`INST_OP_BUS]    op,
  input   [`REG_ADDR_BUS]   rs,
  input   [`REG_ADDR_BUS]   rt,
  input   [`REG_ADDR_BUS]   rd,
  input   [`HALF_DATA_BUS]  imm,
  input                     is_cp0,
  // regfile read & write
  input                     reg_read_is_ref_1,
  input                     reg_read_is_ref_2,
  input   [`DATA_BUS]       reg_read_data_1,
  input   [`DATA_BUS]       reg_read_data_2,
  output                    reg_read_en_1,
  output                    reg_read_en_2,
  output  [`REG_ADDR_BUS]   reg_read_addr_1,
  output  [`REG_ADDR_BUS]   reg_read_addr_2,
  output                    reg_write_en,
  output  [`REG_ADDR_BUS]   reg_write_addr,
  // operands output
  output                    operand_is_ref_1,
  output                    operand_is_ref_2,
  output  [`DATA_BUS]       operand_data_1,
  output  [`DATA_BUS]       operand_data_2
);

  reg reg_read_en_1, reg_read_en_2, reg_write_en;
  reg[`REG_ADDR_BUS] reg_read_addr_1, reg_read_addr_2, reg_write_addr;

  reg operand_is_ref_1, operand_is_ref_2;
  reg[`DATA_BUS] operand_data_1, operand_data_2;

  // information about immediate number
  wire[`DATA_BUS] zero_extended_imm = {16'b0, imm};
  wire[`DATA_BUS] zero_extended_imm_hi = {imm, 16'b0};
  wire[`DATA_BUS] sign_extended_imm = {{16{imm[15]}}, imm};

  // generate address of registers to be read
  always @(*) begin
    if (!rst) begin
      reg_read_en_1 <= 0;
      reg_read_en_2 <= 0;
      reg_read_addr_1 <= 0;
      reg_read_addr_2 <= 0;
    end
    else begin
      case (op)
        // arithmetic & logic (immediate)
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
        `OP_ANDI, `OP_ORI, `OP_XORI,
        // memory accessing
        `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU: begin
          reg_read_en_1 <= 1;
          reg_read_en_2 <= 0;
          reg_read_addr_1 <= rs;
          reg_read_addr_2 <= 0;
        end
        // branch
        `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
        // memory accessing
        `OP_SB, `OP_SH, `OP_SW,
        // r-type
        `OP_SPECIAL, `OP_SPECIAL2: begin
          reg_read_en_1 <= 1;
          reg_read_en_2 <= 1;
          reg_read_addr_1 <= rs;
          reg_read_addr_2 <= rt;
        end
        // reg-imm
        `OP_REGIMM: begin
          case (rt)
            `REGIMM_BLTZ, `REGIMM_BLTZAL,
            `REGIMM_BGEZ, `REGIMM_BGEZAL: begin
              reg_read_en_1 <= 1;
              reg_read_en_2 <= 0;
              reg_read_addr_1 <= rs;
              reg_read_addr_2 <= 0;
            end
            default: begin
              reg_read_en_1 <= 0;
              reg_read_en_2 <= 0;
              reg_read_addr_1 <= 0;
              reg_read_addr_2 <= 0;
            end
          endcase
        end
        // coprocessor
        `OP_CP0: begin
          reg_read_en_1 <= 1;
          reg_read_en_2 <= 0;
          reg_read_addr_1 <= rt;
          reg_read_addr_2 <= 0;
        end
        default: begin    // OP_J, OP_JAL, OP_LUI
          reg_read_en_1 <= 0;
          reg_read_en_2 <= 0;
          reg_read_addr_1 <= 0;
          reg_read_addr_2 <= 0;
        end
      endcase
    end
  end

  // generate operand_1
  always @(*) begin
    if (!rst) begin
      operand_is_ref_1 <= 0;
      operand_data_1 <= 0;
    end
    else begin
      case (op)
        // immediate
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
        `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI,
        // memory accessing
        `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU, `OP_SB, `OP_SH, `OP_SW,
        `OP_SPECIAL, `OP_SPECIAL2, `OP_REGIMM, `OP_CP0: begin
          operand_is_ref_1 <= reg_read_is_ref_1;
          operand_data_1 <= reg_read_data_1;
        end
        default: begin
          operand_is_ref_1 <= 0;
          operand_data_1 <= 0;
        end
    endcase
    end
  end

  // generate operand_2
  always @(*) begin
    if (!rst) begin
      operand_is_ref_2 <= 0;
      operand_data_2 <= 0;
    end
    else begin
      case (op)
        `OP_ORI, `OP_ANDI, `OP_XORI: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= zero_extended_imm;
        end 
        `OP_LUI: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= zero_extended_imm_hi;
        end
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= sign_extended_imm;
        end
        // memory accessing (store)
        `OP_SB, `OP_SH, `OP_SW,
        // r-type
        `OP_SPECIAL, `OP_SPECIAL2: begin
          operand_is_ref_2 <= reg_read_is_ref_2;
          operand_data_2 <= reg_read_data_2;
        end
        default: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= 0;
        end
      endcase
    end
  end

  // generate write address of registers
  always @(*) begin
    if (!rst) begin
      reg_write_en <= 0;
      reg_write_addr <= 0;
    end
    else begin
      case (op)
        // immediate
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
        `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI: begin
          reg_write_en <= 1;
          reg_write_addr <= rt;
        end
        `OP_SPECIAL, `OP_SPECIAL2: begin
          reg_write_en <= 1;
          reg_write_addr <= rd;
        end
        `OP_JAL: begin
          reg_write_en <= 1;
          reg_write_addr <= 31;       // $ra (return address)
        end
        `OP_REGIMM: begin
          case (rt)
            `REGIMM_BGEZAL, `REGIMM_BLTZAL: begin
              reg_write_en <= 1;
              reg_write_addr <= 31;   // $ra
            end
            default: begin
              reg_write_en <= 0;
              reg_write_addr <= 0;
            end
          endcase
        end
        `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW: begin
          reg_write_en <= 1;
          reg_write_addr <= rt;
        end
        `OP_CP0: begin
          if (rs == `CP0_MFC0 && is_cp0) begin
            reg_write_en <= 1;
            reg_write_addr <= rt;
          end
          else begin
            reg_write_en <= 0;
            reg_write_addr <= 0;
          end
        end
        default: begin
          reg_write_en <= 0;
          reg_write_addr <= 0;
        end
      endcase
    end
  end

endmodule // RegGen
