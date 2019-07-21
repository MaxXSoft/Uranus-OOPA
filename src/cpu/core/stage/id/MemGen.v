`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"

module MemGen(
  input                     rst,
  // instruction info
  input   [`INST_OP_BUS]    op,
  input   [`HALF_DATA_BUS]  imm,
  // memory accessing info
  output                    mem_write_flag,
  output                    mem_read_flag,
  output                    mem_sign_ext_flag,
  output  [3:0]             mem_sel,
  output  [`DATA_BUS]       mem_offset
);

  reg mem_write_flag, mem_read_flag, mem_sign_ext_flag;
  reg[3:0] mem_sel;

  // generate offset
  assign mem_offset = {{16{imm[15]}}, imm};

  // generate control signal of memory accessing
  always @(*) begin
    if (!rst) begin
      mem_write_flag <= 0;
    end
    else begin
      case (op)
        `OP_SB, `OP_SH, `OP_SW: mem_write_flag <= 1;
        default: mem_write_flag <= 0;
      endcase
    end
  end

  always @(*) begin
    if (!rst) begin
      mem_read_flag <= 0;
    end
    else begin
      case (op)
        `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW: mem_read_flag <= 1;
        default: mem_read_flag <= 0;
      endcase
    end
  end

  always @(*) begin
    if (!rst) begin
      mem_sign_ext_flag <= 0;
    end
    else begin
      case (op)
        `OP_LB, `OP_LH, `OP_LW: mem_sign_ext_flag <= 1;
        default: mem_sign_ext_flag <= 0;
      endcase
    end
  end

  // mem_sel: lb & sb -> 1, lh & sh -> 11, lw & sw -> 1111
  always @(*) begin
    if (!rst) begin
      mem_sel <= 4'b0000;
    end
    else begin
      case (op)
        `OP_LB, `OP_LBU, `OP_SB: mem_sel <= 4'b0001;
        `OP_LH, `OP_LHU, `OP_SH: mem_sel <= 4'b0011;
        `OP_LW, `OP_SW: mem_sel <= 4'b1111;
        default: mem_sel <= 4'b0000;
      endcase
    end
  end

endmodule // MemGen
