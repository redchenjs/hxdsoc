/*
 * test_idu.sv
 *
 *  Created on: 2020-08-03 17:37
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_idu;

parameter XLEN = 32;

logic clk_i;
logic rst_n_i;

logic [XLEN-1:0] ir_rd_data_i;

logic [4:0] rd_wr_addr_o;
logic [4:0] rs1_rd_addr_o;
logic [4:0] rs2_rd_addr_o;

logic [XLEN-1:0] imm_rd_data_o;

logic inst_lui_o;
logic inst_auipc_o;

logic inst_jal_o;
logic inst_jalr_o;

logic inst_beq_o;
logic inst_bne_o;
logic inst_blt_o;
logic inst_bge_o;
logic inst_bltu_o;
logic inst_bgeu_o;

logic inst_lb_o;
logic inst_lh_o;
logic inst_lw_o;
logic inst_lbu_o;
logic inst_lhu_o;
logic inst_sb_o;
logic inst_sh_o;
logic inst_sw_o;

logic inst_addi_o;
logic inst_slti_o;
logic inst_sltiu_o;
logic inst_xori_o;
logic inst_ori_o;
logic inst_andi_o;
logic inst_slli_o;
logic inst_srli_o;
logic inst_srai_o;

logic inst_add_o;
logic inst_sub_o;
logic inst_sll_o;
logic inst_slt_o;
logic inst_sltu_o;
logic inst_xor_o;
logic inst_srl_o;
logic inst_sra_o;
logic inst_or_o;
logic inst_and_o;

logic inst_fence_o;

logic inst_ecall_o;
logic inst_ebreak_o;

idu #(
    .XLEN(XLEN)
) idu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .ir_rd_data_i(ir_rd_data_i),

    .rd_wr_addr_o(rd_wr_addr_o),
    .rs1_rd_addr_o(rs1_rd_addr_o),
    .rs2_rd_addr_o(rs2_rd_addr_o),

    .imm_rd_data_o(imm_rd_data_o),

    .inst_lui_o(inst_lui_o),
    .inst_auipc_o(inst_auipc_o),

    .inst_jal_o(inst_jal_o),
    .inst_jalr_o(inst_jalr_o),

    .inst_beq_o(inst_beq_o),
    .inst_bne_o(inst_bne_o),
    .inst_blt_o(inst_blt_o),
    .inst_bge_o(inst_bge_o),
    .inst_bltu_o(inst_bltu_o),
    .inst_bgeu_o(inst_bgeu_o),

    .inst_lb_o(inst_lb_o),
    .inst_lh_o(inst_lh_o),
    .inst_lw_o(inst_lw_o),
    .inst_lbu_o(inst_lbu_o),
    .inst_lhu_o(inst_lhu_o),
    .inst_sb_o(inst_sb_o),
    .inst_sh_o(inst_sh_o),
    .inst_sw_o(inst_sw_o),

    .inst_addi_o(inst_addi_o),
    .inst_slti_o(inst_slti_o),
    .inst_sltiu_o(inst_sltiu_o),
    .inst_xori_o(inst_xori_o),
    .inst_ori_o(inst_ori_o),
    .inst_andi_o(inst_andi_o),
    .inst_slli_o(inst_slli_o),
    .inst_srli_o(inst_srli_o),
    .inst_srai_o(inst_srai_o),

    .inst_add_o(inst_add_o),
    .inst_sub_o(inst_sub_o),
    .inst_sll_o(inst_sll_o),
    .inst_slt_o(inst_slt_o),
    .inst_sltu_o(inst_sltu_o),
    .inst_xor_o(inst_xor_o),
    .inst_srl_o(inst_srl_o),
    .inst_sra_o(inst_sra_o),
    .inst_or_o(inst_or_o),
    .inst_and_o(inst_and_o),

    .inst_fence_o(inst_fence_o),

    .inst_ecall_o(inst_ecall_o),
    .inst_ebreak_o(inst_ebreak_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    ir_rd_data_i <= 32'h0000_0000;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    ir_rd_data_i <= 32'h0041_8133;

    #5120 rst_n_i <= 1'b0;

    #25 $stop;
end

endmodule
