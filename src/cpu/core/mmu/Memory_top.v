`timescale 1ns / 1ps

`include "bus.v"

module Memory_top(
  input rst,
  // FROM CPU
  // ICache signals
  input               icache_en_i,
  input               icache_hit_invalid_i,
  input   [3:0]       icache_byte_en_i,  // unused
  input   [`ADDR_BUS] icache_rw_addr_i,
  input   [`ADDR_BUS] icache_invalid_addr_i,
  input   [`DATA_BUS] icache_write_data_i,  // unused
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
  output              unicache_en_o,
  output  [`ADDR_BUS] unicache_rw_addr_o,

  output              undcache_en_o,
  output  [3:0]       undcache_byte_en_o,
  output  [`ADDR_BUS] undcache_rw_addr_o,
  output  [`DATA_BUS] undcache_write_data_o
);

  wire[`ADDR_BUS] icache_rw_addr;
  wire[`ADDR_BUS] dcache_rw_addr;

  wire icache_rw_addr_is_cached;
  wire dcache_rw_addr_is_cached;

  MMU immu(
    .rst        (rst),
    .addr_in    (icache_rw_addr_i),
    .is_cached  (icache_rw_addr_is_cached),
    .addr_out   (icache_rw_addr)
  );

  MMU dmmu(
    .rst        (rst),
    .addr_in    (dcache_rw_addr_i),
    .is_cached  (dcache_rw_addr_is_cached),
    .addr_out   (dcache_rw_addr)
  );

  // TO ICache
  assign icache_en_o = icache_en_i & icache_rw_addr_is_cached;
  assign icache_hit_invalid_o = icache_en_o ? icache_hit_invalid_i : 0;
  assign icache_rw_addr_o = icache_en_o ? icache_rw_addr : 0;
  assign icache_invalid_addr_o = icache_en_o ? icache_invalid_addr_i : 0;
  // TO DCache
  assign dcache_en_o = dcache_en_i & dcache_rw_addr_is_cached;
  assign dcache_hit_invalid_o = dcache_en_o ? dcache_hit_invalid_i : 0;
  assign dcache_byte_en_o = dcache_en_o ? dcache_byte_en_i : 0;
  assign dcache_rw_addr_o = dcache_en_o ? dcache_rw_addr : 0;
  assign dcache_invalid_addr_o = dcache_en_o ? dcache_invalid_addr_i : 0;
  assign dcache_write_data_o = dcache_en_o ? dcache_write_data_i : 0;
  // TO UnCached
  assign unicache_en_o = icache_en_i & !icache_rw_addr_is_cached;
  assign unicache_rw_addr_o = unicache_en_o ? icache_rw_addr : 0;
  assign undcache_en_o = dcache_en_i & !dcache_rw_addr_is_cached;
  assign undcache_byte_en_o = undcache_en_o ? dcache_byte_en_i : 0;
  assign undcache_rw_addr_o = undcache_en_o ? dcache_rw_addr : 0;
  assign undcache_write_data_o = undcache_en_o ? dcache_write_data_i : 0;

endmodule
