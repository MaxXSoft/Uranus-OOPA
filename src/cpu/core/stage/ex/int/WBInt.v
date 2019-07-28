`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "opgen.v"
`include "exception.v"

module WBInt(
  input                       clk,
  input                       rst,
  // from Int unit
  input                       en,
  input   [`RS_INT_ADDR_BUS]  rs_addr_in,
  input   [`EXC_TYPE_BUS]     exc_type_in,
  input   [`DATA_BUS]         result_in,
  // to RS Int
  output                      commit_en,
  output  [`RS_INT_ADDR_BUS]  commit_addr,
  output  [`EXC_TYPE_BUS]     commit_exc_type,
  output  [`DATA_BUS]         commit_data
);

  // generate exception type
  reg[`EXC_TYPE_BUS] exc_type;

  always @(*) begin
    if (!rst) begin
      exc_type <= `EXC_TYPE_NULL;
    end
    else if (exc_type_in[`EXC_TYPE_POS_RI]) begin
      exc_type <= `EXC_TYPE_RI;
    end
    else if (exc_type_in[`EXC_TYPE_POS_OV]) begin
      exc_type <= `EXC_TYPE_OV;
    end
    else if (exc_type_in[`EXC_TYPE_POS_BP]) begin
      exc_type <= `EXC_TYPE_BP;
    end
    else if (exc_type_in[`EXC_TYPE_POS_SYS]) begin
      exc_type <= `EXC_TYPE_SYS;
    end
    else if (exc_type_in[`EXC_TYPE_POS_ERET]) begin
      exc_type <= `EXC_TYPE_ERET;
    end
    else begin
      exc_type <= `EXC_TYPE_NULL;
    end
  end

  // generate output signals
  reg                   commit_en;
  reg[`RS_INT_ADDR_BUS] commit_addr;
  reg[`EXC_TYPE_BUS]    commit_exc_type;
  reg[`DATA_BUS]        commit_data;

  always @(posedge clk) begin
    if (!rst) begin
      commit_en <= 0;
      commit_addr <= 0;
      commit_exc_type <= 0;
      commit_data <= 0;
    end
    else begin
      commit_en <= en;
      commit_addr <= rs_addr_in;
      commit_exc_type <= exc_type;
      commit_data <= result_in;
    end
  end

endmodule // WBInt
