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

    inout wire [XLEN-1:0] iram_rd_addr_io,
    inout wire [XLEN-1:0] dram_rd_addr_io,

    inout wire [XLEN-1:0] dram_wr_addr_io,
    inout wire [XLEN-1:0] dram_wr_data_io,
    inout wire      [3:0] dram_wr_byte_en_io,

    output logic cpu_fault_o
);

logic [XLEN-1:0] inst_data;
logic            inst_error;

logic       pc_wr_en;
logic [1:0] pc_wr_sel;
logic [1:0] pc_inc_sel;

logic [XLEN-1:0] pc_data;

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

logic       rd_wr_en;
logic [1:0] rd_wr_sel;
logic [4:0] rd_wr_addr;

logic [4:0] rs1_rd_addr;
logic [4:0] rs2_rd_addr;

logic [XLEN-1:0] rs1_rd_data;
logic [XLEN-1:0] rs2_rd_data;
logic [XLEN-1:0] imm_rd_data;

logic [3:0] dram_wr_byte_en;

logic            reg_wr_en;
logic      [4:0] reg_wr_addr;
logic [XLEN-1:0] reg_wr_data;

/* pipeline regs */

logic       pc_wr_en_r1;
logic [1:0] pc_wr_sel_r1;
logic [1:0] pc_inc_sel_r1;

logic [XLEN-1:0] pc_data_r1;

logic            alu_comp_r1;
logic [XLEN-1:0] alu_data_r1;

logic [1:0] alu_a_sel_r1;
logic [1:0] alu_b_sel_r1;

logic [2:0] alu_comp_sel_r1;

logic       alu_op_0_sel_r1;
logic [2:0] alu_op_1_sel_r1;

logic       dram_wr_en_r1;
logic [2:0] dram_wr_sel_r1;
logic [2:0] dram_rd_sel_r1;

logic       rd_wr_en_r1;
logic [1:0] rd_wr_sel_r1;
logic [4:0] rd_wr_addr_r1;

logic [4:0] rs1_rd_addr_r1;
logic [4:0] rs2_rd_addr_r1;

logic [XLEN-1:0] rs1_rd_data_r1;
logic [XLEN-1:0] rs2_rd_data_r1;
logic [XLEN-1:0] imm_rd_data_r1;

logic [3:0] dram_wr_byte_en_r1;

logic            reg_wr_en_r1;
logic      [4:0] reg_wr_addr_r1;
logic [XLEN-1:0] reg_wr_data_r1;

assign inst_data = pc_inc_sel_r1[1] | ~pc_wr_en_r1 | (pc_wr_sel_r1 != PC_WR_NEXT) ? (pc_inc_sel_r1[0] ? 32'h0005_0005 : 32'h0000_0013) : iram_rd_data_i;

