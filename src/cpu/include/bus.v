// address bus
`define ADDR_BUS_WIDTH          32
`define ADDR_BUS                (`ADDR_BUS_WIDTH) - 1:0

// instruction bus
`define INST_BUS_WIDTH          32
`define INST_BUS                (`INST_BUS_WIDTH) - 1:0

// data bus
`define DATA_BUS_WIDTH          32
`define DATA_BUS                (`DATA_BUS_WIDTH) - 1:0

// double size data bus
`define DOUBLE_DATA_BUS_WIDTH   64
`define DOUBLE_DATA_BUS         (`DOUBLE_DATA_BUS_WIDTH) - 1:0

// half size data bus
`define HALF_DATA_BUS_WIDTH     16
`define HALF_DATA_BUS           (`HALF_DATA_BUS_WIDTH) - 1:0

// coprocessor address bus
`define CP0_ADDR_BUS_WIDTH      8
`define CP0_ADDR_BUS            (`CP0_ADDR_BUS_WIDTH) - 1:0

// register bus
`define REG_ADDR_BUS_WIDTH      5
`define REG_ADDR_BUS            (`REG_ADDR_BUS_WIDTH) - 1:0

// instruction information bus
`define INST_OP_BUS_WIDTH       6
`define INST_OP_BUS             (`INST_OP_BUS_WIDTH) - 1:0
`define FUNCT_BUS_WIDTH         6
`define FUNCT_BUS               (`FUNCT_BUS_WIDTH) - 1:0
`define SHAMT_BUS_WIDTH         5
`define SHAMT_BUS               (`SHAMT_BUS_WIDTH) - 1:0
