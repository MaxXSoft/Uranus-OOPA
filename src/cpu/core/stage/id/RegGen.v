`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "regimm.v"
`include "cp0.v"
`include "regfile.v"

module RegGen(
  input                     rst,
  // instruction info
  input   [`INST_OP_BUS]    op,
  input   [`REG_ADDR_BUS]   rs,
  input   [`REG_ADDR_BUS]   rt,
  input   [`REG_ADDR_BUS]   rd,
  input   [`SHAMT_BUS]      shamt,
  input   [`FUNCT_BUS]      funct,
  input   [`HALF_DATA_BUS]  imm,
  input   [`CP0_SEL_BUS]    sel,
  input                     is_cp0,
  // regfile read & write
  input                     reg_read_is_ref_1,
  input                     reg_read_is_ref_2,
  input   [`DATA_BUS]       reg_read_data_1,
  input   [`DATA_BUS]       reg_read_data_2,
  output                    reg_read_en_1,
  output                    reg_read_en_2,
  output  [`RF_ADDR_BUS]    reg_read_addr_1,
  output  [`RF_ADDR_BUS]    reg_read_addr_2,
  output                    reg_write_add,
  output                    reg_write_en,
  output  [`RF_ADDR_BUS]    reg_write_addr,
  output                    reg_write_lo_en,
  // operands output
  output                    operand_is_ref_1,
  output                    operand_is_ref_2,
  output  [`DATA_BUS]       operand_data_1,
  output  [`DATA_BUS]       operand_data_2
);

  reg operand_is_ref_1, operand_is_ref_2;
  reg[`DATA_BUS] operand_data_1, operand_data_2;

  // information about immediate number
  wire[`DATA_BUS] zero_extended_imm = {16'b0, imm};
  wire[`DATA_BUS] zero_extended_imm_hi = {imm, 16'b0};
  wire[`DATA_BUS] sign_extended_imm = {{16{imm[15]}}, imm};

  // register file read address translation
  reg read_reg_en_1, read_reg_en_2;
  reg[`REG_ADDR_BUS] read_reg_addr_1, read_reg_addr_2;
  reg read_hilo_en, read_hilo_addr;
  reg read_cp0_en;
  reg[`CP0_ADDR_BUS] read_cp0_addr;

  assign reg_read_en_2 = read_reg_en_2;
  assign reg_read_addr_2 = {
    {(`RF_ADDR_BUS_WIDTH - `REG_ADDR_BUS_WIDTH){1'b0}},
    read_reg_addr_2
  };

  RegAddrTrans reg_addr_trans_read(
    .rst        (rst),
    .reg_en     (read_reg_en_1),
    .reg_addr   (read_reg_addr_1),
    .hilo_en    (read_hilo_en),
    .hilo_addr  (read_hilo_addr),
    .cp0_en     (read_cp0_en),
    .cp0_addr   (read_cp0_addr),
    .rf_en      (reg_read_en_1),
    .rf_addr    (reg_read_addr_1)
  );

  // generate address of registers to be read
  always @(*) begin
    if (!rst) begin
      read_reg_en_1 <= 0;
      read_reg_en_2 <= 0;
      read_reg_addr_1 <= 0;
      read_reg_addr_2 <= 0;
      read_hilo_en <= 0;
      read_hilo_addr <= 0;
      read_cp0_en <= 0;
      read_cp0_addr <= 0;
    end
    else begin
      case (op)
        // r-type 1
        `OP_SPECIAL: begin
          case (funct)
            `FUNCT_MFHI: begin
              read_reg_en_1 <= 0;
              read_reg_en_2 <= 0;
              read_reg_addr_1 <= 0;
              read_reg_addr_2 <= 0;
              read_hilo_en <= 1;
              read_hilo_addr <= `HILO_REG_HI;
              read_cp0_en <= 0;
              read_cp0_addr <= 0;
            end
            `FUNCT_MFLO: begin
              read_reg_en_1 <= 0;
              read_reg_en_2 <= 0;
              read_reg_addr_1 <= 0;
              read_reg_addr_2 <= 0;
              read_hilo_en <= 1;
              read_hilo_addr <= `HILO_REG_LO;
              read_cp0_en <= 0;
              read_cp0_addr <= 0;
            end
            default: begin
              read_reg_en_1 <= 1;
              read_reg_en_2 <= 1;
              read_reg_addr_1 <= rs;
              read_reg_addr_2 <= rt;
              read_hilo_en <= 0;
              read_hilo_addr <= 0;
              read_cp0_en <= 0;
              read_cp0_addr <= 0;
            end
          endcase
        end
        // arithmetic & logic (immediate)
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
        `OP_ANDI, `OP_ORI, `OP_XORI,
        // memory accessing
        `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU: begin
          read_reg_en_1 <= 1;
          read_reg_en_2 <= 0;
          read_reg_addr_1 <= rs;
          read_reg_addr_2 <= 0;
          read_hilo_en <= 0;
          read_hilo_addr <= 0;
          read_cp0_en <= 0;
          read_cp0_addr <= 0;
        end
        // branch
        `OP_BEQ, `OP_BNE, `OP_BLEZ, `OP_BGTZ,
        // memory accessing
        `OP_SB, `OP_SH, `OP_SW,
        // r-type 2
        `OP_SPECIAL2: begin
          read_reg_en_1 <= 1;
          read_reg_en_2 <= 1;
          read_reg_addr_1 <= rs;
          read_reg_addr_2 <= rt;
          read_hilo_en <= 0;
          read_hilo_addr <= 0;
          read_cp0_en <= 0;
          read_cp0_addr <= 0;
        end
        // reg-imm
        `OP_REGIMM: begin
          case (rt)
            `REGIMM_BLTZ, `REGIMM_BLTZAL,
            `REGIMM_BGEZ, `REGIMM_BGEZAL: begin
              read_reg_en_1 <= 1;
              read_reg_en_2 <= 0;
              read_reg_addr_1 <= rs;
              read_reg_addr_2 <= 0;
              read_hilo_en <= 0;
              read_hilo_addr <= 0;
              read_cp0_en <= 0;
              read_cp0_addr <= 0;
            end
            default: begin
              read_reg_en_1 <= 0;
              read_reg_en_2 <= 0;
              read_reg_addr_1 <= 0;
              read_reg_addr_2 <= 0;
              read_hilo_en <= 0;
              read_hilo_addr <= 0;
              read_cp0_en <= 0;
              read_cp0_addr <= 0;
            end
          endcase
        end
        // coprocessor
        `OP_CP0: begin
          if (rs == `CP0_MFC0 && is_cp0) begin
            read_reg_en_1 <= 0;
            read_reg_en_2 <= 0;
            read_reg_addr_1 <= 0;
            read_reg_addr_2 <= 0;
            read_hilo_en <= 0;
            read_hilo_addr <= 0;
            read_cp0_en <= 1;
            read_cp0_addr <= {rd, sel};
          end
          else begin
            read_reg_en_1 <= 1;
            read_reg_en_2 <= 0;
            read_reg_addr_1 <= rt;
            read_reg_addr_2 <= 0;
            read_hilo_en <= 0;
            read_hilo_addr <= 0;
            read_cp0_en <= 0;
            read_cp0_addr <= 0;
          end
        end
        default: begin    // OP_J, OP_JAL, OP_LUI
          read_reg_en_1 <= 0;
          read_reg_en_2 <= 0;
          read_reg_addr_1 <= 0;
          read_reg_addr_2 <= 0;
          read_hilo_en <= 0;
          read_hilo_addr <= 0;
          read_cp0_en <= 0;
          read_cp0_addr <= 0;
        end
      endcase
    end
  end

  // generate operand_1
  always @(*) begin
    if (!rst) begin
      operand_is_ref_1 <= 0;
      operand_data_1 <= 0;
    end
    else begin
      case (op)
        `OP_SPECIAL: begin
          case (funct)
            // shift with amount
            `FUNCT_SLL, `FUNCT_SRL, `FUNCT_SRA: begin
              operand_is_ref_1 <= 0;
              operand_data_1 <= {
                {(`DATA_BUS_WIDTH - `SHAMT_BUS_WIDTH){1'b0}},
                shamt
              };
            end
            default: begin
              operand_is_ref_1 <= reg_read_is_ref_1;
              operand_data_1 <= reg_read_data_1;
            end
          endcase
        end
        // immediate
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
        `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI,
        // memory accessing
        `OP_LB, `OP_LH, `OP_LW, `OP_LBU, `OP_LHU, `OP_SB, `OP_SH, `OP_SW,
        // other
        `OP_SPECIAL2, `OP_REGIMM, `OP_CP0: begin
          operand_is_ref_1 <= reg_read_is_ref_1;
          operand_data_1 <= reg_read_data_1;
        end
        default: begin
          operand_is_ref_1 <= 0;
          operand_data_1 <= 0;
        end
    endcase
    end
  end

  // generate operand_2
  always @(*) begin
    if (!rst) begin
      operand_is_ref_2 <= 0;
      operand_data_2 <= 0;
    end
    else begin
      case (op)
        `OP_ORI, `OP_ANDI, `OP_XORI: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= zero_extended_imm;
        end 
        `OP_LUI: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= zero_extended_imm_hi;
        end
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= sign_extended_imm;
        end
        // memory accessing (store)
        `OP_SB, `OP_SH, `OP_SW,
        // r-type
        `OP_SPECIAL, `OP_SPECIAL2: begin
          operand_is_ref_2 <= reg_read_is_ref_2;
          operand_data_2 <= reg_read_data_2;
        end
        default: begin
          operand_is_ref_2 <= 0;
          operand_data_2 <= 0;
        end
      endcase
    end
  end

  // register file write address translation
  reg write_reg_en;
  reg[`REG_ADDR_BUS] write_reg_addr;
  reg write_hilo_en, write_hilo_addr;
  reg write_cp0_en;
  reg[`CP0_ADDR_BUS] write_cp0_addr;
  reg write_reg_add, write_reg_lo_en;

  assign reg_write_add = write_reg_add;
  assign reg_write_lo_en = write_reg_lo_en;

  RegAddrTrans reg_addr_trans_write(
    .rst        (rst),
    .reg_en     (write_reg_en),
    .reg_addr   (write_reg_addr),
    .hilo_en    (write_hilo_en),
    .hilo_addr  (write_hilo_addr),
    .cp0_en     (write_cp0_en),
    .cp0_addr   (write_cp0_addr),
    .rf_en      (reg_write_en),
    .rf_addr    (reg_write_addr)
  );

  // generate write address of registers
  always @(*) begin
    if (!rst) begin
      write_reg_en <= 0;
      write_reg_addr <= 0;
      write_hilo_en <= 0;
      write_hilo_addr <= 0;
      write_cp0_en <= 0;
      write_cp0_addr <= 0;
      write_reg_add <= 0;
      write_reg_lo_en <= 0;
    end
    else begin
      case (op)
        // immediate
        `OP_ADDI, `OP_ADDIU, `OP_SLTI, `OP_SLTIU,
        `OP_ANDI, `OP_ORI, `OP_XORI, `OP_LUI: begin
          write_reg_en <= 1;
          write_reg_addr <= rt;
          write_hilo_en <= 0;
          write_hilo_addr <= 0;
          write_cp0_en <= 0;
          write_cp0_addr <= 0;
          write_reg_add <= 0;
          write_reg_lo_en <= 0;
        end
        `OP_SPECIAL: begin
          case (funct)
            `FUNCT_MTHI: begin
              write_reg_en <= 0;
              write_reg_addr <= 0;
              write_hilo_en <= 1;
              write_hilo_addr <= `HILO_REG_HI;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 0;
            end
            `FUNCT_MTLO: begin
              write_reg_en <= 0;
              write_reg_addr <= 0;
              write_hilo_en <= 1;
              write_hilo_addr <= `HILO_REG_LO;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 0;
            end
            `FUNCT_MULT, `FUNCT_MULTU, `FUNCT_DIV, `FUNCT_DIVU: begin
              write_reg_en <= 0;
              write_reg_addr <= 0;
              write_hilo_en <= 1;
              write_hilo_addr <= `HILO_REG_HI;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 1;
            end
            default: begin
              write_reg_en <= 1;
              write_reg_addr <= rd;
              write_hilo_en <= 0;
              write_hilo_addr <= 0;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 0;
            end
          endcase
        end
        `OP_SPECIAL2: begin
          case (funct)
            `FUNCT_MADD, `FUNCT_MADDU, `FUNCT_MSUB, `FUNCT_MSUBU: begin
              write_reg_en <= 0;
              write_reg_addr <= 0;
              write_hilo_en <= 1;
              write_hilo_addr <= `HILO_REG_HI;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 1;
              write_reg_lo_en <= 1;
            end
            default: begin
              write_reg_en <= 1;
              write_reg_addr <= rd;
              write_hilo_en <= 0;
              write_hilo_addr <= 0;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 0;
            end
          endcase
        end
        `OP_JAL: begin
          write_reg_en <= 1;
          write_reg_addr <= 31;       // $ra (return address)
          write_hilo_en <= 0;
          write_hilo_addr <= 0;
          write_cp0_en <= 0;
          write_cp0_addr <= 0;
          write_reg_add <= 0;
          write_reg_lo_en <= 0;
        end
        `OP_REGIMM: begin
          case (rt)
            `REGIMM_BGEZAL, `REGIMM_BLTZAL: begin
              write_reg_en <= 1;
              write_reg_addr <= 31;   // $ra
              write_hilo_en <= 0;
              write_hilo_addr <= 0;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 0;
            end
            default: begin
              write_reg_en <= 0;
              write_reg_addr <= 0;
              write_hilo_en <= 0;
              write_hilo_addr <= 0;
              write_cp0_en <= 0;
              write_cp0_addr <= 0;
              write_reg_add <= 0;
              write_reg_lo_en <= 0;
            end
          endcase
        end
        `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW: begin
          write_reg_en <= 1;
          write_reg_addr <= rt;
          write_hilo_en <= 0;
          write_hilo_addr <= 0;
          write_cp0_en <= 0;
          write_cp0_addr <= 0;
          write_reg_add <= 0;
          write_reg_lo_en <= 0;
        end
        `OP_CP0: begin
          if (rs == `CP0_MFC0 && is_cp0) begin
            write_reg_en <= 1;
            write_reg_addr <= rt;
            write_hilo_en <= 0;
            write_hilo_addr <= 0;
            write_cp0_en <= 0;
            write_cp0_addr <= 0;
            write_reg_add <= 0;
            write_reg_lo_en <= 0;
          end
          else if (rs == `CP0_MTC0 && is_cp0) begin
            write_reg_en <= 0;
            write_reg_addr <= 0;
            write_hilo_en <= 0;
            write_hilo_addr <= 0;
            write_cp0_en <= 1;
            write_cp0_addr <= {rd, sel};
            write_reg_add <= 0;
            write_reg_lo_en <= 0;
          end
          else begin
            write_reg_en <= 0;
            write_reg_addr <= 0;
            write_hilo_en <= 0;
            write_hilo_addr <= 0;
            write_cp0_en <= 0;
            write_cp0_addr <= 0;
            write_reg_add <= 0;
            write_reg_lo_en <= 0;
          end
        end
        default: begin
          write_reg_en <= 0;
          write_reg_addr <= 0;
          write_hilo_en <= 0;
          write_hilo_addr <= 0;
          write_cp0_en <= 0;
          write_cp0_addr <= 0;
          write_reg_add <= 0;
          write_reg_lo_en <= 0;
        end
      endcase
    end
  end

endmodule // RegGen
