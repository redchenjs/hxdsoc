/*
 * clk_div.sv
 *
 *  Created on: 2020-07-21 13:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

module clk_div #(
    parameter W = 8
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [W-1:0] div_i,

    output logic clk_o
);

logic clk_p;

logic [W-1:0] clk_cnt;

wire clk_h = (clk_cnt < div_i[W-1:1]);
wire cnt_h = (clk_cnt < (div_i - 1'b1));

assign clk_o = clk_p;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_p <= 1'b0;

        clk_cnt <= {W{1'b0}};
    end else begin
        clk_p <= clk_h;

        clk_cnt <= cnt_h ? clk_cnt + 1'b1 : {W{1'b0}};
    end
end

endmodule
