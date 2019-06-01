`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module BTBLine(
  input                 clk,
  input                 rst,
  input                 write_en,
  // input signals
  input                 valid_in,
  input                 is_jump_in,
  input   [`BTB_PC_BUS] pc_in,
  input   [`ADDR_BUS]   target_in,
  // output signals
  output                valid_out,
  output                is_jump_out,
  output  [`BTB_PC_BUS] pc_out,
  output  [`ADDR_BUS]   target_out
);

  reg valid;
  reg is_jump;
  reg[`BTB_PC_BUS] pc;
  reg[`ADDR_BUS] target;
  assign valid_out  = valid;
  assign pc_out     = pc;
  assign target_out = target;
  assign is_jump_out = is_jump;

  always @(posedge clk) begin
    if (!rst) begin
      valid <= 0;
      is_jump <= 0;
      pc <= 0;
      target <= 0;
    end
    else if (write_en) begin
      valid <= valid_in;
      is_jump <= is_jump_in;
      pc <= pc_in;
      target <= target_in;
    end
  end

endmodule // BTBLine
