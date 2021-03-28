/*
 * test_ram_loader.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_ram_loader;

logic clk_i;
logic rst_n_i;

logic dc_i;

logic       byte_rdy_i;
logic [7:0] byte_data_i;

logic        wr_en_o;
logic        wr_done_o;
logic [12:0] wr_addr_o;
logic [ 3:0] wr_byte_en_o;

ram_loader test_ram_loader(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .dc_i(dc_i),

    .byte_rdy_i(byte_rdy_i),
    .byte_data_i(byte_data_i),

    .wr_en_o(wr_en_o),
    .wr_done_o(wr_done_o),
    .wr_addr_o(wr_addr_o),
    .wr_byte_en_o(wr_byte_en_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    dc_i <= 1'b0;

    byte_rdy_i  <= 1'b0;
    byte_data_i <= 8'h00;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    // RAM_WR_ST
    #5 dc_i <= 1'b0;
       byte_rdy_i  <= 1'b1;
       byte_data_i <= 8'h2a;
    #5 byte_rdy_i  <= 1'b0;

    // ADDR DATA
    for (integer i=0; i<64; i++) begin
        #5 dc_i <= 1'b1;
           byte_rdy_i  <= 1'b1;
           byte_data_i <= i;
        #5 byte_rdy_i  <= 1'b0;
    end

    // RAM_WR_SP
    #5 dc_i <= 1'b0;
       byte_rdy_i  <= 1'b1;
       byte_data_i <= 8'h2b;
    #5 byte_rdy_i  <= 1'b0;

    #75 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
