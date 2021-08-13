/*
 * exu.sv
 *
 *  Created on: 2020-08-05 19:44
 *      Author: Jack Chen <redchenjs@live.com>
 */

import alu_op_enum::*;

module exu #(
    parameter XLEN = 32
) (
    input logic [XLEN-1:0] pc_data_i,

    input logic [XLEN-1:0] rs1_rd_data_i,
    input logic [XLEN-1:0] rs2_rd_data_i,
    input logic [XLEN-1:0] imm_rd_data_i,

    input logic [1:0] alu_a_sel_i,
    input logic [1:0] alu_b_sel_i,

    input logic [2:0] alu_comp_sel_i,

    input logic       alu_op_0_sel_i,
    input logic [2:0] alu_op_1_sel_i,

    output logic            alu_comp_o,
    output logic [XLEN-1:0] alu_data_o
);

logic [XLEN-1:0] alu_a_data;
logic [XLEN-1:0] alu_b_data;

alu #(
    .XLEN(XLEN)
) alu (
    .alu_comp_sel_i(alu_comp_sel_i),

    .alu_op_0_sel_i(alu_op_0_sel_i),
    .alu_op_1_sel_i(alu_op_1_sel_i),

    .alu_a_comp_i(rs1_rd_data_i),
    .alu_b_comp_i(rs2_rd_data_i),

    .alu_a_data_i(alu_a_data),
    .alu_b_data_i(alu_b_data),

    .alu_comp_o(alu_comp_o),
    .alu_data_o(alu_data_o)
);

always_comb begin
    case (alu_a_sel_i)
        ALU_A_RS1:
            alu_a_data = rs1_rd_data_i;
        ALU_A_PC:
            alu_a_data = pc_data_i;
        default:
            alu_a_data = {XLEN{1'b0}};
    endcase

    case (alu_b_sel_i)
        ALU_B_RS2:
            alu_b_data = rs2_rd_data_i;
        ALU_B_IMM:
            alu_b_data = imm_rd_data_i;
        default:
            alu_b_data = {XLEN{1'b0}};
    endcase
end

endmodule
