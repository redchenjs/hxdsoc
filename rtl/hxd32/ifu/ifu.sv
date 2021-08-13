/*
 * ifu.sv
 *
 *  Created on: 2020-08-05 12:27
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ifu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic       pc_wr_en_i,
    input logic [1:0] pc_wr_sel_i,
    input logic       pc_inc_sel_i,

    input logic [XLEN-1:0] alu_data_i,

    output logic [XLEN-1:0] pc_data_o,
    output logic [XLEN-1:0] pc_next_o
);

pc pc(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .pc_wr_en_i(pc_wr_en_i),
    .pc_wr_sel_i(pc_wr_sel_i),
    .pc_inc_sel_i(pc_inc_sel_i),

    .alu_data_i(alu_data_i),

    .pc_data_o(pc_data_o),
    .pc_next_o(pc_next_o)
);

endmodule
