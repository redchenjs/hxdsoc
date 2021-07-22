/*
 * pipe.sv
 *
 *  Created on: 2021-07-12 15:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

module pipe #(
    parameter WIDTH = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [WIDTH-1:0] data_i,
    input logic             data_vld_i,
    input logic             data_rdy_i,

    output logic [WIDTH-1:0] data_o,
    output logic             data_vld_o,
    output logic             data_rdy_o
);

logic [WIDTH-1:0] data;
logic             data_vld;
logic             data_rdy;

assign data_o     = data;
assign data_vld_o = data_vld;
assign data_rdy_o = data_rdy_i | ~data_vld;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data     <= {WIDTH{1'b0}};
        data_vld <= 1'b0;
    end else begin
        if (data_rdy_o) begin
            data     <= data_i;
            data_vld <= data_vld_i;
        end
    end
end

endmodule
