`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "opgen.v"

module RSLineInt(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  input   [`ROB_ADDR_BUS] rob_addr_in,
  input   [`OPGEN_BUS]    opgen_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input   [`DATA_BUS]     operand_data_1_in,
  input   [`DATA_BUS]     operand_data_2_in,
  // commit channel
  input                   invalidate_en,
  input                   commit_en,
  input   [`DATA_BUS]     commit_data_in,
  // CDB channel
  input                   bus_en,
  input   [`DATA_BUS]     bus_ref_id_in,
  input   [`DATA_BUS]     bus_data_in,
  input                   bus_lo_en,
  input   [`DATA_BUS]     bus_lo_ref_id_in,
  input   [`DATA_BUS]     bus_lo_data_in,
  // issue channel
  input                   issue_en,
  output  [`RS_STATE_BUS] rs_state,
  output  [`ROB_ADDR_BUS] rob_addr_out,
  output  [`OPGEN_BUS]    opgen_out,
  output  [`DATA_BUS]     operand_data_1_out,
  output  [`DATA_BUS]     operand_data_2_out,
  output  [`DATA_BUS]     commit_data_out
);

  // state indicator
  reg[`RS_STATE_BUS]  rs_state;

  // storage
  reg[`ROB_ADDR_BUS]  rob_addr;
  reg[`OPGEN_BUS]     opgen;
  reg                 operand_is_ref_1;
  reg                 operand_is_ref_2;
  reg[`DATA_BUS]      operand_data_1;
  reg[`DATA_BUS]      operand_data_2;
  reg[`DATA_BUS]      commit_data;

  // read channel
  assign rob_addr_out = rob_addr;
  assign opgen_out = opgen;
  assign operand_data_1_out = operand_data_1;
  assign operand_data_2_out = operand_data_2;
  assign commit_data_out = commit_data;

  // update state
  always @(posedge clk) begin
    if (!rst || !invalidate_en) begin
      rs_state <= `RS_STATE_NONE;
    end
    else if (write_en) begin
      rs_state <= `RS_STATE_WRITE;
    end
    else if (!operand_is_ref_1 && !operand_is_ref_2) begin
      rs_state <= `RS_STATE_READY;
    end
    else if (issue_en) begin
      rs_state <= `RS_STATE_WAIT;
    end
    else if (commit_en) begin
      rs_state <= `RS_STATE_COMMIT;
    end
  end

  // update data
  always @(posedge clk) begin
    if (!rst) begin
      rob_addr <= 0;
      opgen <= 0;
      operand_is_ref_1 <= 0;
      operand_is_ref_2 <= 0;
      operand_data_1 <= 0;
      operand_data_2 <= 0;
      commit_data <= 0;
    end
    else if (write_en) begin
      rob_addr <= rob_addr_in;
      opgen <= opgen_in;
      operand_is_ref_1 <= operand_is_ref_1_in;
      operand_is_ref_2 <= operand_is_ref_2_in;
      operand_data_1 <= operand_data_1_in;
      operand_data_2 <= operand_data_2_in;
      commit_data <= 0;
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
      // lo channel
      if (bus_lo_en) begin
        if (operand_is_ref_1 && bus_lo_ref_id_in == operand_data_1) begin
          operand_is_ref_1 <= 0;
          operand_data_1 <= bus_lo_data_in;
        end
        if (operand_is_ref_2 && bus_lo_ref_id_in == operand_data_2) begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= bus_lo_data_in;
        end
      end
    end
    else if (commit_en) begin
      commit_data <= commit_data_in;
    end
  end

endmodule // RSLineInt
