`timescale 1ns / 1ps

/*
 * Virtual Address                   Physical Address
 * ------------+-------------+       +-------------+
 * 0xFFFF_FFFF |    kseg3    |       |    kseg3    |
 *             |             |       |             |
 * 0xE000_0000 |    512MB    |       |    512MB    |
 * ------------+-------------+       +-------------+
 * 0xDFFF_FFFF |    kseg2    |       |    kseg2    |
 *             |             |       |             |
 * 0xC000_0000 |    512MB    |       |    512MB    |
 * ------------+-------------+       +-------------+
 * 0xBFFF_FFFF |    kseg1    |       |             |
 *             |   Uncached  |       |             |
 * 0xA000_0000 |    512MB    |       |             |
 * ------------+-------------+       |   reserved  |
 * 0x9FFF_FFFF |    kseg0    |       |             |
 *             |             |       |             |
 * 0x8000_0000 |    512MB    |       |             |
 * ------------+-------------+       +-------------+
 * 0x7FFF_FFFF |             |       |             |
 *             |             |       |    kuseg    |
 *             |    kuseg    |       |             |
 *             |             |       |     2GB     |
 *             |             |       |             |
 *             |     2GB     |       |             |
 *             |             |       |- - - - - - -|
 *             |             |       |   kseg0/1   |
 * 0x0000_0000 |             |       |    512MB    |
 * ------------+-------------+       +-------------+
*/

`include "bus.v"

/* verilator lint_off UNSIGNED */
`define IN_RANGE(v, l, u) v[31:28] >= (l) && v[31:28] <= (u)

module MMU(
  input               rst,
  input   [`ADDR_BUS] addr_in,
  output              is_cached,
  output  [`ADDR_BUS] addr_out
);

  always @(*) begin
    if (!rst) begin
      is_cached <= 0;
      addr_out <= 0;
    end
    else begin
      if (`IN_RANGE(addr_in, 4'h0, 4'h7)) begin
        is_cached <= 1;
        addr_out <= addr_in;
      end
      else if (`IN_RANGE(addr_in, 4'h8, 4'h9)) begin
        is_cached <= 1;
        addr_out <= {addr_in[31:28] - 4'h8, addr_in[27:0]};
      end
      else if (`IN_RANGE(addr_in, 4'ha, 4'hb)) begin
        is_cached <= 0;
        addr_out <= {addr_in[31:28] - 4'ha, addr_in[27:0]};
      end
      else if (`IN_RANGE(addr_in, 4'hc, 4'hd)) begin
        is_cached <= 1;
        addr_out <= addr_in;
      end
      else begin  // 0xE000_0000, 0xFFFF_FFFF
        is_cached <= 1;
        addr_out <= addr_in;
      end
    end
  end

endmodule