`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "rob.v"
`include "regfile.v"
`include "exception.v"

module RegFile_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg                 write_en;
  reg[`RF_ADDR_BUS]   write_addr;
  reg[`ROB_ADDR_BUS]  write_ref_id;
  reg                 commit_restore;
  reg                 commit_add;
  reg                 commit_en;
  reg[`RF_ADDR_BUS]   commit_addr;
  reg[`DATA_BUS]      commit_data;
  reg                 read_en_1;
  reg                 read_en_2;
  reg[`RF_ADDR_BUS]   read_addr_1;
  reg[`RF_ADDR_BUS]   read_addr_2;

  // output signals
  wire                read_is_ref_1;
  wire                read_is_ref_2;
  wire[`DATA_BUS]     read_data_1;
  wire[`DATA_BUS]     read_data_2;
  wire[`DATA_BUS]     cp0_status;
  wire[`DATA_BUS]     cp0_cause;
  wire[`DATA_BUS]     cp0_epc;
  wire[`DATA_BUS]     cp0_ebase;

  RegFile regfile(
    .clk              (clk),
    .rst              (rst),

    .write_en         (write_en),
    .write_addr       (write_addr),
    .write_ref_id     (write_ref_id),

    .write_lo_en      (0),
    .write_lo_ref_id  (0),

    .commit_restore   (commit_restore),
    .commit_add       (commit_add),
    .commit_en        (commit_en),
    .commit_addr      (commit_addr),
    .commit_data      (commit_data),

    .commit_lo_en     (1),
    .commit_lo_data   (1),

    .read_en_1        (read_en_1),
    .read_en_2        (read_en_2),
    .read_addr_1      (read_addr_1),
    .read_addr_2      (read_addr_2),
    .read_is_ref_1    (read_is_ref_1),
    .read_is_ref_2    (read_is_ref_2),
    .read_data_1      (read_data_1),
    .read_data_2      (read_data_2),

    .hard_int         (0),
    .badvaddr_data    (0),
    .exception_type   (0),
    .is_delayslot     (0),
    .current_pc       (0),

    .cp0_status       (cp0_status),
    .cp0_cause        (cp0_cause),
    .cp0_epc          (cp0_epc),
    .cp0_ebase        (cp0_ebase)
  );

  always @(posedge clk) begin
    if (!rst) begin
      write_en <= 0;
      write_addr <= 0;
      write_ref_id <= 0;
      commit_restore <= 0;
      commit_add <= 0;
      commit_en <= 0;
      commit_addr <= 0;
      commit_data <= 0;
      read_en_1 <= 0;
      read_en_2 <= 0;
      read_addr_1 <= 0;
      read_addr_2 <= 0;
    end
    else begin
      read_en_1 <= 1;
      read_en_2 <= 1;

      case (`TICK)
        0: begin
          $display("commit value");
          read_addr_1 <= 1;
          read_addr_2 <= 2;
          write_en <= 0;
          write_addr <= 0;
          write_ref_id <= 0;
          commit_restore <= 0;
          commit_add <= 0;
          commit_en <= 1;
          commit_addr <= 1;
          commit_data <= 32'h12345678;
        end
        1: begin
          $display("write ref id");
          read_addr_1 <= 1;
          read_addr_2 <= 2;
          write_en <= 1;
          write_addr <= 1;
          write_ref_id <= `ROB_ADDR_WIDTH'h0a;
          commit_restore <= 0;
          commit_add <= 0;
          commit_en <= 0;
          commit_addr <= 0;
          commit_data <= 0;
        end
        2: begin
          $display("write and commit at same time");
          read_addr_1 <= 1;
          read_addr_2 <= 2;
          write_en <= 1;
          write_addr <= 2;
          write_ref_id <= `ROB_ADDR_WIDTH'h0f;
          commit_restore <= 0;
          commit_add <= 0;
          commit_en <= 1;
          commit_addr <= 2;
          commit_data <= 32'habcdef00;
        end
        3: begin
          $display("restore value");
          read_addr_1 <= 1;
          read_addr_2 <= 2;
          write_en <= 0;
          write_addr <= 0;
          write_ref_id <= 0;
          commit_restore <= 1;
          commit_add <= 0;
          commit_en <= 0;
          commit_addr <= 0;
          commit_data <= 0;
        end
        4: begin
          $display("read and commit hi/lo");
          read_addr_1 <= `RF_REG_HI;
          read_addr_2 <= `RF_REG_LO;
          write_en <= 0;
          write_addr <= 0;
          write_ref_id <= 0;
          commit_restore <= 0;
          commit_add <= 1;
          commit_en <= 1;
          commit_addr <= `RF_REG_HI;
          commit_data <= 32'h10203040;
        end
      endcase
    end

    `DISPLAY("read_is_ref_1 ", read_is_ref_1);
    `DISPLAY("read_is_ref_2 ", read_is_ref_2);
    `DISPLAY("read_data_1   ", read_data_1);
    `DISPLAY("read_data_2   ", read_data_2);
    `DISPLAY("cp0_status    ", cp0_status);
    `DISPLAY("cp0_cause     ", cp0_cause);
    `DISPLAY("cp0_epc       ", cp0_epc);
    `DISPLAY("cp0_ebase     ", cp0_ebase);
    $display("");
    `END_AT_TICK(5);
  end

endmodule // RegFile_tb
