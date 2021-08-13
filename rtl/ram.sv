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
    input logic      [7:0] ram_wr_data_i,
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

logic [XLEN-1:2] iram_rw_addr_0;
logic [XLEN-1:2] iram_rw_addr_1;
logic [XLEN-1:2] iram_rw_addr_2;
logic [XLEN-1:2] iram_rw_addr_3;

logic [7:0] iram_rd_data_0;
logic [7:0] iram_rd_data_1;
logic [7:0] iram_rd_data_2;
logic [7:0] iram_rd_data_3;

logic [XLEN-1:2] dram_rd_addr_0;
logic [XLEN-1:2] dram_rd_addr_1;
logic [XLEN-1:2] dram_rd_addr_2;
logic [XLEN-1:2] dram_rd_addr_3;

logic [7:0] dram_rd_data_0;
logic [7:0] dram_rd_data_1;
logic [7:0] dram_rd_data_2;
logic [7:0] dram_rd_data_3;

logic [XLEN-1:2] dram_wr_addr_0;
logic [XLEN-1:2] dram_wr_addr_1;
logic [XLEN-1:2] dram_wr_addr_2;
logic [XLEN-1:2] dram_wr_addr_3;

logic [7:0] dram_wr_data_0;
logic [7:0] dram_wr_data_1;
logic [7:0] dram_wr_data_2;
logic [7:0] dram_wr_data_3;

logic dram_wr_byte_en_0;
logic dram_wr_byte_en_1;
logic dram_wr_byte_en_2;
logic dram_wr_byte_en_3;

logic [XLEN-1:0] iram_rw_addr;
logic [XLEN-1:0] iram_rw_addr_r1;

logic [XLEN-1:0] dram_rd_addr;
logic [XLEN-1:0] dram_rd_addr_r1;

logic [XLEN-1:0] dram_wr_addr;
logic [XLEN-1:0] dram_wr_data;
logic      [3:0] dram_wr_byte_en;

logic [XLEN-1:0] iram_rd_data;
logic [XLEN-1:0] dram_rd_data;

