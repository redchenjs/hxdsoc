/*
 * exu.sv
 *
 *  Created on: 2020-08-05 19:44
 *      Author: Jack Chen <redchenjs@live.com>
 */

module exu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] pc_rd_data_i,

    input logic [XLEN-1:0] rs1_rd_data_i,
    input logic [XLEN-1:0] rs2_rd_data_i,
    input logic [XLEN-1:0] imm_rd_data_i,

    input logic inst_lui_i,
    input logic inst_auipc_i,

    input logic inst_jal_i,
    input logic inst_jalr_i,

    input logic inst_beq_i,
    input logic inst_bne_i,
    input logic inst_blt_i,
    input logic inst_bge_i,
    input logic inst_bltu_i,
    input logic inst_bgeu_i,

    input logic inst_lb_i,
    input logic inst_lh_i,
    input logic inst_lw_i,
    input logic inst_lbu_i,
    input logic inst_lhu_i,
    input logic inst_sb_i,
    input logic inst_sh_i,
    input logic inst_sw_i,

    input logic inst_addi_i,
    input logic inst_slti_i,
    input logic inst_sltiu_i,
    input logic inst_xori_i,
    input logic inst_ori_i,
    input logic inst_andi_i,
    input logic inst_slli_i,
    input logic inst_srli_i,
    input logic inst_srai_i,

    input logic inst_add_i,
    input logic inst_sub_i,
    input logic inst_sll_i,
    input logic inst_slt_i,
    input logic inst_sltu_i,
    input logic inst_xor_i,
    input logic inst_srl_i,
    input logic inst_sra_i,
    input logic inst_or_i,
    input logic inst_and_i,

    input logic inst_fence_i,

    input logic inst_ecall_i,
    input logic inst_ebreak_i,

    output logic            rd_wr_en_o,
    output logic [XLEN-1:0] rd_wr_data_o
);

alu #(
    .XLEN(XLEN)
) alu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_rd_data_i(pc_rd_data_i),

    .rs1_rd_data_i(rs1_rd_data_i),
    .rs2_rd_data_i(rs2_rd_data_i),
    .imm_rd_data_i(imm_rd_data_i),

    .inst_lui_i(inst_lui_i),
    .inst_auipc_i(inst_auipc_i),

    .inst_lb_i(inst_lb_i),
    .inst_lh_i(inst_lh_i),
    .inst_lw_i(inst_lw_i),
    .inst_lbu_i(inst_lbu_i),
    .inst_lhu_i(inst_lhu_i),
    .inst_sb_i(inst_sb_i),
    .inst_sh_i(inst_sh_i),
    .inst_sw_i(inst_sw_i),

    .inst_addi_i(inst_addi_i),
    .inst_slti_i(inst_slti_i),
    .inst_sltiu_i(inst_sltiu_i),
    .inst_xori_i(inst_xori_i),
    .inst_ori_i(inst_ori_i),
    .inst_andi_i(inst_andi_i),
    .inst_slli_i(inst_slli_i),
    .inst_srli_i(inst_srli_i),
    .inst_srai_i(inst_srai_i),

    .inst_add_i(inst_add_i),
    .inst_sub_i(inst_sub_i),
    .inst_sll_i(inst_sll_i),
    .inst_slt_i(inst_slt_i),
    .inst_sltu_i(inst_sltu_i),
    .inst_xor_i(inst_xor_i),
    .inst_srl_i(inst_srl_i),
    .inst_sra_i(inst_sra_i),
    .inst_or_i(inst_or_i),
    .inst_and_i(inst_and_i),

    .rd_wr_en_o(rd_wr_en_o),
    .rd_wr_data_o(rd_wr_data_o)
);

endmodule
