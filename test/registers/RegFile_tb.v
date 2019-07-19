`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "rob.v"

module RegFile_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg                 write_en;
  reg[`REG_ADDR_BUS]  write_addr;
  reg[`ROB_ADDR_BUS]  write_ref_id;
  reg                 commit_en;
  reg                 commit_restore;
  reg[`REG_ADDR_BUS]  commit_addr;
  reg[`DATA_BUS]      commit_data;
  reg                 read_en_1;
  reg                 read_en_2;
  reg[`REG_ADDR_BUS]  read_addr_1;
  reg[`REG_ADDR_BUS]  read_addr_2;

  // output signals
  wire                read_is_ref_1;
  wire                read_is_ref_2;
  wire[`DATA_BUS]     read_data_1;
  wire[`DATA_BUS]     read_data_2;

  RegFile regfile(
    .clk            (clk),
    .rst            (rst),
    .write_en       (write_en),
    .write_addr     (write_addr),
    .write_ref_id   (write_ref_id),
    .commit_en      (commit_en),
    .commit_restore (commit_restore),
    .commit_addr    (commit_addr),
    .commit_data    (commit_data),
    .read_en_1      (read_en_1),
    .read_en_2      (read_en_2),
    .read_addr_1    (read_addr_1),
    .read_addr_2    (read_addr_2),
    .read_is_ref_1  (read_is_ref_1),
    .read_is_ref_2  (read_is_ref_2),
    .read_data_1    (read_data_1),
    .read_data_2    (read_data_2)
  );

  always @(posedge clk) begin
    if (!rst) begin
      write_en <= 0;
      write_addr <= 0;
      write_ref_id <= 0;
      commit_en <= 0;
      commit_restore <= 0;
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
      read_addr_1 <= 1;
      read_addr_2 <= 2;

      case (`TICK)
        0: begin
          $display("commit value");
          write_en <= 0;
          write_addr <= 0;
          write_ref_id <= 0;
          commit_en <= 1;
          commit_restore <= 0;
          commit_addr <= 1;
          commit_data <= 32'h12345678;
        end
        1: begin
          $display("write ref id");
          write_en <= 1;
          write_addr <= 1;
          write_ref_id <= `ROB_ADDR_WIDTH'h0a;
          commit_en <= 0;
          commit_restore <= 0;
          commit_addr <= 0;
          commit_data <= 0;
        end
        2: begin
          $display("write and commit at same time");
          write_en <= 1;
          write_addr <= 2;
          write_ref_id <= `ROB_ADDR_WIDTH'h0f;
          commit_en <= 1;
          commit_restore <= 0;
          commit_addr <= 2;
          commit_data <= 32'habcdef00;
        end
        3: begin
          $display("restore value");
          write_en <= 0;
          write_addr <= 0;
          write_ref_id <= 0;
          commit_en <= 0;
          commit_restore <= 1;
          commit_addr <= 0;
          commit_data <= 0;
        end
      endcase
    end

    `DISPLAY("read_is_ref_1 ", read_is_ref_1);
    `DISPLAY("read_is_ref_2 ", read_is_ref_2);
    `DISPLAY("read_data_1   ", read_data_1);
    `DISPLAY("read_data_2   ", read_data_2);
    $display("");
    `END_AT_TICK(4);
  end

endmodule // RegFile_tb
