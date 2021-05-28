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

    input logic            iram_wr_en_i,
    input logic [XLEN-1:0] iram_wr_addr_i,
    input logic [XLEN-1:0] iram_wr_data_i,
    input logic      [3:0] iram_wr_byte_en_i,

    input logic            dram_wr_en_a_i,
    input logic            dram_wr_en_b_i,
    input logic [XLEN-1:0] dram_wr_addr_a_i,
    input logic [XLEN-1:0] dram_wr_addr_b_i,
    input logic [XLEN-1:0] dram_wr_data_a_i,
    input logic [XLEN-1:0] dram_wr_data_b_i,
    input logic      [3:0] dram_wr_byte_en_a_i,
    input logic      [3:0] dram_wr_byte_en_b_i,

    output logic [XLEN-1:0] iram_rd_data_a_o,
    output logic      [7:0] iram_rd_data_b_o,

    output logic [XLEN-1:0] dram_rd_data_a_o,
    output logic      [7:0] dram_rd_data_b_o
);

logic [XLEN-1:0] iram_rw_addr_u;
logic [XLEN-1:0] iram_rw_addr_l;

logic [XLEN-1:0] dram_rd_addr;

logic            dram_wr_en;
logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;
logic      [3:0] dram_wr_byte_en;

logic [XLEN-1:0] iram_rd_data_a;
logic      [7:0] iram_rd_data_b;

logic [XLEN-1:0] dram_rd_data_a;
logic      [7:0] dram_rd_data_b;

assign iram_rd_data_a_o = iram_rd_data_a;
assign iram_rd_data_b_o = iram_rd_data_b;

assign dram_rd_data_a_o = dram_rd_data_a;
assign dram_rd_data_b_o = dram_rd_data_b;

ram8k iram(
    .clock(clk_i),
    .address_a(iram_rw_addr_u),
    .address_b(iram_rw_addr_l),
    .byteena_a(iram_wr_byte_en_i[3:2]),
    .byteena_b(iram_wr_byte_en_i[1:0]),
    .wren_a(iram_wr_en_i),
    .wren_b(iram_wr_en_i),
    .data_a(iram_wr_data_i[31:16]),
    .data_b(iram_wr_data_i[15:0]),
    .q_a(iram_rd_data_a[31:16]),
    .q_b(iram_rd_data_a[15:0])
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
    case ({iram_rd_sel_i, iram_wr_sel_i})
        2'b00: begin
            iram_rw_addr_u = iram_rd_addr_a_i[31:1] + 1'b1;
            iram_rw_addr_l = iram_rd_addr_a_i[31:1];
        end
        2'b01: begin
            iram_rw_addr_u = iram_wr_addr_i[31:16];
            iram_rw_addr_l = iram_wr_addr_i[15:0];
        end
        2'b10: begin
            iram_rw_addr_u = iram_rd_addr_b_i[31:16];
            iram_rw_addr_l = iram_rd_addr_b_i[15:0];
        end
        default: begin
            iram_rw_addr_u = {XLEN{1'b0}};
            iram_rw_addr_l = {XLEN{1'b0}};
        end
    endcase

    case ({dram_rd_sel_i, dram_wr_sel_i})
        2'b00: begin
            dram_rd_addr    = dram_rd_addr_a_i;

            dram_wr_en      = dram_wr_en_a_i;
            dram_wr_addr    = dram_wr_addr_a_i;
            dram_wr_data    = dram_wr_data_a_i;
            dram_wr_byte_en = dram_wr_byte_en_a_i;
        end
        2'b01: begin
            dram_rd_addr    = dram_rd_addr_a_i;

            dram_wr_en      = dram_wr_en_b_i;
            dram_wr_addr    = dram_wr_addr_b_i;
            dram_wr_data    = dram_wr_data_b_i;
            dram_wr_byte_en = dram_wr_byte_en_b_i;
        end
        2'b10: begin
            dram_rd_addr    = dram_rd_addr_b_i;

            dram_wr_en      = dram_wr_en_a_i;
            dram_wr_addr    = dram_wr_addr_a_i;
            dram_wr_data    = dram_wr_data_a_i;
            dram_wr_byte_en = dram_wr_byte_en_a_i;
        end
        default: begin
            dram_rd_addr    = {XLEN{1'b0}};

            dram_wr_en      = 1'b0;
            dram_wr_addr    = {XLEN{1'b0}};
            dram_wr_data    = {XLEN{1'b0}};
            dram_wr_byte_en = 4'b0000;
        end
    endcase

    case (iram_rw_addr_l[1:0])
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

endmodule
