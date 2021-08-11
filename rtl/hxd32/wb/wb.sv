/*
 * wb.sv
 *
 *  Created on: 2021-05-28 15:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

import reg_op_enum::*;
import ram_op_enum::*;

module wb #(
    parameter XLEN = 32
) (
    input logic [1:0] rd_wr_sel_i,

    input logic [XLEN-1:0] pc_next_i,

    input logic [XLEN-1:0] alu_data_i,

    input logic      [2:0] dram_rd_sel_i,
    input logic [XLEN-1:0] dram_rd_data_i,

    output logic [XLEN-1:0] rd_wr_data_o
);

always_comb begin
    case (rd_wr_sel_i)
        RD_WR_ALU:
            rd_wr_data_o = alu_data_i;
        RD_WR_DRAM:
            case (dram_rd_sel_i)
                DRAM_RD_B:
                    rd_wr_data_o = {{24{dram_rd_data_i[7]}}, dram_rd_data_i[7:0]};
                DRAM_RD_H:
                    rd_wr_data_o = {{16{dram_rd_data_i[15]}}, dram_rd_data_i[15:0]};
                DRAM_RD_W:
                    rd_wr_data_o = dram_rd_data_i;
                DRAM_RD_BU:
                    rd_wr_data_o = {{24{1'b0}}, dram_rd_data_i[7:0]};
                DRAM_RD_HU:
                    rd_wr_data_o = {{16{1'b0}}, dram_rd_data_i[15:0]};
                default:
                    rd_wr_data_o = {XLEN{1'b0}};
            endcase
        RD_WR_PC_NEXT:
            rd_wr_data_o = pc_next_i;
        default:
            rd_wr_data_o = {XLEN{1'b0}};
    endcase
end

endmodule
