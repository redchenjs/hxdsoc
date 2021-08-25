/*
 * uart.sv
 *
 *  Created on: 2021-08-22 18:36
 *      Author: Jack Chen <redchenjs@live.com>
 */

module uart #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic uart_rx_i,

    input logic [XLEN-1:0] rd_addr_i,
    input logic [XLEN-1:0] wr_addr_i,
    input logic [XLEN-1:0] wr_data_i,
    input logic      [3:0] wr_byte_en_i,

    output logic uart_tx_o,

    inout wire [XLEN-1:0] rd_data_io
);

typedef enum logic [1:0] {
    UART_REG_CTRL_0  = 2'h0,
    UART_REG_CTRL_1  = 2'h1,
    UART_REG_DATA_TX = 2'h2,
    UART_REG_DATA_RX = 2'h3
} uart_reg_t;

typedef struct packed {
    logic [31:0] baud;
} uart_ctrl_0_t;

typedef struct packed {
    logic [7:0] rsvd_3;
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;

    logic [7:1] rsvd_0;
    logic       rst_n;
} uart_ctrl_1_t;

typedef struct packed {
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;

    logic [7:1] rsvd_0;
    logic       tx_flag;

    logic [7:0] tx_data;
} uart_data_tx_t;

typedef struct packed {
    logic [7:0] rsvd_2;
    logic [7:0] rsvd_1;

    logic [7:1] rsvd_0;
    logic       rx_flag;

    logic [7:0] rx_data;
} uart_data_rx_t;

logic [XLEN-1:0] data[4];

logic [XLEN-1:0] rd_data;
logic            rd_en_r1;

logic [7:0] tx_data;
logic       tx_data_vld;
logic       tx_data_rdy;

logic [7:0] rx_data;
logic       rx_data_vld;
logic       rx_data_rdy;

uart_ctrl_0_t uart_ctrl_0 = 32'h0000_0000;
uart_ctrl_1_t uart_ctrl_1 = 32'h0000_0000;

uart_data_tx_t uart_data_tx = 32'h0000_0000;
uart_data_rx_t uart_data_rx = 32'h0000_0000;

wire rd_en = (rd_addr_i[31:8] == 24'h4000_00);
wire wr_en = (wr_addr_i[31:8] == 24'h4000_00);

assign data[UART_REG_CTRL_0]  = uart_ctrl_0;
assign data[UART_REG_CTRL_1]  = uart_ctrl_1;
assign data[UART_REG_DATA_TX] = uart_data_tx;
assign data[UART_REG_DATA_RX] = uart_data_rx;

assign uart_data_tx.tx_data = tx_data;
assign uart_data_tx.tx_flag = tx_data_rdy;
assign uart_data_rx.rx_data = rx_data;
assign uart_data_rx.rx_flag = rx_data_vld;

assign rd_data_io = rd_en_r1 ? rd_data : {XLEN{1'bz}};

uart_tx uart_tx(
    .clk_i(clk_i),
    .rst_n_i(uart_ctrl_1.rst_n),

    .uart_tx_data_i(tx_data),
    .uart_tx_data_vld_i(tx_data_vld),

    .uart_tx_baud_div_i(uart_ctrl_0.baud),

    .uart_tx_o(uart_tx_o),
    .uart_tx_data_rdy_o(tx_data_rdy)
);

uart_rx uart_rx(
    .clk_i(clk_i),
    .rst_n_i(uart_ctrl_1.rst_n),

    .uart_rx_i(uart_rx_i),
    .uart_rx_data_rdy_i(rx_data_rdy),

    .uart_rx_baud_div_i(uart_ctrl_0.baud),

    .uart_rx_data_o(rx_data),
    .uart_rx_data_vld_o(rx_data_vld)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_data <= {XLEN{1'b0}};

        uart_ctrl_0.baud  <= {XLEN{1'b0}};
        uart_ctrl_1.rst_n <= 1'b0;

        tx_data     <= 8'h00;
        tx_data_vld <= 1'b0;
    end else begin
        rd_data <= rd_en ? data[rd_addr_i[3:2]] : rd_data;

        if (wr_en & |wr_byte_en_i) begin
            case (wr_addr_i[3:2])
                UART_REG_CTRL_0: begin
                    uart_ctrl_0.baud <= wr_data_i;
                end
                UART_REG_CTRL_1: begin
                    uart_ctrl_1.rst_n <= wr_data_i;
                end
                UART_REG_DATA_TX: begin
                    tx_data     <= wr_data_i;
                    tx_data_vld <= 1'b1;
                end
            endcase
        end else begin
            tx_data_vld <= tx_data_rdy ? 1'b0 : tx_data_vld;
        end
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rx_data_rdy <= 1'b0;
    end else begin
        rx_data_rdy <= rx_data_vld ? (rd_en & (rd_addr_i[3:2] == UART_REG_DATA_RX) ? 1'b1 : rx_data_rdy) : 1'b0;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_en_r1 <= 1'b0;
    end else begin
        rd_en_r1 <= rd_en;
    end
end

endmodule
