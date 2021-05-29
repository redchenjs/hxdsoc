/*
 * test_top.sv
 *
 *  Created on: 2021-05-22 14:11
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_top;

localparam XLEN = 32;

logic clk_i;
logic rst_n_i;

logic dc_i;

logic spi_sclk_i;
logic spi_mosi_i;
logic spi_cs_n_i;
logic spi_miso_o;

logic cpu_rst_n;

logic iram_rd_sel;
logic iram_wr_sel;

logic dram_rd_sel;
logic dram_wr_sel;

logic       spi_byte_rdy;
logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic [XLEN-1:0] ram_rw_addr;
logic      [7:0] ram_rd_data;
logic      [3:0] ram_wr_byte_en;

logic [XLEN-1:0] iram_rd_addr;
logic [XLEN-1:0] dram_rd_addr;

logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;
logic      [3:0] dram_wr_byte_en;

logic [XLEN-1:0] iram_rd_data;
logic [XLEN-1:0] dram_rd_data;

spi_slave spi_slave(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .spi_byte_rdy_i(spi_byte_rdy),
    .spi_byte_data_i(ram_rd_data),

    .spi_sclk_i(spi_sclk_i),
    .spi_mosi_i(spi_mosi_i),
    .spi_cs_n_i(spi_cs_n_i),

    .spi_miso_o(spi_miso_o),

    .spi_byte_vld_o(spi_byte_vld),
    .spi_byte_data_o(spi_byte_data)
);

ram_rw #(
    .XLEN(XLEN)
) ram_rw (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .cpu_rst_n_o(cpu_rst_n),

    .iram_rd_sel_o(iram_rd_sel),
    .iram_wr_sel_o(iram_wr_sel),

    .dram_rd_sel_o(dram_rd_sel),
    .dram_wr_sel_o(dram_wr_sel),

    .spi_byte_rdy_o(spi_byte_rdy),

    .ram_rw_addr_o(ram_rw_addr),
    .ram_wr_byte_en_o(ram_wr_byte_en)
);

ram #(
    .XLEN(XLEN)
) ram (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .iram_rd_sel_i(iram_rd_sel),
    .iram_wr_sel_i(iram_wr_sel),

    .dram_rd_sel_i(dram_rd_sel),
    .dram_wr_sel_i(dram_wr_sel),

    .iram_rd_addr_a_i(iram_rd_addr),
    .iram_rd_addr_b_i(ram_rw_addr),

    .dram_rd_addr_a_i(dram_rd_addr),
    .dram_rd_addr_b_i(ram_rw_addr),

    .iram_wr_addr_i(ram_rw_addr),
    .iram_wr_data_i({spi_byte_data, spi_byte_data, spi_byte_data, spi_byte_data}),
    .iram_wr_byte_en_i(ram_wr_byte_en),

    .dram_wr_addr_a_i(dram_wr_addr),
    .dram_wr_data_a_i(dram_wr_data),
    .dram_wr_byte_en_a_i(dram_wr_byte_en),

    .dram_wr_addr_b_i(ram_rw_addr),
    .dram_wr_data_b_i({spi_byte_data, spi_byte_data, spi_byte_data, spi_byte_data}),
    .dram_wr_byte_en_b_i(ram_wr_byte_en),

    .iram_rd_data_o(iram_rd_data),
    .dram_rd_data_o(dram_rd_data),

    .ram_rd_data_o(ram_rd_data)
);

hxd32 #(
    .XLEN(XLEN)
) hxd32 (
    .clk_i(clk_i),
    .rst_n_i(cpu_rst_n),

    .iram_rd_data_i(iram_rd_data),
    .dram_rd_data_i(dram_rd_data),

    .iram_rd_addr_o(iram_rd_addr),
    .dram_rd_addr_o(dram_rd_addr),

    .dram_wr_addr_o(dram_wr_addr),
    .dram_wr_data_o(dram_wr_data),
    .dram_wr_byte_en_o(dram_wr_byte_en)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    dc_i <= 1'b0;

    spi_cs_n_i <= 1'b1;
    spi_sclk_i <= 1'b0;
    spi_mosi_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #50 spi_cs_n_i <= 1'b0;

    // IRAM_WR
    #20 dc_i <= 1'b0;

    // 0x2C
    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT7
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT6
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT5
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT4
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT3
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT2
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT1
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT0
    #15 spi_sclk_i <= 1'b1;

    #20 dc_i <= 1'b1;

    for (integer i = 0; i < 8; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b1;
        #15 spi_sclk_i <= 1'b1;
    end

    for (integer i = 0; i < 8; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b1;
        #15 spi_sclk_i <= 1'b1;
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
    end

    // IRAM_RD
    #20 dc_i <= 1'b0;

    // 0x2D
    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT7
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT6
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT5
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT4
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT3
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT2
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT1
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT0
    #15 spi_sclk_i <= 1'b1;

    #20 dc_i <= 1'b1;

    for (integer i = 0; i < 32; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
    end

    // DRAM_WR
    #20 dc_i <= 1'b0;

    // 0x2E
    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT7
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT6
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT5
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT4
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT3
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT2
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT1
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT0
    #15 spi_sclk_i <= 1'b1;

    #20 dc_i <= 1'b1;

    for (integer i = 0; i < 8; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b1;
        #15 spi_sclk_i <= 1'b1;
    end

    for (integer i = 0; i < 8; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b1;
        #15 spi_sclk_i <= 1'b1;
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
    end

    // DRAM_RD
    #20 dc_i <= 1'b0;

    // 0x2F
    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT7
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT6
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT5
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b0;  // BIT4
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT3
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT2
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT1
    #15 spi_sclk_i <= 1'b1;

    #15 spi_sclk_i <= 1'b0;
        spi_mosi_i <= 1'b1;  // BIT0
    #15 spi_sclk_i <= 1'b1;

    #20 dc_i <= 1'b1;

    for (integer i = 0; i < 32; i++) begin
        #15 spi_sclk_i <= 1'b0;
            spi_mosi_i <= 1'b0;
        #15 spi_sclk_i <= 1'b1;
    end

    #20 dc_i <= 1'b0;

    #15 spi_sclk_i <= 1'b0;

    #25 spi_cs_n_i <= 1'b1;

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
