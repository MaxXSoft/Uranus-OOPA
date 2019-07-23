`timescale 1ns / 1ps

`include "bus.v"
`include "cache.v"

module CacheLine #(parameter
  TAG_WIDTH = 20,
  INDEX_WIDTH = 6,
  OFFSET_WIDTH = 4
) (
  input                         clk,
  input                         rst,  
  // cache control
  // input signals
  input                         write_en,
  input                         valid_in,
  input                         dirty_in,
  input [TAG_WIDTH - 1:0]       tag_in,
  input [OFFSET_WIDTH - 1:0]    offset_in,
  input [3:0]                   data_byte_en,
  input [`DATA_BUS]             data_in,
  // output signals
  output                        valid_out,
  output                        dirty_out,
  output [TAG_WIDTH - 1:0]      tag_out,
  output [`DATA_BUS]            data_out
);

  reg[TAG_WIDTH - 1:0] tag;
  reg valid;
  reg dirty;
  (* ram_style = "block" *)
  reg[`DATA_BUS] data[2 ** OFFSET_WIDTH - 1 :0];

  assign valid_out = valid;
  assign dirty_out = valid ? dirty : 0;
  assign tag_out = tag;
  assign data_out = valid ? data[offset_in] : 0;

  always @(posedge clk) begin
    if (!rst) begin
      valid <= 0;
      dirty <= 0;
      tag <= 0;
    end
    else if (write_en) begin
      valid <= valid_in;
      dirty <= dirty_in;
      tag <= tag_in;
    end
  end

  always @(posedge clk) begin
    if (write_en) begin
      if (data_byte_en[0]) data[offset_in][7:0] <= data_in[7:0];
      if (data_byte_en[1]) data[offset_in][15:8] <= data_in[15:8];
      if (data_byte_en[2]) data[offset_in][23:16] <= data_in[23:16];
      if (data_byte_en[3]) data[offset_in][31:24] <= data_in[31:24];
    end
  end

endmodule // CacheLine
