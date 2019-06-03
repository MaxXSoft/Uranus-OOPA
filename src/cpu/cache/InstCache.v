`timescale 1ns / 1ps

`include "bus.v"
`include "cache.v"

module InstCache(
  input               clk,
  input               rst,
  // cache control
  input               read_en,
  input               hit_invalidate,
  input   [`ADDR_BUS] addr_read,
  input   [`ADDR_BUS] addr_inv,
  output              ready,
  output  [`DATA_BUS] data_out,
  // AXI interface (32-bit addr & data)
  output  [3:0]       arid,
  output  [31:0]      araddr,
  output  [7:0]       arlen,
  output  [2:0]       arsize,
  output  [1:0]       arburst,
  output  [1:0]       arlock,
  output  [3:0]       arcache,
  output  [2:0]       arprot,
  output              arvalid,
  input               arready,
  // ---
  input   [3:0]       rid,
  input   [31:0]      rdata,
  input   [1:0]       rresp,
  input               rlast,
  input               rvalid,
  output              rready,
  // ---
  output  [3:0]       awid,
  output  [31:0]      awaddr,
  output  [7:0]       awlen,
  output  [2:0]       awsize,
  output  [1:0]       awburst,
  output  [1:0]       awlock,
  output  [3:0]       awcache,
  output  [2:0]       awprot,
  output              awvalid,
  input               awready,
  // ---
  output  [3:0]       wid,
  output  [31:0]      wdata,
  output  [3:0]       wstrb,
  output              wlast,
  output              wvalid,
  input               wready,
  // ---
  input   [3:0]       bid,
  input   [1:0]       bresp,
  input               bvalid,
  output              bready
);

  localparam kIndexWidth = `ICACHE_LINE_WIDTH - 2,
      kTagWidth = `ADDR_BUS_WIDTH - `ICACHE_LINE_WIDTH - `ICACHE_WIDTH;

  // TODO
  // reference: Uranus Zero's unfinished instruction cache module

endmodule // InstCache
