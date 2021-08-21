/*
 * regfile.sv
 *
 *  Created on: 2020-08-02 16:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

`include "../config.sv"

module regfile #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            rd_wr_en_i,
    input logic      [4:0] rd_wr_addr_i,
    input logic [XLEN-1:0] rd_wr_data_i,

    input logic [4:0] rs1_rd_addr_i,
    input logic [4:0] rs2_rd_addr_i,

    output logic [XLEN-1:0] rs1_rd_data_o,
    output logic [XLEN-1:0] rs2_rd_data_o
);

`ifdef CONFIG_ISA_RV32E
    localparam REG_N = 16;
`else
    localparam REG_N = 32;
`endif

logic [XLEN-1:0] regs[REG_N-1:1];
logic [XLEN-1:0] data[REG_N-1:0];

genvar i;
generate
    assign data[0] = {XLEN{1'b0}};

    for (i = 1; i < REG_N; i++) begin: rd_data
        assign data[i] = regs[i];
    end
endgenerate

assign rs1_rd_data_o = data[rs1_rd_addr_i];
assign rs2_rd_data_o = data[rs2_rd_addr_i];

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        for (integer i = 1; i < REG_N; i++) begin
            regs[i] <= {XLEN{1'b0}};
        end
    end else begin
        if (rd_wr_en_i) begin
            regs[rd_wr_addr_i] <= rd_wr_data_i;
        end
    end
end

endmodule
