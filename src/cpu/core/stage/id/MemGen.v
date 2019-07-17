`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"

module MemGen(
  input                   rst,
  // instruction info
  input   [`INST_OP_BUS]  op,
  // regfile reader
  input                   reg_read_is_rsid_2,
  input   [`DATA_BUS]     reg_read_data_2,
  // memory accessing info
  output                  mem_write_flag,
  output                  mem_read_flag,
  output                  mem_sign_ext_flag,
  output  [3:0]           mem_sel,
  output                  mem_write_is_rsid,
  output  [`DATA_BUS]     mem_write_data
);

  reg mem_write_flag, mem_read_flag, mem_sign_ext_flag, mem_write_is_rsid;
  reg[3:0] mem_sel;
  reg[`DATA_BUS] mem_write_data;

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

  // generate data to be written to memory
  always @(*) begin
    if (!rst) begin
      mem_write_is_rsid <= 0;
      mem_write_data <= 0;
    end
    else begin
      case (op)
        `OP_SB, `OP_SH, `OP_SW: begin
          mem_write_is_rsid <= reg_read_is_rsid_2;
          mem_write_data <= reg_read_data_2;
        end
        default: begin
          mem_write_is_rsid <= 0;
          mem_write_data <= 0;
        end
      endcase
    end
  end

endmodule // MemGen
