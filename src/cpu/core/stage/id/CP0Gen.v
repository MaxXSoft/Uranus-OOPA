`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "cp0.v"

module CP0Gen(
  input                   rst,
  // instruction info
  input   [`INST_OP_BUS]  op,
  input   [`REG_ADDR_BUS] rs,
  input   [`REG_ADDR_BUS] rd,
  input   [`CP0_SEL_BUS]  sel,
  input                   is_cp0,
  // CP0 info
  output                  cp0_read_flag,
  output                  cp0_write_flag,
  output  [`CP0_ADDR_BUS] cp0_addr
);

  reg cp0_read_flag, cp0_write_flag;
  reg[`CP0_ADDR_BUS] cp0_addr;

  // generate coprocessor 0 register address
  always @(*) begin
    if (!rst) begin
      cp0_read_flag <= 0;
      cp0_write_flag <= 0;
      cp0_addr <= 0;
    end
    else begin
      case (op)
        `OP_CP0: begin
          if (rs == `CP0_MTC0 && is_cp0) begin
            cp0_read_flag <= 0;
            cp0_write_flag <= 1;
            cp0_addr <= {rd, sel};
          end
          else if (rs == `CP0_MFC0 && is_cp0) begin
            cp0_read_flag <= 1;
            cp0_write_flag <= 0;
            cp0_addr <= {rd, sel};
          end
          else begin
            cp0_read_flag <= 0;
            cp0_write_flag <= 0;
            cp0_addr <= 0;
          end
        end
        default: begin
          cp0_read_flag <= 0;
          cp0_write_flag <= 0;
          cp0_addr <= 0;
        end
      endcase
    end
  end

endmodule // CP0Gen
