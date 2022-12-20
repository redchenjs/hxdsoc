/*
 * top_zynq.sv
 *
 *  Created on: 2022-12-20 14:46
 *      Author: Jack Chen <redchenjs@live.com>
 */

module top_zynq(
    input logic clk_i,          // clk_i = 50 MHz
    input logic rst_n_i,        // rst_n_i, active low

    input logic btn_n_i,

    output logic led1_o,
    output logic led2_o,
    output logic led3_o,
    output logic led4_o,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic uart1_rx_i,
    output logic uart1_tx_o
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

assign led1_o = ~rst_n_i;
assign led2_o = ~btn_n_i;
assign led3_o = ~cpu_rst_n;
assign led4_o = cpu_fault;

sys_ctl sys_ctl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

uart_rx uart_rx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .init_i(uart_rx_data_rdy),
    .done_o(uart_rx_data_vld),

    .data_i(uart_rx_i),
    .data_o(uart_rx_data),

    .baud_div_i(BAUD_DIV)
);

uart_tx uart_tx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .init_i(uart_tx_data_vld),
    .done_o(uart_tx_data_rdy),

    .data_i(uart_tx_data),
    .data_o(uart_tx_o),

    .baud_div_i(BAUD_DIV)
);

mmio_uart mmio_uart(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .rd_addr_i(dram_rd_addr),
    .rd_data_io(dram_rd_data),

    .wr_addr_i(dram_wr_addr),
    .wr_data_i(dram_wr_data),
    .wr_byte_en_i(dram_wr_byte_en),

    .rx_i(uart1_rx_i),
    .tx_o(uart1_tx_o)

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
