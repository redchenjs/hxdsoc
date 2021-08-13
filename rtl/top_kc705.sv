/*
 * top_kc705.sv
 *
 *  Created on: 2021-07-27 19:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

module top_kc705(
    input logic sys_clk_p_i,
    input logic sys_clk_n_i,

    input logic cpu_rst_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic sm_fan_tach_i,
    output logic sm_fan_pwm_o,

    input  logic [6:2] gpio_sw_i,
    output logic [7:0] gpio_led_o
);

localparam XLEN = 32;

logic sys_clk;
logic sys_clk_i;
logic sys_rst_n;

logic cpu_rst_n;

logic [7:0] uart_rx_data;
logic       uart_rx_data_vld;
logic       uart_rx_data_rdy;

logic [7:0] uart_tx_data;
logic       uart_tx_data_vld;
logic       uart_tx_data_rdy;

logic            ram_rw_sel;
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

assign gpio_led_o[7] = sys_rst_n;
assign gpio_led_o[6] = cpu_rst_n;
assign gpio_led_o[5] = ram_rw_sel;
assign gpio_led_o[4] = 1'b0;
assign gpio_led_o[3] = uart_rx_data_vld;
assign gpio_led_o[2] = uart_rx_data_rdy;
assign gpio_led_o[1] = uart_tx_data_vld;
assign gpio_led_o[0] = uart_tx_data_rdy;

IBUFGDS clk_buf(
    .O(sys_clk_i),
    .I(sys_clk_p_i),
    .IB(sys_clk_n_i)
);

adc adc(
    .reset_in(cpu_rst_i),
    .vp_in(1'b0),
    .vn_in(1'b0),
    .user_temp_alarm_out(sm_fan_pwm_o)
);

sys_ctl sys_ctl(
    .clk_i(sys_clk_i),
    .rst_n_i(~cpu_rst_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

uart_rx uart_rx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_rx_i(uart_rx_i),
    .uart_rx_data_rdy_i(uart_rx_data_rdy),

    .uart_rx_baud_div_i(32'd107),

    .uart_rx_data_o(uart_rx_data),
    .uart_rx_data_vld_o(uart_rx_data_vld)
);

uart_tx uart_tx(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_tx_data_i(uart_tx_data),
    .uart_tx_data_vld_i(uart_tx_data_vld),

    .uart_tx_baud_div_i(32'd107),

    .uart_tx_o(uart_tx_o),
    .uart_tx_data_rdy_o(uart_tx_data_rdy)
);

ram_rw #(
    .XLEN(XLEN)
) ram_rw (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_tx_data_rdy_i(uart_tx_data_rdy),

    .uart_rx_data_i(uart_rx_data),
    .uart_rx_data_vld_i(uart_rx_data_vld),

    .ram_rd_data_i(ram_rd_data),

    .cpu_rst_n_o(cpu_rst_n),

    .ram_rw_sel_o(ram_rw_sel),
    .ram_rw_addr_o(ram_rw_addr),
    .ram_wr_byte_en_o(ram_wr_byte_en),

    .uart_rx_data_rdy_o(uart_rx_data_rdy),

    .uart_tx_data_o(uart_tx_data),
    .uart_tx_data_vld_o(uart_tx_data_vld)
);

ram #(
    .XLEN(XLEN)
) ram (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .ram_rw_sel_i(ram_rw_sel),
    .ram_rw_addr_i(ram_rw_addr),
    .ram_wr_data_i(uart_rx_data),
    .ram_wr_byte_en_i(ram_wr_byte_en),

    .iram_rd_addr_i(iram_rd_addr),

    .dram_rd_addr_i(dram_rd_addr),
    .dram_wr_addr_i(dram_wr_addr),
    .dram_wr_data_i(dram_wr_data),
    .dram_wr_byte_en_i(dram_wr_byte_en),

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
