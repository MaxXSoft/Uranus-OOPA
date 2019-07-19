`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"

module RegFile(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  input                   write_restore,
  input   [`REG_ADDR_BUS] write_addr,
  input                   write_is_ref,
  input   [`DATA_BUS]     write_data,
  // read channel (x2)
  input                   read_en_1,
  input                   read_en_2,
  input   [`REG_ADDR_BUS] read_addr_1,
  input   [`REG_ADDR_BUS] read_addr_2,
  output                  read_is_ref_1,
  output                  read_is_ref_2,
  output  [`DATA_BUS]     read_data_1,
  output  [`DATA_BUS]     read_data_2
);

  // indicate whether current register stores RS/ROB id
  reg is_ref[31:0];
  // stores register value
  reg[`DATA_BUS] reg_val[31:0];
  // stores RS/ROB id
  reg[`ROB_ADDR_BUS] ref_id[31:0];

  // write channel
  always @(posedge clk) begin
    if (!rst) begin
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        is_ref[i] <= 0;
        reg_val[i] <= 0;
        ref_id[i] <= 0;
      end
    end
    else if (write_restore) begin
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        is_ref[i] <= 0;
      end
    end
    else if (write_en && |write_addr) begin
      is_ref[write_addr] <= write_is_ref;
      if (write_is_ref) begin
        ref_id[write_addr] <= write_data[`ROB_ADDR_BUS];
      end
      else begin
        reg_val[write_addr] <= write_data;
      end
    end
  end

  // read channel 1
  reg read_is_ref_1;
  reg[`DATA_BUS] read_data_1;

  always @(*) begin
    if (!rst) begin
      read_is_ref_1 <= 0;
      read_data_1 <= 0;
    end
    else if (read_en_1) begin
      if (write_en && read_addr_1 == write_addr) begin
        // data forwarding
        if (write_restore) begin
          read_is_ref_1 <= 0;
          read_data_1 <= reg_val[read_addr_1];
        end
        else begin
          read_is_ref_1 <= write_is_ref;
          read_data_1 <= write_data;
        end
      end
      else begin
        read_is_ref_1 <= is_ref[read_addr_1];
        if (is_ref[read_addr_1]) begin
          read_data_1 <= {
            {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
            ref_id[read_addr_1]
          };
        end
        else begin
          read_data_1 <= reg_val[read_addr_1];
        end
      end
    end
    else begin
      read_is_ref_1 <= 0;
      read_data_1 <= 0;
    end
  end

  // read channel 2
  reg read_is_ref_2;
  reg[`DATA_BUS] read_data_2;

  always @(*) begin
    if (!rst) begin
      read_is_ref_2 <= 0;
      read_data_2 <= 0;
    end
    else if (read_en_2) begin
      if (write_en && read_addr_2 == write_addr) begin
        // data forwarding
        if (write_restore) begin
          read_is_ref_2 <= 0;
          read_data_2 <= reg_val[read_addr_2];
        end
        else begin
          read_is_ref_2 <= write_is_ref;
          read_data_2 <= write_data;
        end
      end
      else begin
        read_is_ref_2 <= is_ref[read_addr_2];
        if (is_ref[read_addr_2]) begin
          read_data_2 <= {
            {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
            ref_id[read_addr_2]
          };
        end
        else begin
          read_data_2 <= reg_val[read_addr_2];
        end
      end
    end
    else begin
      read_is_ref_2 <= 0;
      read_data_2 <= 0;
    end
  end

endmodule // RegFile
