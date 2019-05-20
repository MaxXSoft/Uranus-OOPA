`ifndef OOPA_CPU_INCLUDE_BRANCH_V_
`define OOPA_CPU_INCLUDE_BRANCH_V_

// some definitions about branch prediction
`define GHR_WIDTH         5
`define GHR_BUS           (`GHR_WIDTH) - 1:0
`define PHT_SIZE          (2 ** (`GHR_WIDTH))

`define BTB_INDEX_WIDTH   6
`define BTB_SIZE          (2 ** (`BTB_INDEX_WIDTH))

`endif  // OOPA_CPU_INCLUDE_BRANCH_V_
