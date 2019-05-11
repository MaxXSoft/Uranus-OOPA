`timescale 1ns / 1ps

module InstCache #(parameter
  ADDR_WIDTH = 32,
  LINE_WIDTH = 6,         // 2^6 = 64 bytes/line
  CACHE_WIDTH = 6         // 2^6 = 64 lines
  `define LINE_COUNT      (2 ** CACHE_WIDTH)
  `define INDEX_WIDTH     (LINE_WIDTH - 2)
  `define TAG_WIDTH       (ADDR_WIDTH - LINE_WIDTH - CACHE_WIDTH)
) (
  input clk,
  input rst,
  // cache control
  input read_en,
  input hit_invalidate,
  input [ADDR_WIDTH - 1:0] addr_read,
  input [ADDR_WIDTH - 1:0] addr_inv,
  output ready,
  output [31:0] data_out,
  // AXI interface
  output [3:0]  arid,
  output [31:0] araddr,
  output [7:0]  arlen,
  output [2:0]  arsize,
  output [1:0]  arburst,
  output [1:0]  arlock,
  output [3:0]  arcache,
  output [2:0]  arprot,
  output        arvalid,
  input         arready,
  // ---
  input  [3:0]  rid,
  input  [31:0] rdata,
  input  [1:0]  rresp,
  input         rlast,
  input         rvalid,
  output        rready,
  // ---
  output [3:0]  awid,
  output [31:0] awaddr,
  output [7:0]  awlen,
  output [2:0]  awsize,
  output [1:0]  awburst,
  output [1:0]  awlock,
  output [3:0]  awcache,
  output [2:0]  awprot,
  output        awvalid,
  input         awready,
  // ---
  output [3:0]  wid,
  output [31:0] wdata,
  output [3:0]  wstrb,
  output        wlast,
  output        wvalid,
  input         wready,
  // ---
  input  [3:0]  bid,
  input  [1:0]  bresp,
  input         bvalid,
  output        bready
);

  // TODO
  // reference: Uranus Zero's unfinished instruction cache module

endmodule // InstCache
