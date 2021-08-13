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
    input logic       pc_inc_sel_i,

    input logic [XLEN-1:0] alu_data_i,

    output logic [XLEN-1:0] pc_data_o,
    output logic [XLEN-1:0] pc_next_o
);

logic [XLEN-1:0] pc;

wire [XLEN-1:0] pc_inc  = pc_inc_sel_i ? 32'h2 : 32'h4;
wire [XLEN-1:0] pc_next = pc + pc_inc;

assign pc_data_o = pc;
assign pc_next_o = pc_next;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        pc <= {XLEN{1'b0}};
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
        end
    end
end

endmodule
