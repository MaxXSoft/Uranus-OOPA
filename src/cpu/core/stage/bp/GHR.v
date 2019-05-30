`timescale 1ns / 1ps

`include "branch.v"

module GHR(
  input               clk,
  input               rst,
  // from ID
  input               is_branch,
  input               is_taken,
  // output of global history register
  output  [`GHR_BUS]  ghr_out
);

  reg [`GHR_BUS] ghr;
  assign ghr_out = ghr;

  always @(posedge clk) begin
    if (!rst) begin
      ghr <= 0;
    end
    else if (is_branch) begin
      ghr <= {ghr[`GHR_WIDTH - 2:0], is_taken};
    end
  end

endmodule // GHR
