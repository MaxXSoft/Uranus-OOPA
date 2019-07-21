`timescale 1ns / 1ps

`include "tb.v"
`include "bus.v"
`include "branch.v"
`include "opgen.v"

module ID_tb(
  input clk,
  input rst
);

  // generate tick counter
  `GEN_TICK(clk, rst);

  reg[`ADDR_BUS]      pc;
  reg[`INST_BUS]      inst;

  // output signals of ID
  wire                id_reg_read_en_1;
  wire                id_reg_read_en_2;
  wire[`REG_ADDR_BUS] id_reg_read_addr_1;
  wire[`REG_ADDR_BUS] id_reg_read_addr_2;
  wire                id_reg_write_en;
  wire[`REG_ADDR_BUS] id_reg_write_addr;
  wire                id_is_branch_taken;
  wire[`GHR_BUS]      id_pht_index;
  wire[`ADDR_BUS]     id_inst_branch_target;
  wire                id_mem_write_flag;
  wire                id_mem_read_flag;
  wire                id_mem_sign_ext_flag;
  wire[3:0]           id_mem_sel;
  wire[`DATA_BUS]     id_mem_offset;
  wire                id_cp0_read_flag;
  wire                id_cp0_write_flag;
  wire[`CP0_ADDR_BUS] id_cp0_addr;
  wire[`EXC_TYPE_BUS] id_exception_type;
  wire                id_is_next_delayslot;
  wire                id_is_delayslot;
  wire[`OPGEN_BUS]    id_opgen;
  wire[`SHAMT_BUS]    id_shamt;
  wire                id_operand_is_ref_1;
  wire                id_operand_is_ref_2;
  wire[`DATA_BUS]     id_operand_data_1;
  wire[`DATA_BUS]     id_operand_data_2;
  wire[`ADDR_BUS]     id_pc;

  // output signals of IDROB
  wire                idrob_reg_write_en;
  wire[`REG_ADDR_BUS] idrob_reg_write_addr;
  wire                idrob_is_branch_taken;
  wire[`GHR_BUS]      idrob_pht_index;
  wire[`ADDR_BUS]     idrob_inst_branch_target;
  wire                idrob_mem_write_flag;
  wire                idrob_mem_read_flag;
  wire                idrob_mem_sign_ext_flag;
  wire[3:0]           idrob_mem_sel;
  wire[`DATA_BUS]     idrob_mem_offset;
  wire                idrob_cp0_read_flag;
  wire                idrob_cp0_write_flag;
  wire[`CP0_ADDR_BUS] idrob_cp0_addr;
  wire[`EXC_TYPE_BUS] idrob_exception_type;
  wire                idrob_is_current_delayslot;
  wire                idrob_is_delayslot;
  wire[`OPGEN_BUS]    idrob_opgen;
  wire[`SHAMT_BUS]    idrob_shamt;
  wire                idrob_operand_is_ref_1;
  wire                idrob_operand_is_ref_2;
  wire[`DATA_BUS]     idrob_operand_data_1;
  wire[`DATA_BUS]     idrob_operand_data_2;
  wire[`ADDR_BUS]     idrob_pc;

  ID id(
    .rst                      (rst),

    .is_branch_taken_in       (0),
    .pht_index_in             (0),
    .pc_in                    (pc),
    .inst_in                  (inst),

    .is_current_delayslot     (idrob_is_current_delayslot),

    .reg_read_is_ref_1        (0),
    .reg_read_is_ref_2        (0),
    .reg_read_data_1          (32'h12345678),
    .reg_read_data_2          (32'habcdef00),
    .reg_read_en_1            (id_reg_read_en_1),
    .reg_read_en_2            (id_reg_read_en_2),
    .reg_read_addr_1          (id_reg_read_addr_1),
    .reg_read_addr_2          (id_reg_read_addr_2),

    .reg_write_en             (id_reg_write_en),
    .reg_write_addr           (id_reg_write_addr),

    .is_branch_taken_out      (id_is_branch_taken),
    .pht_index_out            (id_pht_index),
    .inst_branch_target       (id_inst_branch_target),

    .mem_write_flag           (id_mem_write_flag),
    .mem_read_flag            (id_mem_read_flag),
    .mem_sign_ext_flag        (id_mem_sign_ext_flag),
    .mem_sel                  (id_mem_sel),
    .mem_offset               (id_mem_offset),

    .cp0_read_flag            (id_cp0_read_flag),
    .cp0_write_flag           (id_cp0_write_flag),
    .cp0_addr                 (id_cp0_addr),

    .exception_type           (id_exception_type),
    .is_next_delayslot        (id_is_next_delayslot),
    .is_delayslot             (id_is_delayslot),

    .opgen                    (id_opgen),
    .shamt                    (id_shamt),
    .operand_is_ref_1         (id_operand_is_ref_1),
    .operand_is_ref_2         (id_operand_is_ref_2),
    .operand_data_1           (id_operand_data_1),
    .operand_data_2           (id_operand_data_2),
    .pc_out                   (id_pc)
  );

  IDROB idrob(
    .clk                      (clk),
    .rst                      (rst),
    .flush                    (0),
    .stall_current_stage      (0),
    .stall_next_stage         (0),

    .reg_write_en_in          (id_reg_write_en),
    .reg_write_addr_in        (id_reg_write_addr),
    .is_branch_taken_in       (id_is_branch_taken),
    .pht_index_in             (id_pht_index),
    .inst_branch_target_in    (id_inst_branch_target),
    .mem_write_flag_in        (id_mem_write_flag),
    .mem_read_flag_in         (id_mem_read_flag),
    .mem_sign_ext_flag_in     (id_mem_sign_ext_flag),
    .mem_sel_in               (id_mem_sel),
    .mem_offset_in            (id_mem_offset),
    .cp0_read_flag_in         (id_cp0_read_flag),
    .cp0_write_flag_in        (id_cp0_write_flag),
    .cp0_addr_in              (id_cp0_addr),
    .exception_type_in        (id_exception_type),
    .is_next_delayslot_in     (id_is_next_delayslot),
    .is_delayslot_in          (id_is_delayslot),
    .opgen_in                 (id_opgen),
    .shamt_in                 (id_shamt),
    .operand_is_ref_1_in      (id_operand_is_ref_1),
    .operand_is_ref_2_in      (id_operand_is_ref_2),
    .operand_data_1_in        (id_operand_data_1),
    .operand_data_2_in        (id_operand_data_2),
    .pc_in                    (id_pc),

    .reg_write_en_out         (idrob_reg_write_en),
    .reg_write_addr_out       (idrob_reg_write_addr),
    .is_branch_taken_out      (idrob_is_branch_taken),
    .pht_index_out            (idrob_pht_index),
    .inst_branch_target_out   (idrob_inst_branch_target),
    .mem_write_flag_out       (idrob_mem_write_flag),
    .mem_read_flag_out        (idrob_mem_read_flag),
    .mem_sign_ext_flag_out    (idrob_mem_sign_ext_flag),
    .mem_sel_out              (idrob_mem_sel),
    .mem_offset_out           (idrob_mem_offset),
    .cp0_read_flag_out        (idrob_cp0_read_flag),
    .cp0_write_flag_out       (idrob_cp0_write_flag),
    .cp0_addr_out             (idrob_cp0_addr),
    .exception_type_out       (idrob_exception_type),
    .is_current_delayslot_out (idrob_is_current_delayslot),
    .is_delayslot_out         (idrob_is_delayslot),
    .opgen_out                (idrob_opgen),
    .shamt_out                (idrob_shamt),
    .operand_is_ref_1_out     (idrob_operand_is_ref_1),
    .operand_is_ref_2_out     (idrob_operand_is_ref_2),
    .operand_data_1_out       (idrob_operand_data_1),
    .operand_data_2_out       (idrob_operand_data_2),
    .pc_out                   (idrob_pc)
  );

  always @(posedge clk) begin
    if (!rst) begin
      pc <= 0;
      inst <= 0;
    end
    else begin
      case (`TICK)
        0: begin
          pc    <= 32'hbfc00000;
          inst  <= 32'h90001234;
        end
        1: begin
          pc    <= 32'hbfc00004;
          inst  <= 32'hac001234;
        end
        2: begin
          pc    <= 32'hbfc00008;
          inst  <= 32'h0c123456;
        end
        3: begin
          pc    <= 32'hbfc0000c;
          inst  <= 32'h00005009;
        end
        4: begin
          pc    <= 32'hbfc00010;
          inst  <= 32'h14001234;
        end
        5: begin
          pc    <= 32'hbfc00014;
          inst  <= 32'h40005005;
        end
        6: begin
          pc    <= 32'hbfc00018;
          inst  <= 32'h40805005;
        end
        7: begin
          pc    <= 32'hbfc0001c;
          inst  <= 32'h2000cdef;
        end
        8: begin
          pc    <= 32'hbfc00020;
          inst  <= 32'h2408cdef;
        end
        9: begin
          pc    <= 32'hbfc00024;
          inst  <= 32'hffffffff;
        end
      endcase

      case (idrob_pc)
        32'hbfc00000: $display(">>>>> LBU");
        32'hbfc00004: $display(">>>>> SW");
        32'hbfc00008: $display(">>>>> JAL");
        32'hbfc0000c: $display(">>>>> JALR");
        32'hbfc00010: $display(">>>>> BNE");
        32'hbfc00014: $display(">>>>> MFC0");
        32'hbfc00018: $display(">>>>> MTC0");
        32'hbfc0001c: $display(">>>>> ADDI");
        32'hbfc00020: $display(">>>>> ADDIU");
        32'hbfc00024: $display(">>>>> invalid instruction");
      endcase

    end

    $display("regfile writer");
    `DISPLAY("reg_write_en      ", idrob_reg_write_en);
    `DISPLAY("reg_write_addr    ", idrob_reg_write_addr);
    $display("branch info (from decoder)");
    `DISPLAY("inst_target       ", idrob_inst_branch_target);
    $display("memory accessing info");
    `DISPLAY("mem_write_flag    ", idrob_mem_write_flag);
    `DISPLAY("mem_read_flag     ", idrob_mem_read_flag);
    `DISPLAY("mem_sign_ext_flag ", idrob_mem_sign_ext_flag);
    `DISPLAY("mem_sel           ", idrob_mem_sel);
    `DISPLAY("mem_offset        ", idrob_mem_offset);
    $display("CP0 info");
    `DISPLAY("cp0_read_flag     ", idrob_cp0_read_flag);
    `DISPLAY("cp0_write_flag    ", idrob_cp0_write_flag);
    `DISPLAY("cp0_addr          ", idrob_cp0_addr);
    $display("exception info");
    `DISPLAY("exception_type    ", idrob_exception_type);
    `DISPLAY("is_delayslot      ", idrob_is_delayslot);
    $display("to ROB stage");
    `DISPLAY("opgen             ", idrob_opgen);
    `DISPLAY("shamt             ", idrob_shamt);
    `DISPLAY("operand_is_ref_1  ", idrob_operand_is_ref_1);
    `DISPLAY("operand_is_ref_2  ", idrob_operand_is_ref_2);
    `DISPLAY("operand_data_1    ", idrob_operand_data_1);
    `DISPLAY("operand_data_2    ", idrob_operand_data_2);
    `DISPLAY("pc                ", idrob_pc);
    $display("");

    `END_AT_TICK(11);
  end

endmodule // ID_tb
