/*
 * ram.sv
 *
 *  Created on: 2020-08-55 08:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ram #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic iram_rw_sel_i,
    input logic dram_rd_sel_i,

    input logic [XLEN-1:0] iram_rd_addr_i,
    input logic [XLEN-1:0] dram_rd_addr_a_i,
    input logic [XLEN-1:0] dram_rd_addr_b_i,

    input logic            iram_wr_en_i,
    input logic [XLEN-1:0] iram_wr_addr_i,
    input logic [XLEN-1:0] iram_wr_data_i,
    input logic      [3:0] iram_wr_byte_en_i,

    input logic            dram_wr_en_i,
    input logic [XLEN-1:0] dram_wr_addr_i,
    input logic [XLEN-1:0] dram_wr_data_i,
    input logic      [3:0] dram_wr_byte_en_i,

    output logic [XLEN-1:0] iram_rd_data_o,
    output logic [XLEN-1:0] dram_rd_data_a_o,
    output logic      [7:0] dram_rd_data_b_o
);

wire [XLEN-1:0] iram_rw_addr_a = iram_rw_sel_i ? iram_wr_addr_i : iram_rd_addr_i[31:1] + 1'b1;
wire [XLEN-1:0] iram_rw_addr_b = iram_rw_sel_i ? iram_wr_addr_i : iram_rd_addr_i[31:1];

wire [XLEN-1:0] dram_rd_addr = dram_rd_sel_i ? dram_rd_addr_a_i : dram_rd_addr_b_i;

logic [XLEN-1:0] dram_rd_data_a;
logic      [7:0] dram_rd_data_b;

assign dram_rd_data_a_o = dram_rd_data_a;
assign dram_rd_data_b_o = dram_rd_data_b;

ram8k iram(
    .clock(clk_i),
    .address_a(iram_rw_addr_a),
    .address_b(iram_rw_addr_b),
    .byteena_a(iram_wr_byte_en_i[3:2]),
    .byteena_b(iram_wr_byte_en_i[1:0]),
    .wren_a(iram_wr_en_i),
    .wren_b(iram_wr_en_i),
    .data_a(iram_wr_data_i[31:16]),
    .data_b(iram_wr_data_i[15:0]),
    .q_a(iram_rd_data_o[31:16]),
    .q_b(iram_rd_data_o[15:0])
);

ram40k dram(
    .clock(clk_i),
    .rdaddress(dram_rd_addr),
    .wraddress(dram_wr_addr_i),
    .byteena_a(dram_wr_byte_en_i),
    .wren(dram_wr_en_i),
    .data(dram_wr_data_i),
    .q(dram_rd_data_a)
);

always_comb begin
    case (dram_rd_addr[1:0])
        2'b00:
            dram_rd_data_b = dram_rd_data_a[7:0];
        2'b01:
            dram_rd_data_b = dram_rd_data_a[15:8];
        2'b10:
            dram_rd_data_b = dram_rd_data_a[23:16];
        2'b11:
            dram_rd_data_b = dram_rd_data_a[31:24];
        default:
            dram_rd_data_b = 8'h00;
    endcase
end

endmodule
