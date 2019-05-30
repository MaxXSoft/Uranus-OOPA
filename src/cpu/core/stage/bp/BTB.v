`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module BTB(
  input clk,
  input rst,
  // from ID
  input               is_branch_in,
  input               is_jump_in,
  input   [`ADDR_BUS] inst_pc,
  input   [`ADDR_BUS] target_in,
  // other ports
  input   [`ADDR_BUS] pc_in,
  output              is_branch_out,
  output              is_jump_out,
  output  [`ADDR_BUS] target_out
);

  // control signals of BTB lines
  wire line_write_en[`BTB_SIZE - 1:0];
  wire btb_valid_out[`BTB_SIZE - 1:0];
  wire btb_is_jump_out[`BTB_SIZE - 1:0];
  wire [`BTB_PC_BUS] btb_pc_out[`BTB_SIZE - 1:0];
  wire [`ADDR_BUS] btb_target_out[`BTB_SIZE - 1:0];

  // generate BTB lines
  genvar i;
  generate
    for (i = 0; i < `BTB_SIZE; i = i + 1) begin
      BTBLine line(
        .clk          (clk),
        .rst          (rst),
        .write_en     (line_write_en[i]),
        .valid_in     (1'b1),
        .is_jump_in   (is_jump_in),
        .pc_in        (inst_pc[`BTB_PC_SEL]),
        .target_in    (target_in),
        .valid_out    (btb_valid_out[i]),
        .is_jump_out  (btb_is_jump_out[i]),
        .pc_out       (btb_pc_out[i]),
        .target_out   (btb_target_out[i])
      );
    end
  endgenerate

  // BTB line selector
  wire [`BTB_INDEX_WIDTH - 1:0] line_index;
  wire is_btb_hit;  
  assign line_index = pc_in[`BTB_INDEX_SEL];
  assign is_btb_hit = btb_valid_out[line_index]
      && btb_pc_out[line_index] == pc_in[`BTB_PC_SEL];

  wire btb_write_en;
  assign btb_write_en = is_branch_in;
  generate
    for (i = 0; i < `BTB_SIZE; i = i + 1) begin
      assign line_write_en[i] = btb_write_en ? line_index == i : 0;
    end
  endgenerate

  // output signals of module
  assign is_branch_out = is_btb_hit;
  assign is_jump_out = is_btb_hit ? btb_is_jump_out : 0;
  assign target_out = is_btb_hit ? btb_target_out : 0;

endmodule // BTB
