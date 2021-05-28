/*
 * test_regfile.sv
 *
 *  Created on: 2020-07-08 18:23
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_regfile;

localparam XLEN = 32;

logic clk_i;
logic rst_n_i;

logic            rd_wr_en_i;
logic      [4:0] rd_wr_addr_i;
logic [XLEN-1:0] rd_wr_data_i;

logic [4:0] rs1_rd_addr_i;
logic [4:0] rs2_rd_addr_i;

logic [XLEN-1:0] rs1_rd_data_o;
logic [XLEN-1:0] rs2_rd_data_o;

regfile test_regfile(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rd_wr_en_i(rd_wr_en_i),
    .rd_wr_addr_i(rd_wr_addr_i),
    .rd_wr_data_i(rd_wr_data_i),

    .rs1_rd_addr_i(rs1_rd_addr_i),
    .rs2_rd_addr_i(rs2_rd_addr_i),

    .rs1_rd_data_o(rs1_rd_data_o),
    .rs2_rd_data_o(rs2_rd_data_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    rd_wr_en_i   <= 1'b0;
    rd_wr_addr_i <= 5'h00;
    rd_wr_data_i <= 32'h0000_0000;

    rs1_rd_addr_i <= 5'h00;
    rs2_rd_addr_i <= 5'h00;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    for (integer i = 0; i < 32; i++) begin
        #6 rd_wr_data_i <= i + 16;
        #6 rd_wr_addr_i <= i;
        #6 rd_wr_en_i <= 1'b1;
        #6 rd_wr_en_i <= 1'b0;
    end

    for (integer i = 0; i < 32; i++) begin
        #6 rs1_rd_addr_i <= i;
        #6 rs2_rd_addr_i <= i + 16;
    end

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
