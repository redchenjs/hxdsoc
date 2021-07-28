/*
 * test_uart.sv
 *
 *  Created on: 2021-07-12 15:23
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_uart;

logic clk_i;
logic rst_n_i;

logic [7:0] uart_tx_data_i;
logic       uart_tx_data_vld_i;

logic [31:0] uart_tx_baud_div_i;

logic uart_tx_o;
logic uart_tx_data_rdy_o;

logic uart_rx_data_rdy_i;

logic [31:0] uart_rx_baud_div_i;

logic       uart_rx_data_vld_o;
logic [7:0] uart_rx_data_o;

logic uart_tx_2_o;

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_tx_data_vld_i(uart_tx_data_vld_i),
    .uart_tx_data_i(uart_tx_data_i),

    .uart_tx_baud_div_i(uart_tx_baud_div_i),

    .uart_tx_o(uart_tx_o),
    .uart_tx_data_rdy_o(uart_tx_data_rdy_o)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_rx_i(uart_tx_o),
    .uart_rx_data_rdy_i(uart_rx_data_rdy_i),

    .uart_rx_baud_div_i(uart_rx_baud_div_i),

    .uart_rx_data_vld_o(uart_rx_data_vld_o),
    .uart_rx_data_o(uart_rx_data_o)
);

uart_tx uart_tx_2(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_tx_data_vld_i(uart_rx_data_vld_o),
    .uart_tx_data_i(uart_rx_data_o),

    .uart_tx_baud_div_i(uart_tx_baud_div_i),

    .uart_tx_o(uart_tx_2_o),
    .uart_tx_data_rdy_o(uart_rx_data_rdy_i)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        uart_tx_data_i     <= 8'h61;
        uart_tx_data_vld_i <= 1'b1;
    end else begin
        uart_tx_data_i     <= uart_tx_data_vld_i & uart_tx_data_rdy_o ? uart_tx_data_i + 1'b1 : uart_tx_data_i;
        uart_tx_data_vld_i <= uart_tx_data_vld_i & uart_tx_data_rdy_o ? 1'b0 : 1'b1;
    end
end

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    uart_tx_baud_div_i <= 32'd100;
    uart_rx_baud_div_i <= 32'd100;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #750000 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
