`timescale 1ns / 1ps

// address formation (ICACHE)
// 31        12|11      6|5     2 |1  0 
// +---------------------------------+
// |    tag    |  index  | offset |  |
// +---------------------------------+

// CahceLine data formation
//      20     |   1   |   1   |    64 * 8 = 32 * 16
// +---------------------------------------------------+
// |    tag    | valid | dirty | data0 | ... | data 15 +
// +---------------------------------------------------+

`include "bus.v"
`include "cache.v"

module InstCache(
  input               clk,
  input               rst,
  // cache control
  input               read_en,
  input               hit_invalidate,
  input   [`ADDR_BUS] addr_read,
  input   [`ADDR_BUS] addr_invalidate,
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

  localparam kTagWidth = `ADDR_BUS_WIDTH - `ICACHE_LINE_WIDTH - `ICACHE_WIDTH,
    kIndexWidth = `ICACHE_WIDTH,
    kOffsetWidth = `ICACHE_LINE_WIDTH - 2;

  // cache control
  // input signals
  wire                      line_write_en[`ICACHE_LINE_SIZE - 1:0];
  reg                       line_valid_in;
  reg[kTagWidth - 1:0]      line_tag_in;
  reg[kOffsetWidth - 1:0]   line_offset_in;
  wire[kOffsetWidth - 1:0]  line_offset_in_fwd;
  reg[`DATA_BUS]            line_data_in;
  // output signals
  wire                    line_valid_out[`ICACHE_LINE_SIZE - 1:0];
  wire[kTagWidth - 1:0]   line_tag_out[`ICACHE_LINE_SIZE - 1:0];
  wire[`DATA_BUS]         line_data_out[`ICACHE_LINE_SIZE - 1:0];

  // generate cache lines
  genvar i;
  generate
    for (i = 0; i < `ICACHE_LINE_COUNT; i = i + 1) begin
      CacheLine #(
        .TAG_WIDTH(kTagWidth),
        .INDEX_WIDTH(kIndexWidth),
        .OFFSET_WIDTH(kOffsetWidth)
      ) line (
        .clk(clk),
        .rst(rst),
        .write_en(line_write_en[i]),
        .valid_in(line_valid_in),
        .dirty_in(0),
        .tag_in(line_tag_in),
        .offset_in(line_offset_in_fwd),
        .data_byte_en(4'b1111),
        .data_in(line_data_in),
        .valid_out(line_valid_out[i]),
        /* verilator lint_off PINCONNECTEMPTY */
        .dirty_out(/* null */),
        .tag_out(line_tag_out[i]),
        .data_out(line_data_out[i])
      );
    end
  endgenerate

  // cache line signals
  wire[kTagWidth - 1:0]     read_line_tag;
  wire[kIndexWidth - 1:0]   read_line_index;
  wire[kOffsetWidth - 1:0]  read_line_offset;

  wire[kTagWidth - 1:0]     invalid_line_tag;
  wire[kIndexWidth - 1:0]   invalid_line_index;
  wire[kOffsetWidth - 1:0]  invalid_line_offset;

  assign read_line_tag    = addr_read[`ADDR_BUS_WIDTH - 1:`ADDR_BUS_WIDTH - kTagWidth];
  assign read_line_index  = addr_read[`ADDR_BUS_WIDTH - kTagWidth - 1:`ADDR_BUS_WIDTH - kTagWidth - kIndexWidth];
  assign read_line_offset = addr_read[kOffsetWidth + 1:2];

  assign invalid_line_tag    = addr_invalidate[`ADDR_BUS_WIDTH - 1:`ADDR_BUS_WIDTH - kTagWidth];
  assign invalid_line_index  = addr_invalidate[`ADDR_BUS_WIDTH - kTagWidth - 1:`ADDR_BUS_WIDTH - kTagWidth - kIndexWidth];
  assign invalid_line_offset = addr_invalidate[kOffsetWidth + 1:2];

  wire read_line_valid;
  wire read_line_hit;
  wire invalid_line_valid;
  wire invalid_line_hit;

  assign read_line_valid = line_valid_out[read_line_index];
  assign read_line_hit = read_line_tag == line_tag_out[read_line_index];
  assign invalid_line_valid = line_valid_out[invalid_line_index];
  assign invalid_line_hit = invalid_line_tag == line_tag_out[invalid_line_index];

  wire need_invalidate;
  wire need_memread;

  assign need_invalidate = hit_invalidate && invalid_line_valid && invalid_line_hit;
  assign need_memread = read_en && (!read_line_valid || !read_line_hit);

  reg cache_write_en;
  reg[kIndexWidth - 1:0]cache_write_index;
  generate
    for (i = 0; i < `ICACHE_LINE_SIZE; i = i + 1) begin
      assign line_write_en[i] = cache_write_en ? cache_write_index == i : 0;
    end
  endgenerate

  // AXI adapter
  reg[31:0] axi_read_addr;
  reg axi_read_valid;
  
  assign araddr = axi_read_addr;
  assign arlen = 2 ** kOffsetWidth - 1;
  assign arvalid = axi_read_valid;
  // constants
  assign arid = 4'b0;
  assign arsize = 3'b010;
  assign arburst = 2'b01;
  assign arlock = 2'b0;
  assign arcache = 4'b0;
  assign arprot = 3'b0;
  assign rready = 1'b1;
  assign awid = 4'b0;
  assign awaddr = 32'b0;
  assign awlen = 8'b0;
  assign awsize = 3'b0;
  assign awburst = 2'b0;
  assign awlock = 2'b0;
  assign awcache = 4'b0;
  assign awprot = 3'b0;
  assign awvalid = 1'b0;
  assign wid = 4'b0;
  assign wdata = 32'b0;
  assign wstrb = 4'b0;
  assign wlast = 1'b0;
  assign wvalid = 1'b0;
  assign bready = 1'b0;

  // FSM definition
  reg[1:0]  state;
  reg[1:0]  next_state;
  localparam kStateIdle = 0, kStateAddr = 1,
    kStateData = 2, kStateUpdate = 3;

  assign line_offset_in_fwd = (state == kStateIdle) ? read_line_offset :
    line_offset_in;
  assign ready = (state == kStateIdle) && 
    (!need_invalidate || addr_read != addr_invalidate) &&
    !need_memread;
  assign data_out = ready ? line_data_out[read_line_index] : 0;

  always @(posedge clk) begin
    if (!rst) begin
      state <= kStateIdle;
    end
    else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      kStateIdle: begin
        if (read_en && need_invalidate) begin
          next_state <= kStateUpdate;
        end
        else if (read_en && need_memread) begin
          next_state <= kStateAddr;
        end
        else begin
          next_state <= kStateIdle;
        end
      end
      kStateAddr: begin
        next_state <= arready ? kStateData : kStateAddr;
      end
      kStateData: begin
        next_state <= rlast ? kStateUpdate : kStateData;
      end
      kStateUpdate: begin
        next_state <= kStateIdle;
      end
      default: next_state <= kStateIdle;
    endcase
  end

  always @(posedge clk) begin
    if (!rst) begin
      // cache control
      line_valid_in <= 0;
      line_tag_in <= 0;
      line_offset_in <= 0;
      line_data_in <= 0;
      cache_write_en <= 0;
      cache_write_index <= 0;
      // AXI
      axi_read_addr <= 0;
      axi_read_valid <= 0;
    end
    else begin
      case (state)
        kStateIdle: begin
          if (need_invalidate) begin
            // cache control
            line_valid_in <= 0;
            line_tag_in <= invalid_line_tag;
            line_offset_in <= invalid_line_offset;
            line_data_in <= 0;
            cache_write_en <= 1;
            cache_write_index <= invalid_line_index;
            // AXI
            axi_read_addr <= 0;
            axi_read_valid <= 0;
          end
          else begin
            // cache control
            line_valid_in <= 0;
            line_tag_in <= 0;
            line_offset_in <= 0;
            line_data_in <= 0;
            cache_write_en <= 0;
            cache_write_index <= 0;
            // AXI
            axi_read_addr <= 0;
            axi_read_valid <= 0;
          end
        end
        kStateAddr: begin
          // cache control
          line_valid_in <= 0;
          line_tag_in <= 0;
          line_offset_in <= -1;
          line_data_in <= 0;
          cache_write_en <= 0;
          cache_write_index <= 0;
          // AXI
          axi_read_addr <= addr_read;
          axi_read_valid <= 1;
        end
        kStateData: begin
          // cache control
          line_valid_in <= 1;
          line_tag_in <= read_line_tag;
          if (rvalid) begin
            line_offset_in <= line_offset_in + 1;
            line_data_in <= rdata;
          end
          else begin
            line_offset_in <= line_offset_in;
            line_data_in <= 0;
          end
          cache_write_en <= 1;
          cache_write_index <= read_line_index;
          // AXI
          axi_read_addr <= 0;
          axi_read_valid <= 0;
        end
        kStateUpdate: begin
          // cache control
          line_valid_in <= 0;
          line_tag_in <= 0;
          line_offset_in <= 0;
          line_data_in <= 0;
          cache_write_en <= 0;
          cache_write_index <= 0;
          // AXI
          axi_read_addr <= 0;
          axi_read_valid <= 0;
        end
        default: begin
          // cache control
          line_valid_in <= 0;
          line_tag_in <= 0;
          line_offset_in <= 0;
          line_data_in <= 0;
          cache_write_en <= 0;
          cache_write_index <= 0;
          // AXI
          axi_read_addr <= 0;
          axi_read_valid <= 0;
        end
      endcase
    end
  end

endmodule // InstCache
