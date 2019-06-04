`timescale 1ns / 1ps

module PipelineDeliver #(parameter
  kWidth = 1,
  kRstVal = 0
) (
  input                   clk,
  input                   rst,
  input                   flush,
  input                   stall_current_stage,
  input                   stall_next_stage,
  input   [kWidth - 1:0]  in,
  output  [kWidth - 1:0]  out
);

  reg[kWidth - 1:0] out;

  always @(posedge clk) begin
    if (!rst) begin
      out <= kRstVal;
    end
    else if (flush) begin
      out <= kRstVal;
    end
    else if (stall_current_stage && !stall_next_stage) begin
      out <= kRstVal;
    end
    else if (!stall_current_stage) begin
      out <= in;
    end
  end

endmodule // PipelineDeliver
