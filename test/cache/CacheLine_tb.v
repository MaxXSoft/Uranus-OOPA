`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "cache.v"

module CacheLine_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg             write_en;
  reg             valid_in;
  reg             dirty_in;
  reg[19:0]       tag_in;
  reg[3:0]        offset_in;
  reg[3:0]        data_byte_en;
  reg[`DATA_BUS]  data_in;

  // output signals
  wire            valid_out;
  wire            dirty_out;
  wire[19:0]      tag_out;
  wire[`DATA_BUS] data_out;

  CacheLine cacheline (
    .clk          (clk),
    .rst          (rst),
    .write_en     (write_en),
    .valid_in     (valid_in),
    .dirty_in     (dirty_in),
    .tag_in       (tag_in),
    .offset_in    (offset_in),
    .data_byte_en (data_byte_en),
    .data_in      (data_in),
    .valid_out    (valid_out),
    .dirty_out    (dirty_out),
    .tag_out      (tag_out),
    .data_out     (data_out)
  );

  always @(posedge clk) begin
    if (!rst) begin
      write_en <= 0;
      valid_in <= 0;
      dirty_in <= 0;
      tag_in <= 0;
      offset_in <= 0;
      data_byte_en <= 0;
      data_in <= 0;
    end
    else begin
      case (`TICK)
        0: begin
          write_en <= 1'b1;
          valid_in <= 1'b1;
          dirty_in <= 1'b1;
          tag_in <= 20'h2;
          offset_in <= 4'h3;
          data_byte_en <= 4'b0011;
          data_in <= 32'hFFFF_FFFF;
        end
        1: begin
          write_en <= 1'b1;
          valid_in <= 1'b0;
          dirty_in <= 1'b1;
          tag_in <= 20'h2;
          offset_in <= 4'h3;
          data_byte_en <= 4'b0001;
          data_in <= 32'hFFFF_FFFF;
        end
        2: begin
          write_en <= 1'b0;
          valid_in <= 1'b0;
          dirty_in <= 1'b0;
          tag_in <= 20'h2;
          offset_in <= 4'h3;
          data_byte_en <= 4'b1111;
          data_in <= 32'hFFFF_FFFF;
        end
      endcase
    end

    `DISPLAY("valid_out", valid_out);
    `DISPLAY("dirty_out", dirty_out);
    `DISPLAY("tag_out  ", tag_out);
    `DISPLAY("data_out ", data_out);
    $display("");
    `END_AT_TICK(3);
  end

endmodule