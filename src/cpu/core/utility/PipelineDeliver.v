`timescale 1ns / 1ps

module PipelineDeliver #(parameter
  WIDTH = 1,
  RST_VAL = 0
) (
  input                 clk,
  input                 rst,
  input                 flush,
  input                 stall_current_stage,
  input                 stall_next_stage,
  input   [WIDTH - 1:0] in,
  output  [WIDTH - 1:0] out
);

  reg[WIDTH - 1:0] last_status;
  assign out = last_status;

  always @(posedge clk) begin
    if (!rst) begin
      last_status <= RST_VAL;
    end
    else if (flush) begin
      last_status <= RST_VAL;
    end
    else if (stall_current_stage && !stall_next_stage) begin
      last_status <= RST_VAL;
    end
    else if (!stall_current_stage) begin
      last_status <= in;
    end
  end

endmodule // PipelineDeliver
