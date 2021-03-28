/*
 * test_clk_div.sv
 *
 *  Created on: 2020-07-21 13:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_clk_div;

parameter W = 8;

logic clk_i;
logic rst_n_i;

logic [W-1:0] div_i;

logic clk_o;

clk_div #(
    .W(W)
) test_clk_div (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .div_i(div_i),

    .clk_o(clk_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    div_i <= 8'h05;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always begin
    #5120 rst_n_i <= 1'b0;

    #25 $stop;
end

endmodule
