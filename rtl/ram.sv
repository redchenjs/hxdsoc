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

    input logic [XLEN-1:0] iram_rd_addr_i,
    input logic [XLEN-1:0] iram_wr_addr_i,
    input logic [XLEN-1:0] iram_wr_data_i,
    input logic      [3:0] iram_wr_byte_en_i,

    input logic [XLEN-1:0] dram_rd_addr_i,
    input logic [XLEN-1:0] dram_wr_addr_i,
    input logic [XLEN-1:0] dram_wr_data_i,
    input logic      [3:0] dram_wr_byte_en_i,

    inout wire [XLEN-1:0] iram_rd_data_io,
    inout wire [XLEN-1:0] dram_rd_data_io
);

logic iram_rd_en_r1;
logic dram_rd_en_r1;

logic [XLEN-1:2] iram_rd_addr_0;
logic [XLEN-1:2] iram_rd_addr_1;
logic [XLEN-1:2] iram_rd_addr_2;
logic [XLEN-1:2] iram_rd_addr_3;

logic [7:0] iram_rd_data_0;
logic [7:0] iram_rd_data_1;
logic [7:0] iram_rd_data_2;
logic [7:0] iram_rd_data_3;

logic [XLEN-1:2] iram_wr_addr_0;
logic [XLEN-1:2] iram_wr_addr_1;
logic [XLEN-1:2] iram_wr_addr_2;
logic [XLEN-1:2] iram_wr_addr_3;

logic [7:0] iram_wr_data_0;
logic [7:0] iram_wr_data_1;
logic [7:0] iram_wr_data_2;
logic [7:0] iram_wr_data_3;

logic iram_wr_byte_en_0;
logic iram_wr_byte_en_1;
logic iram_wr_byte_en_2;
logic iram_wr_byte_en_3;

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

logic [XLEN-1:0] iram_rd_addr_r1;
logic [XLEN-1:0] dram_rd_addr_r1;

logic [XLEN-1:0] iram_rd_data;
logic [XLEN-1:0] dram_rd_data;

