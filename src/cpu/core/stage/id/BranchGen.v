`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "regimm.v"

/*
 * NOTE:
 *  for jump instructions:
 *    use jump address (offset) as target
 *  for branch instructions:
 *    use branch offset as target
 */

module BranchGen(
  input rst,
  // instruction info
  input   [`INST_OP_BUS]    op,
  input   [`REG_ADDR_BUS]   rt,
  input   [`FUNCT_BUS]      funct,
  input   [`HALF_DATA_BUS]  imm,
  input   [`JUMP_ADDR_BUS]  jump_addr,
  // branch info
  output                    is_branch,
  output  [`ADDR_BUS]       target
);

  reg is_branch;
  reg[`ADDR_BUS] target;

  // generate branch address
  wire[`DATA_BUS] branch_offset = {{14{imm[15]}}, imm[15:0], 2'b00};

  always @(*) begin
    if (!rst) begin
      is_branch <= 0;
      target <= 0;
    end
    else begin
      case (op)
        `OP_SPECIAL: begin
          case (funct)
            `FUNCT_JR, `FUNCT_JALR: begin
              // NOTE: ignoring JR and JALR
              //       because it's target info is in operand1
              is_branch <= 1;
              target <= 0;
            end
            default: begin
              is_branch <= 0;
              target <= 0;
            end
          endcase
        end
        `OP_J, `OP_JAL: begin
          is_branch <= 1;
          target <= {4'b0000, jump_addr, 2'b00};
        end
        `OP_BEQ, `OP_BNE, `OP_BGTZ, `OP_BLEZ: begin
          is_branch <= 1;
          target <= branch_offset;
        end
        `OP_REGIMM: begin
          case (rt)
            `REGIMM_BLTZ, `REGIMM_BLTZAL,
            `REGIMM_BGEZ, `REGIMM_BGEZAL: begin
              is_branch <= 1;
              target <= branch_offset;
            end
            default: begin
              is_branch <= 0;
              target <= 0;
            end
          endcase
        end
        default: begin
          is_branch <= 0;
          target <= 0;
        end
      endcase
    end
  end

endmodule // BranchGen
