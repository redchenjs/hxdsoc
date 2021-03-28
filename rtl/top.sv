/*
 * top.sv
 *
 *  Created on: 2020-07-19 17:33
 *      Author: Jack Chen <redchenjs@live.com>
 */

module corerv32(
    input logic clk_i,          // clk_i = 12 MHz
    input logic rst_n_i,        // rst_n_i, active low

    input logic dc_i,
    input logic spi_sclk_i,
    input logic spi_mosi_i,
    input logic spi_cs_n_i,

    output logic [7:0] water_led_o,        // Optional, FPS Counter
    output logic [8:0] segment_led_1_o,    // Optional, FPS Counter
    output logic [8:0] segment_led_2_o     // Optional, FPS Counter
);

parameter W = 8;
parameter N = 8;

logic sys_clk;
logic sys_rst_n;

logic       byte_rdy;
logic [7:0] byte_data;

logic [N-1:0] data_lsfr;
logic         data_done;

logic clk_out;

parameter XLEN = 32;

logic        ldr_iram_wr_en;
logic        ldr_iram_wr_done;
logic [12:0] ldr_iram_wr_addr;
wire  [31:0] ldr_iram_wr_data = {byte_data, byte_data, byte_data, byte_data};
logic [ 3:0] ldr_iram_wr_byte_en;

logic            cpu_iram_rd_en;
logic [XLEN-1:0] cpu_iram_addr;
logic [XLEN-1:0] cpu_iram_data;

logic            cpu_dram_rd_en;
logic [XLEN-1:0] cpu_dram_rd_addr;
logic [XLEN-1:0] cpu_dram_rd_data;

logic            cpu_dram_wr_en;
logic [XLEN-1:0] cpu_dram_wr_addr;
logic [XLEN-1:0] cpu_dram_wr_data;
logic      [3:0] cpu_dram_wr_byte_en;

assign water_led_o = cpu_dram_wr_addr;

sys_ctrl sys_ctrl(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .sys_clk_o(sys_clk),
    .sys_rst_n_o(sys_rst_n)
);

spi_slave spi_slave(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .spi_sclk_i(spi_sclk_i),
    .spi_mosi_i(spi_mosi_i),
    .spi_cs_n_i(spi_cs_n_i),

    .byte_rdy_o(byte_rdy),
    .byte_data_o(byte_data)
);

iram_loader iram_loader(
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),
    
    .dc_i(dc_i),

    .byte_rdy_i(byte_rdy),
    .byte_data_i(byte_data),

    .wr_en_o(ldr_iram_wr_en),
    .wr_done_o(ldr_iram_wr_done),
    .wr_addr_o(ldr_iram_wr_addr),
    .wr_byte_en_o(ldr_iram_wr_byte_en)
);

iram #(
    .XLEN(XLEN)
) iram (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .wr_en_i(ldr_iram_wr_en),
    .wr_addr_i(ldr_iram_wr_addr),
    .wr_data_i(ldr_iram_wr_data),
    .wr_byte_en_i(ldr_iram_wr_byte_en),

    .rd_en_i(cpu_iram_rd_en),
    .rd_addr_i(cpu_iram_rd_addr),

    .rd_data_o(cpu_iram_rd_data)
);

dram #(
    .XLEN(XLEN)
) dram (
    .clk_i(sys_clk),
    .rst_n_i(sys_rst_n),

    .wr_en_i(cpu_dram_wr_en),
    .wr_addr_i(cpu_dram_wr_addr),
    .wr_data_i(cpu_dram_wr_data),
    .wr_byte_en_i(cpu_dram_wr_byte_en),

    .rd_en_i(cpu_dram_rd_en),
    .rd_addr_i(cpu_dram_rd_addr),

    .rd_data_o(cpu_dram_rd_data)
);

cpu #(
    .XLEN(XLEN)
) cpu (
    .clk_i(sys_clk),
    .rst_n_i(~ldr_iram_wr_done),

    .iram_rd_data_i(cpu_iram_rd_data),
    .dram_rd_data_i(cpu_dram_rd_data),

    .iram_rd_en_o(cpu_iram_rd_en),
    .iram_rd_addr_o(cpu_iram_rd_addr),

    .dram_rd_en_o(cpu_dram_rd_en),
    .dram_rd_addr_o(cpu_dram_rd_addr),

    .dram_wr_en_o(cpu_dram_wr_en),
    .dram_wr_addr_o(cpu_dram_wr_addr),
    .dram_wr_data_o(cpu_dram_wr_data),
    .dram_wr_byte_en_o(cpu_dram_wr_byte_en)
);

// clk_div #(
//     .W(W)
// ) clk_div (
//     .clk_i(sys_clk),
//     .rst_n_i(sys_rst_n),

//     .div_i(2'h2),

//     .clk_o(clk_out)
// );

// pulse_counter fps_counter(
//     .clk_i(sys_clk),
//     .rst_n_i(sys_rst_n),

//     .pulse_i(clk_out),

// //    .water_led_o(water_led_o),
//     .segment_led_1_o(segment_led_1_o),
//     .segment_led_2_o(segment_led_2_o)
// );

endmodule
