`timescale 1ns / 1ps

`include "bus.v"
`include "regfile.v"

module ROBLine(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  input                   write_reg_write_add_in,
  input                   write_reg_write_en_in,
  input   [`RF_ADDR_BUS]  write_reg_write_addr_in,
  input                   write_reg_write_lo_en_in,
  input   [`EXC_TYPE_BUS] write_exception_type_in,
  input                   write_is_delayslot_in,
  input   [`ADDR_BUS]     write_pc_in,
  // update channel
  input                   update_en,
  input   [`DATA_BUS]     update_reg_write_data_in,
  input   [`DATA_BUS]     update_reg_write_lo_data_in,
  input   [`EXC_TYPE_BUS] update_exception_type_in,
  // output signals
  output                  done_out,
  output                  reg_write_add_out,
  output                  reg_write_en_out,
  output  [`RF_ADDR_BUS]  reg_write_addr_out,
  output  [`DATA_BUS]     reg_write_data_out,
  output                  reg_write_lo_en_out,
  output  [`DATA_BUS]     reg_write_lo_data_out,
  output  [`EXC_TYPE_BUS] exception_type_out,
  output                  is_delayslot_out,
  output  [`ADDR_BUS]     pc_out
);

  // storage
  reg                     done_out;
  reg                     reg_write_add_out;
  reg                     reg_write_en_out;
  reg[`RF_ADDR_BUS]       reg_write_addr_out;
  reg[`DATA_BUS]          reg_write_data_out;
  reg                     reg_write_lo_en_out;
  reg[`DATA_BUS]          reg_write_lo_data_out;
  reg[`EXC_TYPE_BUS]      exception_type_out;
  reg                     is_delayslot_out;
  reg[`ADDR_BUS]          pc_out;

  // write to storage
  always @(posedge clk) begin
    if (!rst) begin
      done_out <= 0;
      reg_write_add_out <= 0;
      reg_write_en_out <= 0;
      reg_write_addr_out <= 0;
      reg_write_data_out <= 0;
      reg_write_lo_en_out <= 0;
      reg_write_lo_data_out <= 0;
      exception_type_out <= 0;
      is_delayslot_out <= 0;
      pc_out <= 0;
    end
    else if (update_en) begin
      done_out <= 1;
      reg_write_data_out <= update_reg_write_data_in;
      reg_write_lo_data_out <= update_reg_write_lo_data_in;
      exception_type_out <= update_exception_type_in;
    end
    else if (write_en) begin
      done_out <= 0;
      reg_write_add_out <= write_reg_write_add_in;
      reg_write_en_out <= write_reg_write_en_in;
      reg_write_addr_out <= write_reg_write_addr_in;
      reg_write_data_out <= 0;
      reg_write_lo_en_out <= write_reg_write_lo_en_in;
      reg_write_lo_data_out <= 0;
      exception_type_out <= write_exception_type_in;
      is_delayslot_out <= write_is_delayslot_in;
      pc_out <= write_pc_in;
    end
  end

endmodule // ROBLine
