`timescale 1ns / 1ps

module OOPA(
  input           aclk,
  input           aresetn,

  input           int_0,
  input           int_1,
  input           int_2,
  input           int_3,
  input           int_4,

  output  [3:0]   arid,
  output  [31:0]  araddr,
  output  [7:0]   arlen,
  output  [2:0]   arsize,
  output  [1:0]   arburst,
  output  [1:0]   arlock,
  output  [3:0]   arcache,
  output  [2:0]   arprot,
  output          arvalid,
  input           arready,

  input   [3:0]   rid,
  input   [31:0]  rdata,
  input   [1:0]   rresp,
  input           rlast,
  input           rvalid,
  output          rready,

  output  [3:0]   awid,
  output  [31:0]  awaddr,
  output  [7:0]   awlen,
  output  [2:0]   awsize,
  output  [1:0]   awburst,
  output  [1:0]   awlock,
  output  [3:0]   awcache,
  output  [2:0]   awprot,
  output          awvalid,
  input           awready,

  output  [3:0]   wid,
  output  [31:0]  wdata,
  output  [3:0]   wstrb,
  output          wlast,
  output          wvalid,
  input           wready,

  input   [3:0]   bid,
  input   [1:0]   bresp,
  input           bvalid,
  output          bready,

  output  [31:0]  debug_pc_addr,
  output  [3:0]   debug_reg_write_en,
  output  [4:0]   debug_reg_write_addr,
  output  [31:0]  debug_reg_write_data
);

  always @(posedge clk) begin
    if (!rst) begin
      //
    end
    else begin
      //
    end
  end

endmodule // OOPA
