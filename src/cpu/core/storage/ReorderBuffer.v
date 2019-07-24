`timescale 1ns / 1ps

`include "bus.v"
`include "rob.v"
`include "regfile.v"

module ReorderBuffer(
  input                   clk,
  input                   rst,
  // write channel
  input                   write_en,
  output                  can_write,
  output  [`ROB_ADDR_BUS] write_rob_addr_out,
  // write data
  input                   write_reg_write_add_in,
  input                   write_reg_write_en_in,
  input   [`RF_ADDR_BUS]  write_reg_write_addr_in,
  input                   write_reg_write_lo_en_in,
  input   [`EXC_TYPE_BUS] write_exception_type_in,
  input                   write_is_delayslot_in,
  input   [`ADDR_BUS]     write_pc_in,
  // update channel
  input                   update_en,
  input   [`ROB_ADDR_BUS] update_addr,
  // update data
  input   [`DATA_BUS]     update_reg_write_data_in,
  input   [`DATA_BUS]     update_reg_write_lo_data_in,
  input   [`EXC_TYPE_BUS] update_exception_type_in,
  // commit channel
  input                   commit_en,
  output                  can_commit,
  // commit data
  output                  commit_reg_write_add_out,
  output                  commit_reg_write_en_out,
  output  [`RF_ADDR_BUS]  commit_reg_write_addr_out,
  output  [`DATA_BUS]     commit_reg_write_data_out,
  output                  commit_reg_write_lo_en_out,
  output  [`DATA_BUS]     commit_reg_write_lo_data_out,
  output  [`EXC_TYPE_BUS] commit_exception_type_out,
  output                  commit_is_delayslot_out,
  output  [`ADDR_BUS]     commit_pc_out,
  // erase channel
  input                   erase_en,
  input   [`ROB_ADDR_BUS] erase_from_addr
);

  // output signals
  reg                 commit_reg_write_add_out;
  reg                 commit_reg_write_en_out;
  reg[`RF_ADDR_BUS]   commit_reg_write_addr_out;
  reg[`DATA_BUS]      commit_reg_write_data_out;
  reg                 commit_reg_write_lo_en_out;
  reg[`DATA_BUS]      commit_reg_write_lo_data_out;
  reg[`EXC_TYPE_BUS]  commit_exception_type_out;
  reg                 commit_is_delayslot_out;
  reg[`ADDR_BUS]      commit_pc_out;

  // control signals of ROB lines
  wire                line_write_en[`ROB_SIZE - 1:0];
  wire                line_update_en[`ROB_SIZE - 1:0];
  wire                robl_done[`ROB_SIZE - 1:0];
  wire                robl_reg_write_add[`ROB_SIZE - 1:0];
  wire                robl_reg_write_en[`ROB_SIZE - 1:0];
  wire[`RF_ADDR_BUS]  robl_reg_write_addr[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_reg_write_data[`ROB_SIZE - 1:0];
  wire                robl_reg_write_lo_en[`ROB_SIZE - 1:0];
  wire[`DATA_BUS]     robl_reg_write_lo_data[`ROB_SIZE - 1:0];
  wire[`EXC_TYPE_BUS] robl_exception_type[`ROB_SIZE - 1:0];
  wire                robl_is_delayslot[`ROB_SIZE - 1:0];
  wire[`ADDR_BUS]     robl_pc[`ROB_SIZE - 1:0];

  // generate ROB lines
  genvar i;
  generate
    for (i = 0; i < `ROB_SIZE; i = i + 1) begin
      ROBLine line(
        .clk                          (clk),
        .rst                          (rst),

        .write_en                     (line_write_en[i]),
        .write_reg_write_add_in       (write_reg_write_add_in),
        .write_reg_write_en_in        (write_reg_write_en_in),
        .write_reg_write_addr_in      (write_reg_write_addr_in),
        .write_reg_write_lo_en_in     (write_reg_write_lo_en_in),
        .write_exception_type_in      (write_exception_type_in),
        .write_is_delayslot_in        (write_is_delayslot_in),
        .write_pc_in                  (write_pc_in),

        .update_en                    (line_update_en[i]),
        .update_reg_write_data_in     (update_reg_write_data_in),
        .update_reg_write_lo_data_in  (update_reg_write_lo_data_in),
        .update_exception_type_in     (update_exception_type_in),

        .done_out                     (robl_done[i]),
        .reg_write_add_out            (robl_reg_write_add[i]),
        .reg_write_en_out             (robl_reg_write_en[i]),
        .reg_write_addr_out           (robl_reg_write_addr[i]),
        .reg_write_data_out           (robl_reg_write_data[i]),
        .reg_write_lo_en_out          (robl_reg_write_lo_en[i]),
        .reg_write_lo_data_out        (robl_reg_write_lo_data[i]),
        .exception_type_out           (robl_exception_type[i]),
        .is_delayslot_out             (robl_is_delayslot[i]),
        .pc_out                       (robl_pc[i])
      );
    end
  endgenerate

  // pointers of FIFO
  reg[`ROB_ADDR_WIDTH:0] head_ptr, tail_ptr;
  wire[`ROB_ADDR_WIDTH:0] head_ptr_fwd, tail_ptr_fwd;
  assign head_ptr_fwd = commit_en ? head_ptr + 1 : head_ptr;
  assign tail_ptr_fwd = erase_en ? {1'b0, erase_from_addr} :
                        write_en ? tail_ptr + 1 : tail_ptr;

  // output of write ROB address
  assign write_rob_addr_out = tail_ptr_fwd[`ROB_ADDR_WIDTH - 1:0];

  // FIFO indicator
  wire foe_head = head_ptr_fwd[`ROB_ADDR_WIDTH - 1:0] == tail_ptr_fwd[`ROB_ADDR_WIDTH - 1:0];
  wire robl_done_fwd = update_en && head_ptr_fwd[`ROB_ADDR_WIDTH - 1:0] == update_addr ?
      1 : robl_done[head_ptr_fwd[`ROB_ADDR_WIDTH - 1:0]];
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

  // generate output signals of commit channel
  always @(*) begin
    if (!rst) begin
      commit_reg_write_add_out <= 0;
      commit_reg_write_en_out <= 0;
      commit_reg_write_addr_out <= 0;
      commit_reg_write_data_out <= 0;
      commit_reg_write_lo_en_out <= 0;
      commit_reg_write_lo_data_out <= 0;
      commit_exception_type_out <= 0;
      commit_is_delayslot_out <= 0;
      commit_pc_out <= 0;
    end
    else begin
      commit_reg_write_add_out <= robl_reg_write_add[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_reg_write_en_out <= robl_reg_write_en[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_reg_write_addr_out <= robl_reg_write_addr[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_reg_write_lo_en_out <= robl_reg_write_lo_en[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_is_delayslot_out <= robl_is_delayslot[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      commit_pc_out <= robl_pc[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
      if (update_en && head_ptr[`ROB_ADDR_WIDTH - 1:0] == update_addr) begin
        // data forwarding
        commit_reg_write_data_out <= update_reg_write_data_in;
        commit_reg_write_lo_data_out <= update_reg_write_lo_data_in;
        commit_exception_type_out <= update_exception_type_in;
      end
      else begin
        commit_reg_write_data_out <= robl_reg_write_data[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
        commit_reg_write_lo_data_out <= robl_reg_write_lo_data[head_ptr[`ROB_ADDR_WIDTH - 1:0]];
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
