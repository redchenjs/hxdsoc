/*
 * uart_tx.sv
 *
 *  Created on: 2021-07-12 13:02
 *      Author: Jack Chen <redchenjs@live.com>
 */

module uart_tx(
    input logic clk_i,
    input logic rst_n_i,

    input logic [7:0] uart_tx_data_i,
    input logic       uart_tx_data_vld_i,

    input logic [31:0] uart_tx_baud_div_i,

    output logic uart_tx_o,
    output logic uart_tx_data_rdy_o
);

typedef enum logic [1:0] {
    IDLE  = 2'h0,
    START = 2'h1,
    DATA  = 2'h2,
    STOP  = 2'h3
} state_t;

state_t tx_sta;

logic        clk_s;
logic [31:0] clk_cnt;

logic [2:0] bit_sel;
logic [7:0] bit_sft;

logic bit_data;

logic [7:0] tx_data;
logic       tx_data_vld;
logic       tx_data_rdy;

assign tx_data     = uart_tx_data_i;
assign tx_data_vld = uart_tx_data_vld_i;

assign uart_tx_o          = bit_data;
assign uart_tx_data_rdy_o = tx_data_rdy;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        clk_s   <= 1'b0;
        clk_cnt <= 32'h0000_0000;
    end else begin
        clk_s   <= (clk_cnt == uart_tx_baud_div_i);
        clk_cnt <= (tx_sta == IDLE) | clk_s ? 32'h0000_0000 : clk_cnt + 1'b1;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        tx_data_rdy <= 1'b1;
    end else begin
        tx_data_rdy <= tx_data_vld & tx_data_rdy ? 1'b0 : (clk_s & (tx_sta == STOP) ? 1'b1 : tx_data_rdy);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        tx_sta <= IDLE;

        bit_sel <= 3'h0;
        bit_sft <= 8'h00;

        bit_data <= 1'b1;
    end else begin
        case (tx_sta)
            IDLE:
                tx_sta <= tx_data_vld ? START : tx_sta;
            START:
                tx_sta <= clk_s ? DATA : tx_sta;
            DATA:
                tx_sta <= clk_s & (bit_sel == 3'h7) ? STOP : tx_sta;
            STOP:
                tx_sta <= clk_s ? IDLE : tx_sta;
            default:
                tx_sta <= IDLE;
        endcase

        case (tx_sta)
            START: begin
                bit_sel <= clk_s ? 1'b0 : bit_sel;
                bit_sft <= clk_s ? tx_data : bit_sft;
            end
            DATA: begin
                bit_sel <= clk_s ? bit_sel + 1'b1 : bit_sel;
                bit_sft <= clk_s ? {1'b0, bit_sft[7:1]} : bit_sft;
            end
        endcase

        bit_data <= bit_sft[0] | (tx_sta == IDLE) | (tx_sta == STOP);
    end
end

endmodule
