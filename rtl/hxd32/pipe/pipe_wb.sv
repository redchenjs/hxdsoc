/*
 * pipe_wb.sv
 *
 *  Created on: 2021-08-03 10:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

module pipe_wb #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] rd_wr_data_i,

    output logic [XLEN-1:0] rd_wr_data_o
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_wr_data_o <= {XLEN{1'b0}};
    end else begin
        rd_wr_data_o <= rd_wr_data_i;
    end
end

endmodule
