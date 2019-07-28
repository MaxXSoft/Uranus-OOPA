`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "opgen.v"
`include "exception.v"

module IntUnit(
  input                       rst,
  // from RS Int
  input                       en,
  input   [`RS_INT_ADDR_BUS]  rs_addr_in,
  input   [`EXC_TYPE_BUS]     exc_type_in,
  input   [`OPGEN_BUS]        opgen_in,
  input   [`DATA_BUS]         operand_1_in,
  input   [`DATA_BUS]         operand_2_in,
  // to Int WB
  output                      wb_en_out,
  output  [`RS_INT_ADDR_BUS]  rs_addr_out,
  output  [`EXC_TYPE_BUS]     exc_type_out,
  output  [`DATA_BUS]         result_out
);


  // generate write enable
  reg wb_en;
  assign wb_en_out = en && wb_en;

  always @(*) begin
    case (opgen_in)
      `OPGEN_NOP: wb_en <= 0;
      `OPGEN_ADD, `OPGEN_SUB, `OPGEN_SLT, `OPGEN_SLTU, `OPGEN_AND,
      `OPGEN_NOR, `OPGEN_OR, `OPGEN_XOR, `OPGEN_SLL, `OPGEN_SRA, `OPGEN_SRL,
      `OPGEN_CLZ, `OPGEN_CLO: wb_en <= 1;
      `OPGEN_MOVZ: wb_en <= !(|operand_2_in);
      `OPGEN_MOVN: wb_en <= |operand_2_in;
      default: wb_en <= 0;
    endcase
  end


  // generate RS address out
  assign rs_addr_out = rs_addr_in;


  // generate internal signals
  wire[`DATA_BUS] operand_2_mux, result_sum;
  wire overflow_sum, opr1_lt_opr2;

  assign operand_2_mux =
      (opgen_in == `OPGEN_SUB || opgen_in == `OPGEN_SLT) ?
      -operand_2_in : operand_2_in;
  assign result_sum = operand_1_in + operand_2_mux;
  assign overflow_sum =
      ((!operand_1_in[31] && !operand_2_mux[31]) && result_sum[31]) ||
      ((operand_1_in[31] && operand_2_mux[31]) && (!result_sum[31]));
  assign opr1_lt_opr2 = opgen_in == `OPGEN_SLT ?
      // opr1 is negative & opr2 is positive
      ((operand_1_in[31] && !operand_2_in[31]) ||
          // opr1 & opr2 is positive, op1 - op2 is negative
          (!operand_1_in[31] && !operand_2_in[31] && result_sum[31]) ||
          // opr1 & opr2 is negative, op1 - op2 is negative
          (operand_1_in[31] && operand_2_in[31] && result_sum[31])) :
      // otherwise, perform an unsigned 'lt' operation
      (operand_1_in < operand_2_in);


  // generate exception signals
  assign exc_type_out = {
    exc_type_in[7:3],
    (exc_type_in[`EXC_TYPE_POS_OV] ? overflow_sum : 1'b0),
    exc_type_in[1:0]
  };


  // generate bit counter
  wire[`DATA_BUS] counter_result;

  BitCounter bit_counter(
    .opgen  (opgen_in),
    .opr    (operand_1_in),
    .result (counter_result)
  );


  // generate result
  reg[`DATA_BUS] result_out;

  always @(*) begin
    case (opgen_in)
      `OPGEN_NOP: result_out <= 0;
      `OPGEN_ADD, `OPGEN_SUB: result_out <= result_sum;
      `OPGEN_SLT, `OPGEN_SLTU: result_out <= {31'b0, opr1_lt_opr2};
      `OPGEN_AND: result_out <= operand_1_in & operand_2_in;
      `OPGEN_NOR: result_out <= ~(operand_1_in | operand_2_in);
      `OPGEN_OR: result_out <= operand_1_in | operand_2_in;
      `OPGEN_XOR: result_out <= operand_1_in ^ operand_2_in;
      `OPGEN_SLL: result_out <= operand_2_in << operand_1_in[4:0];
      `OPGEN_SRA: result_out <=
          ({32{operand_2_in[31]}} << (6'd32 - {1'b0, operand_1_in[4:0]})) |
          operand_2_in >> operand_1_in[4:0];
      `OPGEN_SRL: result_out <= operand_2_in >> operand_1_in[4:0];
      `OPGEN_CLZ, `OPGEN_CLO: result_out <= counter_result;
      `OPGEN_MOVZ, `OPGEN_MOVN: result_out <= operand_1_in;
      default: result_out <= 0;
    endcase
  end

endmodule // IntUnit
