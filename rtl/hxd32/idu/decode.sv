/*
 * decode.sv
 *
 *  Created on: 2020-08-02 16:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

import alu_op_enum::*;

module decode #(
    parameter XLEN = 32
) (
    input logic alu_comp_i,

    input logic [XLEN-1:0] inst_data_i,

    output logic pc_wr_en_o,
    output logic pc_wr_sel_o,
    output logic pc_inc_sel_o,

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

localparam [4:0] OPCODE_LOAD      = 5'b00_000;
localparam [4:0] OPCODE_STORE     = 5'b01_000;
localparam [4:0] OPCODE_MADD      = 5'b10_000;
localparam [4:0] OPCODE_BRANCH    = 5'b11_000;

localparam [4:0] OPCODE_LOAD_FP   = 5'b00_001;
localparam [4:0] OPCODE_STORE_FP  = 5'b01_001;
localparam [4:0] OPCODE_MSUB      = 5'b10_001;
localparam [4:0] OPCODE_JALR      = 5'b11_001;

localparam [4:0] OPCODE_NMSUB     = 5'b10_010;

localparam [4:0] OPCODE_MISC_MEM  = 5'b00_011;
localparam [4:0] OPCODE_AMO       = 5'b01_011;
localparam [4:0] OPCODE_NMADD     = 5'b10_011;
localparam [4:0] OPCODE_JAL       = 5'b11_011;

localparam [4:0] OPCODE_OP_IMM    = 5'b00_100;
localparam [4:0] OPCODE_OP        = 5'b01_100;
localparam [4:0] OPCODE_OP_FP     = 5'b10_100;
localparam [4:0] OPCODE_SYSTEM    = 5'b11_100;

localparam [4:0] OPCODE_AUIPC     = 5'b00_101;
localparam [4:0] OPCODE_LUI       = 5'b01_101;

localparam [4:0] OPCODE_OP_IMM_32 = 5'b00_110;
localparam [4:0] OPCODE_OP_32     = 5'b01_110;

wire [4:0] opcode = inst_data_i[6:2];

wire opcode_load     = (opcode == OPCODE_LOAD);
wire opcode_store    = (opcode == OPCODE_STORE);
wire opcode_branch   = (opcode == OPCODE_BRANCH);
wire opcode_jalr     = (opcode == OPCODE_JALR);
wire opcode_misc_mem = (opcode == OPCODE_MISC_MEM);
wire opcode_jal      = (opcode == OPCODE_JAL);
wire opcode_op_imm   = (opcode == OPCODE_OP_IMM);
wire opcode_op       = (opcode == OPCODE_OP);
wire opcode_system   = (opcode == OPCODE_SYSTEM);
wire opcode_auipc    = (opcode == OPCODE_AUIPC);
wire opcode_lui      = (opcode == OPCODE_LUI);

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

logic alu_op_0_sel;

logic [1:0] alu_a_sel;
logic [1:0] alu_b_sel;

logic [XLEN-1:0] imm;

assign pc_wr_en_o   = 1'b1;
assign pc_wr_sel_o  = opcode_jal | opcode_jalr | (opcode_branch & alu_comp_i);
assign pc_inc_sel_o = ~(inst_data_i[1] & inst_data_i[0]);

assign rd_wr_en_o     = opcode_lui | opcode_auipc | opcode_op | opcode_op_imm |
                        opcode_jal | opcode_jalr | opcode_load;
assign rd_wr_sel_o[1] = opcode_jal | opcode_jalr;
assign rd_wr_sel_o[0] = opcode_load;
assign rd_wr_addr_o   = rd;

assign rs1_rd_addr_o = rs1;
assign rs2_rd_addr_o = rs2;

assign alu_a_sel_o = alu_a_sel;
assign alu_b_sel_o = alu_b_sel;

assign alu_comp_sel_o = funct3;

assign alu_op_0_sel_o = alu_op_0_sel;
assign alu_op_1_sel_o = (opcode_op | opcode_op_imm) ? funct3 : 3'b000;

assign dram_wr_en_o  = opcode_store;
assign dram_wr_sel_o = funct3;
assign dram_rd_sel_o = funct3;

assign imm_rd_data_o = imm;

always_comb begin
    case (funct3)
        ALU_OP_1_ADD: begin
            alu_op_0_sel = inst_data_i[30] & opcode_op;
        end
        ALU_OP_1_SRL: begin
            alu_op_0_sel = inst_data_i[30] & (opcode_op | opcode_op_imm);
        end
        default: begin
            alu_op_0_sel = 1'b0;
        end
    endcase
end

always_comb begin
    case (opcode)
        OPCODE_LOAD: begin
            alu_a_sel = ALU_A_RS1;
            alu_b_sel = ALU_B_IMM;

            imm = {{20{imm_i[11]}}, imm_i};
        end
        OPCODE_STORE: begin
            alu_a_sel = ALU_A_RS1;
            alu_b_sel = ALU_B_IMM;

            imm = {{20{imm_s[11]}}, imm_s};
        end
        OPCODE_BRANCH: begin
            alu_a_sel = ALU_A_RS1;
            alu_b_sel = ALU_B_RS2;

            imm = {{19{imm_b[11]}}, imm_b, 1'b0};
        end
        OPCODE_JALR: begin
            alu_a_sel = ALU_A_PC;
            alu_b_sel = ALU_B_IMM;

            imm = {{20{imm_i[11]}}, imm_i};
        end
        OPCODE_JAL: begin
            alu_a_sel = ALU_A_RS1;
            alu_b_sel = ALU_B_IMM;

            imm = {{11{imm_j[19]}}, imm_j, 1'b0};
        end
        OPCODE_OP_IMM: begin
            alu_a_sel = ALU_A_RS1;
            alu_b_sel = ALU_B_IMM;

            imm = {{20{imm_i[11]}}, imm_i};
        end
        OPCODE_OP: begin
            alu_a_sel = ALU_A_RS1;
            alu_b_sel = ALU_B_RS2;

            imm = {XLEN{1'b0}};
        end
        OPCODE_AUIPC: begin
            alu_a_sel = ALU_A_PC;
            alu_b_sel = ALU_B_IMM;

            imm = {imm_u, {12{1'b0}}};
        end
        OPCODE_LUI: begin
            alu_a_sel = ALU_A_ZERO;
            alu_b_sel = ALU_B_IMM;

            imm = {imm_u, {12{1'b0}}};
        end
        default: begin
            alu_a_sel = ALU_A_ZERO;
            alu_b_sel = ALU_B_ZERO;

            imm = {XLEN{1'b0}};
        end
    endcase
end

endmodule
