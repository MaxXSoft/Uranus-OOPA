`ifndef OOPA_CPU_INCLUDE_CACHE_V_
`define OOPA_CPU_INCLUDE_CACHE_V_

`include "util.v"

// I-Cache
`define ICACHE_LINE_WIDTH   6       // 2^6 = 64 bytes/line
`define ICACHE_WIDTH        6       // 2^6 = 64 lines
`define ICACHE_LINE_SIZE    `MAKE_SIZE(`ICACHE_LINE_WIDTH)
`define ICACHE_LINE_COUNT   `MAKE_SIZE(`ICACHE_WIDTH)

// D-Cache
`define DCACHE_LINE_WIDTH   6       // 2^6 = 64 bytes/line
`define DCACHE_WIDTH        7       // 2^7 = 128 lines
`define DCACHE_LINE_SIZE    `MAKE_SIZE(`DCACHE_LINE_WIDTH)
`define DCACHE_LINE_COUNT   `MAKE_SIZE(`DCACHE_WIDTH)

`endif  // OOPA_CPU_INCLUDE_CACHE_V_
