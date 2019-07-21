`timescale 1ns / 1ps

`include "bus.v"
`include "branch.v"
`include "rob.v"
`include "opgen.v"

module ReorderBuffer(
  input                   clk,
  input                   rst,
  // read channel
  input                   read_en,
  output                  can_read,
  output  [`ROB_ADDR_BUS] read_rob_addr_out,
  // read data
  output                  read_is_branch_taken_out,
  output  [`GHR_BUS]      read_pht_index_out,
  output  [`ADDR_BUS]     read_inst_branch_target_out,
  output                  read_mem_write_flag_out,
  output                  read_mem_read_flag_out,
  output                  read_mem_sign_ext_flag_out,
  output  [3:0]           read_mem_sel_out,
  output  [`DATA_BUS]     read_mem_offset_out,
  output                  read_cp0_read_flag_out,
  output                  read_cp0_write_flag_out,
  output  [`CP0_ADDR_BUS] read_cp0_addr_out,
  output  [`EXC_TYPE_BUS] read_exception_type_out,
  output  [`OPGEN_BUS]    read_opgen_out,
  output  [`SHAMT_BUS]    read_shamt_out,
  output                  read_operand_is_ref_1_out,
  output                  read_operand_is_ref_2_out,
  output  [`DATA_BUS]     read_operand_data_1_out,
  output  [`DATA_BUS]     read_operand_data_2_out,
  output  [`ADDR_BUS]     read_pc_out,
  // write channel
  input                   write_en,
  output                  can_write,
  output  [`ROB_ADDR_BUS] write_rob_addr_out,
  // write data
  input                   write_reg_write_en_in,
  input   [`REG_ADDR_BUS] write_reg_write_addr_in,
  input                   write_is_branch_taken_in,
  input   [`GHR_BUS]      write_pht_index_in,
  input   [`ADDR_BUS]     write_inst_branch_target_in,
  input                   write_mem_write_flag_in,
  input                   write_mem_read_flag_in,
  input                   write_mem_sign_ext_flag_in,
  input   [3:0]           write_mem_sel_in,
  input   [`DATA_BUS]     write_mem_offset_in,
  input                   write_cp0_read_flag_in,
  input                   write_cp0_write_flag_in,
  input   [`CP0_ADDR_BUS] write_cp0_addr_in,
  input   [`EXC_TYPE_BUS] write_exception_type_in,
  input                   write_is_delayslot_in,
  input   [`OPGEN_BUS]    write_opgen_in,
  input   [`SHAMT_BUS]    write_shamt_in,
  input                   write_operand_is_ref_1_in,
  input                   write_operand_is_ref_2_in,
  input   [`DATA_BUS]     write_operand_data_1_in,
  input   [`DATA_BUS]     write_operand_data_2_in,
  input   [`ADDR_BUS]     write_pc_in,
  // update channel
  input                   update_en,
  input   [`ROB_ADDR_BUS] update_addr,
  // update data
  input   [`DATA_BUS]     update_reg_write_data_in,
  input   [`EXC_TYPE_BUS] update_exception_type_in,
  // commit channel
  input                   commit_en,
  output                  can_commit,
  // commit data
  output                  commit_reg_write_en_out,
  output  [`REG_ADDR_BUS] commit_reg_write_addr_out,
  output  [`DATA_BUS]     commit_reg_write_data_out,
  output  [`EXC_TYPE_BUS] commit_exception_type_out,
  output                  commit_is_delayslot_out,
  // erase channel
  input                   erase_en,
  input   [`ROB_ADDR_BUS] erase_from_addr
);

  // output signals
  reg[`ROB_ADDR_BUS]  read_rob_addr_out;
  reg                 read_is_branch_taken_out;
  reg[`GHR_BUS]       read_pht_index_out;
  reg[`ADDR_BUS]      read_inst_branch_target_out;
  reg                 read_mem_write_flag_out;
  reg                 read_mem_read_flag_out;
  reg                 read_mem_sign_ext_flag_out;
  reg[3:0]            read_mem_sel_out;
  reg[`DATA_BUS]      read_mem_offset_out;
  reg                 read_cp0_read_flag_out;
  reg                 read_cp0_write_flag_out;
  reg[`CP0_ADDR_BUS]  read_cp0_addr_out;
  reg[`EXC_TYPE_BUS]  read_exception_type_out;
  reg[`OPGEN_BUS]     read_opgen_out;
  reg[`SHAMT_BUS]     read_shamt_out;
  reg                 read_operand_is_ref_1_out;
  reg                 read_operand_is_ref_2_out;
  reg[`DATA_BUS]      read_operand_data_1_out;
  reg[`DATA_BUS]      read_operand_data_2_out;
  reg[`ADDR_BUS]      read_pc_out;
  reg                 commit_reg_write_en_out;
  reg[`REG_ADDR_BUS]  commit_reg_write_addr_out;
  reg[`DATA_BUS]      commit_reg_write_data_out;
  reg[`EXC_TYPE_BUS]  commit_exception_type_out;
  reg                 commit_is_delayslot_out;

  // control signals of ROB lines
  wire                line_write_en[`ROB_SIZE - 1:0];
  wire                line_update_en[`ROB_SIZE - 1:0];
  wire                robl_done[`ROB_SIZE - 1:0];
  wire                robl_reg_write_en[`ROB_SIZE - 1:0];
  wire[`REG_ADDR_BUS] robl_reg_write_addr[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_reg_write_data[`ROB_SIZE - 1:0];
  wire                robl_is_branch_taken[`ROB_SIZE - 1:0];
  wire[`GHR_BUS]      robl_pht_index[`ROB_SIZE - 1:0];
  wire[`ADDR_BUS]     robl_inst_branch_target[`ROB_SIZE - 1:0];
  wire                robl_mem_write_flag[`ROB_SIZE - 1:0];
  wire                robl_mem_read_flag[`ROB_SIZE - 1:0];
  wire                robl_mem_sign_ext_flag[`ROB_SIZE - 1:0];
  wire[3:0]           robl_mem_sel[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_mem_offset[`ROB_SIZE - 1:0];
  wire                robl_cp0_read_flag[`ROB_SIZE - 1:0];
  wire                robl_cp0_write_flag[`ROB_SIZE - 1:0];
  wire[`CP0_ADDR_BUS] robl_cp0_addr[`ROB_SIZE - 1:0];
  wire[`EXC_TYPE_BUS] robl_exception_type[`ROB_SIZE - 1:0];
  wire                robl_is_delayslot[`ROB_SIZE - 1:0];
  wire[`OPGEN_BUS]    robl_opgen[`ROB_SIZE - 1:0];
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
        .clk                          (clk),
        .rst                          (rst),
        .write_en                     (line_write_en[i]),
        .write_reg_write_en_in        (write_reg_write_en_in),
        .write_reg_write_addr_in      (write_reg_write_addr_in),
        .write_is_branch_taken_in     (write_is_branch_taken_in),
        .write_pht_index_in           (write_pht_index_in),
        .write_inst_branch_target_in  (write_inst_branch_target_in),
        .write_mem_write_flag_in      (write_mem_write_flag_in),
        .write_mem_read_flag_in       (write_mem_read_flag_in),
        .write_mem_sign_ext_flag_in   (write_mem_sign_ext_flag_in),
        .write_mem_sel_in             (write_mem_sel_in),
        .write_mem_offset_in          (write_mem_offset_in),
        .write_cp0_read_flag_in       (write_cp0_read_flag_in),
        .write_cp0_write_flag_in      (write_cp0_write_flag_in),
        .write_cp0_addr_in            (write_cp0_addr_in),
        .write_exception_type_in      (write_exception_type_in),
        .write_is_delayslot_in        (write_is_delayslot_in),
        .write_opgen_in               (write_opgen_in),
        .write_shamt_in               (write_shamt_in),
        .write_operand_is_ref_1_in    (write_operand_is_ref_1_in),
        .write_operand_is_ref_2_in    (write_operand_is_ref_2_in),
        .write_operand_data_1_in      (write_operand_data_1_in),
        .write_operand_data_2_in      (write_operand_data_2_in),
        .write_pc_in                  (write_pc_in),
        .update_en                    (line_update_en[i]),
        .update_reg_write_data_in     (update_reg_write_data_in),
        .update_exception_type_in     (update_exception_type_in),
        .done_out                     (robl_done[i]),
        .reg_write_en_out             (robl_reg_write_en[i]),
        .reg_write_addr_out           (robl_reg_write_addr[i]),
        .reg_write_data_out           (robl_reg_write_data[i]),
        .is_branch_taken_out          (robl_is_branch_taken[i]),
        .pht_index_out                (robl_pht_index[i]),
        .inst_branch_target_out       (robl_inst_branch_target[i]),
        .mem_write_flag_out           (robl_mem_write_flag[i]),
        .mem_read_flag_out            (robl_mem_read_flag[i]),
        .mem_sign_ext_flag_out        (robl_mem_sign_ext_flag[i]),
        .mem_sel_out                  (robl_mem_sel[i]),
        .mem_offset_out               (robl_mem_offset[i]),
        .cp0_read_flag_out            (robl_cp0_read_flag[i]),
        .cp0_write_flag_out           (robl_cp0_write_flag[i]),
        .cp0_addr_out                 (robl_cp0_addr[i]),
        .exception_type_out           (robl_exception_type[i]),
        .is_delayslot_out             (robl_is_delayslot[i]),
        .opgen_out                    (robl_opgen[i]),
        .shamt_out                    (robl_shamt[i]),
        .operand_is_ref_1_out         (robl_operand_is_ref_1[i]),
        .operand_is_ref_2_out         (robl_operand_is_ref_2[i]),
        .operand_data_1_out           (robl_operand_data_1[i]),
        .operand_data_2_out           (robl_operand_data_2[i]),
        .pc_out                       (robl_pc[i])
      );
    end
  endgenerate

  // pointers of FIFO
  reg[`ROB_ADDR_WIDTH:0] head_ptr, read_ptr, tail_ptr;
  wire[`ROB_ADDR_WIDTH:0] head_ptr_fwd, read_ptr_fwd, tail_ptr_fwd;
  assign head_ptr_fwd = commit_en ? head_ptr + 1 : head_ptr;
  assign read_ptr_fwd = read_en ? read_ptr + 1 : read_ptr;
  assign tail_ptr_fwd = erase_en ? {1'b0, erase_from_addr} :
                        write_en ? tail_ptr + 1 : tail_ptr;

  // output of write ROB address
  assign write_rob_addr_out = tail_ptr_fwd[`ROB_ADDR_WIDTH - 1:0];

  // FIFO indicator
  wire foe_head = head_ptr_fwd[`ROB_ADDR_WIDTH - 1:0] == tail_ptr_fwd[`ROB_ADDR_WIDTH - 1:0];
  wire foe_read = read_ptr_fwd[`ROB_ADDR_WIDTH - 1:0] == tail_ptr_fwd[`ROB_ADDR_WIDTH - 1:0];
  wire robl_done_fwd = update_en && head_ptr[`ROB_ADDR_WIDTH - 1:0] == update_addr ?
      1 : robl_done[head_ptr_fwd[`ROB_ADDR_WIDTH - 1:0]];
  assign can_read = !(foe_read && read_ptr_fwd == tail_ptr_fwd);
  assign can_write = !(foe_head && head_ptr_fwd != tail_ptr_fwd);
  assign can_commit = !(foe_head && head_ptr_fwd == tail_ptr_fwd) && robl_done_fwd;

  // ROB line write enable
  // policy: cannot write when erase
  generate
    for (i = 0; i < `ROB_SIZE; i = i + 1) begin
      assign line_write_en[i] = write_en && !erase_en ?
          tail_ptr[`ROB_ADDR_WIDTH - 1:0] == i : 0;
    end
  endgenerate

  // ROB line update enable
  generate
    for (i = 0; i < `ROB_SIZE; i = i + 1) begin
      assign line_update_en[i] = update_en ? update_addr == i : 0;
    end
  endgenerate

  // generate output signals of read channel
  always @(*) begin
    if (!rst) begin
      read_rob_addr_out <= 0;
      read_is_branch_taken_out <= 0;
      read_pht_index_out <= 0;
      read_inst_branch_target_out <= 0;
      read_mem_write_flag_out <= 0;
      read_mem_read_flag_out <= 0;
      read_mem_sign_ext_flag_out <= 0;
      read_mem_sel_out <= 0;
      read_mem_offset_out <= 0;
      read_cp0_read_flag_out <= 0;
      read_cp0_write_flag_out <= 0;
      read_cp0_addr_out <= 0;
      read_exception_type_out <= 0;
      read_opgen_out <= 0;
      read_shamt_out <= 0;
      read_operand_is_ref_1_out <= 0;
      read_operand_is_ref_2_out <= 0;
      read_operand_data_1_out <= 0;
      read_operand_data_2_out <= 0;
      read_pc_out <= 0;
    end
    else if (read_en) begin
      read_rob_addr_out <= read_ptr[`ROB_ADDR_WIDTH - 1:0];
      if (write_en && !erase_en && read_ptr[`ROB_ADDR_WIDTH - 1:0] ==
                                   tail_ptr[`ROB_ADDR_WIDTH - 1:0]) begin
        // data forwarding
        read_is_branch_taken_out <= write_is_branch_taken_in;
        read_pht_index_out <= write_pht_index_in;
        read_inst_branch_target_out <= write_inst_branch_target_in;
        read_mem_write_flag_out <= write_mem_write_flag_in;
        read_mem_read_flag_out <= write_mem_read_flag_in;
        read_mem_sign_ext_flag_out <= write_mem_sign_ext_flag_in;
        read_mem_sel_out <= write_mem_sel_in;
        read_mem_offset_out <= write_mem_offset_in;
        read_cp0_read_flag_out <= write_cp0_read_flag_in;
        read_cp0_write_flag_out <= write_cp0_write_flag_in;
        read_cp0_addr_out <= write_cp0_addr_in;
        read_exception_type_out <= write_exception_type_in;
        read_opgen_out <= write_opgen_in;
        read_shamt_out <= write_shamt_in;
        read_operand_is_ref_1_out <= write_operand_is_ref_1_in;
        read_operand_is_ref_2_out <= write_operand_is_ref_2_in;
        read_operand_data_1_out <= write_operand_data_1_in;
        read_operand_data_2_out <= write_operand_data_2_in;
        read_pc_out <= write_pc_in;
      end
      else begin
        read_is_branch_taken_out <= robl_is_branch_taken[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_pht_index_out <= robl_pht_index[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_inst_branch_target_out <= robl_inst_branch_target[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_mem_write_flag_out <= robl_mem_write_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_mem_read_flag_out <= robl_mem_read_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_mem_sign_ext_flag_out <= robl_mem_sign_ext_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_mem_sel_out <= robl_mem_sel[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_mem_offset_out <= robl_mem_offset[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_cp0_read_flag_out <= robl_cp0_read_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_cp0_write_flag_out <= robl_cp0_write_flag[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_cp0_addr_out <= robl_cp0_addr[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_exception_type_out <= robl_exception_type[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_opgen_out <= robl_opgen[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_shamt_out <= robl_shamt[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_operand_is_ref_1_out <= robl_operand_is_ref_1[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_operand_is_ref_2_out <= robl_operand_is_ref_2[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_operand_data_1_out <= robl_operand_data_1[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_operand_data_2_out <= robl_operand_data_2[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
        read_pc_out <= robl_pc[read_ptr[`ROB_ADDR_WIDTH - 1:0]];
      end
    end
  end

  // generate output signals of commit channel
  always @(*) begin
    if (!rst) begin
      commit_reg_write_en_out <= 0;
      commit_reg_write_addr_out <= 0;
      commit_reg_write_data_out <= 0;
      commit_exception_type_out <= 0;
      commit_is_delayslot_out <= 0;
    end
    else if (commit_en) begin
      commit_reg_write_en_out <= robl_reg_write_en[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_reg_write_addr_out <= robl_reg_write_addr[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_is_delayslot_out <= robl_is_delayslot[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      if (update_en && head_ptr[`ROB_ADDR_WIDTH - 1:0] == update_addr) begin
        // data forwarding
        commit_reg_write_data_out <= update_reg_write_data_in;
        commit_exception_type_out <= update_exception_type_in;
      end
      else begin
        commit_reg_write_data_out <= robl_reg_write_data[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
        commit_exception_type_out <= robl_exception_type[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      end
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
