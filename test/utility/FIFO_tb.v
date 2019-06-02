`timescale 1ns / 1ps

`include "tb.v"

module FIFO_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  reg write_en, read_en;
  reg[31:0] write_data;
  wire[31:0] read_data;
  wire is_full, is_empty;

  FIFO #(
    .kWidth       (32),
    .kAddrWidth   (4)
  ) fifo(
    .clk          (clk),
    .rst          (rst),
    .write_en     (write_en),
    .write_data   (write_data),
    .read_en      (read_en),
    .read_data    (read_data),
    .is_full      (is_full),
    .is_empty     (is_empty)
  );

  always @(posedge clk) begin
    if (!rst) begin
      write_en <= 0;
      read_en <= 0;
      write_data <= 0;
    end
    else begin
      case (`TICK)
        4: begin
          write_en <= 1;
          read_en <= 0;
          write_data <= 32'h12345678;
        end
        5: begin
          write_en <= 0;
          read_en <= 1;
          write_data <= 0;
        end
        6, 7, 8, 9, 10, 11, 12: begin
          write_en <= 1;
          read_en <= 0;
          write_data <= `TICK;
        end
        13, 14, 15, 16: begin
          write_en <= 0;
          read_en <= 1;
          write_data <= 0;
        end
      endcase
    end

    `DISPLAY("read_data   ", read_data);
    `DISPLAY("is_full     ", is_full);
    `DISPLAY("is_empty    ", is_empty);
    `DISPLAY("write_en    ", write_en);
    `DISPLAY("read_en     ", read_en);
    `DISPLAY("read_ptr    ", fifo.read_ptr);
    `DISPLAY("write_ptr   ", fifo.write_ptr);
    $display("");
    `END_AT_TICK(20);
  end

endmodule // FIFO_tb
