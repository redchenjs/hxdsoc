/*
 * test_ram_rw.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ram_rw;

localparam XLEN = 32;

logic clk_i;
logic rst_n_i;

logic dc_i;

logic       spi_byte_vld_i;
logic [7:0] spi_byte_data_i;

logic cpu_rst_n_o;

logic iram_wr_sel_o;
logic iram_rd_sel_o;

logic dram_wr_sel_o;
logic dram_rd_sel_o;

logic [XLEN-1:0] ram_rw_addr_o;
logic      [3:0] ram_wr_byte_en_o;

ram_rw #(
    .XLEN(XLEN)
) ram_rw (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld_i),
    .spi_byte_data_i(spi_byte_data_i),

    .cpu_rst_n_o(cpu_rst_n_o),

    .iram_rd_sel_o(iram_rd_sel_o),
    .iram_wr_sel_o(iram_wr_sel_o),

    .dram_rd_sel_o(dram_rd_sel_o),
    .dram_wr_sel_o(dram_wr_sel_o),

    .ram_rw_addr_o(ram_rw_addr_o),
    .ram_wr_byte_en_o(ram_wr_byte_en_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    dc_i <= 1'b0;

    spi_byte_vld_i  <= 1'b0;
    spi_byte_data_i <= 8'h00;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    // CPU_RST
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h2a;
    #5  spi_byte_vld_i  <= 1'b0;

    // CPU_RUN
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h2b;
    #5  spi_byte_vld_i  <= 1'b0;

    // IRAM_WR
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h2c;
    #5  spi_byte_vld_i  <= 1'b0;

    // IRAM DATA
    for (integer i = 0; i < 32; i++) begin
        #40 dc_i <= 1'b1;
            spi_byte_vld_i  <= 1'b1;
            spi_byte_data_i <= i % 8'hff;
        #5  spi_byte_vld_i  <= 1'b0;
    end

    // IRAM_RD
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h2d;
    #5  spi_byte_vld_i  <= 1'b0;

    // DUMMY DATA
    for (integer i = 0; i < 32; i++) begin
        #40 dc_i <= 1'b1;
            spi_byte_vld_i  <= 1'b1;
            spi_byte_data_i <= 1'b0;
        #5  spi_byte_vld_i  <= 1'b0;
    end

    // DRAM_WR
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h2e;
    #5  spi_byte_vld_i  <= 1'b0;

    // DRAM DATA
    for (integer i = 0; i < 32; i++) begin
        #40 dc_i <= 1'b1;
            spi_byte_vld_i  <= 1'b1;
            spi_byte_data_i <= i % 8'hff;
        #5  spi_byte_vld_i  <= 1'b0;
    end

    // DRAM_RD
    #40 dc_i <= 1'b0;
        spi_byte_vld_i  <= 1'b1;
        spi_byte_data_i <= 8'h2f;
    #5  spi_byte_vld_i  <= 1'b0;

    // DUMMY DATA
    for (integer i = 0; i < 32; i++) begin
        #40 dc_i <= 1'b1;
            spi_byte_vld_i  <= 1'b1;
            spi_byte_data_i <= 1'b0;
        #5  spi_byte_vld_i  <= 1'b0;
    end

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
