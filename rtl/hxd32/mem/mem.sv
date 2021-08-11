/*
 * mem.sv
 *
 *  Created on: 2021-05-28 15:05
 *      Author: Jack Chen <redchenjs@live.com>
 */

import ram_op_enum::*;

module mem #(
    parameter XLEN = 32
) (
    input logic       dram_wr_en_i,
    input logic [2:0] dram_wr_sel_i,

    output logic [3:0] dram_wr_byte_en_o
);

always_comb begin
    case ({~dram_wr_en_i, dram_wr_sel_i})
        DRAM_WR_B:
            dram_wr_byte_en_o = 4'b0001;
        DRAM_WR_H:
            dram_wr_byte_en_o = 4'b0011;
        DRAM_WR_W:
            dram_wr_byte_en_o = 4'b1111;
        default:
            dram_wr_byte_en_o = 4'b0000;
    endcase
end

endmodule
