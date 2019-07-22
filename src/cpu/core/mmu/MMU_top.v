`timescale 1ns / 1ps

`include "bus.v"

module MMU_top(
  input rst,
  // FROM CPU
  // ICache signals
  input               icache_en_i,
  input               icache_hit_invalid_i,
  input   [3:0]       icache_byte_en_i,
  input   [`ADDR_BUS] icache_rw_addr_i,
  input   [`ADDR_BUS] icache_invalid_addr_i,
  input   [`DATA_BUS] icache_write_data_i,
  // DCache signals
  input               dcache_en_i,
  input               dcache_hit_invalid_i,
  input   [3:0]       dcache_byte_en_i,
  input   [`ADDR_BUS] dcache_rw_addr_i,
  input   [`ADDR_BUS] dcache_invalid_addr_i,
  input   [`DATA_BUS] dcache_write_data_i,

  // TO CPU
  // ICache signals
  output              icache_ready,
  output  [`DATA_BUS] icache_read_data,
  // DCache signals
  output              dcache_ready,
  output  [`DATA_BUS] dcache_read_data,
  // UnCached signals
  output              uncached_ready,
  output  [`DATA_BUS] uncached_read_data,

  // TO ICache
  output              icache_en_o,
  output              icache_hit_invalid_o,
  output  [`ADDR_BUS] icache_rw_addr_o,
  output  [`ADDR_BUS] icache_invalid_addr_o,

  // TO Dcache
  output              dcache_en_o,
  output              dcache_hit_invalid_o,
  output  [3:0]       dcache_byte_en_o,
  output  [`ADDR_BUS] dcache_rw_addr_o,
  output  [`ADDR_BUS] dcache_invalid_addr_o,
  output  [`DATA_BUS] dcache_write_data_o,

  // TO UnCached
  output              uncached_en_o,
  output  [3:0]       uncached_byte_en_o,
  output  [`ADDR_BUS] uncached_rw_addr_o,
  output  [`DATA_BUS] uncached_write_data_o
);

endmodule
