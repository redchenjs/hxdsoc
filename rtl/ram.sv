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

    input logic            ram_rw_sel_i,
    input logic [XLEN-1:0] ram_rw_addr_i,
    input logic [XLEN-1:0] ram_wr_data_i,
    input logic      [3:0] ram_wr_byte_en_i,

    input logic [XLEN-1:0] iram_rd_addr_i,

    input logic [XLEN-1:0] dram_rd_addr_i,
    input logic [XLEN-1:0] dram_wr_addr_i,
    input logic [XLEN-1:0] dram_wr_data_i,
    input logic      [3:0] dram_wr_byte_en_i,

    output logic [XLEN-1:0] iram_rd_data_o,
    output logic [XLEN-1:0] dram_rd_data_o,

    output logic [7:0] ram_rd_data_o
);

logic [XLEN-1:0] iram_rw_addr;

logic [XLEN-1:0] dram_rd_addr;
logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;
logic      [3:0] dram_wr_byte_en;

logic [XLEN-1:0] iram_rd_data;
logic [XLEN-1:0] dram_rd_data;

logic [7:0] ram_rd_data;

wire iram_rw_en = (iram_rw_addr[31:17] == 15'h0000);

wire dram_rd_en = (dram_rd_addr[31:17] == 15'h0001);
wire dram_wr_en = (dram_wr_addr[31:17] == 15'h0001);

assign iram_rd_data_o = iram_rd_data;
assign dram_rd_data_o = dram_rd_data;

assign ram_rd_data_o = ram_rd_data;

iram iram(
    .clka(clk_i),
    .ena(iram_rw_en),
    .wea(ram_wr_byte_en_i[3:2]),
    .addra({iram_rw_addr[16:2], 1'b1}),
    .dina(ram_wr_data_i[31:16]),
    .douta(iram_rd_data[31:16]),
    .clkb(clk_i),
    .enb(iram_rw_en),
    .web(ram_wr_byte_en_i[1:0]),
    .addrb({iram_rw_addr[16:2], 1'b0}),
    .dinb(ram_wr_data_i[15:0]),
    .doutb(iram_rd_data[15:0])
);

dram dram(
    .clka(clk_i),
    .ena(dram_wr_en),
    .wea(dram_wr_byte_en),
    .addra(dram_wr_addr[16:2]),
    .dina(dram_wr_data),
    .clkb(clk_i),
    .enb(dram_rd_en),
    .addrb(dram_rd_addr[16:2]),
    .doutb(dram_rd_data)
);

always_comb begin
    if (ram_rw_sel_i) begin
        iram_rw_addr    = ram_rw_addr_i;

        dram_rd_addr    = ram_rw_addr_i;
        dram_wr_addr    = ram_rw_addr_i;
        dram_wr_data    = ram_wr_data_i;
        dram_wr_byte_en = ram_wr_byte_en_i;
    end else begin
        iram_rw_addr    = iram_rd_addr_i;

        dram_rd_addr    = dram_rd_addr_i;
        dram_wr_addr    = dram_wr_addr_i;
        dram_wr_data    = dram_wr_data_i;
        dram_wr_byte_en = dram_wr_byte_en_i;
    end

    case (ram_rw_addr_i[1:0])
        2'b00:
            ram_rd_data = iram_rw_en ? iram_rd_data[7:0] : dram_rd_data[7:0];
        2'b01:
            ram_rd_data = iram_rw_en ? iram_rd_data[15:8] : dram_rd_data[15:8];
        2'b10:
            ram_rd_data = iram_rw_en ? iram_rd_data[23:16] : dram_rd_data[23:16];
        2'b11:
            ram_rd_data = iram_rw_en ? iram_rd_data[31:24] : dram_rd_data[31:24];
        default:
            ram_rd_data = 8'h00;
    endcase
end

endmodule
