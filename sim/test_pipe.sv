/*
 * test_pipe.sv
 *
 *  Created on: 2021-07-12 15:23
 *      Author: Jack Chen <redchenjs@live.com>
 */

`timescale 1ns / 1ps

module test_pipe;

parameter WIDTH = 32;

logic clk_i;
logic rst_n_i;

logic [WIDTH-1:0] data_i;
logic             data_vld_i;
logic             data_rdy_i;

logic [WIDTH-1:0] data_o;
logic             data_vld_o;
logic             data_rdy_o;

logic [WIDTH-1:0] data_s;

pipe #(
    .WIDTH(WIDTH)
) pipe (
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .data_i(data_i),
    .data_vld_i(data_vld_i),
    .data_rdy_i(data_rdy_i),

    .data_o(data_o),
    .data_vld_o(data_vld_o),
    .data_rdy_o(data_rdy_o)
);

initial begin
    clk_i   <= 1'b1;
    rst_n_i <= 1'b0;

    #2 rst_n_i <= 1'b1;
end

always begin
    #2.5 clk_i <= ~clk_i;
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_i     <= 32'hdead_beef;
        data_vld_i <= 1'b1;
    end else begin
        if (data_rdy_o) begin
            data_i     <= data_i + 1'b1;
            data_vld_i <= 1'b0;
        end
    end
end

always @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        data_s     <= 32'h0000_0000;
        data_rdy_i <= 1'b0;
    end else begin
        if (data_vld_o) begin
            data_s     <= data_o;
            data_rdy_i <= 1'b1;
        end else begin
            data_rdy_i <= 1'b0;
        end
    end
end

always begin
    #7500 rst_n_i <= 1'b0;
    #25 $stop;
end

endmodule
