/*
 * ifu.sv
 *
 *  Created on: 2020-08-05 12:27
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ifu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            ir_rd_en_i,
    input logic [XLEN-1:0] pc_rd_data_i,

    input logic [XLEN-1:0] iram_rd_data_i,

    output logic            iram_rd_en_o,
    output logic [XLEN-1:0] iram_rd_addr_o,

    output logic            pc_wr_en_o,
    output logic [XLEN-1:0] pc_wr_data_o,

    output logic [XLEN-1:0] ir_rd_data_o
);

assign pc_wr_en_o = ir_rd_en_i;

mem_rd #(
    .XLEN(XLEN)
) mem_rd (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .rd_en_i(ir_rd_en_i),
    .rd_addr_i(pc_rd_data_i[XLEN-1:2]),
    .rd_data_i(iram_rd_data_i),

    .rd_en_o(iram_rd_en_o),
    .rd_addr_o(iram_rd_addr_o),
    .rd_data_o(ir_rd_data_o),

    .rd_done_o(ir_rd_done_o)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        pc_wr_data_o <= {XLEN{1'b0}};
    end else begin
        if (ir_rd_en_i) begin
            pc_wr_data_o <= pc_rd_data_i + 3'b100;
        end
    end
end

endmodule
