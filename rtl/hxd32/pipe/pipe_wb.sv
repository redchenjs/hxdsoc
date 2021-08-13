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

    input logic            reg_wr_en_i,
    input logic      [4:0] reg_wr_addr_i,
    input logic [XLEN-1:0] reg_wr_data_i,

    output logic            reg_wr_en_o,
    output logic      [4:0] reg_wr_addr_o,
    output logic [XLEN-1:0] reg_wr_data_o
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        reg_wr_en_o   <= 1'b0;
        reg_wr_addr_o <= 5'h00;
        reg_wr_data_o <= {XLEN{1'b0}};
    end else begin
        reg_wr_en_o   <= reg_wr_en_i;
        reg_wr_addr_o <= reg_wr_addr_i;
        reg_wr_data_o <= reg_wr_data_i;
    end
end

endmodule
