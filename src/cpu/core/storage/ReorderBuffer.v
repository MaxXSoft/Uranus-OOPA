`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "rob.v"

module ReorderBuffer(
  input                   clk,
  input                   rst,
  // read control
  input                   read_en,
  input                   read_head_en,
  output                  can_read,
  // write control
  input                   write_en,
  output                  can_write,
  // update control
  input                   update_en,
  input   [`ROB_ADDR_BUS] update_addr,
  // commit control
  input                   commit_en,
  output                  can_commit,
  // erase control
  input                   erase_en,
  input   [`ROB_ADDR_BUS] erase_from_addr,
  // input signals
  input                   done_in,
  input                   reg_write_en_in,
  input   [`REG_ADDR_BUS] reg_write_addr_in,
  input                   is_branch_taken_in,
  input   [`GHR_BUS]      pht_index_in,
  input                   is_inst_branch_in,
  input                   is_inst_jump_in,
  input                   is_inst_branch_taken_in,
  input                   is_inst_branch_determined_in,
  input   [`ADDR_BUS]     inst_branch_target_in,
  input                   is_delayslot_in,
  input                   mem_write_flag_in,
  input                   mem_read_flag_in,
  input                   mem_sign_ext_flag_in,
  input   [3:0]           mem_sel_in,
  input                   mem_write_is_ref_in,
  input   [`DATA_BUS]     mem_write_data_in,
  input   [`CP0_ADDR_BUS] cp0_addr_in,
  input                   cp0_read_flag_in,
  input                   cp0_write_flag_in,
  input                   cp0_write_is_ref_in,
  input   [`DATA_BUS]     cp0_write_data_in,
  input   [`EXC_TYPE_BUS] exception_type_in,
  input   [`FUNCT_BUS]    funct_in,
  input   [`SHAMT_BUS]    shamt_in,
  input                   operand_is_ref_1_in,
  input                   operand_is_ref_2_in,
  input   [`DATA_BUS]     operand_data_1_in,
  input   [`DATA_BUS]     operand_data_2_in,
  input   [`ADDR_BUS]     pc_in,
  // output signals
  output  [`ROB_ADDR_BUS] rob_addr_out,
  output                  done_out,
  output                  reg_write_en_out,
  output  [`REG_ADDR_BUS] reg_write_addr_out,
  output                  is_branch_taken_out,
  output  [`GHR_BUS]      pht_index_out,
  output                  is_inst_branch_out,
  output                  is_inst_jump_out,
  output                  is_inst_branch_taken_out,
  output                  is_inst_branch_determined_out,
  output  [`ADDR_BUS]     inst_branch_target_out,
  output                  is_delayslot_out,
  output                  mem_write_flag_out,
  output                  mem_read_flag_out,
  output                  mem_sign_ext_flag_out,
  output  [3:0]           mem_sel_out,
  output                  mem_write_is_ref_out,
  output  [`DATA_BUS]     mem_write_data_out,
  output  [`CP0_ADDR_BUS] cp0_addr_out,
  output                  cp0_read_flag_out,
  output                  cp0_write_flag_out,
  output                  cp0_write_is_ref_out,
  output  [`DATA_BUS]     cp0_write_data_out,
  output  [`EXC_TYPE_BUS] exception_type_out,
  output  [`FUNCT_BUS]    funct_out,
  output  [`SHAMT_BUS]    shamt_out,
  output                  operand_is_ref_1_out,
  output                  operand_is_ref_2_out,
  output  [`DATA_BUS]     operand_data_1_out,
  output  [`DATA_BUS]     operand_data_2_out,
  output  [`ADDR_BUS]     pc_out
);

  // output signals
  reg[`ROB_ADDR_BUS]  rob_addr_out;
  reg                 done_out;
  reg                 reg_write_en_out;
  reg[`REG_ADDR_BUS]  reg_write_addr_out;
  reg                 is_branch_taken_out;
  reg[`GHR_BUS]       pht_index_out;
  reg                 is_inst_branch_out;
  reg                 is_inst_jump_out;
  reg                 is_inst_branch_taken_out;
  reg                 is_inst_branch_determined_out;
  reg[`ADDR_BUS]      inst_branch_target_out;
  reg                 is_delayslot_out;
  reg                 mem_write_flag_out;
  reg                 mem_read_flag_out;
  reg                 mem_sign_ext_flag_out;
  reg[3:0]            mem_sel_out;
  reg                 mem_write_is_ref_out;
  reg[`DATA_BUS]      mem_write_data_out;
  reg[`CP0_ADDR_BUS]  cp0_addr_out;
  reg                 cp0_read_flag_out;
  reg                 cp0_write_flag_out;
  reg                 cp0_write_is_ref_out;
  reg[`DATA_BUS]      cp0_write_data_out;
  reg[`EXC_TYPE_BUS]  exception_type_out;
  reg[`FUNCT_BUS]     funct_out;
  reg[`SHAMT_BUS]     shamt_out;
  reg                 operand_is_ref_1_out;
  reg                 operand_is_ref_2_out;
  reg[`DATA_BUS]      operand_data_1_out;
  reg[`DATA_BUS]      operand_data_2_out;
  reg[`ADDR_BUS]      pc_out;

  // control signals of ROB lines
  wire                line_write_en[`ROB_SIZE - 1:0];
  wire                robl_done[`ROB_SIZE - 1:0];
  wire                robl_reg_write_en[`ROB_SIZE - 1:0];
  wire[`REG_ADDR_BUS] robl_reg_write_addr[`ROB_SIZE - 1:0];
  wire                robl_is_branch_taken[`ROB_SIZE - 1:0];
  wire[`GHR_BUS]      robl_pht_index[`ROB_SIZE - 1:0];
  wire                robl_is_inst_branch[`ROB_SIZE - 1:0];
  wire                robl_is_inst_jump[`ROB_SIZE - 1:0];
  wire                robl_is_inst_branch_taken[`ROB_SIZE - 1:0];
  wire                robl_is_inst_branch_determined[`ROB_SIZE - 1:0];
  wire[`ADDR_BUS]     robl_inst_branch_target[`ROB_SIZE - 1:0];
  wire                robl_is_delayslot[`ROB_SIZE - 1:0];
  wire                robl_mem_write_flag[`ROB_SIZE - 1:0];
  wire                robl_mem_read_flag[`ROB_SIZE - 1:0];
  wire                robl_mem_sign_ext_flag[`ROB_SIZE - 1:0];
  wire[3:0]           robl_mem_sel[`ROB_SIZE - 1:0];
  wire                robl_mem_write_is_ref[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_mem_write_data[`ROB_SIZE - 1:0];
  wire[`CP0_ADDR_BUS] robl_cp0_addr[`ROB_SIZE - 1:0];
  wire                robl_cp0_read_flag[`ROB_SIZE - 1:0];
  wire                robl_cp0_write_flag[`ROB_SIZE - 1:0];
  wire                robl_cp0_write_is_ref[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_cp0_write_data[`ROB_SIZE - 1:0];
  wire[`EXC_TYPE_BUS] robl_exception_type[`ROB_SIZE - 1:0];
  wire[`FUNCT_BUS]    robl_funct[`ROB_SIZE - 1:0];
  wire[`SHAMT_BUS]    robl_shamt[`ROB_SIZE - 1:0];
  wire                robl_operand_is_ref_1[`ROB_SIZE - 1:0];
  wire                robl_operand_is_ref_2[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_operand_data_1[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_operand_data_2[`ROB_SIZE - 1:0];
  wire[`ADDR_BUS]     robl_pc[`ROB_SIZE - 1:0];

  // generate ROB lines
  genvar i;
  generate
    for (i = 0; i < `ROB_SIZE; i = i + 1) begin
      ROBLine line(
        .clk                            (clk),
        .rst                            (rst),
        .write_en                       (line_write_en[i]),
        .done_in                        (done_in),
        .reg_write_en_in                (reg_write_en_in),
        .reg_write_addr_in              (reg_write_addr_in),
        .is_branch_taken_in             (is_branch_taken_in),
        .pht_index_in                   (pht_index_in),
        .is_inst_branch_in              (is_inst_branch_in),
        .is_inst_jump_in                (is_inst_jump_in),
        .is_inst_branch_taken_in        (is_inst_branch_taken_in),
        .is_inst_branch_determined_in   (is_inst_branch_determined_in),
        .inst_branch_target_in          (inst_branch_target_in),
        .is_delayslot_in                (is_delayslot_in),
        .mem_write_flag_in              (mem_write_flag_in),
        .mem_read_flag_in               (mem_read_flag_in),
        .mem_sign_ext_flag_in           (mem_sign_ext_flag_in),
        .mem_sel_in                     (mem_sel_in),
        .mem_write_is_ref_in            (mem_write_is_ref_in),
        .mem_write_data_in              (mem_write_data_in),
        .cp0_addr_in                    (cp0_addr_in),
        .cp0_read_flag_in               (cp0_read_flag_in),
        .cp0_write_flag_in              (cp0_write_flag_in),
        .cp0_write_is_ref_in            (cp0_write_is_ref_in),
        .cp0_write_data_in              (cp0_write_data_in),
        .exception_type_in              (exception_type_in),
        .funct_in                       (funct_in),
        .shamt_in                       (shamt_in),
        .operand_is_ref_1_in            (operand_is_ref_1_in),
        .operand_is_ref_2_in            (operand_is_ref_2_in),
        .operand_data_1_in              (operand_data_1_in),
        .operand_data_2_in              (operand_data_2_in),
        .pc_in                          (pc_in),
        .done_out                       (robl_done[i]),
        .reg_write_en_out               (robl_reg_write_en[i]),
        .reg_write_addr_out             (robl_reg_write_addr[i]),
        .is_branch_taken_out            (robl_is_branch_taken[i]),
        .pht_index_out                  (robl_pht_index[i]),
        .is_inst_branch_out             (robl_is_inst_branch[i]),
        .is_inst_jump_out               (robl_is_inst_jump[i]),
        .is_inst_branch_taken_out       (robl_is_inst_branch_taken[i]),
        .is_inst_branch_determined_out  (robl_is_inst_branch_determined[i]),
        .inst_branch_target_out         (robl_inst_branch_target[i]),
        .is_delayslot_out               (robl_is_delayslot[i]),
        .mem_write_flag_out             (robl_mem_write_flag[i]),
        .mem_read_flag_out              (robl_mem_read_flag[i]),
        .mem_sign_ext_flag_out          (robl_mem_sign_ext_flag[i]),
        .mem_sel_out                    (robl_mem_sel[i]),
        .mem_write_is_ref_out           (robl_mem_write_is_ref[i]),
        .mem_write_data_out             (robl_mem_write_data[i]),
        .cp0_addr_out                   (robl_cp0_addr[i]),
        .cp0_read_flag_out              (robl_cp0_read_flag[i]),
        .cp0_write_flag_out             (robl_cp0_write_flag[i]),
        .cp0_write_is_ref_out           (robl_cp0_write_is_ref[i]),
        .cp0_write_data_out             (robl_cp0_write_data[i]),
        .exception_type_out             (robl_exception_type[i]),
        .funct_out                      (robl_funct[i]),
        .shamt_out                      (robl_shamt[i]),
        .operand_is_ref_1_out           (robl_operand_is_ref_1[i]),
        .operand_is_ref_2_out           (robl_operand_is_ref_2[i]),
        .operand_data_1_out             (robl_operand_data_1[i]),
        .operand_data_2_out             (robl_operand_data_2[i]),
        .pc_out                         (robl_pc[i])
      );
    end
  endgenerate

  // pointers of FIFO
  reg[`ROB_ADDR_WIDTH:0] head_ptr, read_ptr, tail_ptr;

  // FIFO indicator
  wire foe_head = head_ptr[`ROB_ADDR_WIDTH - 1:0] == tail_ptr[`ROB_ADDR_WIDTH - 1:0];
  wire foe_read = read_ptr[`ROB_ADDR_WIDTH - 1:0] == tail_ptr[`ROB_ADDR_WIDTH - 1:0];
  assign can_read = !(foe_read && read_ptr == tail_ptr);
  assign can_write = !(foe_head && head_ptr != tail_ptr);
  assign can_commit = !(foe_head && head_ptr == tail_ptr) &&
                      robl_done[head_ptr[`ROB_ADDR_WIDTH - 1:0]];

  // ROB line selector
  // policy: write (rather than update) first, cannot write when erase
  generate
    for (i = 0; i < `ROB_SIZE; i = i + 1) begin
      assign line_write_en[i] =
          write_en && !erase_en ? tail_ptr[`ROB_ADDR_WIDTH - 1:0] == i :
          update_en ? update_addr == i : 0;
    end
  endgenerate

  // read from ROB
  always @(*) begin
    if (!rst) begin
      rob_addr_out <= 0;
      done_out <= 0;
      reg_write_en_out <= 0;
      reg_write_addr_out <= 0;
      is_branch_taken_out <= 0;
      pht_index_out <= 0;
      is_inst_branch_out <= 0;
      is_inst_jump_out <= 0;
      is_inst_branch_taken_out <= 0;
      is_inst_branch_determined_out <= 0;
      inst_branch_target_out <= 0;
      is_delayslot_out <= 0;
      mem_write_flag_out <= 0;
      mem_read_flag_out <= 0;
      mem_sign_ext_flag_out <= 0;
      mem_sel_out <= 0;
      mem_write_is_ref_out <= 0;
      mem_write_data_out <= 0;
      cp0_addr_out <= 0;
      cp0_read_flag_out <= 0;
      cp0_write_flag_out <= 0;
      cp0_write_is_ref_out <= 0;
      cp0_write_data_out <= 0;
      exception_type_out <= 0;
      funct_out <= 0;
      shamt_out <= 0;
      operand_is_ref_1_out <= 0;
      operand_is_ref_2_out <= 0;
      operand_data_1_out <= 0;
      operand_data_2_out <= 0;
      pc_out <= 0;
    end
    else if (read_en) begin
      rob_addr_out <= read_ptr[`ROB_ADDR_WIDTH - 1:0];
      done_out <= robl_done[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      reg_write_en_out <= robl_reg_write_en[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      reg_write_addr_out <= robl_reg_write_addr[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_branch_taken_out <= robl_is_branch_taken[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      pht_index_out <= robl_pht_index[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_branch_out <= robl_is_inst_branch[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_jump_out <= robl_is_inst_jump[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_branch_taken_out <= robl_is_inst_branch_taken[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_branch_determined_out <= robl_is_inst_branch_determined[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      inst_branch_target_out <= robl_inst_branch_target[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_delayslot_out <= robl_is_delayslot[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_write_flag_out <= robl_mem_write_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_read_flag_out <= robl_mem_read_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_sign_ext_flag_out <= robl_mem_sign_ext_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_sel_out <= robl_mem_sel[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_write_is_ref_out <= robl_mem_write_is_ref[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_write_data_out <= robl_mem_write_data[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_addr_out <= robl_cp0_addr[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_read_flag_out <= robl_cp0_read_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_write_flag_out <= robl_cp0_write_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_write_is_ref_out <= robl_cp0_write_is_ref[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_write_data_out <= robl_cp0_write_data[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      exception_type_out <= robl_exception_type[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      funct_out <= robl_funct[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      shamt_out <= robl_shamt[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_is_ref_1_out <= robl_operand_is_ref_1[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_is_ref_2_out <= robl_operand_is_ref_2[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_data_1_out <= robl_operand_data_1[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_data_2_out <= robl_operand_data_2[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      pc_out <= robl_pc[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
    end
    else if (read_head_en) begin
      rob_addr_out <= head_ptr[`ROB_ADDR_WIDTH - 1:0];
      done_out <= robl_done[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      reg_write_en_out <= robl_reg_write_en[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      reg_write_addr_out <= robl_reg_write_addr[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_branch_taken_out <= robl_is_branch_taken[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      pht_index_out <= robl_pht_index[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_branch_out <= robl_is_inst_branch[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_jump_out <= robl_is_inst_jump[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_branch_taken_out <= robl_is_inst_branch_taken[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_inst_branch_determined_out <= robl_is_inst_branch_determined[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      inst_branch_target_out <= robl_inst_branch_target[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      is_delayslot_out <= robl_is_delayslot[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_write_flag_out <= robl_mem_write_flag[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_read_flag_out <= robl_mem_read_flag[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_sign_ext_flag_out <= robl_mem_sign_ext_flag[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_sel_out <= robl_mem_sel[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_write_is_ref_out <= robl_mem_write_is_ref[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      mem_write_data_out <= robl_mem_write_data[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_addr_out <= robl_cp0_addr[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_read_flag_out <= robl_cp0_read_flag[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_write_flag_out <= robl_cp0_write_flag[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_write_is_ref_out <= robl_cp0_write_is_ref[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      cp0_write_data_out <= robl_cp0_write_data[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      exception_type_out <= robl_exception_type[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      funct_out <= robl_funct[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      shamt_out <= robl_shamt[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_is_ref_1_out <= robl_operand_is_ref_1[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_is_ref_2_out <= robl_operand_is_ref_2[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_data_1_out <= robl_operand_data_1[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      operand_data_2_out <= robl_operand_data_2[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      pc_out <= robl_pc[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
    end
    else begin
      done_out <= 0;
      reg_write_en_out <= 0;
      reg_write_addr_out <= 0;
      is_branch_taken_out <= 0;
      pht_index_out <= 0;
      is_inst_branch_out <= 0;
      is_inst_jump_out <= 0;
      is_inst_branch_taken_out <= 0;
      is_inst_branch_determined_out <= 0;
      inst_branch_target_out <= 0;
      is_delayslot_out <= 0;
      mem_write_flag_out <= 0;
      mem_read_flag_out <= 0;
      mem_sign_ext_flag_out <= 0;
      mem_sel_out <= 0;
      mem_write_is_ref_out <= 0;
      mem_write_data_out <= 0;
      cp0_addr_out <= 0;
      cp0_read_flag_out <= 0;
      cp0_write_flag_out <= 0;
      cp0_write_is_ref_out <= 0;
      cp0_write_data_out <= 0;
      exception_type_out <= 0;
      funct_out <= 0;
      shamt_out <= 0;
      operand_is_ref_1_out <= 0;
      operand_is_ref_2_out <= 0;
      operand_data_1_out <= 0;
      operand_data_2_out <= 0;
      pc_out <= 0;
    end
  end

  // update head pointer
  always @(posedge clk) begin
    if (!rst) begin
      head_ptr <= 0;
    end
    else if (commit_en) begin
      head_ptr <= head_ptr + 1;
    end
  end

  // update read pointer
  always @(posedge clk) begin
    if (!rst) begin
      read_ptr <= 0;
    end
    else if (read_en) begin
      read_ptr <= read_ptr + 1;
    end
  end

  // update tail pointer
  always @(posedge clk) begin
    if (!rst) begin
      tail_ptr <= 0;
    end
    else if (erase_en) begin
      tail_ptr <= {1'b0, erase_from_addr};
    end
    else if (write_en) begin
      tail_ptr <= tail_ptr + 1;
    end
  end

endmodule // ReorderBuffer
