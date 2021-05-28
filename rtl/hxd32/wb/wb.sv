/*
 * wb.sv
 *
 *  Created on: 2021-05-28 15:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

module wb #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic      [2:0] dram_rd_sel_i,
    input logic [XLEN-1:0] dram_rd_data_i,

    output logic [XLEN-1:0] rd_wr_data_o
);

logic [XLEN-1:0] rd_wr_data;

assign rd_wr_data_o = rd_wr_data;

always_comb begin
    case (dram_rd_sel_i)
        DRAM_RD_B:
            rd_wr_data = {{24{dram_rd_data_i[7]}}, dram_rd_data_i[7:0]};
        DRAM_RD_H:
            rd_wr_data = {{16{dram_rd_data_i[15]}}, dram_rd_data_i[15:0]};
        DRAM_RD_W:
            rd_wr_data = dram_rd_data_i;
        DRAM_RD_BU:
            rd_wr_data = {{24{1'b0}}, dram_rd_data_i[7:0]};
        DRAM_RD_HU:
            rd_wr_data = {{16{1'b0}}, dram_rd_data_i[15:0]};
        default:
            rd_wr_data = {XLEN{1'b0}};
    endcase
end

endmodule
