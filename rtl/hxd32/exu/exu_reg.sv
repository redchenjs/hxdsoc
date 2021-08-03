/*
 * exu_reg.sv
 *
 *  Created on: 2021-08-03 10:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

module exu_reg #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            alu_comp_i,
    input logic [XLEN-1:0] alu_data_i,

    output logic            alu_comp_o,
    output logic [XLEN-1:0] alu_data_o
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        alu_comp_o <= 1'b0;
        alu_data_o <= {XLEN{1'b0}};
    end else begin
        alu_comp_o <= alu_comp_i;
        alu_data_o <= alu_data_i;
    end
end

endmodule
