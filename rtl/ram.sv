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

    input logic iram_rd_sel_i,
    input logic iram_wr_sel_i,

    input logic dram_rd_sel_i,
    input logic dram_wr_sel_i,

    input logic [XLEN-1:0] iram_rd_addr_a_i,
    input logic [XLEN-1:0] iram_rd_addr_b_i,

    input logic [XLEN-1:0] dram_rd_addr_a_i,
    input logic [XLEN-1:0] dram_rd_addr_b_i,

    input logic [XLEN-1:0] iram_wr_addr_i,
    input logic [XLEN-1:0] iram_wr_data_i,
    input logic      [3:0] iram_wr_byte_en_i,

    input logic [XLEN-1:0] dram_wr_addr_a_i,
    input logic [XLEN-1:0] dram_wr_data_a_i,
    input logic      [3:0] dram_wr_byte_en_a_i,

    input logic [XLEN-1:0] dram_wr_addr_b_i,
    input logic [XLEN-1:0] dram_wr_data_b_i,
    input logic      [3:0] dram_wr_byte_en_b_i,

    output logic [XLEN-1:0] iram_rd_data_o,
    output logic [XLEN-1:0] dram_rd_data_o,

    output logic [7:0] ram_rd_data_o
);

logic [XLEN-1:0] iram_rw_addr;

logic [XLEN-1:0] dram_rd_addr;
logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;
logic      [3:0] dram_wr_byte_en;

logic [XLEN-1:0] iram_rd_data_a;
logic      [7:0] iram_rd_data_b;

logic [XLEN-1:0] dram_rd_data_a;
logic      [7:0] dram_rd_data_b;

logic [7:0] ram_rd_data;

wire iram_rw_en = (iram_rw_addr[31:17] == 15'h0000);

wire dram_rd_en = (dram_rd_addr[31:17] == 15'h0001);
wire dram_wr_en = (dram_wr_addr[31:17] == 15'h0001);

assign iram_rd_data_o = iram_rd_data_a;
assign dram_rd_data_o = dram_rd_data_a;

assign ram_rd_data_o = ram_rd_data;

iram iram(
    .clka(clk_i),
    .ena(iram_rw_en),
    .wea(iram_wr_byte_en_i[3:2]),
    .addra({iram_rw_addr[16:2], 1'b1}),
    .dina(iram_wr_data_i[31:16]),
    .douta(iram_rd_data_a[31:16]),
    .clkb(clk_i),
    .enb(iram_rw_en),
    .web(iram_wr_byte_en_i[1:0]),
    .addrb({iram_rw_addr[16:2], 1'b0}),
    .dinb(iram_wr_data_i[15:0]),
    .doutb(iram_rd_data_a[15:0])
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
    .doutb(dram_rd_data_a)
);

always_comb begin
    case ({iram_rd_sel_i, iram_wr_sel_i})
        2'b00: begin
            iram_rw_addr = iram_rd_addr_a_i;
        end
        2'b01: begin
            iram_rw_addr = iram_wr_addr_i;
        end
        2'b10: begin
            iram_rw_addr = iram_rd_addr_b_i;
        end
        default: begin
            iram_rw_addr = {XLEN{1'b0}};
        end
    endcase

    case ({dram_rd_sel_i, dram_wr_sel_i})
        2'b00: begin
            dram_rd_addr    = dram_rd_addr_a_i;
            dram_wr_addr    = dram_wr_addr_a_i;
            dram_wr_data    = dram_wr_data_a_i;
            dram_wr_byte_en = dram_wr_byte_en_a_i;
        end
        2'b01: begin
            dram_rd_addr    = dram_rd_addr_a_i;
            dram_wr_addr    = dram_wr_addr_b_i;
            dram_wr_data    = dram_wr_data_b_i;
            dram_wr_byte_en = dram_wr_byte_en_b_i;
        end
        2'b10: begin
            dram_rd_addr    = dram_rd_addr_b_i;
            dram_wr_addr    = dram_wr_addr_a_i;
            dram_wr_data    = dram_wr_data_a_i;
            dram_wr_byte_en = dram_wr_byte_en_a_i;
        end
        default: begin
            dram_rd_addr    = {XLEN{1'b0}};
            dram_wr_addr    = {XLEN{1'b0}};
            dram_wr_data    = {XLEN{1'b0}};
            dram_wr_byte_en = 4'b0000;
        end
    endcase

    case (iram_rw_addr[1:0])
        2'b00:
            iram_rd_data_b = iram_rd_data_a[7:0];
        2'b01:
            iram_rd_data_b = iram_rd_data_a[15:8];
        2'b10:
            iram_rd_data_b = iram_rd_data_a[23:16];
        2'b11:
            iram_rd_data_b = iram_rd_data_a[31:24];
        default:
            iram_rd_data_b = 8'h00;
    endcase

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

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        ram_rd_data <= {XLEN{1'b0}};
    end else begin
        case ({dram_rd_sel_i, iram_rd_sel_i})
            2'b01:
                ram_rd_data <= iram_rd_data_b;
            2'b10:
                ram_rd_data <= dram_rd_data_b;
            default:
                ram_rd_data <= {XLEN{1'b0}};
        endcase
    end
end

endmodule
