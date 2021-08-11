/*
 * top_cmod_a7.sv
 *
 *  Created on: 2020-07-19 17:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module top_cmod_a7(
    input logic clk_i,          // clk_i = 12 MHz
    input logic rst_n_i,        // rst_n_i, active low

    input logic dc_i,

    input logic spi_sclk_i,
    input logic spi_mosi_i,
    input logic spi_cs_n_i,

    input logic btn0_i,
    input logic btn1_i,

    input logic uart_rx_i,

    output logic uart_tx_o,

    output logic spi_miso_o,

    output logic led0_r_n_o,
    output logic led0_g_n_o,
    output logic led0_b_n_o,
    output logic led1_o,
    output logic led2_o
);

localparam XLEN = 32;

logic sys_clk;
logic sys_rst_n;

logic cpu_rst_n;

logic iram_rd_sel;
logic iram_wr_sel;

logic dram_rd_sel;
logic dram_wr_sel;

logic       spi_byte_vld;
logic [7:0] spi_byte_data;

logic [7:0] uart_tx_data;
logic       uart_tx_data_rdy;
logic       uart_tx_data_vld;

logic [7:0] uart_rx_data;
logic       uart_rx_data_rdy;
logic       uart_rx_data_vld;

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

assign led0_r_n_o = ~(rst_n_i & ~cpu_rst_n & ~(iram_rd_sel | iram_wr_sel | dram_rd_sel | dram_wr_sel));
assign led0_g_n_o = ~(rst_n_i & cpu_rst_n);
assign led0_b_n_o = ~(rst_n_i & ~cpu_rst_n & (iram_rd_sel | iram_wr_sel | dram_rd_sel | dram_wr_sel));
assign led1_o = iram_rd_sel | iram_wr_sel;
assign led2_o = dram_rd_sel | dram_wr_sel;

sys_ctl sys_ctl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

uart_rx uart_rx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_rx_i(uart_rx_i),
    .uart_rx_data_rdy_i(uart_rx_data_rdy),

    .uart_rx_baud_div_i(32'd434),

    .uart_rx_data_o(uart_rx_data),
    .uart_rx_data_vld_o(uart_rx_data_vld)
);

pipe #(
    .WIDTH(32'h8)
) pipe (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .data_i(uart_rx_data),
    .data_vld_i(uart_rx_data_vld),
    .data_rdy_i(uart_tx_data_rdy),

    .data_o(uart_tx_data),
    .data_vld_o(uart_tx_data_vld),
    .data_rdy_o(uart_rx_data_rdy)
);

uart_tx uart_tx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_tx_data_i(uart_tx_data),
    .uart_tx_data_vld_i(uart_tx_data_vld),

    .uart_tx_baud_div_i(32'd434),

    .uart_tx_o(uart_tx_o),
    .uart_tx_data_rdy_o(uart_tx_data_rdy)
);

spi_slave spi_slave(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

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
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .dc_i(dc_i),

    .spi_byte_vld_i(spi_byte_vld),
    .spi_byte_data_i(spi_byte_data),

    .cpu_rst_n_o(cpu_rst_n),

    .iram_rd_sel_o(iram_rd_sel),
    .iram_wr_sel_o(iram_wr_sel),

    .dram_rd_sel_o(dram_rd_sel),
    .dram_wr_sel_o(dram_wr_sel),

    .ram_rw_addr_o(ram_rw_addr),
    .ram_wr_byte_en_o(ram_wr_byte_en)
);

ram #(
    .XLEN(XLEN)
) ram (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

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
    .clk_i(sys_clk),
    .rst_n_i(cpu_rst_n),

    .iram_rd_data_i(iram_rd_data),
    .dram_rd_data_i(dram_rd_data),

    .iram_rd_addr_o(iram_rd_addr),
    .dram_rd_addr_o(dram_rd_addr),

    .dram_wr_addr_o(dram_wr_addr),
    .dram_wr_data_o(dram_wr_data),
    .dram_wr_byte_en_o(dram_wr_byte_en)
);

endmodule
