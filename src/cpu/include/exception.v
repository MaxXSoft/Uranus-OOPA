`ifndef OOPA_CPU_INCLUDE_EXCEPTION_V_
`define OOPA_CPU_INCLUDE_EXCEPTION_V_

// exception entrance
`define INIT_PC             32'hbfc00000
`define EXC_BASE            32'hbfc00200
`define EXC_OFFSET          32'h00000180

// invalid PC value in order to invalidate PC stage
`define INVALID_PC        32'hffffffff

`endif  // OOPA_CPU_INCLUDE_EXCEPTION_V_
