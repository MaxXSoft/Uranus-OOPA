`timescale 1ns / 1ps

`include "bus.v"

module RegFile(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  input   [`REG_ADDR_BUS] write_addr,
  input                   write_is_rsid,
  input   [`DATA_BUS]     write_data,
  // read channel (x2)
  input                   read_en_1,
  input                   read_en_2,
  input   [`REG_ADDR_BUS] read_addr_1,
  input   [`REG_ADDR_BUS] read_addr_2,
  output                  read_is_rsid_1,
  output                  read_is_rsid_2,
  output  [`DATA_BUS]     read_data_1,
  output  [`DATA_BUS]     read_data_2
);

  // indicate whether current register stores RS id
  reg is_rsid[31:0];
  // store register value or reservation station id
  reg[`DATA_BUS] reg_rsid[31:0];

  // write channel
  always @(posedge clk) begin
    if (!rst) begin
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        is_rsid[i] <= 0;
        reg_rsid[i] <= 0;
      end
    end
    else if (write_en && write_addr) begin
      is_rsid[write_data] <= write_is_rsid;
      reg_rsid[write_data] <= write_data;
    end
  end

  // read channel 1
  reg read_is_rsid_1;
  reg[`DATA_BUS] read_data_1;

  always @(*) begin
    if (!rst) begin
      read_is_rsid_1 <= 0;
      read_data_1 <= 0;
    end
    else if (read_en_1) begin
      if (write_en && read_addr_1 == write_addr) begin
        // data forwarding
        read_is_rsid_1 <= write_is_rsid;
        read_data_1 <= write_data;
      end
      else begin
        read_is_rsid_1 <= is_rsid[read_addr_1];
        read_data_1 <= reg_rsid[read_addr_1];
      end
    end
    else begin
      read_is_rsid_1 <= 0;
      read_data_1 <= 0;
    end
  end

  // read channel 2
  reg read_is_rsid_2;
  reg[`DATA_BUS] read_data_2;

  always @(*) begin
    if (!rst) begin
      read_is_rsid_2 <= 0;
      read_data_2 <= 0;
    end
    else if (read_en_2) begin
      if (write_en && read_addr_2 == write_addr) begin
        // data forwarding
        read_is_rsid_2 <= write_is_rsid;
        read_data_2 <= write_data;
      end
      else begin
        read_is_rsid_2 <= is_rsid[read_addr_2];
        read_data_2 <= reg_rsid[read_addr_2];
      end
    end
    else begin
      read_is_rsid_2 <= 0;
      read_data_2 <= 0;
    end
  end

endmodule // RegFile
