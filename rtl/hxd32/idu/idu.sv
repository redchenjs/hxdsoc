/*
 * idu.sv
 *
 *  Created on: 2020-08-02 16:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

module idu #(
    parameter XLEN = 32
) (
    input logic alu_comp_i,

    input logic [XLEN-1:0] inst_data_i,

    output logic pc_wr_en_o,
    output logic pc_wr_sel_o,
    output logic pc_inc_sel_o,

    output logic [1:0] alu_a_sel_o,
    output logic [1:0] alu_b_sel_o,

    output logic [2:0] alu_comp_sel_o,

    output logic       alu_op_0_sel_o,
    output logic [2:0] alu_op_1_sel_o,

    output logic       dram_wr_en_o,
    output logic [2:0] dram_wr_sel_o,
    output logic [2:0] dram_rd_sel_o,

    output logic       rd_wr_en_o,
    output logic [1:0] rd_wr_sel_o,
    output logic [4:0] rd_wr_addr_o,

    output logic [4:0] rs1_rd_addr_o,
    output logic [4:0] rs2_rd_addr_o,

    output logic [XLEN-1:0] imm_rd_data_o
);

decode #(
    .XLEN(XLEN)
) decode (
    .alu_comp_i(alu_comp_i),

    .inst_data_i(inst_data_i),

    .pc_wr_en_o(pc_wr_en_o),
    .pc_wr_sel_o(pc_wr_sel_o),
    .pc_inc_sel_o(pc_inc_sel_o),

    .rd_wr_en_o(rd_wr_en_o),
    .rd_wr_sel_o(rd_wr_sel_o),
    .rd_wr_addr_o(rd_wr_addr_o),

    .rs1_rd_addr_o(rs1_rd_addr_o),
    .rs2_rd_addr_o(rs2_rd_addr_o),

    .alu_a_sel_o(alu_a_sel_o),
    .alu_b_sel_o(alu_b_sel_o),

    .alu_comp_sel_o(alu_comp_sel_o),

    .alu_op_0_sel_o(alu_op_0_sel_o),
    .alu_op_1_sel_o(alu_op_1_sel_o),

    .dram_wr_en_o(dram_wr_en_o),
    .dram_wr_sel_o(dram_wr_sel_o),
    .dram_rd_sel_o(dram_rd_sel_o),

    .imm_rd_data_o(imm_rd_data_o)
);

endmodule
