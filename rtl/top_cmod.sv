/*
 * top_cmod.sv
 *
 *  Created on: 2020-07-19 17:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module top_cmod(
    input logic clk_i,          // clk_i = 12 MHz
    input logic rst_i,          // rst_i, active high

    input logic btn1_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    output logic led0_r_n_o,
    output logic led0_g_n_o,
    output logic led0_b_n_o,

    output logic led1_o,
    output logic led2_o
);

localparam XLEN     = 32;
localparam BAUD_DIV = 32'd63;

logic sys_clk;
logic sys_rst_n;

logic cpu_rst_n;
logic cpu_fault;

logic [7:0] uart_rx_data;
logic       uart_rx_data_vld;
logic       uart_rx_data_rdy;

logic [7:0] uart_tx_data;
logic       uart_tx_data_vld;
logic       uart_tx_data_rdy;

wire [XLEN-1:0] iram_rd_addr;
wire [XLEN-1:0] iram_wr_addr;
wire [XLEN-1:0] iram_wr_data;
wire      [3:0] iram_wr_byte_en;

wire [XLEN-1:0] dram_rd_addr;
wire [XLEN-1:0] dram_wr_addr;
wire [XLEN-1:0] dram_wr_data;
wire      [3:0] dram_wr_byte_en;

wire [XLEN-1:0] iram_rd_data;
wire [XLEN-1:0] dram_rd_data;

assign led0_r_n_o = ~(~rst_i & ~cpu_rst_n & ~cpu_fault);
assign led0_g_n_o = ~(~rst_i & cpu_rst_n);
assign led0_b_n_o = ~(~rst_i & ~cpu_rst_n & cpu_fault);
assign led1_o = uart_rx_data_vld;
assign led2_o = uart_tx_data_vld;

sys_ctl sys_ctl(
    .clk_i(clk_i),
    .rst_n_i(~rst_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

uart_rx uart_rx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_rx_i(uart_rx_i),
    .uart_rx_data_rdy_i(uart_rx_data_rdy),

    .uart_rx_baud_div_i(BAUD_DIV),

    .uart_rx_data_o(uart_rx_data),
    .uart_rx_data_vld_o(uart_rx_data_vld)
);

uart_tx uart_tx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_tx_data_i(uart_tx_data),
    .uart_tx_data_vld_i(uart_tx_data_vld),

    .uart_tx_baud_div_i(BAUD_DIV),

    .uart_tx_o(uart_tx_o),
    .uart_tx_data_rdy_o(uart_tx_data_rdy)
);

ram_rw #(
    .XLEN(XLEN)
) ram_rw (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .cpu_fault_i(cpu_fault),

    .uart_rx_data_i(uart_rx_data),
    .uart_rx_data_vld_i(uart_rx_data_vld),
    .uart_tx_data_rdy_i(uart_tx_data_rdy),

    .iram_rd_data_i(iram_rd_data),
    .dram_rd_data_i(dram_rd_data),

    .cpu_rst_n_o(cpu_rst_n),

    .uart_tx_data_o(uart_tx_data),
    .uart_tx_data_vld_o(uart_tx_data_vld),
    .uart_rx_data_rdy_o(uart_rx_data_rdy),

    .iram_rd_addr_io(iram_rd_addr),
    .iram_wr_addr_io(iram_wr_addr),
    .iram_wr_data_io(iram_wr_data),
    .iram_wr_byte_en_io(iram_wr_byte_en),

    .dram_rd_addr_io(dram_rd_addr),
    .dram_wr_addr_io(dram_wr_addr),
    .dram_wr_data_io(dram_wr_data),
    .dram_wr_byte_en_io(dram_wr_byte_en)
);

ram #(
    .XLEN(XLEN)
) ram (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .iram_rd_addr_i(iram_rd_addr),
    .iram_wr_addr_i(iram_wr_addr),
    .iram_wr_data_i(iram_wr_data),
    .iram_wr_byte_en_i(iram_wr_byte_en),

    .dram_rd_addr_i(dram_rd_addr),
    .dram_wr_addr_i(dram_wr_addr),
    .dram_wr_data_i(dram_wr_data),
    .dram_wr_byte_en_i(dram_wr_byte_en),

    .iram_rd_data_io(iram_rd_data),
    .dram_rd_data_io(dram_rd_data)
);

hxd32 #(
    .XLEN(XLEN)
) hxd32 (
    .clk_i(sys_clk),
    .rst_n_i(cpu_rst_n),

    .iram_rd_data_i(iram_rd_data),
    .dram_rd_data_i(dram_rd_data),

    .iram_rd_addr_io(iram_rd_addr),
    .dram_rd_addr_io(dram_rd_addr),

    .dram_wr_addr_io(dram_wr_addr),
    .dram_wr_data_io(dram_wr_data),
    .dram_wr_byte_en_io(dram_wr_byte_en),

    .cpu_fault_o(cpu_fault)
);

endmodule
