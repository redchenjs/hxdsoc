/*
 * test_ram_rw.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ram_rw;

localparam XLEN = 32;

typedef enum logic [7:0] {
    CPU_RST = 8'h2a,
    CPU_RUN = 8'h2b,
    CONF_WR = 8'h2c,
    CONF_RD = 8'h2d,
    DATA_WR = 8'h2e,
    DATA_RD = 8'h2f
} cmd_t;

logic clk_i;
logic rst_n_i;

logic [7:0] uart_tx_data_i;
logic       uart_tx_data_vld_i;
logic       uart_tx_data_rdy_o;
logic       uart_tx_i;

logic [7:0] uart_rx_data;
logic       uart_rx_data_vld;
logic       uart_rx_data_rdy;

logic [7:0] uart_tx_data;
logic       uart_tx_data_vld;
logic       uart_tx_data_rdy;
logic       uart_tx_o;

logic cpu_rst_n_o;

logic            ram_rw_sel;
logic [XLEN-1:0] ram_rw_addr;
logic      [7:0] ram_rd_data;
logic      [3:0] ram_wr_byte_en;

logic [XLEN-1:0] uart_tx_data_cnt;

logic [7:0] cmd_table[] = '{
    CPU_RST,
    CPU_RUN,
    CONF_WR, 8'h01, 8'h23, 8'h45, 8'h67, 8'h00, 8'h00, 8'h00, 8'h00,
    CONF_RD,
    DATA_WR, 8'haa,
    DATA_RD
};

uart_tx data_gen(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_tx_data_i(uart_tx_data_i),
    .uart_tx_data_vld_i(uart_tx_data_vld_i),

    .uart_tx_baud_div_i(32'd100),

    .uart_tx_o(uart_tx_i),
    .uart_tx_data_rdy_o(uart_tx_data_rdy_o)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_rx_i(uart_tx_i),
    .uart_rx_data_rdy_i(uart_rx_data_rdy),

    .uart_rx_baud_div_i(32'd100),

    .uart_rx_data_o(uart_rx_data),
    .uart_rx_data_vld_o(uart_rx_data_vld)
);

ram_rw #(
    .XLEN(XLEN)
) ram_rw (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_tx_data_rdy_i(uart_tx_data_rdy),

    .uart_rx_data_i(uart_rx_data),
    .uart_rx_data_vld_i(uart_rx_data_vld),

    .ram_rd_data_i(ram_rd_data),

    .cpu_rst_n_o(cpu_rst_n_o),

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
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .iram_rd_sel_i(ram_rw_sel),
    .iram_wr_sel_i(ram_rw_sel),

    .dram_rd_sel_i(ram_rw_sel),
    .dram_wr_sel_i(ram_rw_sel),

    .iram_rd_addr_a_i(32'h0000_0000),
    .iram_rd_addr_b_i(ram_rw_addr),

    .dram_rd_addr_a_i(32'h0000_0000),
    .dram_rd_addr_b_i(ram_rw_addr),

    .iram_wr_addr_i(ram_rw_addr),
    .iram_wr_data_i({uart_rx_data, uart_rx_data, uart_rx_data, uart_rx_data}),
    .iram_wr_byte_en_i(ram_wr_byte_en),

    .dram_wr_addr_a_i(32'h0000_0000),
    .dram_wr_data_a_i(32'h0000_0000),
    .dram_wr_byte_en_a_i(4'b0000),

    .dram_wr_addr_b_i(ram_rw_addr),
    .dram_wr_data_b_i({uart_rx_data, uart_rx_data, uart_rx_data, uart_rx_data}),
    .dram_wr_byte_en_b_i(ram_wr_byte_en),

    .ram_rd_data_o(ram_rd_data)
);

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .uart_tx_data_i(uart_tx_data),
    .uart_tx_data_vld_i(uart_tx_data_vld),

    .uart_tx_baud_div_i(32'd100),

    .uart_tx_o(uart_tx_o),
    .uart_tx_data_rdy_o(uart_tx_data_rdy)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        uart_tx_data_i     <= 8'h00;
        uart_tx_data_vld_i <= 1'b1;

        uart_tx_data_cnt <= 32'h0000_0000;
    end else begin
        if (uart_tx_data_cnt <= $size(cmd_table)) begin
            uart_tx_data_i     <= uart_tx_data_vld_i & uart_tx_data_rdy_o ? cmd_table[uart_tx_data_cnt] : uart_tx_data_i;
            uart_tx_data_vld_i <= uart_tx_data_vld_i & uart_tx_data_rdy_o ? 1'b0 : 1'b1;

            uart_tx_data_cnt <= uart_tx_data_vld_i & uart_tx_data_rdy_o ? uart_tx_data_cnt + 1'b1 : uart_tx_data_cnt;
        end
    end
end

always begin
    #750000 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
