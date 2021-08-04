/*
 * hxd32.sv
 *
 *  Created on: 2020-08-02 16:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

module hxd32 #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] iram_rd_data_i,
    input logic [XLEN-1:0] dram_rd_data_i,

    output logic [XLEN-1:0] iram_rd_addr_o,
    output logic [XLEN-1:0] dram_rd_addr_o,

    output logic [XLEN-1:0] dram_wr_addr_o,
    output logic [XLEN-1:0] dram_wr_data_o,
    output logic      [3:0] dram_wr_byte_en_o
);

logic pc_wr_en;
logic pc_wr_sel;
logic pc_inc_sel;

logic [XLEN-1:0] pc_data;
logic [XLEN-1:0] pc_next;

logic            alu_comp;
logic [XLEN-1:0] alu_data;

logic [1:0] alu_a_sel;
logic [1:0] alu_b_sel;

logic [2:0] alu_comp_sel;

logic       alu_op_0_sel;
logic [2:0] alu_op_1_sel;

logic       dram_wr_en;
logic [2:0] dram_wr_sel;
logic [2:0] dram_rd_sel;

logic [XLEN-1:0] rd_wr_data;

logic [XLEN-1:0] rs1_rd_data;
logic [XLEN-1:0] rs2_rd_data;
logic [XLEN-1:0] imm_rd_data;

logic [3:0] dram_wr_byte_en;

logic pc_wr_en_r;
logic pc_wr_sel_r;
logic pc_inc_sel_r;

logic [XLEN-1:0] pc_data_r;
logic [XLEN-1:0] pc_next_r;

logic            alu_comp_r;
logic [XLEN-1:0] alu_data_r;

logic [1:0] alu_a_sel_r;
logic [1:0] alu_b_sel_r;

logic [2:0] alu_comp_sel_r;

logic       alu_op_0_sel_r;
logic [2:0] alu_op_1_sel_r;

logic       dram_wr_en_r;
logic [2:0] dram_wr_sel_r;
logic [2:0] dram_rd_sel_r;

logic [XLEN-1:0] rd_wr_data_r;

logic [XLEN-1:0] rs1_rd_data_r;
logic [XLEN-1:0] rs2_rd_data_r;
logic [XLEN-1:0] imm_rd_data_r;

logic [3:0] dram_wr_byte_en_r;

assign iram_rd_addr_o = pc_data;
assign dram_rd_addr_o = alu_data;

assign dram_wr_addr_o    = alu_data;
assign dram_wr_data_o    = rs2_rd_data;
assign dram_wr_byte_en_o = dram_wr_byte_en;

ifu #(
    .XLEN(XLEN)
) ifu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_wr_en_i(pc_wr_en),
    .pc_wr_sel_i(pc_wr_sel),
    .pc_inc_sel_i(pc_inc_sel),

    .alu_data_i(alu_data),

    .pc_data_o(pc_data),
    .pc_next_o(pc_next)
);

ifu_reg #(
    .XLEN(XLEN)
) ifu_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_data_i(pc_data),
    .pc_next_i(pc_next),

    .pc_data_o(pc_data_r),
    .pc_next_o(pc_next_r)
);

idu #(
    .XLEN(XLEN)
) idu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_next_i(pc_next_r),

    .alu_comp_i(alu_comp),
    .alu_data_i(alu_data),

    .inst_data_i(iram_rd_data_i),

    .rd_wr_data_i(rd_wr_data),

    .pc_wr_en_o(pc_wr_en),
    .pc_wr_sel_o(pc_wr_sel),
    .pc_inc_sel_o(pc_inc_sel),

    .alu_a_sel_o(alu_a_sel),
    .alu_b_sel_o(alu_b_sel),

    .alu_comp_sel_o(alu_comp_sel),

    .alu_op_0_sel_o(alu_op_0_sel),
    .alu_op_1_sel_o(alu_op_1_sel),

    .dram_wr_en_o(dram_wr_en),
    .dram_wr_sel_o(dram_wr_sel),
    .dram_rd_sel_o(dram_rd_sel),

    .rs1_rd_data_o(rs1_rd_data),
    .rs2_rd_data_o(rs2_rd_data),
    .imm_rd_data_o(imm_rd_data)
);

idu_reg #(
    .XLEN(XLEN)
) idu_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_wr_en_i(pc_wr_en),
    .pc_wr_sel_i(pc_wr_sel),
    .pc_inc_sel_i(pc_inc_sel),

    .alu_a_sel_i(alu_a_sel),
    .alu_b_sel_i(alu_b_sel),

    .alu_comp_sel_i(alu_comp_sel),

    .alu_op_0_sel_i(alu_op_0_sel),
    .alu_op_1_sel_i(alu_op_1_sel),

    .dram_wr_en_i(dram_wr_en),
    .dram_wr_sel_i(dram_wr_sel),
    .dram_rd_sel_i(dram_rd_sel),

    .rs1_rd_data_i(rs1_rd_data),
    .rs2_rd_data_i(rs2_rd_data),
    .imm_rd_data_i(imm_rd_data),

    .pc_wr_en_o(pc_wr_en_r),
    .pc_wr_sel_o(pc_wr_sel_r),
    .pc_inc_sel_o(pc_inc_sel_r),

    .alu_a_sel_o(alu_a_sel_r),
    .alu_b_sel_o(alu_b_sel_r),

    .alu_comp_sel_o(alu_comp_sel_r),

    .alu_op_0_sel_o(alu_op_0_sel_r),
    .alu_op_1_sel_o(alu_op_1_sel_r),

    .dram_wr_en_o(dram_wr_en_r),
    .dram_wr_sel_o(dram_wr_sel_r),
    .dram_rd_sel_o(dram_rd_sel_r),

    .rs1_rd_data_o(rs1_rd_data_r),
    .rs2_rd_data_o(rs2_rd_data_r),
    .imm_rd_data_o(imm_rd_data_r)
);

exu #(
    .XLEN(XLEN)
) exu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_data_i(pc_data_r),

    .rs1_rd_data_i(rs1_rd_data),
    .rs2_rd_data_i(rs2_rd_data),
    .imm_rd_data_i(imm_rd_data),

    .alu_a_sel_i(alu_a_sel),
    .alu_b_sel_i(alu_b_sel),

    .alu_comp_sel_i(alu_comp_sel),

    .alu_op_0_sel_i(alu_op_0_sel),
    .alu_op_1_sel_i(alu_op_1_sel),

    .alu_comp_o(alu_comp),
    .alu_data_o(alu_data)
);

exu_reg #(
    .XLEN(XLEN)
) exu_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .alu_comp_i(alu_comp),
    .alu_data_i(alu_data),

    .alu_comp_o(alu_comp_r),
    .alu_data_o(alu_data_r)
);

mem #(
    .XLEN(XLEN)
) mem (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dram_wr_en_i(dram_wr_en),
    .dram_wr_sel_i(dram_wr_sel),

    .dram_wr_byte_en_o(dram_wr_byte_en)
);

mem_reg #(
    .XLEN(XLEN)
) mem_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dram_wr_byte_en_i(dram_wr_byte_en),

    .dram_wr_byte_en_o(dram_wr_byte_en_r)
);

wb #(
    .XLEN(XLEN)
) wb (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dram_rd_sel_i(dram_rd_sel),
    .dram_rd_data_i(dram_rd_data_i),

    .rd_wr_data_o(rd_wr_data)
);

wb_reg #(
    .XLEN(XLEN)
) wb_reg (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rd_wr_data_i(rd_wr_data),

    .rd_wr_data_o(rd_wr_data_r)
);

endmodule
