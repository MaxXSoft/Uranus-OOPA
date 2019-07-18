`ifndef OOPA_CPU_INCLUDE_UTIL_V_
`define OOPA_CPU_INCLUDE_UTIL_V_

// some global utilities

`define MAKE_SIZE(width)    (2 ** (width))
`define MAKE_BUS(width)     (width) - 1:0

`endif  // OOPA_CPU_INCLUDE_UTIL_V_
