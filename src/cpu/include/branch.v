`ifndef OOPA_CPU_INCLUDE_BRANCH_V_
`define OOPA_CPU_INCLUDE_BRANCH_V_

`include "bus.v"
`include "util.v"

// some definitions about branch prediction
`define GHR_WIDTH         5
`define GHR_BUS           `MAKE_BUS(`GHR_WIDTH)
`define PHT_SIZE          `MAKE_SIZE(`GHR_WIDTH)

`define BTB_INDEX_WIDTH   6
`define BTB_SIZE          `MAKE_SIZE(`BTB_INDEX_WIDTH)
`define BTB_PC_WIDTH      (`ADDR_BUS_WIDTH) - (`BTB_INDEX_WIDTH) - 2
`define BTB_PC_BUS        `MAKE_BUS(`BTB_PC_WIDTH)
`define BTB_PC_SEL        (`ADDR_BUS_WIDTH) - 1:(`BTB_INDEX_WIDTH) + 2
`define BTB_INDEX_SEL     (`BTB_INDEX_WIDTH) + 1:2

`endif  // OOPA_CPU_INCLUDE_BRANCH_V_
