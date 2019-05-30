`ifndef OOPA_CPU_INCLUDE_BRANCH_V_
`define OOPA_CPU_INCLUDE_BRANCH_V_

`include "bus.v"

// some definitions about branch prediction
`define GHR_WIDTH         5
`define GHR_BUS           (`GHR_WIDTH) - 1:0
`define PHT_SIZE          (2 ** (`GHR_WIDTH))

`define BTB_INDEX_WIDTH   6
`define BTB_SIZE          (2 ** (`BTB_INDEX_WIDTH))
`define BTB_PC_BUS        (`ADDR_BUS_WIDTH) - (`BTB_INDEX_WIDTH) - 3:0
`define BTB_PC_SEL        (`ADDR_BUS_WIDTH) - 1:(`BTB_INDEX_WIDTH) + 2
`define BTB_INDEX_SEL     (`BTB_INDEX_WIDTH) + 1:2

`endif  // OOPA_CPU_INCLUDE_BRANCH_V_
