`ifndef OOPA_CPU_INCLUDE_UTIL_V_
`define OOPA_CPU_INCLUDE_UTIL_V_

// some global utilities

`define MAKE_SIZE(width)    (2 ** (width))
`define MAKE_BUS(width)     (width) - 1:0

// TODO: make it parameterized (maybe impossible)
`define GEN_OUT_16(out, en, val)                                        \
  assign out = en[ 0] ? val[ 0] : en[ 1] ? val[ 1] : en[ 2] ? val[ 2] : \
               en[ 3] ? val[ 3] : en[ 4] ? val[ 4] : en[ 5] ? val[ 5] : \
               en[ 6] ? val[ 6] : en[ 7] ? val[ 7] : en[ 8] ? val[ 8] : \
               en[ 9] ? val[ 9] : en[10] ? val[10] : en[11] ? val[11] : \
               en[12] ? val[12] : en[13] ? val[13] : en[14] ? val[14] : \
               en[15] ? val[15] : 0;

`endif  // OOPA_CPU_INCLUDE_UTIL_V_
