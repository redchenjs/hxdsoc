/*
 * pipe_idu.sv
 *
 *  Created on: 2021-08-03 10:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

module pipe_idu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic       pc_wr_en_i,
    input logic [1:0] pc_wr_sel_i,
    input logic [1:0] pc_inc_sel_i,

    input logic [1:0] alu_a_sel_i,
    input logic [1:0] alu_b_sel_i,

    input logic [2:0] alu_comp_sel_i,

    input logic       alu_op_0_sel_i,
    input logic [2:0] alu_op_1_sel_i,

    input logic       dram_wr_en_i,
    input logic [2:0] dram_wr_sel_i,
    input logic [2:0] dram_rd_sel_i,

    input logic       rd_wr_en_i,
    input logic [1:0] rd_wr_sel_i,
    input logic [4:0] rd_wr_addr_i,

    input logic [4:0] rs1_rd_addr_i,
    input logic [4:0] rs2_rd_addr_i,

    input logic [XLEN-1:0] imm_rd_data_i,

    output logic       pc_wr_en_o,
    output logic [1:0] pc_wr_sel_o,
    output logic [1:0] pc_inc_sel_o,

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

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        pc_wr_en_o   <= 1'b0;
        pc_wr_sel_o  <= 2'b00;
        pc_inc_sel_o <= 2'b00;

        alu_a_sel_o <= 2'b00;
        alu_b_sel_o <= 2'b00;

        alu_comp_sel_o <= 3'b000;

        alu_op_0_sel_o <= 1'b0;
        alu_op_1_sel_o <= 3'b000;

        dram_wr_en_o  <= 1'b0;
        dram_wr_sel_o <= 3'b000;
        dram_rd_sel_o <= 3'b000;

        rd_wr_en_o   <= 1'b0;
        rd_wr_sel_o  <= 2'b00;
        rd_wr_addr_o <= 5'h00;

        rs1_rd_addr_o <= 5'h00;
        rs2_rd_addr_o <= 5'h00;

        imm_rd_data_o <= {XLEN{1'b0}};
    end else begin
        pc_wr_en_o   <= pc_wr_en_i;
        pc_wr_sel_o  <= pc_wr_sel_i;
        pc_inc_sel_o <= pc_inc_sel_i;

        alu_a_sel_o <= alu_a_sel_i;
        alu_b_sel_o <= alu_b_sel_i;

        alu_comp_sel_o <= alu_comp_sel_i;

        alu_op_0_sel_o <= alu_op_0_sel_i;
        alu_op_1_sel_o <= alu_op_1_sel_i;

        dram_wr_en_o  <= dram_wr_en_i;
        dram_wr_sel_o <= dram_wr_sel_i;
        dram_rd_sel_o <= dram_rd_sel_i;

        rd_wr_en_o   <= rd_wr_en_i;
        rd_wr_sel_o  <= rd_wr_sel_i;
        rd_wr_addr_o <= rd_wr_addr_i;

        rs1_rd_addr_o <= rs1_rd_addr_i;
        rs2_rd_addr_o <= rs2_rd_addr_i;

        imm_rd_data_o <= imm_rd_data_i;
    end
end

endmodule