wire iram_rw_en = (iram_rw_addr[31:24] == 8'h00);

wire dram_rd_en = (dram_rd_addr[31:24] == 8'h10);
wire dram_wr_en = (dram_wr_addr[31:24] == 8'h10);

wire [XLEN-1:2] iram_rw_addr_a = iram_rw_addr[XLEN-1:2];
wire [XLEN-1:2] iram_rw_addr_b = iram_rw_addr[XLEN-1:2] + 1'b1;

wire [XLEN-1:2] dram_rd_addr_a = dram_rd_addr[XLEN-1:2];
wire [XLEN-1:2] dram_rd_addr_b = dram_rd_addr[XLEN-1:2] + 1'b1;

wire [XLEN-1:2] dram_wr_addr_a = dram_wr_addr[XLEN-1:2];
wire [XLEN-1:2] dram_wr_addr_b = dram_wr_addr[XLEN-1:2] + 1'b1;

assign iram_rd_data_o = iram_rd_data;
assign dram_rd_data_o = dram_rd_data;

assign ram_rd_data_o = iram_rw_en ? iram_rd_data : (dram_rd_en ? dram_rd_data : 8'h00);

iram iram_0(
    .clka(clk_i),
    .ena(iram_rw_en),
    .wea(ram_wr_byte_en_i[0]),
    .addra(iram_rw_addr_0),
    .dina(ram_wr_data_i),
    .clkb(clk_i),
    .enb(iram_rw_en),
    .addrb(iram_rw_addr_0),
    .doutb(iram_rd_data_0)
);

iram iram_1(
    .clka(clk_i),
    .ena(iram_rw_en),
    .wea(ram_wr_byte_en_i[1]),
    .addra(iram_rw_addr_1),
    .dina(ram_wr_data_i),
    .clkb(clk_i),
    .enb(iram_rw_en),
    .addrb(iram_rw_addr_1),
    .doutb(iram_rd_data_1)
);

iram iram_2(
    .clka(clk_i),
    .ena(iram_rw_en),
    .wea(ram_wr_byte_en_i[2]),
    .addra(iram_rw_addr_2),
    .dina(ram_wr_data_i),
    .clkb(clk_i),
    .enb(iram_rw_en),
    .addrb(iram_rw_addr_2),
    .doutb(iram_rd_data_2)
);

iram iram_3(
    .clka(clk_i),
    .ena(iram_rw_en),
    .wea(ram_wr_byte_en_i[3]),
    .addra(iram_rw_addr_3),
    .dina(ram_wr_data_i),
    .clkb(clk_i),
    .enb(iram_rw_en),
    .addrb(iram_rw_addr_3),
    .doutb(iram_rd_data_3)
);

dram dram_0(
    .clka(clk_i),
    .ena(dram_wr_en),
    .wea(dram_wr_byte_en_0),
    .addra(dram_wr_addr_0),
    .dina(dram_wr_data_0),
    .clkb(clk_i),
    .enb(dram_rd_en),
    .addrb(dram_rd_addr_0),
    .doutb(dram_rd_data_0)
);

dram dram_1(
    .clka(clk_i),
    .ena(dram_wr_en),
    .wea(dram_wr_byte_en_1),
    .addra(dram_wr_addr_1),
    .dina(dram_wr_data_1),
    .clkb(clk_i),
    .enb(dram_rd_en),
    .addrb(dram_rd_addr_1),
    .doutb(dram_rd_data_1)
);

dram dram_2(
    .clka(clk_i),
    .ena(dram_wr_en),
    .wea(dram_wr_byte_en_2),
    .addra(dram_wr_addr_2),
    .dina(dram_wr_data_2),
    .clkb(clk_i),
    .enb(dram_rd_en),
    .addrb(dram_rd_addr_2),
    .doutb(dram_rd_data_2)
);

dram dram_3(
    .clka(clk_i),
    .ena(dram_wr_en),
    .wea(dram_wr_byte_en_3),
    .addra(dram_wr_addr_3),
    .dina(dram_wr_data_3),
    .clkb(clk_i),
    .enb(dram_rd_en),
    .addrb(dram_rd_addr_3),
    .doutb(dram_rd_data_3)
);

always_comb begin
    if (ram_rw_sel_i) begin
        iram_rw_addr    = ram_rw_addr_i;

        dram_rd_addr    = ram_rw_addr_i;
        dram_wr_addr    = ram_rw_addr_i;
        dram_wr_data    = {4{ram_wr_data_i}};
        dram_wr_byte_en = ram_wr_byte_en_i;
    end else begin
        iram_rw_addr    = iram_rd_addr_i;

        dram_rd_addr    = dram_rd_addr_i;
        dram_wr_addr    = dram_wr_addr_i;
        dram_wr_data    = dram_wr_data_i;
        dram_wr_byte_en = dram_wr_byte_en_i;
    end

    case (iram_rw_addr[1:0])
        2'b00: begin
            iram_rw_addr_0 = iram_rw_addr_a;
            iram_rw_addr_1 = iram_rw_addr_a;
            iram_rw_addr_2 = iram_rw_addr_a;
            iram_rw_addr_3 = iram_rw_addr_a;
        end
        2'b01: begin
            iram_rw_addr_0 = iram_rw_addr_b;
            iram_rw_addr_1 = iram_rw_addr_a;
            iram_rw_addr_2 = iram_rw_addr_a;
            iram_rw_addr_3 = iram_rw_addr_a;
        end
        2'b10: begin
            iram_rw_addr_0 = iram_rw_addr_b;
            iram_rw_addr_1 = iram_rw_addr_b;
            iram_rw_addr_2 = iram_rw_addr_a;
            iram_rw_addr_3 = iram_rw_addr_a;
        end
        2'b11: begin
            iram_rw_addr_0 = iram_rw_addr_b;
            iram_rw_addr_1 = iram_rw_addr_b;
            iram_rw_addr_2 = iram_rw_addr_b;
            iram_rw_addr_3 = iram_rw_addr_a;
        end
    endcase

    case (iram_rw_addr_r1[1:0])
        2'b00: begin
            iram_rd_data = {iram_rd_data_3, iram_rd_data_2, iram_rd_data_1, iram_rd_data_0};
        end
        2'b01: begin
            iram_rd_data = {iram_rd_data_0, iram_rd_data_3, iram_rd_data_2, iram_rd_data_1};
        end
        2'b10: begin
            iram_rd_data = {iram_rd_data_1, iram_rd_data_0, iram_rd_data_3, iram_rd_data_2};
        end
        2'b11: begin
            iram_rd_data = {iram_rd_data_2, iram_rd_data_1, iram_rd_data_0, iram_rd_data_3};
        end
    endcase

    case (dram_rd_addr[1:0])
        2'b00: begin
            dram_rd_addr_0 = dram_rd_addr_a;
            dram_rd_addr_1 = dram_rd_addr_a;
            dram_rd_addr_2 = dram_rd_addr_a;
            dram_rd_addr_3 = dram_rd_addr_a;
        end
        2'b01: begin
            dram_rd_addr_0 = dram_rd_addr_b;
            dram_rd_addr_1 = dram_rd_addr_a;
            dram_rd_addr_2 = dram_rd_addr_a;
            dram_rd_addr_3 = dram_rd_addr_a;
        end
        2'b10: begin
            dram_rd_addr_0 = dram_rd_addr_b;
            dram_rd_addr_1 = dram_rd_addr_b;
            dram_rd_addr_2 = dram_rd_addr_a;
            dram_rd_addr_3 = dram_rd_addr_a;
        end
        2'b11: begin
            dram_rd_addr_0 = dram_rd_addr_b;
            dram_rd_addr_1 = dram_rd_addr_b;
            dram_rd_addr_2 = dram_rd_addr_b;
            dram_rd_addr_3 = dram_rd_addr_a;
        end
    endcase

    case (dram_rd_addr_r1[1:0])
        2'b00: begin
            dram_rd_data = {dram_rd_data_3, dram_rd_data_2, dram_rd_data_1, dram_rd_data_0};
        end
        2'b01: begin
            dram_rd_data = {dram_rd_data_0, dram_rd_data_3, dram_rd_data_2, dram_rd_data_1};
        end
        2'b10: begin
            dram_rd_data = {dram_rd_data_1, dram_rd_data_0, dram_rd_data_3, dram_rd_data_2};
        end
        2'b11: begin
            dram_rd_data = {dram_rd_data_2, dram_rd_data_1, dram_rd_data_0, dram_rd_data_3};
        end
    endcase

    case (dram_wr_addr[1:0])
        2'b00: begin
            dram_wr_addr_0 = dram_wr_addr_a;
            dram_wr_addr_1 = dram_wr_addr_a;
            dram_wr_addr_2 = dram_wr_addr_a;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data[7:0];
            dram_wr_data_1 = dram_wr_data[15:8];
            dram_wr_data_2 = dram_wr_data[23:16];
            dram_wr_data_3 = dram_wr_data[31:24];

            dram_wr_byte_en_0 = dram_wr_byte_en[0];
            dram_wr_byte_en_1 = dram_wr_byte_en[1];
            dram_wr_byte_en_2 = dram_wr_byte_en[2];
            dram_wr_byte_en_3 = dram_wr_byte_en[3];
        end
        2'b01: begin
            dram_wr_addr_0 = dram_wr_addr_b;
            dram_wr_addr_1 = dram_wr_addr_a;
            dram_wr_addr_2 = dram_wr_addr_a;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data[31:24];
            dram_wr_data_1 = dram_wr_data[7:0];
            dram_wr_data_2 = dram_wr_data[15:8];
            dram_wr_data_3 = dram_wr_data[23:16];

            dram_wr_byte_en_0 = dram_wr_byte_en[3];
            dram_wr_byte_en_1 = dram_wr_byte_en[0];
            dram_wr_byte_en_2 = dram_wr_byte_en[1];
            dram_wr_byte_en_3 = dram_wr_byte_en[2];
        end
        2'b10: begin
            dram_wr_addr_0 = dram_wr_addr_b;
            dram_wr_addr_1 = dram_wr_addr_b;
            dram_wr_addr_2 = dram_wr_addr_a;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data[23:16];
            dram_wr_data_1 = dram_wr_data[31:24];
            dram_wr_data_2 = dram_wr_data[7:0];
            dram_wr_data_3 = dram_wr_data[15:8];

            dram_wr_byte_en_0 = dram_wr_byte_en[2];
            dram_wr_byte_en_1 = dram_wr_byte_en[3];
            dram_wr_byte_en_2 = dram_wr_byte_en[0];
            dram_wr_byte_en_3 = dram_wr_byte_en[1];
        end
        2'b11: begin
            dram_wr_addr_0 = dram_wr_addr_b;
            dram_wr_addr_1 = dram_wr_addr_b;
            dram_wr_addr_2 = dram_wr_addr_b;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data[15:8];
            dram_wr_data_1 = dram_wr_data[23:16];
            dram_wr_data_2 = dram_wr_data[31:24];
            dram_wr_data_3 = dram_wr_data[7:0];

            dram_wr_byte_en_0 = dram_wr_byte_en[1];
            dram_wr_byte_en_1 = dram_wr_byte_en[2];
            dram_wr_byte_en_2 = dram_wr_byte_en[3];
            dram_wr_byte_en_3 = dram_wr_byte_en[0];
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        iram_rw_addr_r1 <= {XLEN{1'b0}};
        dram_rd_addr_r1 <= {XLEN{1'b0}};
    end else begin
        iram_rw_addr_r1 <= iram_rw_addr;
        dram_rd_addr_r1 <= dram_rd_addr;
    end
end

endmodule
