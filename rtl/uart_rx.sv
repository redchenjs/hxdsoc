/*
 * uart_rx.sv
 *
 *  Created on: 2021-07-12 13:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

module uart_rx(
    input logic clk_i,
    input logic rst_n_i,

    input logic uart_rx_i,
    input logic uart_rx_data_rdy_i,

    input logic [31:0] uart_rx_baud_div_i,

    output logic [7:0] uart_rx_data_o,
    output logic       uart_rx_data_vld_o
);

typedef enum logic [1:0] {
    IDLE  = 2'h0,
    START = 2'h1,
    DATA  = 2'h2,
    STOP  = 2'h3
} state_t;

state_t rx_sta;

logic uart_rx_n;

logic        clk_r;
logic        clk_s;
logic [31:0] clk_cnt;

logic [2:0] bit_sel;
logic [7:0] bit_sft;

logic bit_data;

logic sta_idle;

logic [7:0] rx_data;
logic       rx_data_vld;

assign uart_rx_data_o     = rx_data;
assign uart_rx_data_vld_o = rx_data_vld;

edge2en uart_rx_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(uart_rx_i),
    .neg_edge_o(uart_rx_n)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rx_data     <= 8'h00;
        rx_data_vld <= 1'b0;
    end else begin
        rx_data     <= sta_idle & ~rx_data_vld ? bit_sft : rx_data;
        rx_data_vld <= sta_idle & ~rx_data_vld ? 1'b1 : (uart_rx_data_rdy_i ? 1'b0 : rx_data_vld);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_r   <= 1'b0;
        clk_s   <= 1'b0;
        clk_cnt <= 32'h0000_0000;
    end else begin
        clk_r   <= (rx_sta == IDLE) & uart_rx_n;
        clk_s   <= (clk_cnt == uart_rx_baud_div_i);
        clk_cnt <= clk_r ? uart_rx_baud_div_i[31:1] : ((rx_sta == IDLE) | clk_s ? 32'h0000_0000 : clk_cnt + 1'b1);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rx_sta <= IDLE;

        bit_sel <= 3'h0;
        bit_sft <= 8'h00;

        bit_data <= 1'b1;

        sta_idle <= 1'b0;
    end else begin
        case (rx_sta)
            IDLE:
                rx_sta <= clk_r ? START : rx_sta;
            START:
                rx_sta <= clk_s ? DATA : rx_sta;
            DATA:
                rx_sta <= clk_s & (bit_sel == 3'h7) ? STOP : rx_sta;
            STOP:
                rx_sta <= clk_s ? (clk_r ? START : IDLE) : rx_sta;
            default:
                rx_sta <= IDLE;
        endcase

        case (rx_sta)
            START: begin
                bit_sel <= clk_s ? 1'b0 : bit_sel;
                bit_sft <= clk_s ? 8'h00 : bit_sft;
            end
            DATA: begin
                bit_sel <= clk_s ? bit_sel + 1'b1 : bit_sel;
                bit_sft <= clk_s ? {bit_data, bit_sft[7:1]} : bit_sft;
            end
        endcase

        bit_data <= uart_rx_i;

        sta_idle <= clk_s & (rx_sta == STOP);
    end
end

endmodule
