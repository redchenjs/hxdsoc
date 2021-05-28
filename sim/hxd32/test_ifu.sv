/*
 * test_ifu.sv
 *
 *  Created on: 2020-08-03 17:37
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ifu;

parameter XLEN = 32;

logic clk_i;
logic rst_n_i;

logic pc_wr_en_i;

logic [XLEN-1:0] iram_rd_data_i;
logic [XLEN-1:0] iram_rd_addr_o;

ifu #(
    .XLEN(XLEN)
) ifu (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_wr_en_i(pc_wr_en_i),

    .iram_rd_data_i(iram_rd_data_i),
    .iram_rd_addr_o(iram_rd_addr_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    pc_wr_en_i <= 1'b1;

    iram_rd_data_i <= 32'h0000_0000;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #25 iram_rd_data_i <= 32'h00000093;    // addi x1 x0 0
    #25 iram_rd_data_i <= 32'h0100026F;    // jal x4 16
    #25 iram_rd_data_i <= 32'h00000013;    // addi x0 x0 0
    #25 iram_rd_data_i <= 32'h00000013;    // addi x0 x0 0
    #25 iram_rd_data_i <= 32'h0100006F;    // jal x0 16
    #25 iram_rd_data_i <= 32'h00000117;    // auipc x2 0
    #25 iram_rd_data_i <= 32'hFF410113;    // addi x2 x2 -12
    #25 iram_rd_data_i <= 32'h00411263;    // bne x2 x4 4
    #25 iram_rd_data_i <= 32'h000302E7;    // jalr x5 x6 0

    #5120 rst_n_i <= 1'b0;

    #25 $stop;
end

endmodule
