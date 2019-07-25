`ifndef OOPA_CPU_INCLUDE_ROB_V_
`define OOPA_CPU_INCLUDE_ROB_V_

`include "util.v"

// --- reservation station config ---

// integer unit
`define RS_INT_ADDR_WIDTH     4
`define RS_INT_SIZE           `MAKE_SIZE(`RS_INT_ADDR_WIDTH)

// mult div unit
`define RS_MDU_ADDR_WIDTH     4
`define RS_MDU_SIZE           `MAKE_SIZE(`RS_MDU_ADDR_WIDTH)

// // floating point unit
// `define RS_FPU_ADDR_WIDTH     3
// `define RS_FPU_SIZE           `MAKE_SIZE(`RS_FPU_ADDR_WIDTH)

// load store unit
`define RS_LSU_ADDR_WIDTH     4
`define RS_LSU_SIZE           `MAKE_SIZE(`RS_LSU_ADDR_WIDTH)

// branch unit
`define RS_BRU_ADDR_WIDTH     4
`define RS_BRU_SIZE           `MAKE_SIZE(`RS_BRU_ADDR_WIDTH)

// ---------   end config   ---------


// reorder buffer config
`define ROB_ADDR_WIDTH        6
`define ROB_SIZE              `MAKE_SIZE(`ROB_ADDR_WIDTH)
`define ROB_ADDR_BUS          `MAKE_BUS(`ROB_ADDR_WIDTH)

`endif  // OOPA_CPU_INCLUDE_ROB_V_
