/*
 * test_hxd32.sv
 *
 *  Created on: 2021-05-29 11:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_hxd32;

localparam XLEN = 32;

logic clk_i;
logic rst_n_i;

logic [XLEN-1:0] iram_rd_data_i;
logic [XLEN-1:0] dram_rd_data_i;

logic [XLEN-1:0] iram_rd_addr_o;
logic [XLEN-1:0] dram_rd_addr_o;

logic [XLEN-1:0] dram_wr_addr_o;
logic [XLEN-1:0] dram_wr_data_o;
logic      [3:0] dram_wr_byte_en_o;

hxd32 #(
    .XLEN(XLEN)
) hxd32 (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .iram_rd_data_i(iram_rd_data_i),
    .dram_rd_data_i(dram_rd_data_i),

    .iram_rd_addr_o(iram_rd_addr_o),
    .dram_rd_addr_o(dram_rd_addr_o),

    .dram_wr_addr_o(dram_wr_addr_o),
    .dram_wr_data_o(dram_wr_data_o),
    .dram_wr_byte_en_o(dram_wr_byte_en_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    iram_rd_data_i <= 32'h0000_0000;
    dram_rd_data_i <= 32'h0000_0000;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #2.5

    // rs2 == rd != rs1, rs1==x4, rs2==x24, rd==x24, rs1_val > 0 and rs2_val > 0, rs2_val == 1, rs1_val == (2**(xlen-1)-1), rs1_val != rs2_val, rs1_val == 2147483647
    // opcode: add ; op1:x4; op2:x24; dest:x24; op1val:0x7fffffff;  op2val:0x1
    #5 iram_rd_data_i <= 32'h80000237;          	// lui	tp,0x80000
    #5 iram_rd_data_i <= 32'hfff20213;          	// addi	tp,tp,-1 # 7fffffff <_end+0xffffa4fb>
    #5 iram_rd_data_i <= 32'h00100c13;          	// li	s8,1
    #5 iram_rd_data_i <= 32'h01820c33;          	// add	s8,tp,s8
    #5 iram_rd_data_i <= 32'h0181a023;          	// sw	s8,0(gp)

    // rs1 == rs2 != rd, rs1==x10, rs2==x10, rd==x28, rs1_val > 0 and rs2_val < 0, rs2_val == -257, rs1_val == 131072
    // opcode: add ; op1:x10; op2:x10; dest:x28; op1val:0x20000;  op2val:0x20000
    #5 iram_rd_data_i <= 32'h00020537;          	// lui	a0,0x20
    #5 iram_rd_data_i <= 32'h00020537;          	// lui	a0,0x20
    #5 iram_rd_data_i <= 32'h00a50e33;          	// add	t3,a0,a0
    #5 iram_rd_data_i <= 32'h01c1a223;          	// sw	t3,4(gp)

    // rs1 == rs2 == rd, rs1==x21, rs2==x21, rd==x21, rs1_val < 0 and rs2_val < 0, rs1_val == -16777217
    // opcode: add ; op1:x21; op2:x21; dest:x21; op1val:-0x1000001;  op2val:-0x1000001
    #5 iram_rd_data_i <= 32'hff000ab7;          	// lui	s5,0xff000
    #5 iram_rd_data_i <= 32'hfffa8a93;          	// addi	s5,s5,-1 # feffffff <_end+0x7effa4fb>
    #5 iram_rd_data_i <= 32'hff000ab7;          	// lui	s5,0xff000
    #5 iram_rd_data_i <= 32'hfffa8a93;          	// addi	s5,s5,-1 # feffffff <_end+0x7effa4fb>
    #5 iram_rd_data_i <= 32'h015a8ab3;          	// add	s5,s5,s5
    #5 iram_rd_data_i <= 32'h0151a423;          	// sw	s5,8(gp)

    // rs1 == rd != rs2, rs1==x22, rs2==x31, rd==x22, rs1_val < 0 and rs2_val > 0, rs1_val == -2, rs2_val == 262144
    // opcode: add ; op1:x22; op2:x31; dest:x22; op1val:-0x2;  op2val:0x40000
    #5 iram_rd_data_i <= 32'hffe00b13;          	// li	s6,-2
    #5 iram_rd_data_i <= 32'h00040fb7;          	// lui	t6,0x40
    #5 iram_rd_data_i <= 32'h01fb0b33;          	// add	s6,s6,t6
    #5 iram_rd_data_i <= 32'h0161a623;          	// sw	s6,12(gp)

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
