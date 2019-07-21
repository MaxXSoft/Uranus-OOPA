`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "branch.v"
`include "rob.v"
`include "opgen.v"

module ReorderBuffer_tb(
  input clk,
  input rst
);

  `GEN_TICK(clk, rst);

  // input signals
  reg                 read_en;
  reg                 write_en;
  reg                 update_en;
  reg[`ROB_ADDR_BUS]  update_addr;
  reg                 commit_en;
  reg                 erase_en;
  reg[`ROB_ADDR_BUS]  erase_from_addr;
  reg[`ADDR_BUS]      pc;

  // output signals
  wire                can_read;
  wire[`ROB_ADDR_BUS] read_rob_addr_out;
  wire                read_is_branch_taken_out;
  wire[`GHR_BUS]      read_pht_index_out;
  wire[`ADDR_BUS]     read_inst_branch_target_out;
  wire                read_mem_write_flag_out;
  wire                read_mem_read_flag_out;
  wire                read_mem_sign_ext_flag_out;
  wire[3:0]           read_mem_sel_out;
  wire[`DATA_BUS]     read_mem_offset_out;
  wire                read_cp0_read_flag_out;
  wire                read_cp0_write_flag_out;
  wire[`CP0_ADDR_BUS] read_cp0_addr_out;
  wire[`EXC_TYPE_BUS] read_exception_type_out;
  wire[`OPGEN_BUS]    read_opgen_out;
  wire[`SHAMT_BUS]    read_shamt_out;
  wire                read_operand_is_ref_1_out;
  wire                read_operand_is_ref_2_out;
  wire[`DATA_BUS]     read_operand_data_1_out;
  wire[`DATA_BUS]     read_operand_data_2_out;
  wire[`ADDR_BUS]     read_pc_out;
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

    .read_en                      (read_en),
    .can_read                     (can_read),
    .read_rob_addr_out            (read_rob_addr_out),
    .read_is_branch_taken_out     (read_is_branch_taken_out),
    .read_pht_index_out           (read_pht_index_out),
    .read_inst_branch_target_out  (read_inst_branch_target_out),
    .read_mem_write_flag_out      (read_mem_write_flag_out),
    .read_mem_read_flag_out       (read_mem_read_flag_out),
    .read_mem_sign_ext_flag_out   (read_mem_sign_ext_flag_out),
    .read_mem_sel_out             (read_mem_sel_out),
    .read_mem_offset_out          (read_mem_offset_out),
    .read_cp0_read_flag_out       (read_cp0_read_flag_out),
    .read_cp0_write_flag_out      (read_cp0_write_flag_out),
    .read_cp0_addr_out            (read_cp0_addr_out),
    .read_exception_type_out      (read_exception_type_out),
    .read_opgen_out               (read_opgen_out),
    .read_shamt_out               (read_shamt_out),
    .read_operand_is_ref_1_out    (read_operand_is_ref_1_out),
    .read_operand_is_ref_2_out    (read_operand_is_ref_2_out),
    .read_operand_data_1_out      (read_operand_data_1_out),
    .read_operand_data_2_out      (read_operand_data_2_out),
    .read_pc_out                  (read_pc_out),

    .write_en                     (write_en),
    .can_write                    (can_write),
    .write_rob_addr_out           (write_rob_addr_out),
    .write_reg_write_en_in        (0),
    .write_reg_write_addr_in      (0),
    .write_is_branch_taken_in     (0),
    .write_pht_index_in           (0),
    .write_inst_branch_target_in  (0),
    .write_mem_write_flag_in      (0),
    .write_mem_read_flag_in       (0),
    .write_mem_sign_ext_flag_in   (0),
    .write_mem_sel_in             (0),
    .write_mem_offset_in          (0),
    .write_cp0_read_flag_in       (0),
    .write_cp0_write_flag_in      (0),
    .write_cp0_addr_in            (0),
    .write_exception_type_in      (0),
    .write_is_delayslot_in        (0),
    .write_opgen_in               (0),
    .write_shamt_in               (0),
    .write_operand_is_ref_1_in    (0),
    .write_operand_is_ref_2_in    (0),
    .write_operand_data_1_in      (0),
    .write_operand_data_2_in      (0),
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
      read_en <= 0;
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
          read_en <= 0;
          write_en <= 1;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        1: begin
          $display(">>>>>> write");
          read_en <= 0;
          write_en <= 1;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        2: begin
          $display(">>>>>> read");
          read_en <= 1;
          write_en <= 0;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        3: begin
          $display(">>>>>> update");
          read_en <= 0;
          write_en <= 0;
          update_en <= 1;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        4: begin
          $display(">>>>>> read, write, update, commit");
          read_en <= 1;
          write_en <= 1;
          update_en <= 1;
          update_addr <= 1;
          commit_en <= 1;
          erase_en <= 0;
          erase_from_addr <= 0;
        end
        5: begin
          $display(">>>>>> erase");
          read_en <= 0;
          write_en <= 0;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 0;
          erase_en <= 1;
          erase_from_addr <= 1;
        end
      endcase
      
    `DISPLAY("can_read            ", can_read);
    `DISPLAY("can_write           ", can_write);
    `DISPLAY("can_commit          ", can_commit);
    `DISPLAY("read_rob_addr_out   ", read_rob_addr_out);
    `DISPLAY("write_rob_addr_out  ", write_rob_addr_out);
    `DISPLAY("pc                  ", pc);
    `DISPLAY("read_pc_out         ", read_pc_out);
    `DISPLAY("commit_pc_out       ", commit_pc_out);
    $display("");
    `END_AT_TICK(6);
    end
  end

endmodule // ReorderBuffer_tb
