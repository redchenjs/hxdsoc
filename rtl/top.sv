/*
 * top.sv
 *
 *  Created on: 2020-07-19 17:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module hxdsoc(
    input logic clk_i,          // clk_i = 12 MHz
    input logic rst_n_i,        // rst_n_i, active low

    input logic dc_i,

    input logic spi_sclk_i,
    input logic spi_mosi_i,
    input logic spi_cs_n_i,

    output logic spi_miso_o,

    output logic [7:0] water_led_o,

    output logic [8:0] segment_led_1_o,
    output logic [8:0] segment_led_2_o
);

localparam XLEN = 32;

logic sys_clk;
logic sys_rst_n;

logic iram_rw_sel;
logic dram_rd_sel;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic            iram_wr_en;
logic [XLEN-1:0] iram_wr_addr;
logic [XLEN-1:0] iram_wr_data;

logic [XLEN-1:0] iram_rd_addr;
logic [XLEN-1:0] dram_rd_addr_a;
logic [XLEN-1:0] dram_rd_addr_b;

logic [XLEN-1:0] iram_rd_data;
logic [XLEN-1:0] dram_rd_data_a;
logic      [7:0] dram_rd_data_b;

logic            dram_wr_en;
logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;

sys_ctl sys_ctl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

spi_slave spi_slave(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .spi_byte_data_i(dram_rd_data_b),

    .spi_sclk_i(spi_sclk_i),
    .spi_mosi_i(spi_mosi_i),
    .spi_cs_n_i(spi_cs_n_i),

    .spi_miso_o(spi_miso_o),

    .spi_byte_vld_o(spi_byte_vld),
    .spi_byte_data_o(spi_byte_data)
);

ram_rw ram_rw(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .iram_rw_sel_o(iram_rw_sel),
    .dram_rd_sel_o(dram_rd_sel),

    .iram_wr_en_o(iram_wr_en),
    .iram_wr_addr_o(iram_wr_addr),
    .iram_wr_data_o(iram_wr_data),
    
    .dram_rd_addr_o(dram_rd_addr_b)
);

ram #(
    .XLEN(XLEN)
) ram (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .iram_rw_sel_i(iram_rw_sel),
    .dram_rd_sel_i(dram_rd_sel),

    .iram_rd_addr_i(iram_rd_addr),
    .dram_rd_addr_a_i(dram_rd_addr_a),
    .dram_rd_addr_b_i(dram_rd_addr_b),

    .iram_wr_en_i(iram_wr_en),
    .iram_wr_addr_i(iram_wr_addr),
    .iram_wr_data_i(iram_wr_data),

    .dram_wr_en_i(dram_wr_en),
    .dram_wr_addr_i(dram_wr_addr),
    .dram_wr_data_i(dram_wr_data),

    .iram_rd_data_o(iram_rd_data),
    .dram_rd_data_a_o(dram_rd_data_a),
    .dram_rd_data_b_o(dram_rd_data_b)
);

hxd32 #(
    .XLEN(XLEN)
) hxd32 (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .iram_rd_data_i(iram_rd_data),
    .dram_rd_data_i(dram_rd_data_a),

    .iram_rd_addr_o(iram_rd_addr),
    .dram_rd_addr_o(dram_rd_addr),

    .dram_wr_en_o(dram_wr_en),
    .dram_wr_addr_o(dram_wr_addr),
    .dram_wr_data_o(dram_wr_data),
    .dram_wr_byte_en_o(dram_wr_byte_en)
);

endmodule
