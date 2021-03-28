/*
 * mem_rd.sv
 *
 *  Created on: 2020-08-05 11:21
 *      Author: Jack Chen <redchenjs@live.com>
 */

module mem_rd #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            rd_en_i,
    input logic [XLEN-1:0] rd_addr_i,
    input logic [XLEN-1:0] rd_data_i,

    output logic            rd_en_o,
    output logic [XLEN-1:0] rd_addr_o,
    output logic [XLEN-1:0] rd_data_o,

    output logic rd_done_o
);

assign rd_en_o   = rd_en_i;
assign rd_addr_o = rd_addr_i;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_data_o <= {XLEN{1'b0}};

        rd_done_o <= 1'b0;
    end else begin
        rd_data_o <= rd_data_i;

        rd_done_o <= rd_en_i;
    end
end

endmodule
