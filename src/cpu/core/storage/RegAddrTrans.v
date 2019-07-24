`timescale 1ns / 1ps

`include "bus.v"
`include "regfile.v"
`include "cp0.v"

module RegAddrTrans(
  input rst,
  // regfile
  input                   reg_en,
  input   [`REG_ADDR_BUS] reg_addr,
  // hi & lo
  input                   hilo_en,
  input                   hilo_addr,
  // coprocessor 0
  input                   cp0_en,
  input   [`CP0_ADDR_BUS] cp0_addr,
  // output signals
  output                  rf_en,
  output  [`RF_ADDR_BUS]  rf_addr
);

  reg[`RF_ADDR_BUS]       rf_addr;
  assign rf_en = reg_en || hilo_en || cp0_en;

  always @(*) begin
    if (!rst) begin
      rf_addr <= 0;
    end
    else if (reg_en) begin
      rf_addr <= {1'b0, reg_addr};
    end
    else if (hilo_en) begin
      rf_addr <= hilo_addr == `HILO_REG_HI ? `RF_REG_HI : `RF_REG_LO;
    end
    else if (cp0_en) begin
      case (cp0_addr)
        `CP0_REG_BADVADDR: rf_addr <= `RF_REG_BADVADDR;
        `CP0_REG_COUNT: rf_addr <= `RF_REG_COUNT;
        `CP0_REG_COMPARE: rf_addr <= `RF_REG_COMPARE;
        `CP0_REG_STATUS: rf_addr <= `RF_REG_STATUS;
        `CP0_REG_CAUSE: rf_addr <= `RF_REG_CAUSE;
        `CP0_REG_EPC: rf_addr <= `RF_REG_EPC;
        `CP0_REG_PRID: rf_addr <= `RF_REG_PRID;
        `CP0_REG_EBASE: rf_addr <= `RF_REG_EBASE;
        `CP0_REG_CONFIG: rf_addr <= `RF_REG_CONFIG;
        default: rf_addr <= 0;
      endcase
    end
    else begin
      rf_addr <= 0;
    end
  end

endmodule // RegAddrTrans

