/*
 * pipe_mem.sv
 *
 *  Created on: 2021-08-03 10:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

module pipe_mem #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [3:0] dram_wr_byte_en_i,

    output logic [3:0] dram_wr_byte_en_o
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        dram_wr_byte_en_o <= 4'b0000;
    end else begin
        dram_wr_byte_en_o <= dram_wr_byte_en_i;
    end
end

endmodule
