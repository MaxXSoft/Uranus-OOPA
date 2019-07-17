`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "regimm.v"

/*
 * NOTE:
 *  for jump instructions:
 *    generate target address only if it's determined
 *  for branch instructions:
 *    generate target address ANYWAY
 */

module BranchGen(
  input rst,
  // instruction info
  input   [`ADDR_BUS]       pc,
  input   [`INST_OP_BUS]    op,
  input   [`REG_ADDR_BUS]   rt,
  input   [`HALF_DATA_BUS]  imm,
  input   [`FUNCT_BUS]      funct,
  input   [`JUMP_ADDR_BUS]  jump_addr,
  // regfile reader
  input                     reg_read_is_rsid_1,
  input                     reg_read_is_rsid_2,
  input   [`DATA_BUS]       reg_read_data_1,
  input   [`DATA_BUS]       reg_read_data_2,
  // branch info
  output                    is_branch,
  output                    is_jump,
  output                    is_taken,
  output                    is_determined,
  output                    is_target_rsid,
  output  [`ADDR_BUS]       target
);

  reg is_branch, is_jump, is_taken, is_determined, is_target_rsid;
  reg[`ADDR_BUS] target;

  // generate branch address
  wire[`ADDR_BUS] pc_plus_4 = pc + 4;
  wire[`DATA_BUS] branch_offset = {{14{imm[15]}}, imm[15:0], 2'b00};

  always @(*) begin
    if (!rst) begin
      is_branch <= 0;
      is_jump <= 0;
      is_taken <= 0;
      is_determined <= 0;
      is_target_rsid <= 0;
      target <= 0;
    end
    else begin
      case (op)
        `OP_J, `OP_JAL: begin
          is_branch <= 1;
          is_jump <= 1;
          is_taken <= 1;
          is_determined <= 1;
          is_target_rsid <= 0;
          target <= {pc_plus_4[31:28], jump_addr, 2'b00};
        end
        `OP_SPECIAL, `OP_SPECIAL2: begin
          if (funct == `FUNCT_JR || funct == `FUNCT_JALR) begin
            is_branch <= 1;
            is_jump <= 1;
            is_taken <= 1;
            is_determined <= !reg_read_is_rsid_1;
            is_target_rsid <= reg_read_is_rsid_1;
            target <= reg_read_data_1;
          end
          else begin
            is_branch <= 0;
            is_jump <= 0;
            is_taken <= 0;
            is_determined <= 0;
            is_target_rsid <= 0;
            target <= 0;
          end
        end
        `OP_BEQ: begin
          if (!reg_read_is_rsid_1 && !reg_read_is_rsid_2) begin
            is_taken <= reg_read_data_1 == reg_read_data_2;
            is_determined <= 1;
          end
          else begin
            is_taken <= 0;
            is_determined <= 0;
          end
          is_branch <= 1;
          is_jump <= 0;
          is_target_rsid <= 0;
          target <= pc_plus_4 + branch_offset;
        end
        `OP_BGTZ: begin
          if (!reg_read_is_rsid_1) begin
            is_taken <= !reg_read_data_1[31] && reg_read_data_1;
            is_determined <= 1;
          end
          else begin
            is_taken <= 0;
            is_determined <= 0;
          end
          is_branch <= 1;
          is_jump <= 0;
          is_target_rsid <= 0;
          target <= pc_plus_4 + branch_offset;
        end
        `OP_BLEZ: begin
          if (!reg_read_is_rsid_1) begin
            is_taken <= reg_read_data_1[31] || !reg_read_data_1;
            is_determined <= 1;
          end
          else begin
            is_taken <= 0;
            is_determined <= 0;
          end
          is_branch <= 1;
          is_jump <= 0;
          is_target_rsid <= 0;
          target <= pc_plus_4 + branch_offset;
        end
        `OP_BNE: begin
          if (!reg_read_is_rsid_1 && !reg_read_is_rsid_2) begin
            is_taken <= reg_read_data_1 != reg_read_data_2;
            is_determined <= 1;
          end
          else begin
            is_taken <= 0;
            is_determined <= 0;
          end
          is_branch <= 1;
          is_jump <= 0;
          is_target_rsid <= 0;
          target <= pc_plus_4 + branch_offset;
        end
        `OP_REGIMM: begin
          case (rt)
            `REGIMM_BLTZ, `REGIMM_BLTZAL: begin
              if (!reg_read_is_rsid_1) begin
                is_taken <= reg_read_data_1[31];
                is_determined <= 1;
              end
              else begin
                is_taken <= 0;
                is_determined <= 0;
              end
              is_branch <= 1;
              is_jump <= 0;
              is_target_rsid <= 0;
              target <= pc_plus_4 + branch_offset;
            end
            `REGIMM_BGEZ, `REGIMM_BGEZAL: begin
              if (!reg_read_is_rsid_1) begin
                is_taken <= !reg_read_data_1[31];
                is_determined <= 1;
              end
              else begin
                is_taken <= 0;
                is_determined <= 0;
              end
              is_branch <= 1;
              is_jump <= 0;
              is_target_rsid <= 0;
              target <= pc_plus_4 + branch_offset;
            end
            default: begin
              is_branch <= 0;
              is_jump <= 0;
              is_taken <= 0;
              is_determined <= 0;
              is_target_rsid <= 0;
              target <= 0;
            end
          endcase
        end
        default: begin
          is_branch <= 0;
          is_jump <= 0;
          is_taken <= 0;
          is_determined <= 0;
          is_target_rsid <= 0;
          target <= 0;
        end
      endcase
    end
  end

endmodule // BranchGen
