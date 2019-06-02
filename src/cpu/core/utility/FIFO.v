`timescale 1ns / 1ps

// general purpose FIFO module

module FIFO #(parameter
  kWidth = 1,
  kAddrWidth = 4
) (
  input                   clk,
  input                   rst,
  input                   write_en,
  input   [kWidth - 1:0]  write_data,
  input                   read_en,
  output  [kWidth - 1:0]  read_data,
  output                  is_full,
  output                  is_empty
);

  localparam kSize = 2 ** kAddrWidth;

  // generate write & read pointers
  reg[kAddrWidth:0] write_ptr, read_ptr;

  always @(posedge clk) begin
    if (!rst) begin
      write_ptr <= 0;
      read_ptr <= 0;
    end
    else if (write_en) begin
      write_ptr <= write_ptr + 1;
    end
    else if (read_en) begin
      read_ptr <= read_ptr + 1;
    end
  end

  // check FIFO is full or empty
  wire full_or_empty, empty;
  assign full_or_empty = write_ptr[kAddrWidth - 1:0]
      == read_ptr[kAddrWidth - 1:0];
  assign empty = write_ptr == read_ptr;
  assign is_full = full_or_empty && !empty;
  assign is_empty = full_or_empty && empty;

  // generate FIFO memory
  reg[kWidth - 1:0] fifo_mem[kSize - 1:0];
  assign read_data = read_en ? fifo_mem[read_ptr[kAddrWidth - 1:0]] : 0;

  always @(posedge clk) begin
    if (!rst) begin
      integer i;
      for (i = 0; i < kSize; i = i + 1) begin
        fifo_mem <= 0;
      end
    end
    else if (write_en) begin
      fifo_mem[write_ptr[kAddrWidth - 1:0]] <= write_data;
    end
  end

endmodule // FIFO
