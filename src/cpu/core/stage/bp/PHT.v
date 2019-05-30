`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"

module PHT(
  input               clk,
  input               rst,
  // branch info (from ID)
  input               is_last_branch,
  input               is_last_taken,
  input   [`GHR_BUS]  last_index,
  // index for looking up counter table
  input   [`GHR_BUS]  index,
  // prediction result
  output              is_taken_out
);

  reg [1:0] counters[`PHT_SIZE - 1:0];
  assign is_taken_out = |(counters[index] & 2'b10);

  always @(posedge clk) begin
    if (!rst) begin
      // reset all of the counters
      integer i;
      for (i = 0; i < `PHT_SIZE; i = i + 1) begin
        counters[i] <= 2'b00;
      end
    end
    else if (is_last_branch) begin
      // if not saturated
      if (!&counters[last_index] && |counters[last_index]) begin
        if (is_last_taken) begin
          counters[last_index] <= counters[last_index] + 1;
        end
        else begin
          counters[last_index] <= counters[last_index] - 1;
        end
      end
    end
  end

endmodule // PHT