wire iram_rd_en = (iram_rd_addr_i[31:24] == 8'h00);
wire iram_wr_en = (iram_wr_addr_i[31:24] == 8'h00);

wire dram_rd_en = (dram_rd_addr_i[31:24] == 8'h10);
wire dram_wr_en = (dram_wr_addr_i[31:24] == 8'h10);

wire [XLEN-1:2] iram_rd_addr_a = iram_rd_addr_i[XLEN-1:2];
wire [XLEN-1:2] iram_rd_addr_b = iram_rd_addr_i[XLEN-1:2] + 1'b1;

wire [XLEN-1:2] iram_wr_addr_a = iram_wr_addr_i[XLEN-1:2];
wire [XLEN-1:2] iram_wr_addr_b = iram_wr_addr_i[XLEN-1:2] + 1'b1;

wire [XLEN-1:2] dram_rd_addr_a = dram_rd_addr_i[XLEN-1:2];
wire [XLEN-1:2] dram_rd_addr_b = dram_rd_addr_i[XLEN-1:2] + 1'b1;

wire [XLEN-1:2] dram_wr_addr_a = dram_wr_addr_i[XLEN-1:2];
wire [XLEN-1:2] dram_wr_addr_b = dram_wr_addr_i[XLEN-1:2] + 1'b1;

assign iram_rd_data_io = iram_rd_en_r1 ? iram_rd_data : {XLEN{1'bz}};
assign dram_rd_data_io = dram_rd_en_r1 ? dram_rd_data : {XLEN{1'bz}};

iram iram_0(
    .clka(clk_i),
    .ena(iram_wr_en),
    .wea(iram_wr_byte_en_0),
    .addra(iram_wr_addr_0),
    .dina(iram_wr_data_0),
    .clkb(clk_i),
    .enb(iram_rd_en),
    .addrb(iram_rd_addr_0),
    .doutb(iram_rd_data_0)
);

iram iram_1(
    .clka(clk_i),
    .ena(iram_wr_en),
    .wea(iram_wr_byte_en_1),
    .addra(iram_wr_addr_1),
    .dina(iram_wr_data_1),
    .clkb(clk_i),
    .enb(iram_rd_en),
    .addrb(iram_rd_addr_1),
    .doutb(iram_rd_data_1)
);

iram iram_2(
    .clka(clk_i),
    .ena(iram_wr_en),
    .wea(iram_wr_byte_en_2),
    .addra(iram_wr_addr_2),
    .dina(iram_wr_data_2),
    .clkb(clk_i),
    .enb(iram_rd_en),
    .addrb(iram_rd_addr_2),
    .doutb(iram_rd_data_2)
);

iram iram_3(
    .clka(clk_i),
    .ena(iram_wr_en),
    .wea(iram_wr_byte_en_3),
    .addra(iram_wr_addr_3),
    .dina(iram_wr_data_3),
    .clkb(clk_i),
    .enb(iram_rd_en),
    .addrb(iram_rd_addr_3),
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
    case (iram_rd_addr_i[1:0])
        2'b00: begin
            iram_rd_addr_0 = iram_rd_addr_a;
            iram_rd_addr_1 = iram_rd_addr_a;
            iram_rd_addr_2 = iram_rd_addr_a;
            iram_rd_addr_3 = iram_rd_addr_a;
        end
        2'b01: begin
            iram_rd_addr_0 = iram_rd_addr_b;
            iram_rd_addr_1 = iram_rd_addr_a;
            iram_rd_addr_2 = iram_rd_addr_a;
            iram_rd_addr_3 = iram_rd_addr_a;
        end
        2'b10: begin
            iram_rd_addr_0 = iram_rd_addr_b;
            iram_rd_addr_1 = iram_rd_addr_b;
            iram_rd_addr_2 = iram_rd_addr_a;
            iram_rd_addr_3 = iram_rd_addr_a;
        end
        2'b11: begin
            iram_rd_addr_0 = iram_rd_addr_b;
            iram_rd_addr_1 = iram_rd_addr_b;
            iram_rd_addr_2 = iram_rd_addr_b;
            iram_rd_addr_3 = iram_rd_addr_a;
        end
    endcase

    case (iram_rd_addr_r1[1:0])
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

    case (iram_wr_addr_i[1:0])
        2'b00: begin
            iram_wr_addr_0 = iram_wr_addr_a;
            iram_wr_addr_1 = iram_wr_addr_a;
            iram_wr_addr_2 = iram_wr_addr_a;
            iram_wr_addr_3 = iram_wr_addr_a;

            iram_wr_data_0 = iram_wr_data_i[7:0];
            iram_wr_data_1 = iram_wr_data_i[15:8];
            iram_wr_data_2 = iram_wr_data_i[23:16];
            iram_wr_data_3 = iram_wr_data_i[31:24];

            iram_wr_byte_en_0 = iram_wr_byte_en_i[0];
            iram_wr_byte_en_1 = iram_wr_byte_en_i[1];
            iram_wr_byte_en_2 = iram_wr_byte_en_i[2];
            iram_wr_byte_en_3 = iram_wr_byte_en_i[3];
        end
        2'b01: begin
            iram_wr_addr_0 = iram_wr_addr_b;
            iram_wr_addr_1 = iram_wr_addr_a;
            iram_wr_addr_2 = iram_wr_addr_a;
            iram_wr_addr_3 = iram_wr_addr_a;

            iram_wr_data_0 = iram_wr_data_i[31:24];
            iram_wr_data_1 = iram_wr_data_i[7:0];
            iram_wr_data_2 = iram_wr_data_i[15:8];
            iram_wr_data_3 = iram_wr_data_i[23:16];

            iram_wr_byte_en_0 = iram_wr_byte_en_i[3];
            iram_wr_byte_en_1 = iram_wr_byte_en_i[0];
            iram_wr_byte_en_2 = iram_wr_byte_en_i[1];
            iram_wr_byte_en_3 = iram_wr_byte_en_i[2];
        end
        2'b10: begin
            iram_wr_addr_0 = iram_wr_addr_b;
            iram_wr_addr_1 = iram_wr_addr_b;
            iram_wr_addr_2 = iram_wr_addr_a;
            iram_wr_addr_3 = iram_wr_addr_a;

            iram_wr_data_0 = iram_wr_data_i[23:16];
            iram_wr_data_1 = iram_wr_data_i[31:24];
            iram_wr_data_2 = iram_wr_data_i[7:0];
            iram_wr_data_3 = iram_wr_data_i[15:8];

            iram_wr_byte_en_0 = iram_wr_byte_en_i[2];
            iram_wr_byte_en_1 = iram_wr_byte_en_i[3];
            iram_wr_byte_en_2 = iram_wr_byte_en_i[0];
            iram_wr_byte_en_3 = iram_wr_byte_en_i[1];
        end
        2'b11: begin
            iram_wr_addr_0 = iram_wr_addr_b;
            iram_wr_addr_1 = iram_wr_addr_b;
            iram_wr_addr_2 = iram_wr_addr_b;
            iram_wr_addr_3 = iram_wr_addr_a;

            iram_wr_data_0 = iram_wr_data_i[15:8];
            iram_wr_data_1 = iram_wr_data_i[23:16];
            iram_wr_data_2 = iram_wr_data_i[31:24];
            iram_wr_data_3 = iram_wr_data_i[7:0];

            iram_wr_byte_en_0 = iram_wr_byte_en_i[1];
            iram_wr_byte_en_1 = iram_wr_byte_en_i[2];
            iram_wr_byte_en_2 = iram_wr_byte_en_i[3];
            iram_wr_byte_en_3 = iram_wr_byte_en_i[0];
        end
    endcase

    case (dram_rd_addr_i[1:0])
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

    case (dram_wr_addr_i[1:0])
        2'b00: begin
            dram_wr_addr_0 = dram_wr_addr_a;
            dram_wr_addr_1 = dram_wr_addr_a;
            dram_wr_addr_2 = dram_wr_addr_a;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data_i[7:0];
            dram_wr_data_1 = dram_wr_data_i[15:8];
            dram_wr_data_2 = dram_wr_data_i[23:16];
            dram_wr_data_3 = dram_wr_data_i[31:24];

            dram_wr_byte_en_0 = dram_wr_byte_en_i[0];
            dram_wr_byte_en_1 = dram_wr_byte_en_i[1];
            dram_wr_byte_en_2 = dram_wr_byte_en_i[2];
            dram_wr_byte_en_3 = dram_wr_byte_en_i[3];
        end
        2'b01: begin
            dram_wr_addr_0 = dram_wr_addr_b;
            dram_wr_addr_1 = dram_wr_addr_a;
            dram_wr_addr_2 = dram_wr_addr_a;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data_i[31:24];
            dram_wr_data_1 = dram_wr_data_i[7:0];
            dram_wr_data_2 = dram_wr_data_i[15:8];
            dram_wr_data_3 = dram_wr_data_i[23:16];

            dram_wr_byte_en_0 = dram_wr_byte_en_i[3];
            dram_wr_byte_en_1 = dram_wr_byte_en_i[0];
            dram_wr_byte_en_2 = dram_wr_byte_en_i[1];
            dram_wr_byte_en_3 = dram_wr_byte_en_i[2];
        end
        2'b10: begin
            dram_wr_addr_0 = dram_wr_addr_b;
            dram_wr_addr_1 = dram_wr_addr_b;
            dram_wr_addr_2 = dram_wr_addr_a;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data_i[23:16];
            dram_wr_data_1 = dram_wr_data_i[31:24];
            dram_wr_data_2 = dram_wr_data_i[7:0];
            dram_wr_data_3 = dram_wr_data_i[15:8];

            dram_wr_byte_en_0 = dram_wr_byte_en_i[2];
            dram_wr_byte_en_1 = dram_wr_byte_en_i[3];
            dram_wr_byte_en_2 = dram_wr_byte_en_i[0];
            dram_wr_byte_en_3 = dram_wr_byte_en_i[1];
        end
        2'b11: begin
            dram_wr_addr_0 = dram_wr_addr_b;
            dram_wr_addr_1 = dram_wr_addr_b;
            dram_wr_addr_2 = dram_wr_addr_b;
            dram_wr_addr_3 = dram_wr_addr_a;

            dram_wr_data_0 = dram_wr_data_i[15:8];
            dram_wr_data_1 = dram_wr_data_i[23:16];
            dram_wr_data_2 = dram_wr_data_i[31:24];
            dram_wr_data_3 = dram_wr_data_i[7:0];

            dram_wr_byte_en_0 = dram_wr_byte_en_i[1];
            dram_wr_byte_en_1 = dram_wr_byte_en_i[2];
            dram_wr_byte_en_2 = dram_wr_byte_en_i[3];
            dram_wr_byte_en_3 = dram_wr_byte_en_i[0];
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        iram_rd_en_r1 <= 1'b0;
        dram_rd_en_r1 <= 1'b0;

        iram_rd_addr_r1 <= {XLEN{1'b0}};
        dram_rd_addr_r1 <= {XLEN{1'b0}};
    end else begin
        iram_rd_en_r1 <= iram_rd_en;
        dram_rd_en_r1 <= dram_rd_en;

        iram_rd_addr_r1 <= iram_rd_addr_i;
        dram_rd_addr_r1 <= dram_rd_addr_i;
    end
end

endmodule
