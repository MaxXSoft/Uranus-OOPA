`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "rob.v"

module ReorderBuffer_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg                 write_en;
  reg                 update_en;
  reg[`ROB_ADDR_BUS]  update_addr;
  reg                 commit_en;
  reg                 erase_en;
  reg[`ROB_ADDR_BUS]  erase_from_addr;
  reg[`ADDR_BUS]      pc;

  // output signals
  wire                can_write;
  wire[`ROB_ADDR_BUS] write_rob_addr_out;
  wire                can_commit;
  wire                commit_reg_write_en_out;
  wire[`REG_ADDR_BUS] commit_reg_write_addr_out;
  wire[`DATA_BUS]     commit_reg_write_data_out;
  wire[`EXC_TYPE_BUS] commit_exception_type_out;
  wire                commit_is_delayslot_out;
  wire[`ADDR_BUS]     commit_pc_out;

  ReorderBuffer reorder_buffer(
    .clk                          (clk),
    .rst                          (rst),

    .write_en                     (write_en),
    .can_write                    (can_write),
    .write_rob_addr_out           (write_rob_addr_out),
    .write_reg_write_en_in        (0),
    .write_reg_write_addr_in      (0),
    .write_exception_type_in      (0),
    .write_is_delayslot_in        (0),
    .write_pc_in                  (pc),

    .update_en                    (update_en),
    .update_addr                  (update_addr),
    .update_reg_write_data_in     (0),
    .update_exception_type_in     (0),

    .commit_en                    (commit_en),
    .can_commit                   (can_commit),
    .commit_reg_write_en_out      (commit_reg_write_en_out),
    .commit_reg_write_addr_out    (commit_reg_write_addr_out),
    .commit_reg_write_data_out    (commit_reg_write_data_out),
    .commit_exception_type_out    (commit_exception_type_out),
    .commit_is_delayslot_out      (commit_is_delayslot_out),
    .commit_pc_out                (commit_pc_out),

    .erase_en                     (erase_en),
    .erase_from_addr              (erase_from_addr)
  );

  always @(posedge clk) begin
    if (!rst) begin
      write_en <= 0;
      update_en <= 0;
      update_addr <= 0;
      commit_en <= 0;
      erase_en <= 0;
      erase_from_addr <= 0;
      pc <= 32'hbfc00000;
    end
    else begin
      pc <= pc + 4;
      
      case (`TICK)
        0: begin
          $display(">>>>>> write");
          write_en <= 1;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        1: begin
          $display(">>>>>> write");
          write_en <= 1;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        2: begin
          $display(">>>>>> update");
          write_en <= 0;
          update_en <= 1;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        3: begin
          $display(">>>>>> write, update, commit");
          write_en <= 1;
          update_en <= 1;
          update_addr <= 1;
          commit_en <= 1;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        4: begin
          $display(">>>>>> erase");
          write_en <= 0;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 1;
          erase_from_addr <= 1;
        end
      endcase
      
    `DISPLAY("can_write           ", can_write);
    `DISPLAY("can_commit          ", can_commit);
    `DISPLAY("write_rob_addr_out  ", write_rob_addr_out);
    `DISPLAY("pc                  ", pc);
    `DISPLAY("commit_pc_out       ", commit_pc_out);
    $display("");
    `END_AT_TICK(5);
    end
  end

endmodule // ReorderBuffer_tb
