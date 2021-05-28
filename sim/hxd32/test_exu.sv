/*
 * test_exu.sv
 *
 *  Created on: 2020-08-03 17:37
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_exu;

parameter XLEN = 32;

logic clk_i;
logic rst_n_i;

logic [XLEN-1:0] pc_rd_data_i;
logic [XLEN-1:0] rs1_rd_data_i;
logic [XLEN-1:0] rs2_rd_data_i;
logic [XLEN-1:0] imm_rd_data_i;

logic inst_lui_i;
logic inst_auipc_i;

logic inst_jal_i;
logic inst_jalr_i;

logic inst_beq_i;
logic inst_bne_i;
logic inst_blt_i;
logic inst_bge_i;
logic inst_bltu_i;
logic inst_bgeu_i;

logic inst_lb_i;
logic inst_lh_i;
logic inst_lw_i;
logic inst_lbu_i;
logic inst_lhu_i;
logic inst_sb_i;
logic inst_sh_i;
logic inst_sw_i;

logic inst_addi_i;
logic inst_slti_i;
logic inst_sltiu_i;
logic inst_xori_i;
logic inst_ori_i;
logic inst_andi_i;
logic inst_slli_i;
logic inst_srli_i;
logic inst_srai_i;

logic inst_add_i;
logic inst_sub_i;
logic inst_sll_i;
logic inst_slt_i;
logic inst_sltu_i;
logic inst_xor_i;
logic inst_srl_i;
logic inst_sra_i;
logic inst_or_i;
logic inst_and_i;

logic inst_fence_i;

logic inst_ecall_i;
logic inst_ebreak_i;

logic            rd_wr_en_o;
logic [XLEN-1:0] rd_wr_data_o;

exu #(
    .XLEN(XLEN)
) exu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_rd_data_i(pc_rd_data_i),

    .rs1_rd_data_i(rs1_rd_data_i),
    .rs2_rd_data_i(rs2_rd_data_i),
    .imm_rd_data_i(imm_rd_data_i),

    .inst_lui_i(inst_lui_i),
    .inst_auipc_i(inst_auipc_i),

    .inst_jal_i(inst_jal_i),
    .inst_jalr_i(inst_jalr_i),

    .inst_beq_i(inst_beq_i),
    .inst_bne_i(inst_bne_i),
    .inst_blt_i(inst_blt_i),
    .inst_bge_i(inst_bge_i),
    .inst_bltu_i(inst_bltu_i),
    .inst_bgeu_i(inst_bgeu_i),

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

    .inst_fence_i(inst_fence_i),

    .inst_ecall_i(inst_ecall_i),
    .inst_ebreak_i(inst_ebreak_i),

    .rd_wr_en_o(rd_wr_en_o),
    .rd_wr_data_o(rd_wr_data_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    pc_rd_data_i <= 32'h0000_0004;

    rs1_rd_data_i <= 32'h0000_0008;
    rs2_rd_data_i <= 32'h0000_0009;
    imm_rd_data_i <= 32'h0000_000A;

    inst_lui_i    <= 1'b0;
    inst_auipc_i  <= 1'b0;

    inst_jal_i    <= 1'b0;
    inst_jalr_i   <= 1'b0;

    inst_beq_i    <= 1'b0;
    inst_bne_i    <= 1'b0;
    inst_blt_i    <= 1'b0;
    inst_bge_i    <= 1'b0;
    inst_bltu_i   <= 1'b0;
    inst_bgeu_i   <= 1'b0;

    inst_lb_i     <= 1'b0;
    inst_lh_i     <= 1'b0;
    inst_lw_i     <= 1'b0;
    inst_lbu_i    <= 1'b0;
    inst_lhu_i    <= 1'b0;
    inst_sb_i     <= 1'b0;
    inst_sh_i     <= 1'b0;
    inst_sw_i     <= 1'b0;

    inst_addi_i   <= 1'b0;
    inst_slti_i   <= 1'b0;
    inst_sltiu_i  <= 1'b0;
    inst_xori_i   <= 1'b0;
    inst_ori_i    <= 1'b0;
    inst_andi_i   <= 1'b0;
    inst_slli_i   <= 1'b0;
    inst_srli_i   <= 1'b0;
    inst_srai_i   <= 1'b0;

    inst_add_i    <= 1'b0;
    inst_sub_i    <= 1'b0;
    inst_sll_i    <= 1'b0;
    inst_slt_i    <= 1'b0;
    inst_sltu_i   <= 1'b0;
    inst_xor_i    <= 1'b0;
    inst_srl_i    <= 1'b0;
    inst_sra_i    <= 1'b0;
    inst_or_i     <= 1'b0;
    inst_and_i    <= 1'b0;

    inst_fence_i  <= 1'b0;

    inst_ecall_i  <= 1'b0;
    inst_ebreak_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #25 
        inst_lui_i    <= 1'b1;
    #5  inst_lui_i    <= 1'b0;
        inst_auipc_i  <= 1'b1;
    #5  inst_auipc_i  <= 1'b0;

        inst_jal_i    <= 1'b1;
    #5  inst_jal_i    <= 1'b0;
        inst_jalr_i   <= 1'b1;
    #5  inst_jalr_i   <= 1'b0;

        inst_beq_i    <= 1'b1;
    #5  inst_beq_i    <= 1'b0;
        inst_bne_i    <= 1'b1;
    #5  inst_bne_i    <= 1'b0;
        inst_blt_i    <= 1'b1;
    #5  inst_blt_i    <= 1'b0;

        inst_bge_i    <= 1'b1;
    #5  inst_bge_i    <= 1'b0;
        inst_bltu_i   <= 1'b1;
    #5  inst_bltu_i   <= 1'b0;
        inst_bgeu_i   <= 1'b1;
    #5  inst_bgeu_i   <= 1'b0;

        inst_lb_i     <= 1'b1;
    #5  inst_lb_i     <= 1'b0;
        inst_lh_i     <= 1'b1;
    #5  inst_lh_i     <= 1'b0;
        inst_lw_i     <= 1'b1;
    #5  inst_lw_i     <= 1'b0;
        inst_lbu_i    <= 1'b1;
    #5  inst_lbu_i    <= 1'b0;
        inst_lhu_i    <= 1'b1;
    #5  inst_lhu_i    <= 1'b0;
        inst_sb_i     <= 1'b1;
    #5  inst_sb_i     <= 1'b0;
        inst_sh_i     <= 1'b1;
    #5  inst_sh_i     <= 1'b0;
        inst_sw_i     <= 1'b1;
    #5  inst_sw_i     <= 1'b0;

        inst_addi_i   <= 1'b1;
    #5  inst_addi_i   <= 1'b0;
        inst_slti_i   <= 1'b1;
    #5  inst_slti_i   <= 1'b0;
        inst_sltiu_i  <= 1'b1;
    #5  inst_sltiu_i  <= 1'b0;
        inst_xori_i   <= 1'b1;
    #5  inst_xori_i   <= 1'b0;
        inst_ori_i    <= 1'b1;
    #5  inst_ori_i    <= 1'b0;
        inst_andi_i   <= 1'b1;
    #5  inst_andi_i   <= 1'b0;
        inst_slli_i   <= 1'b1;
    #5  inst_slli_i   <= 1'b0;
        inst_srli_i   <= 1'b1;
    #5  inst_srli_i   <= 1'b0;
        inst_srai_i   <= 1'b1;
    #5  inst_srai_i   <= 1'b0;

        inst_add_i    <= 1'b1;
    #5  inst_add_i    <= 1'b0;
        inst_sub_i    <= 1'b1;
    #5  inst_sub_i    <= 1'b0;
        inst_sll_i    <= 1'b1;
    #5  inst_sll_i    <= 1'b0;
        inst_slt_i    <= 1'b1;
    #5  inst_slt_i    <= 1'b0;
        inst_sltu_i   <= 1'b1;
    #5  inst_sltu_i   <= 1'b0;
        inst_xor_i    <= 1'b1;
    #5  inst_xor_i    <= 1'b0;
        inst_srl_i    <= 1'b1;
    #5  inst_srl_i    <= 1'b0;
        inst_sra_i    <= 1'b1;
    #5  inst_sra_i    <= 1'b0;
        inst_or_i     <= 1'b1;
    #5  inst_or_i     <= 1'b0;
        inst_and_i    <= 1'b1;
    #5  inst_and_i    <= 1'b0;

        inst_fence_i  <= 1'b1;
    #5  inst_fence_i  <= 1'b0;

        inst_ecall_i  <= 1'b1;
    #5  inst_ecall_i  <= 1'b0;
        inst_ebreak_i <= 1'b1;
    #5  inst_ebreak_i <= 1'b0;

    #5120 rst_n_i <= 1'b0;

    #25 $stop;
end

endmodule