assign iram_rd_addr_io = rst_n_i ? pc_data : {XLEN{1'bz}};
assign dram_rd_addr_io = rst_n_i ? alu_data : {XLEN{1'bz}};

assign dram_wr_addr_io    = rst_n_i ? alu_data : {XLEN{1'bz}};
assign dram_wr_data_io    = rst_n_i ? rs2_rd_data : {XLEN{1'bz}};
assign dram_wr_byte_en_io = rst_n_i ? dram_wr_byte_en : {4{1'bz}};

assign cpu_fault_o = inst_error;

ifu #(
    .XLEN(XLEN)
) ifu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_wr_en_i(pc_wr_en & ~inst_error),
    .pc_wr_sel_i(pc_wr_sel),
    .pc_inc_sel_i(pc_inc_sel),

    .alu_data_i(alu_data),

    .pc_data_o(pc_data)
);

pipe_ifu #(
    .XLEN(XLEN)
) pipe_ifu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_data_i(pc_data),
    .pc_data_o(pc_data_r1)
);

idu #(
    .XLEN(XLEN)
) idu (
    .alu_comp_i(alu_comp),

    .pc_inc_sel_r_i(pc_inc_sel_r1),

    .inst_data_i(inst_data),

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

    .rd_wr_en_o(rd_wr_en),
    .rd_wr_sel_o(rd_wr_sel),
    .rd_wr_addr_o(rd_wr_addr),

    .rs1_rd_addr_o(rs1_rd_addr),
    .rs2_rd_addr_o(rs2_rd_addr),

    .imm_rd_data_o(imm_rd_data)
);

pipe_idu #(
    .XLEN(XLEN)
) pipe_idu (
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

    .rd_wr_en_i(rd_wr_en),
    .rd_wr_sel_i(rd_wr_sel),
    .rd_wr_addr_i(rd_wr_addr),

    .rs1_rd_addr_i(rs1_rd_addr),
    .rs2_rd_addr_i(rs2_rd_addr),

    .imm_rd_data_i(imm_rd_data),

    .pc_wr_en_o(pc_wr_en_r1),
    .pc_wr_sel_o(pc_wr_sel_r1),
    .pc_inc_sel_o(pc_inc_sel_r1),

    .alu_a_sel_o(alu_a_sel_r1),
    .alu_b_sel_o(alu_b_sel_r1),

    .alu_comp_sel_o(alu_comp_sel_r1),

    .alu_op_0_sel_o(alu_op_0_sel_r1),
    .alu_op_1_sel_o(alu_op_1_sel_r1),

    .dram_wr_en_o(dram_wr_en_r1),
    .dram_wr_sel_o(dram_wr_sel_r1),
    .dram_rd_sel_o(dram_rd_sel_r1),

    .rd_wr_en_o(rd_wr_en_r1),
    .rd_wr_sel_o(rd_wr_sel_r1),
    .rd_wr_addr_o(rd_wr_addr_r1),

    .rs1_rd_addr_o(rs1_rd_addr_r1),
    .rs2_rd_addr_o(rs2_rd_addr_r1),

    .imm_rd_data_o(imm_rd_data_r1)
);

regfile #(
    .XLEN(XLEN)
) regfile (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rd_wr_en_i(reg_wr_en),
    .rd_wr_addr_i(reg_wr_addr),
    .rd_wr_data_i(reg_wr_data),

    .rs1_rd_addr_i(rs1_rd_addr),
    .rs2_rd_addr_i(rs2_rd_addr),

    .rs1_rd_data_o(rs1_rd_data),
    .rs2_rd_data_o(rs2_rd_data)
);

pipe_regfile #(
    .XLEN(XLEN)
) pipe_regfile (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rs1_rd_data_i(rs1_rd_data),
    .rs2_rd_data_i(rs2_rd_data),

    .rs1_rd_data_o(rs1_rd_data_r1),
    .rs2_rd_data_o(rs2_rd_data_r1)
);

exu #(
    .XLEN(XLEN)
) exu (
    .pc_data_i(pc_data_r1),

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

pipe_exu #(
    .XLEN(XLEN)
) pipe_exu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .alu_comp_i(alu_comp),
    .alu_data_i(alu_data),

    .alu_comp_o(alu_comp_r1),
    .alu_data_o(alu_data_r1)
);

mem #(
    .XLEN(XLEN)
) mem (
    .dram_wr_en_i(dram_wr_en),
    .dram_wr_sel_i(dram_wr_sel),

    .dram_wr_byte_en_o(dram_wr_byte_en)
);

pipe_mem #(
    .XLEN(XLEN)
) pipe_mem (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dram_wr_byte_en_i(dram_wr_byte_en),

    .dram_wr_byte_en_o(dram_wr_byte_en_r1)
);

wb #(
    .XLEN(XLEN)
) wb (
    .rd_wr_en_i(rd_wr_en),
    .rd_wr_sel_i(rd_wr_sel),
    .rd_wr_addr_i(rd_wr_addr),

    .rd_wr_en_r_i(rd_wr_en_r1),
    .rd_wr_sel_r_i(rd_wr_sel_r1),
    .rd_wr_addr_r_i(rd_wr_addr_r1),

    .pc_data_i(pc_data_r1),

    .alu_data_i(alu_data),

    .dram_rd_sel_i(dram_rd_sel),
    .dram_rd_data_i(dram_rd_data_i),

    .dram_rd_sel_r_i(dram_rd_sel_r1),

    .reg_wr_en_o(reg_wr_en),
    .reg_wr_addr_o(reg_wr_addr),
    .reg_wr_data_o(reg_wr_data)
);

pipe_wb #(
    .XLEN(XLEN)
) pipe_wb (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .reg_wr_en_i(reg_wr_en),
    .reg_wr_addr_i(reg_wr_addr),
    .reg_wr_data_i(reg_wr_data),

    .reg_wr_en_o(reg_wr_en_r1),
    .reg_wr_addr_o(reg_wr_addr_r1),
    .reg_wr_data_o(reg_wr_data_r1)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        inst_error <= 1'b0;
    end else begin
        inst_error <= (inst_data[15:0] == 16'h0000) ? 1'b1 : inst_error;
    end
end

endmodule
