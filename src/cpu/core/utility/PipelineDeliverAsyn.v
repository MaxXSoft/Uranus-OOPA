`timescale 1ns / 1ps

module PipelineDeliverAsyn #(parameter WIDTH = 1) (
  input                 clk,
  input                 rst,
  input                 flush_in,
  input                 stall_current_stage_in,
  input                 stall_next_stage_in,
  input   [WIDTH - 1:0] in,
  output  [WIDTH - 1:0] out
);

  reg flush_delay, stall_current, stall_next;
  wire flush, stall_current_stage, stall_next_stage;

  // NOTE: glitch?
  assign flush = flush_in | flush_delay;
  assign stall_current_stage = stall_current_stage_in | stall_current;
  assign stall_next_stage = stall_next_stage_in | stall_next;

  // delay one more tick for stall signals
  always @(posedge clk) begin
    flush_delay <= flush_in;
    stall_current <= stall_current_stage_in;
    stall_next <= stall_next_stage_in;
  end

  reg[WIDTH - 1:0] last_status;
  assign out = last_status;

  always @(*) begin
    if (!rst) begin
      last_status <= 0;
    end
    else if (flush) begin
      last_status <= 0;
    end
    else if (stall_current_stage && !stall_next_stage) begin
      last_status <= 0;
    end
    else if (!stall_current_stage) begin
      last_status <= in;
    end
  end

endmodule // PipelineDeliverAsyn
