/*
 * idu.sv
 *
 *  Created on: 2020-08-02 16:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

module idu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] pc_next_i,

    input logic            alu_comp_i,
    input logic [XLEN-1:0] alu_data_i,

    input logic [XLEN-1:0] rd_wr_data_i,

    input logic [XLEN-1:0] iram_rd_data_i,

    output logic pc_wr_en_o,
    output logic pc_wr_sel_o,
    output logic pc_inc_sel_o,

    output logic [1:0] alu_a_sel_o,
    output logic [1:0] alu_b_sel_o,

    output logic [2:0] alu_comp_sel_o,

    output logic       alu_op_0_sel_o,
    output logic [2:0] alu_op_1_sel_o,

    output logic       dram_wr_en_o,
    output logic [1:0] dram_wr_sel_o,
    output logic [2:0] dram_rd_sel_o,

    output logic [XLEN-1:0] rs1_rd_data_o,
    output logic [XLEN-1:0] rs2_rd_data_o,
    output logic [XLEN-1:0] imm_rd_data_o
);

logic       rd_wr_en;
logic [1:0] rd_wr_sel;
logic [4:0] rd_wr_addr;

logic [4:0] rs1_rd_addr;
logic [4:0] rs2_rd_addr;

logic [XLEN-1:0] rd_wr_data;

decode #(
    .XLEN(XLEN)
) decode (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .alu_comp_i(alu_comp_i),

    .inst_data_i(iram_rd_data_i),

    .pc_wr_en_o(pc_wr_en_o),
    .pc_wr_sel_o(pc_wr_sel_o),
    .pc_inc_sel_o(pc_inc_sel_o),

    .rd_wr_en_o(rd_wr_en),
    .rd_wr_sel_o(rd_wr_sel),
    .rd_wr_addr_o(rd_wr_addr),

    .rs1_rd_addr_o(rs1_rd_addr),
    .rs2_rd_addr_o(rs2_rd_addr),

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

regfile #(
    .XLEN(XLEN)
) regfile (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rd_wr_en_i(rd_wr_en),
    .rd_wr_addr_i(rd_wr_addr),
    .rd_wr_data_i(rd_wr_data),

    .rs1_rd_addr_i(rs1_rd_addr),
    .rs2_rd_addr_i(rs2_rd_addr),

    .rs1_rd_data_o(rs1_rd_data_o),
    .rs2_rd_data_o(rs2_rd_data_o)
);

always_comb begin
    case (rd_wr_sel)
        RD_WR_ALU:
            rd_wr_data = alu_data_i;
        RD_WR_DRAM:
            rd_wr_data = rd_wr_data_i;
        RD_WR_PC_NEXT:
            rd_wr_data = pc_next_i;
        default:
            rd_wr_data = 32'h0000_0000;
    endcase
end

endmodule
