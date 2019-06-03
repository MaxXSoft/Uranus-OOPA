`ifndef OOPA_CPU_INCLUDE_BUS_V_
`define OOPA_CPU_INCLUDE_BUS_V_

`include "util.v"

// address bus
`define ADDR_BUS_WIDTH          32
`define ADDR_BUS                `MAKE_BUS(`ADDR_BUS_WIDTH)

// instruction bus
`define INST_BUS_WIDTH          32
`define INST_BUS                `MAKE_BUS(`INST_BUS_WIDTH)

// data bus
`define DATA_BUS_WIDTH          32
`define DATA_BUS                `MAKE_BUS(`DATA_BUS_WIDTH)

// double size data bus
`define DOUBLE_DATA_BUS_WIDTH   64
`define DOUBLE_DATA_BUS         `MAKE_BUS(`DOUBLE_DATA_BUS_WIDTH)

// half size data bus
`define HALF_DATA_BUS_WIDTH     16
`define HALF_DATA_BUS           `MAKE_BUS(`HALF_DATA_BUS_WIDTH)

// coprocessor address bus
`define CP0_ADDR_BUS_WIDTH      8
`define CP0_ADDR_BUS            `MAKE_BUS(`CP0_ADDR_BUS_WIDTH)

// register bus
`define REG_ADDR_BUS_WIDTH      5
`define REG_ADDR_BUS            `MAKE_BUS(`REG_ADDR_BUS_WIDTH)

// instruction information bus
`define INST_OP_BUS_WIDTH       6
`define INST_OP_BUS             `MAKE_BUS(`INST_OP_BUS_WIDTH)
`define FUNCT_BUS_WIDTH         6
`define FUNCT_BUS               `MAKE_BUS(`FUNCT_BUS_WIDTH)
`define SHAMT_BUS_WIDTH         5
`define SHAMT_BUS               `MAKE_BUS(`SHAMT_BUS_WIDTH)

`endif  // OOPA_CPU_INCLUDE_BUS_V_
