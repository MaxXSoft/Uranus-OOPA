`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "opgen.v"
`include "util.v"

// Reservation Station for Integer Unit
module RSInt(
  input                       clk,
  input                       rst,
  // write channel (write to RS)
  input                       write_en,
  output                      can_write,
  input   [`ROB_ADDR_BUS]     rob_addr_in,
  input   [`EXC_TYPE_BUS]     exc_type_in,
  input   [`OPGEN_BUS]        opgen_in,
  input                       operand_is_ref_1_in,
  input                       operand_is_ref_2_in,
  input   [`DATA_BUS]         operand_data_1_in,
  input   [`DATA_BUS]         operand_data_2_in,
  // commit channel (commit to RS)
  input                       rs_commit_en,
  input   [`RS_INT_ADDR_BUS]  rs_commit_addr,
  input   [`EXC_TYPE_BUS]     rs_commit_exc_type,
  input   [`DATA_BUS]         rs_commit_data,
  // CDB channel
  input                       bus_en,
  input   [`DATA_BUS]         bus_ref_id_in,
  input   [`DATA_BUS]         bus_data_in,
  input                       bus_lo_en,
  input   [`DATA_BUS]         bus_lo_ref_id_in,
  input   [`DATA_BUS]         bus_lo_data_in,
  // commit channel (commit to ROB)
  output                      can_commit,
  input                       rob_commit_en,
  output  [`ROB_ADDR_BUS]     rob_commit_addr,
  output  [`EXC_TYPE_BUS]     rob_commit_exc_type,
  output  [`DATA_BUS]         rob_commit_data,
  // issue channel (issue to INT)
  output                      can_issue,
  output  [`RS_INT_ADDR_BUS]  rs_addr_out,
  output  [`EXC_TYPE_BUS]     exc_type_out,
  output  [`OPGEN_BUS]        opgen_out,
  output  [`DATA_BUS]         operand_data_1_out,
  output  [`DATA_BUS]         operand_data_2_out
);

  // control signals of RS line
  wire                line_write_en[`RS_INT_SIZE - 1:0];
  wire                line_invalidate_en[`RS_INT_SIZE - 1:0];
  wire                line_commit_en[`RS_INT_SIZE - 1:0];
  wire                line_issue_en[`RS_INT_SIZE - 1:0];
  wire[`RS_STATE_BUS] rsl_state[`RS_INT_SIZE - 1:0];
  wire[`ROB_ADDR_BUS] rsl_rob_addr[`RS_INT_SIZE - 1:0];
  wire[`EXC_TYPE_BUS] rsl_exc_type[`RS_INT_SIZE - 1:0];
  wire[`OPGEN_BUS]    rsl_opgen[`RS_INT_SIZE - 1:0];
  wire[`DATA_BUS]     rsl_operand_data_1[`RS_INT_SIZE - 1:0];
  wire[`DATA_BUS]     rsl_operand_data_2[`RS_INT_SIZE - 1:0];
  wire[`DATA_BUS]     rsl_commit_data[`RS_INT_SIZE - 1:0];

  // generate RS lines
  genvar i;
  generate
    for (i = 0; i < `RS_INT_SIZE; i = i + 1) begin
      RSLineInt rs_line_int(
        .clk                  (clk),
        .rst                  (rst),

        .write_en             (line_write_en[i]),
        .rob_addr_in          (rob_addr_in),
        .exc_type_in          (exc_type_in),
        .opgen_in             (opgen_in),
        .operand_is_ref_1_in  (operand_is_ref_1_in),
        .operand_is_ref_2_in  (operand_is_ref_2_in),
        .operand_data_1_in    (operand_data_1_in),
        .operand_data_2_in    (operand_data_2_in),

        .invalidate_en        (line_invalidate_en[i]),
        .commit_en            (line_commit_en[i]),
        .commit_exc_type_in   (rs_commit_exc_type),
        .commit_data_in       (rs_commit_data),

        .bus_en               (bus_en),
        .bus_ref_id_in        (bus_ref_id_in),
        .bus_data_in          (bus_data_in),
        .bus_lo_en            (bus_lo_en),
        .bus_lo_ref_id_in     (bus_lo_ref_id_in),
        .bus_lo_data_in       (bus_lo_data_in),

        .issue_en             (line_issue_en[i]),
        .rs_state             (rsl_state[i]),
        .rob_addr_out         (rsl_rob_addr[i]),
        .exc_type_out         (rsl_exc_type[i]),
        .opgen_out            (rsl_opgen[i]),
        .operand_data_1_out   (rsl_operand_data_1[i]),
        .operand_data_2_out   (rsl_operand_data_2[i]),
        .commit_data_out      (rsl_commit_data[i])
      );
    end
  endgenerate

  // write control
  wire[`RS_INT_SIZE - 1:0] write_indicator, rsl_write_en;
  assign rsl_write_en = write_indicator & (-write_indicator);
  assign can_write = |write_indicator;

  generate
    for (i = 0; i < `RS_INT_SIZE; i = i + 1) begin
      assign write_indicator[i] = rsl_state[i] == `RS_STATE_NONE;
      assign line_write_en[i] = write_en ? rsl_write_en[i] : 0;
    end
  endgenerate

  // commit control (RS)
  generate
    for (i = 0; i < `RS_INT_SIZE; i = i + 1) begin
      assign line_commit_en[i] = rs_commit_en ? rs_commit_addr == i : 0;
    end
  endgenerate

  // commit control (ROB)
  wire[`RS_INT_SIZE - 1:0] commit_indicator, rsl_commit_en;
  assign rsl_commit_en = commit_indicator & (-commit_indicator);
  assign can_commit = |commit_indicator;

  `GEN_OUT_16(rob_commit_addr, rsl_commit_en, rsl_rob_addr);
  `GEN_OUT_16(rob_commit_exc_type, rsl_commit_en, rsl_exc_type);
  `GEN_OUT_16(rob_commit_data, rsl_commit_en, rsl_commit_data);

  generate
    for (i = 0; i < `RS_INT_SIZE; i = i + 1) begin
      assign commit_indicator[i] = rsl_state[i] == `RS_STATE_COMMIT;
      assign line_invalidate_en[i] = rob_commit_en && rsl_commit_en[i];
    end
  endgenerate

  // issue control
  wire[`RS_INT_SIZE - 1:0] issue_indicator, rsl_issue_en;
  wire[`RS_INT_ADDR_BUS] rsl_line_addr[`RS_INT_SIZE - 1:0];
  assign rsl_issue_en = issue_indicator & (-issue_indicator);
  assign can_issue = |issue_indicator;

  `GEN_OUT_16(rs_addr_out, rsl_issue_en, rsl_line_addr);
  `GEN_OUT_16(exc_type_out, rsl_issue_en, rsl_exc_type);
  `GEN_OUT_16(opgen_out, rsl_issue_en, rsl_opgen);
  `GEN_OUT_16(operand_data_1_out, rsl_issue_en, rsl_operand_data_1);
  `GEN_OUT_16(operand_data_2_out, rsl_issue_en, rsl_operand_data_2);

  generate
    for (i = 0; i < `RS_INT_SIZE; i = i + 1) begin
      assign issue_indicator[i] = rsl_state[i] == `RS_STATE_READY;
      assign rsl_line_addr[i] = i;
      assign line_issue_en[i] = rsl_issue_en[i];
    end
  endgenerate

endmodule // RSInt
