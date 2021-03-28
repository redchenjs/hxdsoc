/*
 * cpu.sv
 *
 *  Created on: 2020-08-02 16:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

module cpu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] iram_rd_data_i,
    input logic [XLEN-1:0] dram_rd_data_i,

    output logic            iram_rd_en_o,
    output logic [XLEN-1:0] iram_rd_addr_o,

    output logic            dram_rd_en_o,
    output logic [XLEN-1:0] dram_rd_addr_o,

    output logic            dram_wr_en_o,
    output logic [XLEN-1:0] dram_wr_addr_o,
    output logic [XLEN-1:0] dram_wr_data_o,
    output logic      [3:0] dram_wr_byte_en_o
);

logic [XLEN-1:0] pc_wr_data;
logic [XLEN-1:0] pc_rd_data;

logic            ir_rd_en;
logic [XLEN-1:0] ir_rd_data;

logic            rd_wr_en;
logic      [4:0] rd_wr_addr;
logic [XLEN-1:0] rd_wr_data;

logic [4:0] rs1_rd_addr;
logic [4:0] rs2_rd_addr;

logic [XLEN-1:0] rs1_rd_data;
logic [XLEN-1:0] rs2_rd_data;
logic [XLEN-1:0] imm_rd_data;

logic            iram_rd_en;
logic [XLEN-1:0] iram_rd_addr;

logic            dram_rd_en;
logic [XLEN-1:0] dram_rd_addr;

logic            dram_wr_en;
logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;
logic      [3:0] dram_wr_byte_en;

logic inst_lui;
logic inst_auipc;

logic inst_jal;
logic inst_jalr;

logic inst_beq;
logic inst_bne;
logic inst_blt;
logic inst_bge;
logic inst_bltu;
logic inst_bgeu;

logic inst_lb;
logic inst_lh;
logic inst_lw;
logic inst_lbu;
logic inst_lhu;
logic inst_sb;
logic inst_sh;
logic inst_sw;

logic inst_addi;
logic inst_slti;
logic inst_sltiu;
logic inst_xori;
logic inst_ori;
logic inst_andi;
logic inst_slli;
logic inst_srli;
logic inst_srai;

logic inst_add;
logic inst_sub;
logic inst_sll;
logic inst_slt;
logic inst_sltu;
logic inst_xor;
logic inst_srl;
logic inst_sra;
logic inst_or;
logic inst_and;

logic inst_fence;

logic inst_ecall;
logic inst_ebreak;

assign ir_rd_en = rd_wr_en;

assign dram_rd_en_o   = dram_rd_en;
assign dram_rd_addr_o = dram_rd_addr;

assign dram_wr_en_o      = dram_wr_en;
assign dram_wr_addr_o    = dram_wr_addr;
assign dram_wr_data_o    = dram_wr_data;
assign dram_wr_byte_en_o = dram_wr_byte_en;

assign bus_data_o = rd_wr_data;

reg_file #(
    .XLEN(XLEN)
) reg_file (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_wr_en_i(pc_wr_en),
    .pc_wr_data_i(pc_wr_data),

    .rd_wr_en_i(rd_wr_en),
    .rd_wr_addr_i(rd_wr_addr),
    .rd_wr_data_i(rd_wr_data),

    .rs1_rd_addr_i(rs1_rd_addr),
    .rs2_rd_addr_i(rs2_rd_addr),

    .pc_rd_data_o(pc_rd_data),

    .rs1_rd_data_o(rs1_rd_data),
    .rs2_rd_data_o(rs2_rd_data)
);

ifu #(
    .XLEN(XLEN)
) ifu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .ir_rd_en_i(ir_rd_en),
    .pc_rd_data_i(pc_rd_data),

    .iram_rd_data_i(iram_rd_data_i),

    .iram_rd_en_o(iram_rd_en_o),
    .iram_rd_addr_o(iram_rd_addr_o),

    .pc_wr_en_o(pc_wr_en),
    .pc_wr_data_o(pc_wr_data),

    .ir_rd_data_o(ir_rd_data)
);

idu #(
    .XLEN(XLEN)
) idu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .ir_rd_data_i(ir_rd_data),

    .rd_wr_addr_o(rd_wr_addr),
    .rs1_rd_addr_o(rs1_rd_addr),
    .rs2_rd_addr_o(rs2_rd_addr),

    .imm_rd_data_o(imm_rd_data),

    .inst_lui_o(inst_lui),
    .inst_auipc_o(inst_auipc),

    .inst_jal_o(inst_jal),
    .inst_jalr_o(inst_jalr),

    .inst_beq_o(inst_beq),
    .inst_bne_o(inst_bne),
    .inst_blt_o(inst_blt),
    .inst_bge_o(inst_bge),
    .inst_bltu_o(inst_bltu),
    .inst_bgeu_o(inst_bgeu),

    .inst_lb_o(inst_lb),
    .inst_lh_o(inst_lh),
    .inst_lw_o(inst_lw),
    .inst_lbu_o(inst_lbu),
    .inst_lhu_o(inst_lhu),
    .inst_sb_o(inst_sb),
    .inst_sh_o(inst_sh),
    .inst_sw_o(inst_sw),

    .inst_addi_o(inst_addi),
    .inst_slti_o(inst_slti),
    .inst_sltiu_o(inst_sltiu),
    .inst_xori_o(inst_xori),
    .inst_ori_o(inst_ori),
    .inst_andi_o(inst_andi),
    .inst_slli_o(inst_slli),
    .inst_srli_o(inst_srli),
    .inst_srai_o(inst_srai),

    .inst_add_o(inst_add),
    .inst_sub_o(inst_sub),
    .inst_sll_o(inst_sll),
    .inst_slt_o(inst_slt),
    .inst_sltu_o(inst_sltu),
    .inst_xor_o(inst_xor),
    .inst_srl_o(inst_srl),
    .inst_sra_o(inst_sra),
    .inst_or_o(inst_or),
    .inst_and_o(inst_and),

    .inst_fence_o(inst_fence),

    .inst_ecall_o(inst_ecall),
    .inst_ebreak_o(inst_ebreak)
);

exu #(
    .XLEN(XLEN)
) exu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rs1_rd_data_i(rs1_rd_data),
    .rs2_rd_data_i(rs2_rd_data),
    .imm_rd_data_i(imm_rd_data),

    .inst_lui_i(inst_lui),
    .inst_auipc_i(inst_auipc),

    .inst_jal_i(inst_jal),
    .inst_jalr_i(inst_jalr),

    .inst_beq_i(inst_beq),
    .inst_bne_i(inst_bne),
    .inst_blt_i(inst_blt),
    .inst_bge_i(inst_bge),
    .inst_bltu_i(inst_bltu),
    .inst_bgeu_i(inst_bgeu),

    .inst_lb_i(inst_lb),
    .inst_lh_i(inst_lh),
    .inst_lw_i(inst_lw),
    .inst_lbu_i(inst_lbu),
    .inst_lhu_i(inst_lhu),
    .inst_sb_i(inst_sb),
    .inst_sh_i(inst_sh),
    .inst_sw_i(inst_sw),

    .inst_addi_i(inst_addi),
    .inst_slti_i(inst_slti),
    .inst_sltiu_i(inst_sltiu),
    .inst_xori_i(inst_xori),
    .inst_ori_i(inst_ori),
    .inst_andi_i(inst_andi),
    .inst_slli_i(inst_slli),
    .inst_srli_i(inst_srli),
    .inst_srai_i(inst_srai),

    .inst_add_i(inst_add),
    .inst_sub_i(inst_sub),
    .inst_sll_i(inst_sll),
    .inst_slt_i(inst_slt),
    .inst_sltu_i(inst_sltu),
    .inst_xor_i(inst_xor),
    .inst_srl_i(inst_srl),
    .inst_sra_i(inst_sra),
    .inst_or_i(inst_or),
    .inst_and_i(inst_and),

    .inst_fence_i(inst_fence),

    .inst_ecall_i(inst_ecall),
    .inst_ebreak_i(inst_ebreak),

    .rd_wr_en_o(rd_wr_en),
    .rd_wr_data_o(rd_wr_data)
);

endmodule
