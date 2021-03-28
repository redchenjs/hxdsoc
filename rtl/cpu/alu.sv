/*
 * alu.sv
 *
 *  Created on: 2020-08-03 17:49
 *      Author: Jack Chen <redchenjs@live.com>
 */

module alu #(
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

wire lui_auipc  = inst_lui_i | inst_auipc_i;
wire load_store = inst_lb_i  | inst_lh_i  | inst_lw_i  | inst_lbu_i | inst_lhu_i |
                  inst_sb_i  | inst_sh_i  | inst_sw_i;

wire op_imm = inst_addi_i | inst_slti_i | inst_sltiu_i | inst_xori_i | inst_ori_i |
              inst_andi_i | inst_slli_i | inst_srli_i  | inst_srai_i;

wire op = inst_add_i | inst_sub_i | inst_sll_i | inst_slt_i | inst_sltu_i |
          inst_xor_i | inst_srl_i | inst_sra_i | inst_or_i  | inst_and_i;

wire [XLEN-1:0] rs1_data = lui_auipc ? pc_rd_data_i : rs1_rd_data_i;
wire [XLEN-1:0] rs2_data = (lui_auipc | load_store | op_imm) ? imm_rd_data_i : rs2_rd_data_i;

wire [XLEN-1:0] res_add  = rs1_data + rs2_data;
wire [XLEN-1:0] res_sub  = rs1_data - rs2_data;
wire [XLEN-1:0] res_slt  = ($signed(rs1_data) < $signed(rs2_data)) ? 32'h0000_0001 : 32'h0000_0000;
wire [XLEN-1:0] res_sltu = (rs1_data < rs2_data) ? 32'h0000_0001 : 32'h0000_0000;
wire [XLEN-1:0] res_xor  = rs1_data ^ rs2_data;
wire [XLEN-1:0] res_or   = rs1_data | rs2_data;
wire [XLEN-1:0] res_and  = rs1_data & rs2_data;
wire [XLEN-1:0] res_sll  = rs1_data << rs2_data[4:0];
wire [XLEN-1:0] res_srl  = rs1_data >> rs2_data[4:0];
wire [XLEN-1:0] res_sra  = $signed(rs1_data) >>> rs2_data[4:0];

wire [XLEN-1:0] rd_add  = (inst_addi_i | inst_add_i) ? res_add : 32'h0000_0000;
wire [XLEN-1:0] rd_sub  = inst_sub_i ? res_sub : 32'h0000_0000;
wire [XLEN-1:0] rd_sll  = (inst_slli_i | inst_sll_i) ? res_sll : 32'h0000_0000;
wire [XLEN-1:0] rd_slt  = (inst_slti_i | inst_slt_i) ? res_slt : 32'h0000_0000;
wire [XLEN-1:0] rd_sltu = (inst_sltiu_i | inst_sltu_i) ? res_sltu : 32'h0000_0000;
wire [XLEN-1:0] rd_xor  = (inst_xori_i | inst_xor_i) ? res_xor : 32'h0000_0000;
wire [XLEN-1:0] rd_srl  = (inst_srli_i | inst_srl_i) ? res_srl : 32'h0000_0000;
wire [XLEN-1:0] rd_sra  = (inst_srai_i | inst_sra_i) ? res_sra : 32'h0000_0000;
wire [XLEN-1:0] rd_or   = (inst_ori_i  | inst_or_i)  ? res_or  : 32'h0000_0000;
wire [XLEN-1:0] rd_and  = (inst_andi_i | inst_and_i) ? res_and : 32'h0000_0000;

wire [XLEN-1:0] rd_lui  = inst_lui_i ? imm_rd_data_i : 32'h0000_0000;
wire [XLEN-1:0] rd_misc = (inst_auipc_i | load_store) ? res_add : 32'h0000_0000;

logic [XLEN-1:0] rd_wr_data;

assign rd_wr_en_o = lui_auipc | op_imm | op;

assign rd_wr_data_o = rd_wr_data;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_wr_data <= {XLEN{1'b0}};
    end else begin
        if (rd_wr_en_o) begin
            rd_wr_data <= rd_add | rd_sub | rd_sll | rd_slt | rd_sltu | rd_xor |
                          rd_srl | rd_sra | rd_or  | rd_and | rd_lui  | rd_misc;
        end
    end
end

endmodule
