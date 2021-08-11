/*
 * pipe_ifu.sv
 *
 *  Created on: 2021-08-03 10:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

module pipe_ifu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] pc_data_i,
    input logic [XLEN-1:0] pc_next_i,

    output logic [XLEN-1:0] pc_data_o,
    output logic [XLEN-1:0] pc_next_o
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        pc_data_o <= {XLEN{1'b0}};
        pc_next_o <= {XLEN{1'b0}};
    end else begin
        pc_data_o <= pc_data_i;
        pc_next_o <= pc_next_i;
    end
end

endmodule
