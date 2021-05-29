/*
 * alu.sv
 *
 *  Created on: 2020-08-03 17:49
 *      Author: Jack Chen <redchenjs@live.com>
 */

import alu_op_enum::*;

module alu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [2:0] alu_comp_sel_i,

    input logic       alu_op_0_sel_i,
    input logic [2:0] alu_op_1_sel_i,

    input logic [XLEN-1:0] alu_a_data_i,
    input logic [XLEN-1:0] alu_b_data_i,

    output logic            alu_comp_o,
    output logic [XLEN-1:0] alu_data_o
);

logic            alu_comp;
logic [XLEN-1:0] alu_data;

wire res_beq  = (alu_a_data_i == alu_b_data_i) ? 1'b1 : 1'b0;
wire res_bne  = ~res_beq;
wire res_blt  = ($signed(alu_a_data_i) < $signed(alu_b_data_i)) ? 1'b1 : 1'b0;
wire res_bge  = ~res_blt;
wire res_bltu = (alu_a_data_i < alu_b_data_i) ? 1'b1 : 1'b0;
wire res_bgeu = ~res_bltu;

wire [XLEN-1:0] res_add  = alu_a_data_i + alu_b_data_i;
wire [XLEN-1:0] res_sub  = alu_a_data_i - alu_b_data_i;
wire [XLEN-1:0] res_and  = alu_a_data_i & alu_b_data_i;
wire [XLEN-1:0] res_or   = alu_a_data_i | alu_b_data_i;
wire [XLEN-1:0] res_xor  = alu_a_data_i ^ alu_b_data_i;
wire [XLEN-1:0] res_sll  = alu_a_data_i << alu_b_data_i[4:0];
wire [XLEN-1:0] res_srl  = alu_a_data_i >> alu_b_data_i[4:0];
wire [XLEN-1:0] res_sra  = $signed(alu_a_data_i) >>> alu_b_data_i[4:0];
wire [XLEN-1:0] res_slt  = res_blt;
wire [XLEN-1:0] res_sltu = res_bltu;

assign alu_comp_o = alu_comp;
assign alu_data_o = alu_data;

always_comb begin
    case (alu_comp_sel_i)
        ALU_COMP_BEQ:
            alu_comp = res_beq;
        ALU_COMP_BNE:
            alu_comp = res_bne;
        ALU_COMP_BLT:
            alu_comp = res_blt;
        ALU_COMP_BGE:
            alu_comp = res_bge;
        ALU_COMP_BLTU:
            alu_comp = res_bltu;
        ALU_COMP_BGEU:
            alu_comp = res_bgeu;
        default:
            alu_comp = 1'b0;
    endcase
end

always_comb begin
    case (alu_op_1_sel_i)
        ALU_OP_1_ADD:
            alu_data = alu_op_0_sel_i ? res_sub : res_add;
        ALU_OP_1_AND:
            alu_data = res_and;
        ALU_OP_1_OR:
            alu_data = res_or;
        ALU_OP_1_XOR:
            alu_data = res_xor;
        ALU_OP_1_SLL:
            alu_data = res_sll;
        ALU_OP_1_SRL:
            alu_data = alu_op_0_sel_i ? res_sra : res_srl;
        ALU_OP_1_SLT:
            alu_data = res_slt;
        ALU_OP_1_SLTU:
            alu_data = res_sltu;
        default:
            alu_data = {XLEN{1'b0}};
    endcase
end

endmodule
