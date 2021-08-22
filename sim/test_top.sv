/*
 * test_top.sv
 *
 *  Created on: 2021-05-22 14:11
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_top;

localparam XLEN     = 32;
localparam BAUD_DIV = 32'd98;

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

wire sys_clk   = clk_i;
wire sys_rst_n = rst_n_i;

logic uart_rx_i;
logic uart_tx_o;

logic uart1_rx_i;
logic uart1_tx_o;

assign uart1_rx_i = uart1_tx_o;

logic [7:0] uart_tx_data_i;
logic       uart_tx_data_vld_i;
logic       uart_tx_data_rdy_o;

logic            uart_tx_data_st;
logic [XLEN-1:0] uart_tx_data_cnt;

logic [7:0] cmd_table[] = '{
    CPU_RST,
    CONF_WR, 8'h00, 8'h00, 8'h00, 8'h40, 8'h1f, 8'h00, 8'h00, 8'h00,
    // CONF_RD,
    // DATA_WR, 8'haa, 8'hbb, 8'hcc, 8'hdd, 8'hee,
    // DATA_RD
    DATA_WR,

    8'h55, 8'haa, 8'h55, 8'hcc,
    8'h01, 8'h0b, 8'h0c, 8'h0d,
    8'hf2, 8'h9b, 8'h00, 8'h00,
    8'h23, 8'h20, 8'h74, 8'h01,

    8'h55, 8'haa, 8'h55, 8'hcc,
    8'h01, 8'h0b, 8'h0c, 8'h0d,
    8'hf2, 8'h9b, 8'h00, 8'h00,
    8'h23, 8'h20, 8'h74, 8'h01,

    DATA_RD
};

uart_tx data_gen(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_tx_data_i(uart_tx_data_i),
    .uart_tx_data_vld_i(uart_tx_data_vld_i),

    .uart_tx_baud_div_i(BAUD_DIV),

    .uart_tx_o(uart_rx_i),
    .uart_tx_data_rdy_o(uart_tx_data_rdy_o)
);

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

uart uart(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .uart_rx_i(uart1_rx_i),

    .rd_addr_i(dram_rd_addr),
    .wr_addr_i(dram_wr_addr),
    .wr_data_i(dram_wr_data),
    .wr_byte_en_i(dram_wr_byte_en),

    .uart_tx_o(uart1_tx_o),

    .rd_data_io(dram_rd_data)
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

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

edge2en uart_tx_data_st_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(uart_tx_data_rdy_o),
    .pos_edge_o(uart_tx_data_st)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        uart_tx_data_i     <= 8'h00;
        uart_tx_data_vld_i <= 1'b0;

        uart_tx_data_cnt <= 32'h0000_0000;
    end else begin
        if (uart_tx_data_st) begin
            uart_tx_data_i     <= (uart_tx_data_cnt < $size(cmd_table)) ? cmd_table[uart_tx_data_cnt] : 8'h00;
            uart_tx_data_vld_i <= (uart_tx_data_cnt < $size(cmd_table)) ? 1'b1 : 1'b0;

            uart_tx_data_cnt <= uart_tx_data_cnt + 1'b1;
        end else begin
            uart_tx_data_vld_i <= uart_tx_data_rdy_o ? 1'b0 : uart_tx_data_vld_i;
        end
    end
end

always begin
    #750000 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
