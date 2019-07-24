`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "regfile.v"
`include "exception.v"
`include "cp0.v"

// Register File
// including all resigters of MIPS ISA (general, hi/lo, cp0...)

module RegFile(
  input                   clk,
  input                   rst,
  // write channel #1
  input                   write_en,
  input   [`RF_ADDR_BUS]  write_addr,
  input   [`ROB_ADDR_BUS] write_ref_id,
  // write channel #2
  input                   write_lo_en,
  input   [`ROB_ADDR_BUS] write_lo_ref_id,
  // commit channel #1
  input                   commit_restore,
  input                   commit_add,
  input                   commit_en,
  input   [`RF_ADDR_BUS]  commit_addr,
  input   [`DATA_BUS]     commit_data,
  // commit channel #2
  input                   commit_lo_en,
  input   [`DATA_BUS]     commit_lo_data,
  // read channel (x2)
  input                   read_en_1,
  input                   read_en_2,
  input   [`RF_ADDR_BUS]  read_addr_1,
  input   [`RF_ADDR_BUS]  read_addr_2,
  output                  read_is_ref_1,
  output                  read_is_ref_2,
  output  [`DATA_BUS]     read_data_1,
  output  [`DATA_BUS]     read_data_2,
  // CP0 exception channel
  input   [4:0]           hard_int,
  input   [`ADDR_BUS]     badvaddr_data,
  input   [`EXC_TYPE_BUS] exception_type,
  input                   is_delayslot,
  input   [`ADDR_BUS]     current_pc,
  // CP0 output channel
  output  [`DATA_BUS]     cp0_status,
  output  [`DATA_BUS]     cp0_cause,
  output  [`DATA_BUS]     cp0_epc,
  output  [`DATA_BUS]     cp0_ebase
);

  // indicate whether current register stores RS/ROB id
  reg                 is_ref[`RF_COUNT - 1:0];
  // stores register value
  reg[`DATA_BUS]      reg_val[`RF_COUNT - 1:0];
  // stores RS/ROB id
  reg[`ROB_ADDR_BUS]  ref_id[`RF_COUNT - 1:0];
  // CP0 timer interrupt
  reg                 timer_int;

  // generate CP0 output
  assign cp0_status = reg_val[`RF_REG_STATUS];
  assign cp0_cause  = reg_val[`RF_REG_CAUSE];
  assign cp0_epc    = reg_val[`RF_REG_EPC];
  assign cp0_ebase  = reg_val[`RF_REG_EBASE];

  // exception PC
  wire[`DATA_BUS] exc_epc = is_delayslot ? current_pc - 4 : current_pc;

  // update 'is_ref'
  always @(posedge clk) begin
    if (!rst || commit_restore) begin
      integer i;
      for (i = 0; i < `RF_COUNT; i = i + 1) begin
        is_ref[i] <= 0;
      end
    end
    else begin
      // write channel #1
      if (write_en) begin
        is_ref[write_addr] <= 1;
      end
      if (commit_en && !(write_en && commit_addr == write_addr)) begin
        is_ref[commit_addr] <= 0;
      end
      // write channel #2
      if (write_lo_en) begin
        is_ref[`RF_REG_LO] <= 1;
      end
      if (commit_lo_en && !write_lo_en) begin
        is_ref[`RF_REG_LO] <= 0;
      end
    end
  end

  // update 'reg_val'
  always @(posedge clk) begin
    if (!rst) begin
      // initialize all non-CP0 registers
      integer i;
      for (i = 0; i < `RF_NON_CP0_COUNT; i = i + 1) begin
        reg_val[i] <= 0;
      end
      // initialize CP0 registers separately
      reg_val[`RF_REG_BADVADDR] <= `CP0_REG_BADVADDR_VALUE;
      reg_val[`RF_REG_COUNT] <= 0;
      reg_val[`RF_REG_COMPARE] <= 0;
      reg_val[`RF_REG_STATUS] <= `CP0_REG_STATUS_VALUE;
      reg_val[`RF_REG_CAUSE] <= `CP0_REG_CAUSE_VALUE;
      reg_val[`RF_REG_EPC] <= `CP0_REG_EPC_VALUE;
      reg_val[`RF_REG_PRID] <= `CP0_REG_PRID_VALUE;
      reg_val[`RF_REG_EBASE] <= `CP0_REG_EBASE_VALUE;
      reg_val[`RF_REG_CONFIG] <= `CP0_REG_CONFIG_VALUE;
      // initialize timer interrupt flag
      timer_int <= 0;
    end
    else begin
      // store the status of hardware interrupts
      reg_val[`RF_REG_CAUSE][`CP0_SEG_HWI] <= {timer_int, hard_int};

      // generate the timer interrupt
      reg_val[`RF_REG_COUNT] <= reg_val[`RF_REG_COUNT] + 1;
      if (|reg_val[`RF_REG_COMPARE] &&
          reg_val[`RF_REG_COUNT] == reg_val[`RF_REG_COMPARE]) begin
        timer_int <= 1;
      end

      // write data by exception info
      case (exception_type[`EXC_TYPE_POS_INT])
        `EXC_TYPE_INT: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_INT;
        end
        `EXC_TYPE_IF, `EXC_TYPE_ADEL: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_BADVADDR] <= badvaddr_data;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_ADEL;
        end
        `EXC_TYPE_RI: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_RI;
        end
        `EXC_TYPE_OV: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_OV;
        end
        `EXC_TYPE_BP: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_BP;
        end
        `EXC_TYPE_SYS: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_SYS;
        end
        `EXC_TYPE_ADES: begin
          reg_val[`RF_REG_EPC] <= exc_epc;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_BD] <= is_delayslot;
          reg_val[`RF_REG_BADVADDR] <= badvaddr_data;
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 1;
          reg_val[`RF_REG_CAUSE][`CP0_SEG_EXCCODE] <= `CP0_EXCCODE_ADES;
        end
        `EXC_TYPE_ERET: begin
          reg_val[`RF_REG_STATUS][`CP0_SEG_EXL] <= 0;
        end
        default:;
      endcase

      // write channel #1
      if (commit_en && |commit_addr) begin
        case (commit_addr)
          `RF_REG_COMPARE: begin
            reg_val[`RF_REG_COMPARE] <= commit_data;
            timer_int <= 0;
          end
          `RF_REG_STATUS: begin
            // allow writing BEV
            reg_val[`RF_REG_STATUS][22] <= commit_data[22];
            reg_val[`RF_REG_STATUS][15:8] <= commit_data[15:8];
            reg_val[`RF_REG_STATUS][1:0] <= commit_data[1:0];
          end
          `RF_REG_EBASE: begin
            reg_val[`RF_REG_EBASE][29:12] <= commit_data[29:12];
          end
          `RF_REG_CAUSE: begin
            reg_val[`RF_REG_CAUSE][9:8] <= commit_data[9:8];
          end
          default: begin
            if (commit_add) begin
              reg_val[commit_addr] <= reg_val[commit_addr] + commit_data;
            end
            else begin
              reg_val[commit_addr] <= commit_data;
            end
          end
        endcase
      end

      // write channel
      if (commit_lo_en) begin
        if (commit_add) begin
          reg_val[`RF_REG_LO] <= reg_val[`RF_REG_LO] + commit_lo_data;
        end
        else begin
          reg_val[`RF_REG_LO] <= commit_lo_data;
        end
      end
    end
  end

  // update 'ref_id'
  always @(posedge clk) begin
    if (!rst) begin
      integer i;
      for (i = 0; i < `RF_COUNT; i = i + 1) begin
        ref_id[i] <= 0;
      end
    end
    else begin
      if (write_en && |write_addr) begin
        ref_id[write_addr] <= write_ref_id;
      end
      if (write_lo_en) begin
        ref_id[`RF_REG_LO] <= write_lo_ref_id;
      end
    end
  end

  // read channel #1
  reg read_is_ref_1;
  reg[`DATA_BUS] read_data_1;

  always @(*) begin
    if (!rst) begin
      read_is_ref_1 <= 0;
      read_data_1 <= 0;
    end
    else if (read_en_1) begin
      if (commit_restore) begin
        // data forwarding
        read_is_ref_1 <= 0;
        read_data_1 <= reg_val[read_addr_1];
      end
      else if (write_en && read_addr_1 == write_addr) begin
        // data forwarding
        read_is_ref_1 <= 1;
        read_data_1 <= {
          {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
          write_ref_id
        };
      end
      else if (write_lo_en && read_addr_1 == `RF_REG_LO) begin
        // data forwarding
        read_is_ref_1 <= 1;
        read_data_1 <= {
          {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
          write_lo_ref_id
        };
      end
      else if (commit_en && read_addr_1 == commit_addr) begin
        // data forwarding
        read_is_ref_1 <= 0;
        if (commit_add) begin
          read_data_1 <= reg_val[commit_addr] + commit_data;
        end
        else begin
          read_data_1 <= commit_data;
        end
      end
      else if (commit_lo_en && read_addr_1 == `RF_REG_LO) begin
        // data forwarding
        read_is_ref_1 <= 0;
        if (commit_add) begin
          read_data_1 <= reg_val[`RF_REG_LO] + commit_lo_data;
        end
        else begin
          read_data_1 <= commit_lo_data;
        end
      end
      else begin
        read_is_ref_1 <= is_ref[read_addr_1];
        if (is_ref[read_addr_1]) begin
          read_data_1 <= {
            {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
            ref_id[read_addr_1]
          };
        end
        else begin
          read_data_1 <= reg_val[read_addr_1];
        end
      end
    end
    else begin
      read_is_ref_1 <= 0;
      read_data_1 <= 0;
    end
  end

  // read channel #2
  reg read_is_ref_2;
  reg[`DATA_BUS] read_data_2;

  always @(*) begin
    if (!rst) begin
      read_is_ref_2 <= 0;
      read_data_2 <= 0;
    end
    else if (read_en_2) begin
      if (commit_restore) begin
        // data forwarding
        read_is_ref_2 <= 0;
        read_data_2 <= reg_val[read_addr_2];
      end
      else if (write_en && read_addr_2 == write_addr) begin
        // data forwarding
        read_is_ref_2 <= 1;
        read_data_2 <= {
          {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
          write_ref_id
        };
      end
      else if (write_lo_en && read_addr_2 == `RF_REG_LO) begin
        // data forwarding
        read_is_ref_2 <= 1;
        read_data_2 <= {
          {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
          write_lo_ref_id
        };
      end
      else if (commit_en && read_addr_2 == commit_addr) begin
        // data forwarding
        read_is_ref_2 <= 0;
        if (commit_add) begin
          read_data_2 <= reg_val[commit_addr] + commit_data;
        end
        else begin
          read_data_2 <= commit_data;
        end
      end
      else if (commit_lo_en && read_addr_2 == `RF_REG_LO) begin
        // data forwarding
        read_is_ref_2 <= 0;
        if (commit_add) begin
          read_data_2 <= reg_val[`RF_REG_LO] + commit_lo_data;
        end
        else begin
          read_data_2 <= commit_lo_data;
        end
      end
      else begin
        read_is_ref_2 <= is_ref[read_addr_2];
        if (is_ref[read_addr_2]) begin
          read_data_2 <= {
            {(`DATA_BUS_WIDTH - `ROB_ADDR_WIDTH){1'b0}},
            ref_id[read_addr_2]
          };
        end
        else begin
          read_data_2 <= reg_val[read_addr_2];
        end
      end
    end
    else begin
      read_is_ref_2 <= 0;
      read_data_2 <= 0;
    end
  end

endmodule // RegFile
