`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "opgen.v"

module RSLineInt(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  input  [`ROB_ADDR_BUS]  rob_addr_in,
  input  [`OPGEN_BUS]     opgen_in,
  input  [`SHAMT_BUS]     shamt_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input  [`DATA_BUS]      operand_data_1_in,
  input  [`DATA_BUS]      operand_data_2_in,
  // CDB channel
  input                   bus_en,
  input  [`DATA_BUS]      bus_ref_id_in,
  input  [`DATA_BUS]      bus_data_in,
  // read channel
  output                  ready,
  output  [`ROB_ADDR_BUS] rob_addr_out,
  output  [`OPGEN_BUS]    opgen_out,
  output  [`SHAMT_BUS]    shamt_out,
  output  [`DATA_BUS]     operand_data_1_out,
  output  [`DATA_BUS]     operand_data_2_out
);

  // storage
  reg[`ROB_ADDR_BUS]  rob_addr;
  reg[`OPGEN_BUS]     opgen;
  reg[`SHAMT_BUS]     shamt;
  reg                 operand_is_ref_1;
  reg                 operand_is_ref_2;
  reg[`DATA_BUS]      operand_data_1;
  reg[`DATA_BUS]      operand_data_2;

  // read channel
  assign ready = !operand_is_ref_1 && !operand_is_ref_2;
  assign rob_addr_out = rob_addr;
  assign opgen_out = opgen;
  assign shamt_out = shamt;
  assign operand_data_1_out = operand_data_1;
  assign operand_data_2_out = operand_data_2;

  // write & CDB channel
  always @(posedge clk) begin
    if (!rst) begin
      rob_addr <= 0;
      opgen <= 0;
      shamt <= 0;
      operand_is_ref_1 <= 0;
      operand_is_ref_2 <= 0;
      operand_data_1 <= 0;
      operand_data_2 <= 0;
    end
    else if (bus_en) begin
      // update data by broadcasted info
      if (operand_is_ref_1 && bus_ref_id_in == operand_data_1) begin
        operand_is_ref_1 <= 0;
        operand_data_1 <= bus_data_in;
      end
      if (operand_is_ref_2 && bus_ref_id_in == operand_data_2) begin
        operand_is_ref_2 <= 0;
        operand_data_2 <= bus_data_in;
      end
    end
    else if (write_en) begin
      rob_addr <= rob_addr_in;
      opgen <= opgen_in;
      shamt <= shamt_in;
      operand_is_ref_1 <= operand_is_ref_1_in;
      operand_is_ref_2 <= operand_is_ref_2_in;
      operand_data_1 <= operand_data_1_in;
      operand_data_2 <= operand_data_2_in;
    end
  end

endmodule // RSLineInt
