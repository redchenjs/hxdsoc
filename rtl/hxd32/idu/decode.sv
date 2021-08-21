/*
 * decode.sv
 *
 *  Created on: 2020-08-02 16:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

`include "../config.sv"

import pc_op_enum::*;

import reg_op_enum::*;
import alu_op_enum::*;
import ram_op_enum::*;

import opcode_enum::*;

module decode #(
    parameter XLEN = 32
) (
    input logic alu_comp_i,

    input logic [1:0] pc_inc_sel_r_i,

    input logic [XLEN-1:0] inst_data_i,

    output logic       pc_wr_en_o,
    output logic [1:0] pc_wr_sel_o,
    output logic [1:0] pc_inc_sel_o,

    output logic       rd_wr_en_o,
    output logic [1:0] rd_wr_sel_o,
    output logic [4:0] rd_wr_addr_o,

    output logic [4:0] rs1_rd_addr_o,
    output logic [4:0] rs2_rd_addr_o,

    output logic [1:0] alu_a_sel_o,
    output logic [1:0] alu_b_sel_o,

    output logic [2:0] alu_comp_sel_o,

    output logic       alu_op_0_sel_o,
    output logic [2:0] alu_op_1_sel_o,

    output logic       dram_wr_en_o,
    output logic [2:0] dram_wr_sel_o,
    output logic [2:0] dram_rd_sel_o,

    output logic [XLEN-1:0] imm_rd_data_o
);

wire [1:0] opcode   = inst_data_i[1:0];
wire [4:0] opcode_g = inst_data_i[6:2];

wire [4:0] rd  = inst_data_i[11:7];
wire [4:0] rs1 = inst_data_i[19:15];
wire [4:0] rs2 = inst_data_i[24:20];

wire [2:0] funct3 = inst_data_i[14:12];
wire [6:0] funct7 = inst_data_i[31:25];

wire [11:0] imm_i = {inst_data_i[31:20]};
wire [11:0] imm_s = {inst_data_i[31:25], inst_data_i[11:7]};
wire [11:0] imm_b = {inst_data_i[31], inst_data_i[7], inst_data_i[30:25], inst_data_i[11:8]};
wire [19:0] imm_u = {inst_data_i[31:12]};
wire [19:0] imm_j = {inst_data_i[31], inst_data_i[19:12], inst_data_i[20], inst_data_i[30:21]};

`ifdef CONFIG_ISA_RV32C
    wire [4:0] opcode_c = {inst_data_i[1:0], inst_data_i[15:13]};

    wire [4:0] rsd_c11 = inst_data_i[11:7];
    wire [4:0] rsd_c9  = {2'b01, inst_data_i[9:7]};
    wire [4:0] rsd_c6  = inst_data_i[6:2];
    wire [4:0] rsd_c4  = {2'b01, inst_data_i[4:2]};

    wire [1:0] funct2_c = inst_data_i[6:5];
    wire [2:0] funct3_c = inst_data_i[15:13];
    wire [3:0] funct4_c = inst_data_i[15:12];
    wire [5:0] funct6_c = inst_data_i[15:10];

    wire  [5:0] imm_c_lwsp       = {inst_data_i[3:2], inst_data_i[12], inst_data_i[6:4]};
    wire  [5:0] imm_c_swsp       = {inst_data_i[8:7], inst_data_i[12:9]};
    wire  [4:0] imm_c_lw_sw      = {inst_data_i[5], inst_data_i[12:10], inst_data_i[6]};
    wire [10:0] imm_c_j_jal      = {inst_data_i[12], inst_data_i[8], inst_data_i[10:9], inst_data_i[6], inst_data_i[7], inst_data_i[2], inst_data_i[11], inst_data_i[5:3]};
    wire  [7:0] imm_c_beqz_bnez  = {inst_data_i[12], inst_data_i[6:5], inst_data_i[2], inst_data_i[11:10], inst_data_i[4:3]};
    wire  [5:0] imm_c_li_lui_alu = {inst_data_i[12], inst_data_i[6:2]};
    wire  [5:0] imm_c_addi16sp   = {inst_data_i[12], inst_data_i[4:3], inst_data_i[5], inst_data_i[2], inst_data_i[6]};
    wire  [7:0] imm_c_addi4spn   = {inst_data_i[10:7], inst_data_i[12:11], inst_data_i[5], inst_data_i[6]};
`endif

logic       pc_wr_en;
logic [1:0] pc_wr_sel;
logic [1:0] pc_inc_sel;

logic       rd_wr_en;
logic [1:0] rd_wr_sel;
logic [4:0] rd_wr_addr;

logic [4:0] rs1_rd_addr;
logic [4:0] rs2_rd_addr;

logic [1:0] alu_a_sel;
logic [1:0] alu_b_sel;

logic [2:0] alu_comp_sel;

logic       alu_op_0_sel;
logic [2:0] alu_op_1_sel;

logic       dram_wr_en;
logic [2:0] dram_wr_sel;
logic [2:0] dram_rd_sel;

logic [XLEN-1:0] imm_rd_data;

assign pc_wr_en_o   = pc_wr_en;
assign pc_wr_sel_o  = pc_wr_sel;
assign pc_inc_sel_o = pc_inc_sel;

assign rd_wr_en_o   = rd_wr_en;
assign rd_wr_sel_o  = rd_wr_sel;
assign rd_wr_addr_o = rd_wr_addr;

assign rs1_rd_addr_o = rs1_rd_addr;
assign rs2_rd_addr_o = rs2_rd_addr;

assign alu_a_sel_o = alu_a_sel;
assign alu_b_sel_o = alu_b_sel;

assign alu_comp_sel_o = alu_comp_sel;

assign alu_op_0_sel_o = alu_op_0_sel;
assign alu_op_1_sel_o = alu_op_1_sel;

assign dram_wr_en_o  = dram_wr_en;
assign dram_wr_sel_o = dram_wr_sel;
assign dram_rd_sel_o = dram_rd_sel;

assign imm_rd_data_o = imm_rd_data;

always_comb begin
`ifdef CONFIG_ISA_RV32C
    if (&opcode) begin
`endif
        case (opcode_g)
            OPCODE_G_OP_IMM: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = inst_data_i[30] & |funct3;
                alu_op_1_sel = funct3;

                dram_wr_en = 1'b0;

                imm_rd_data = {{20{imm_i[11]}}, imm_i};
            end
            OPCODE_G_LUI: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_ZERO;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {imm_u, {12{1'b0}}};
            end
            OPCODE_G_AUIPC: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {imm_u, {12{1'b0}}};
            end
            OPCODE_G_OP: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_RS2;

                alu_op_0_sel = inst_data_i[30];
                alu_op_1_sel = funct3;

                dram_wr_en = 1'b0;

                imm_rd_data = {XLEN{1'b0}};
            end
            OPCODE_G_JAL: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_ALU;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_PC_INC_4;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{11{imm_j[19]}}, imm_j, 1'b0};
            end
            OPCODE_G_JALR: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_JALR;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_PC_INC_4;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{20{imm_i[11]}}, imm_i};
            end
            OPCODE_G_BRANCH: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = alu_comp_i ? PC_WR_ALU : PC_WR_NEXT;

                rd_wr_en  = 1'b0;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{19{imm_b[11]}}, imm_b, 1'b0};
            end
            OPCODE_G_LOAD: begin
                pc_wr_en  = 1'b0;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b1;
                rd_wr_sel = RD_WR_DRAM;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{20{imm_i[11]}}, imm_i};
            end
            OPCODE_G_STORE: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b0;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b1;

                imm_rd_data = {{20{imm_s[11]}}, imm_s};
            end
            default: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en  = 1'b0;
                rd_wr_sel = RD_WR_ALU;

                alu_a_sel = ALU_A_ZERO;
                alu_b_sel = ALU_B_ZERO;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {XLEN{1'b0}};
            end
        endcase

`ifndef CONFIG_ISA_RV32C
        pc_inc_sel = PC_INC_4;
`endif

        rd_wr_addr  = rd;
        rs1_rd_addr = rs1;
        rs2_rd_addr = rs2;

        alu_comp_sel = funct3;

        dram_wr_sel = funct3;
        dram_rd_sel = funct3;
`ifdef CONFIG_ISA_RV32C
    end else begin
        case (opcode_c)
            OPCODE_C_LWSP: begin
                pc_wr_en  = 1'b0;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_DRAM;
                rd_wr_addr = rsd_c11;

                rs1_rd_addr = 5'h02;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {24'h00_0000, imm_c_lwsp, 2'b00};
            end
            OPCODE_C_SWSP: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b0;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = 5'h00;

                rs1_rd_addr = 5'h02;
                rs2_rd_addr = rsd_c6;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b1;

                imm_rd_data = {24'h00_0000, imm_c_swsp, 2'b00};
            end
            OPCODE_C_LW: begin
                pc_wr_en  = 1'b0;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_DRAM;
                rd_wr_addr = rsd_c4;

                rs1_rd_addr = rsd_c9;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {25'h000_0000, imm_c_lw_sw, 2'b00};
            end
            OPCODE_C_SW: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b0;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = 5'h00;

                rs1_rd_addr = rsd_c9;
                rs2_rd_addr = rsd_c4;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b1;

                imm_rd_data = {25'h000_0000, imm_c_lw_sw, 2'b00};
            end
            OPCODE_C_J: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_ALU;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = 5'h00;

                rs1_rd_addr = 5'h00;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{20{imm_c_j_jal[10]}}, imm_c_j_jal, 1'b0};
            end
            OPCODE_C_JAL: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_ALU;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_PC_INC_2;
                rd_wr_addr = 5'h01;

                rs1_rd_addr = 5'h00;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{20{imm_c_j_jal[10]}}, imm_c_j_jal, 1'b0};
            end
            OPCODE_C_JR_MV_ADD: begin
                pc_wr_en = 1'b1;

                rd_wr_en = 1'b1;

                rs1_rd_addr = rsd_c11;
                rs2_rd_addr = rsd_c6;

                case ({funct4_c[0], |rsd_c6})
                    OPCODE_C_EXT0_JR: begin
                        pc_wr_sel = PC_WR_ALU;

                        rd_wr_sel  = RD_WR_ALU;
                        rd_wr_addr = 5'h00;

                        alu_a_sel = ALU_A_RS1;
                        alu_b_sel = ALU_B_ZERO;
                    end
                    OPCODE_C_EXT0_MV: begin
                        pc_wr_sel = PC_WR_NEXT;

                        rd_wr_sel  = RD_WR_ALU;
                        rd_wr_addr = rsd_c11;

                        alu_a_sel = ALU_A_ZERO;
                        alu_b_sel = ALU_B_RS2;
                    end
                    OPCODE_C_EXT0_JALR: begin
                        pc_wr_sel = PC_WR_ALU;

                        rd_wr_sel  = RD_WR_PC_INC_2;
                        rd_wr_addr = 5'h01;

                        alu_a_sel = ALU_A_RS1;
                        alu_b_sel = ALU_B_ZERO;
                    end
                    OPCODE_C_EXT0_ADD: begin
                        pc_wr_sel = PC_WR_NEXT;

                        rd_wr_sel  = RD_WR_ALU;
                        rd_wr_addr = rsd_c11;

                        alu_a_sel = ALU_A_RS1;
                        alu_b_sel = ALU_B_RS2;
                    end
                endcase

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {XLEN{1'b0}};
            end
            OPCODE_C_BEQZ: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = alu_comp_i ? PC_WR_ALU : PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = 5'h00;

                rs1_rd_addr = rsd_c9;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{23{imm_c_beqz_bnez[7]}}, imm_c_beqz_bnez, 1'b0};
            end
            OPCODE_C_BNEZ: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = alu_comp_i ? PC_WR_ALU : PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = 5'h00;

                rs1_rd_addr = rsd_c9;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_PC;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BNE;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{23{imm_c_beqz_bnez[7]}}, imm_c_beqz_bnez, 1'b0};
            end
            OPCODE_C_LI: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = rsd_c11;

                rs1_rd_addr = 5'h00;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_ZERO;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{26{imm_c_li_lui_alu[5]}}, imm_c_li_lui_alu};
            end
            OPCODE_C_LUI_ADDI16SP: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = rsd_c11;

                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                case (rsd_c11 == 5'h02)
                    OPCODE_C_EXT1_LUI: begin
                        rs1_rd_addr = 5'h00;

                        imm_rd_data = {{14{imm_c_li_lui_alu[5]}}, imm_c_li_lui_alu, 12'h000};
                    end
                    OPCODE_C_EXT1_ADDI16SP: begin
                        rs1_rd_addr = 5'h02;

                        imm_rd_data = {{22{imm_c_addi16sp[5]}}, imm_c_addi16sp, 4'h0};
                    end
                endcase
            end
            OPCODE_C_ADDI: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = rsd_c11;

                rs1_rd_addr = rsd_c11;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {{26{imm_c_li_lui_alu[5]}}, imm_c_li_lui_alu};
            end
            OPCODE_C_ADDI4SPN: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = rsd_c4;

                rs1_rd_addr = 5'h02;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {22'h00_0000, imm_c_addi4spn, 2'b00};
            end
            OPCODE_C_SLLI: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = rsd_c11;

                rs1_rd_addr = rsd_c11;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_RS1;
                alu_b_sel = ALU_B_IMM;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_SLL;

                dram_wr_en = 1'b0;

                imm_rd_data = {{26{imm_c_li_lui_alu[5]}}, imm_c_li_lui_alu};
            end
            OPCODE_C_MISC_ALU: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b1;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = rsd_c9;

                rs1_rd_addr = rsd_c9;
                rs2_rd_addr = rsd_c4;

                alu_a_sel = ALU_A_RS1;

                case (funct6_c[1:0])
                    OPCODE_C_ALU_SRLI: begin
                        alu_b_sel = ALU_B_IMM;

                        alu_op_0_sel = ALU_OP_0_ADD_SRL;
                        alu_op_1_sel = ALU_OP_1_SRL;
                    end
                    OPCODE_C_ALU_SRAI: begin
                        alu_b_sel = ALU_B_IMM;

                        alu_op_0_sel = ALU_OP_0_SUB_SRA;
                        alu_op_1_sel = ALU_OP_1_SRL;
                    end
                    OPCODE_C_ALU_ANDI: begin
                        alu_b_sel = ALU_B_IMM;

                        alu_op_0_sel = ALU_OP_0_ADD_SRL;
                        alu_op_1_sel = ALU_OP_1_AND;
                    end
                    OPCODE_C_ALU_MISC: begin
                        alu_b_sel = ALU_B_RS2;

                        case (funct2_c)
                            OPCODE_C_ALU_EXT_SUB: begin
                                alu_op_0_sel = ALU_OP_0_SUB_SRA;
                                alu_op_1_sel = ALU_OP_1_ADD;
                            end
                            OPCODE_C_ALU_EXT_XOR: begin
                                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                                alu_op_1_sel = ALU_OP_1_XOR;
                            end
                            OPCODE_C_ALU_EXT_OR: begin
                                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                                alu_op_1_sel = ALU_OP_1_OR;
                            end
                            OPCODE_C_ALU_EXT_AND: begin
                                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                                alu_op_1_sel = ALU_OP_1_AND;
                            end
                        endcase
                    end
                endcase

                alu_comp_sel = ALU_COMP_BEQ;

                dram_wr_en = 1'b0;

                imm_rd_data = {{26{imm_c_li_lui_alu[5]}}, imm_c_li_lui_alu};
            end
            default: begin
                pc_wr_en  = 1'b1;
                pc_wr_sel = PC_WR_NEXT;

                rd_wr_en   = 1'b0;
                rd_wr_sel  = RD_WR_ALU;
                rd_wr_addr = 5'h00;

                rs1_rd_addr = 5'h00;
                rs2_rd_addr = 5'h00;

                alu_a_sel = ALU_A_ZERO;
                alu_b_sel = ALU_B_ZERO;

                alu_comp_sel = ALU_COMP_BEQ;

                alu_op_0_sel = ALU_OP_0_ADD_SRL;
                alu_op_1_sel = ALU_OP_1_ADD;

                dram_wr_en = 1'b0;

                imm_rd_data = {XLEN{1'b0}};
            end
        endcase

        dram_wr_sel = DRAM_WR_W;
        dram_rd_sel = DRAM_RD_W;
    end

    case ({pc_inc_sel_r_i[0], ~&opcode})
        2'b00: begin
            pc_inc_sel = PC_INC_4;
        end
        2'b01: begin
            pc_inc_sel = PC_INC_2P;
        end
        2'b10: begin
            pc_inc_sel = PC_INC_4P;
        end
        2'b11: begin
            pc_inc_sel = PC_INC_2;
        end
    endcase
`endif
end

endmodule
