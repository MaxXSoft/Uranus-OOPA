`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "branch.v"
`include "rob.v"

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
  reg                 done;
  reg[`ADDR_BUS]      pc;

  // output signals
  wire                can_read;
  wire                can_write;
  wire                can_commit;
  wire[`ROB_ADDR_BUS] rob_addr_out;
  wire                done_out;
  wire                reg_write_en_out;
  wire[`REG_ADDR_BUS] reg_write_addr_out;
  wire                is_branch_taken_out;
  wire[`GHR_BUS]      pht_index_out;
  wire                is_inst_branch_out;
  wire                is_inst_jump_out;
  wire                is_inst_branch_taken_out;
  wire                is_inst_branch_determined_out;
  wire[`ADDR_BUS]     inst_branch_target_out;
  wire                is_delayslot_out;
  wire                mem_write_flag_out;
  wire                mem_read_flag_out;
  wire                mem_sign_ext_flag_out;
  wire[3:0]           mem_sel_out;
  wire                mem_write_is_ref_out;
  wire[`DATA_BUS]     mem_write_data_out;
  wire[`CP0_ADDR_BUS] cp0_addr_out;
  wire                cp0_read_flag_out;
  wire                cp0_write_flag_out;
  wire                cp0_write_is_ref_out;
  wire[`DATA_BUS]     cp0_write_data_out;
  wire[`EXC_TYPE_BUS] exception_type_out;
  wire[`FUNCT_BUS]    funct_out;
  wire[`SHAMT_BUS]    shamt_out;
  wire                operand_is_ref_1_out;
  wire                operand_is_ref_2_out;
  wire[`DATA_BUS]     operand_data_1_out;
  wire[`DATA_BUS]     operand_data_2_out;
  wire[`ADDR_BUS]     pc_out;

  ReorderBuffer reorder_buffer(
    .clk                            (clk),
    .rst                            (rst),
    .read_en                        (read_en),
    .can_read                       (can_read),
    .write_en                       (write_en),
    .can_write                      (can_write),
    .update_en                      (update_en),
    .update_addr                    (update_addr),
    .commit_en                      (commit_en),
    .can_commit                     (can_commit),
    .erase_en                       (erase_en),
    .erase_from_addr                (erase_from_addr),
    .done_in                        (done),
    .reg_write_en_in                (0),
    .reg_write_addr_in              (0),
    .is_branch_taken_in             (0),
    .pht_index_in                   (0),
    .is_inst_branch_in              (0),
    .is_inst_jump_in                (0),
    .is_inst_branch_taken_in        (0),
    .is_inst_branch_determined_in   (0),
    .inst_branch_target_in          (0),
    .is_delayslot_in                (0),
    .mem_write_flag_in              (0),
    .mem_read_flag_in               (0),
    .mem_sign_ext_flag_in           (0),
    .mem_sel_in                     (0),
    .mem_write_is_ref_in            (0),
    .mem_write_data_in              (0),
    .cp0_addr_in                    (0),
    .cp0_read_flag_in               (0),
    .cp0_write_flag_in              (0),
    .cp0_write_is_ref_in            (0),
    .cp0_write_data_in              (0),
    .exception_type_in              (0),
    .funct_in                       (0),
    .shamt_in                       (0),
    .operand_is_ref_1_in            (0),
    .operand_is_ref_2_in            (0),
    .operand_data_1_in              (0),
    .operand_data_2_in              (0),
    .pc_in                          (pc),
    .rob_addr_out                   (rob_addr_out),
    .done_out                       (done_out),
    .reg_write_en_out               (reg_write_en_out),
    .reg_write_addr_out             (reg_write_addr_out),
    .is_branch_taken_out            (is_branch_taken_out),
    .pht_index_out                  (pht_index_out),
    .is_inst_branch_out             (is_inst_branch_out),
    .is_inst_jump_out               (is_inst_jump_out),
    .is_inst_branch_taken_out       (is_inst_branch_taken_out),
    .is_inst_branch_determined_out  (is_inst_branch_determined_out),
    .inst_branch_target_out         (inst_branch_target_out),
    .is_delayslot_out               (is_delayslot_out),
    .mem_write_flag_out             (mem_write_flag_out),
    .mem_read_flag_out              (mem_read_flag_out),
    .mem_sign_ext_flag_out          (mem_sign_ext_flag_out),
    .mem_sel_out                    (mem_sel_out),
    .mem_write_is_ref_out           (mem_write_is_ref_out),
    .mem_write_data_out             (mem_write_data_out),
    .cp0_addr_out                   (cp0_addr_out),
    .cp0_read_flag_out              (cp0_read_flag_out),
    .cp0_write_flag_out             (cp0_write_flag_out),
    .cp0_write_is_ref_out           (cp0_write_is_ref_out),
    .cp0_write_data_out             (cp0_write_data_out),
    .exception_type_out             (exception_type_out),
    .funct_out                      (funct_out),
    .shamt_out                      (shamt_out),
    .operand_is_ref_1_out           (operand_is_ref_1_out),
    .operand_is_ref_2_out           (operand_is_ref_2_out),
    .operand_data_1_out             (operand_data_1_out),
    .operand_data_2_out             (operand_data_2_out),
    .pc_out                         (pc_out)
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
      done <= 0;
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
          done <= 0;
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
          done <= 0;
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
          done <= 0;
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
          done <= 1;
        end
        4: begin
          $display(">>>>>> commit");
          read_en <= 0;
          write_en <= 0;
          update_en <= 0;
          update_addr <= 0;
          commit_en <= 1;
          erase_en <= 0;
          erase_from_addr <= 0;
          done <= 0;
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
          done <= 0;
        end
      endcase
      
    `DISPLAY("can_read      ", can_read);
    `DISPLAY("can_write     ", can_write);
    `DISPLAY("can_commit    ", can_commit);
    `DISPLAY("rob_addr_out  ", rob_addr_out);
    `DISPLAY("pc            ", pc);
    `DISPLAY("pc_out        ", pc_out);
    $display("");
    `END_AT_TICK(6);
    end
  end

endmodule // ReorderBuffer_tb
