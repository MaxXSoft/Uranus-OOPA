`ifndef OOPA_CPU_INCLUDE_REGFILE_V_
`define OOPA_CPU_INCLUDE_REGFILE_V_

// regfile address bus
`define RF_ADDR_BUS_WIDTH       6
`define RF_ADDR_BUS             `MAKE_BUS(`RF_ADDR_BUS_WIDTH)

// register count in regfile
`define RF_COUNT                43
`define RF_NON_CP0_COUNT        34

// hi & lo register address definitions
`define HILO_REG_HI             1'b0
`define HILO_REG_LO             1'b1

// regfile address definitions
`define RF_REG_HI               6'd32
`define RF_REG_LO               6'd33
`define RF_REG_BADVADDR         6'd34
`define RF_REG_COUNT            6'd35
`define RF_REG_COMPARE          6'd36
`define RF_REG_STATUS           6'd37
`define RF_REG_CAUSE            6'd38
`define RF_REG_EPC              6'd39
`define RF_REG_PRID             6'd40
`define RF_REG_EBASE            6'd41
`define RF_REG_CONFIG           6'd42

`endif  // OOPA_CPU_INCLUDE_REGFILE_V_
