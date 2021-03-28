/*
 * iram.sv
 *
 *  Created on: 2020-08-55 08:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

module iram #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            wr_en_i,
    input logic [XLEN-1:0] wr_addr_i,
    input logic [XLEN-1:0] wr_data_i,
    input logic      [3:0] wr_byte_en_i,

    input logic            rd_en_i,
    input logic [XLEN-1:0] rd_addr_i,

    output logic [XLEN-1:0] rd_data_o
);

ram32k ram32k(
    .data(wr_data_i),
    .byteena_a(wr_byte_en_i),
    .rd_aclr(~rst_n_i),
    .rdaddress(rd_addr_i),
    .rdclock(clk_i),
    .rden(rd_en_i),
    .wraddress(wr_addr_i),
    .wrclock(clk_i),
    .wren(wr_en_i),
    .q(rd_data_o)
);

endmodule
