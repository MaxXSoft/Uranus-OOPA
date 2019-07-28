`timescale 1ns / 1ps

`include "bus.v"
`include "opgen.v"

module BitCounter(
  input   [`OPGEN_BUS]  opgen,
  input   [`DATA_BUS]   opr,
  output  [`DATA_BUS]   result
);

  reg[`DATA_BUS]  result;
  wire[`DATA_BUS] opr_not = ~opr;

  always @(*) begin
    case (opgen)
      `OPGEN_CLZ: result <=
          opr[31] ?  0 : opr[30] ?  1 : opr[29] ?  2 : opr[28] ?  3 :
          opr[27] ?  4 : opr[26] ?  5 : opr[25] ?  6 : opr[24] ?  7 :
          opr[23] ?  8 : opr[22] ?  9 : opr[21] ? 10 : opr[20] ? 11 :
          opr[19] ? 12 : opr[18] ? 13 : opr[17] ? 14 : opr[16] ? 15 :
          opr[15] ? 16 : opr[14] ? 17 : opr[13] ? 18 : opr[12] ? 19 :
          opr[11] ? 20 : opr[10] ? 21 : opr[ 9] ? 22 : opr[ 8] ? 23 :
          opr[ 7] ? 24 : opr[ 6] ? 25 : opr[ 5] ? 26 : opr[ 4] ? 27 :
          opr[ 3] ? 28 : opr[ 2] ? 29 : opr[ 1] ? 30 : opr[ 0] ? 31 : 32;
      `OPGEN_CLO: result <=
          opr_not[31] ?  0 : opr_not[30] ?  1 : opr_not[29] ?  2 :
          opr_not[28] ?  3 : opr_not[27] ?  4 : opr_not[26] ?  5 :
          opr_not[25] ?  6 : opr_not[24] ?  7 : opr_not[23] ?  8 :
          opr_not[22] ?  9 : opr_not[21] ? 10 : opr_not[20] ? 11 :
          opr_not[19] ? 12 : opr_not[18] ? 13 : opr_not[17] ? 14 :
          opr_not[16] ? 15 : opr_not[15] ? 16 : opr_not[14] ? 17 :
          opr_not[13] ? 18 : opr_not[12] ? 19 : opr_not[11] ? 20 :
          opr_not[10] ? 21 : opr_not[ 9] ? 22 : opr_not[ 8] ? 23 :
          opr_not[ 7] ? 24 : opr_not[ 6] ? 25 : opr_not[ 5] ? 26 :
          opr_not[ 4] ? 27 : opr_not[ 3] ? 28 : opr_not[ 2] ? 29 :
          opr_not[ 1] ? 30 : opr_not[ 0] ? 31 : 32;
      default: result <= 0;
    endcase
  end

endmodule // BitCounter
