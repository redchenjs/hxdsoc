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
    input logic       rd_wr_en_i,
    input logic [1:0] rd_wr_sel_i,
    input logic [4:0] rd_wr_addr_i,

    input logic       rd_wr_en_r_i,
    input logic [1:0] rd_wr_sel_r_i,
    input logic [4:0] rd_wr_addr_r_i,

    input logic [XLEN-1:0] pc_next_i,

    input logic [XLEN-1:0] alu_data_i,

    input logic      [2:0] dram_rd_sel_i,
    input logic [XLEN-1:0] dram_rd_addr_i,
    input logic [XLEN-1:0] dram_rd_data_i,

    input logic [2:0] dram_rd_sel_r_i,

    output logic            reg_wr_en_o,
    output logic      [4:0] reg_wr_addr_o,
    output logic [XLEN-1:0] reg_wr_data_o
);

logic            reg_wr_en_0;
logic      [4:0] reg_wr_addr_0;
logic [XLEN-1:0] reg_wr_data_0;

logic            reg_wr_en_1;
logic      [4:0] reg_wr_addr_1;
logic [XLEN-1:0] reg_wr_data_1;

assign reg_wr_en_o   = (rd_wr_sel_r_i == RD_WR_DRAM) ? reg_wr_en_1 : reg_wr_en_0;
assign reg_wr_addr_o = (rd_wr_sel_r_i == RD_WR_DRAM) ? reg_wr_addr_1 : reg_wr_addr_0;
assign reg_wr_data_o = (rd_wr_sel_r_i == RD_WR_DRAM) ? reg_wr_data_1 : reg_wr_data_0;

always_comb begin
    case (rd_wr_sel_i)
        RD_WR_ALU: begin
            reg_wr_en_0   = rd_wr_en_i;
            reg_wr_addr_0 = rd_wr_addr_i;
            reg_wr_data_0 = alu_data_i;
        end
        RD_WR_PC_NEXT: begin
            reg_wr_en_0   = rd_wr_en_i;
            reg_wr_addr_0 = rd_wr_addr_i;
            reg_wr_data_0 = pc_next_i;
        end
        default: begin
            reg_wr_en_0   = 1'b0;
            reg_wr_addr_0 = 5'h00;
            reg_wr_data_0 = {XLEN{1'b0}};
        end
    endcase
end

always_comb begin
    case (rd_wr_sel_r_i)
        RD_WR_DRAM: begin
            reg_wr_en_1   = rd_wr_en_r_i;
            reg_wr_addr_1 = rd_wr_addr_r_i;

            case (dram_rd_sel_r_i)
                DRAM_RD_B:
                    reg_wr_data_1 = {{24{dram_rd_data_i[7]}}, dram_rd_data_i[7:0]};
                DRAM_RD_H:
                    reg_wr_data_1 = {{16{dram_rd_data_i[15]}}, dram_rd_data_i[15:0]};
                DRAM_RD_W:
                    reg_wr_data_1 = dram_rd_data_i;
                DRAM_RD_BU:
                    reg_wr_data_1 = {{24{1'b0}}, dram_rd_data_i[7:0]};
                DRAM_RD_HU:
                    reg_wr_data_1 = {{16{1'b0}}, dram_rd_data_i[15:0]};
                default:
                    reg_wr_data_1 = {XLEN{1'b0}};
            endcase
        end
        default: begin
            reg_wr_en_1   = 1'b0;
            reg_wr_addr_1 = 5'h00;
            reg_wr_data_1 = {XLEN{1'b0}};
        end
    endcase
end

endmodule
