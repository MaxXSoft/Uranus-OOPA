`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"

module RegFile_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg                 write_en;
  reg[`REG_ADDR_BUS]  write_addr;
  reg                 write_restore;
  reg                 write_is_ref;
  reg[`DATA_BUS]      write_data;
  reg                 read_en_1;
  reg                 read_en_2;
  reg[`REG_ADDR_BUS]  read_addr_1;
  reg[`REG_ADDR_BUS]  read_addr_2;

  // output signals
  wire                read_is_ref_1;
  wire                read_is_ref_2;
  wire[`DATA_BUS]     read_data_1;
  wire[`DATA_BUS]     read_data_2;

  RegFile regfile(
    .clk            (clk),
    .rst            (rst),
    .write_en       (write_en),
    .write_addr     (write_addr),
    .write_restore  (write_restore),
    .write_is_ref   (write_is_ref),
    .write_data     (write_data),
    .read_en_1      (read_en_1),
    .read_en_2      (read_en_2),
    .read_addr_1    (read_addr_1),
    .read_addr_2    (read_addr_2),
    .read_is_ref_1  (read_is_ref_1),
    .read_is_ref_2  (read_is_ref_2),
    .read_data_1    (read_data_1),
    .read_data_2    (read_data_2)
  );

  always @(posedge clk) begin
    if (!rst) begin
      write_en <= 0;
      write_addr <= 0;
      write_restore <= 0;
      write_is_ref <= 0;
      write_data <= 0;
      read_en_1 <= 0;
      read_en_2 <= 0;
      read_addr_1 <= 0;
      read_addr_2 <= 0;
    end
    else begin
      read_en_1 <= 1;
      read_en_2 <= 1;
      read_addr_1 <= 1;
      read_addr_2 <= 2;

      case (`TICK)
        0: begin
          $display("write value");
          write_en <= 1;
          write_addr <= 1;
          write_restore <= 0;
          write_is_ref <= 0;
          write_data <= 32'h12345678;
        end
        1: begin
          $display("write rsid");
          write_en <= 1;
          write_addr <= 1;
          write_restore <= 0;
          write_is_ref <= 1;
          write_data <= 32'h0000000a;
        end
        2: begin
          $display("restore value");
          write_en <= 1;
          write_addr <= 1;
          write_restore <= 1;
          write_is_ref <= 0;
          write_data <= 0;
        end
      endcase
    end

    `DISPLAY("read_is_ref_1 ", read_is_ref_1);
    `DISPLAY("read_is_ref_2 ", read_is_ref_2);
    `DISPLAY("read_data_1   ", read_data_1);
    `DISPLAY("read_data_2   ", read_data_2);
    $display("");
    `END_AT_TICK(3);
  end

endmodule // RegFile_tb
