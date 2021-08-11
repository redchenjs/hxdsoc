/*
 * pipe_regfile.sv
 *
 *  Created on: 2021-08-11 20:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

module pipe_regfile #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] rs1_rd_data_i,
    input logic [XLEN-1:0] rs2_rd_data_i,

    output logic [XLEN-1:0] rs1_rd_data_o,
    output logic [XLEN-1:0] rs2_rd_data_o
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rs1_rd_data_o <= {XLEN{1'b0}};
        rs2_rd_data_o <= {XLEN{1'b0}};
    end else begin
        rs1_rd_data_o <= rs1_rd_data_i;
        rs2_rd_data_o <= rs2_rd_data_i;
    end
end

endmodule
