/*
 * pc.sv
 *
 *  Created on: 2020-08-05 12:27
 *      Author: Jack Chen <redchenjs@live.com>
 */

import pc_op_enum::*;

module pc #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic       pc_wr_en_i,
    input logic [1:0] pc_wr_sel_i,
    input logic [1:0] pc_inc_sel_i,

    input logic [XLEN-1:0] alu_data_i,

    output logic [XLEN-1:0] pc_data_o
);

logic [XLEN-1:0] pc;

logic [XLEN-1:0] pc_prev;
logic [XLEN-1:0] pc_next;

assign pc_data_o = pc;

always_comb begin
    case (pc_inc_sel_i)
        PC_INC_4:
            pc_next = pc + 3'h4;
        PC_INC_2:
            pc_next = pc + 3'h2;
        PC_INC_4P:
            pc_next = pc_prev + 3'h4;
        PC_INC_2P:
            pc_next = pc_prev + 3'h2;
    endcase
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        pc      <= {XLEN{1'b0}};
        pc_prev <= {XLEN{1'b0}};
    end else begin
        if (pc_wr_en_i) begin
            case (pc_wr_sel_i)
                PC_WR_NEXT:
                    pc <= pc_next;
                PC_WR_JALR:
                    pc <= {alu_data_i[31:1], 1'b0};
                PC_WR_ALU:
                    pc <= alu_data_i;
                default:
                    pc <= {XLEN{1'b0}};
            endcase

            pc_prev <= pc;
        end
    end
end

endmodule
