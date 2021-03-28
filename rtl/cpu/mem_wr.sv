/*
 * mem_wr.sv
 *
 *  Created on: 2020-08-05 12:57
 *      Author: Jack Chen <redchenjs@live.com>
 */

module mem_wr #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            wr_en_i,
    input logic [XLEN-1:0] wr_addr_i,
    input logic [XLEN-1:0] wr_data_i,

    output logic            wr_en_o,
    output logic [XLEN-1:0] wr_addr_o,
    output logic [XLEN-1:0] wr_data_o,

    output logic wr_done_o
);

assign wr_en_o   = wr_en_i;
assign wr_addr_o = wr_addr_i;
assign wr_data_o = wr_data_i;

assign wr_done_o = wr_en_i;

endmodule
