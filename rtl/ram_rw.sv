/*
 * ram_rw.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ram_rw #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic dc_i,

    input logic       spi_byte_vld_i,
    input logic [7:0] spi_byte_data_i,

    output logic cpu_rst_n_o,

    output logic iram_wr_sel_o,
    output logic iram_rd_sel_o,

    output logic dram_wr_sel_o,
    output logic dram_rd_sel_o,

    output logic spi_byte_rdy_o,

    output logic [XLEN-1:0] ram_rw_addr_o,
    output logic      [3:0] ram_wr_byte_en_o
);

typedef enum logic [7:0] {
    CPU_RST = 8'h2a,
    CPU_RUN = 8'h2b,
    IRAM_WR = 8'h2c,
    IRAM_RD = 8'h2d,
    DRAM_WR = 8'h2e,
    DRAM_RD = 8'h2f
} cmd_t;

logic ram_rd_en;
logic ram_wr_en;

logic cpu_rst_n;

logic iram_rd_sel;
logic iram_wr_sel;

logic dram_rd_sel;
logic dram_wr_sel;

logic [1:0] spi_byte_rdy;

logic      [3:0] ram_wr_sel;
logic [XLEN-1:0] ram_rw_addr;
logic      [3:0] ram_wr_byte_en;

assign cpu_rst_n_o = cpu_rst_n;

assign iram_rd_sel_o = iram_rd_sel;
assign iram_wr_sel_o = iram_wr_sel;

assign dram_rd_sel_o = dram_rd_sel;
assign dram_wr_sel_o = dram_wr_sel;

assign spi_byte_rdy_o = spi_byte_rdy[1];

assign ram_rw_addr_o    = ram_rw_addr;
assign ram_wr_byte_en_o = ram_wr_byte_en;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        ram_rd_en <= 1'b0;
        ram_wr_en <= 1'b0;

        cpu_rst_n <= 1'b0;

        iram_rd_sel <= 1'b0;
        iram_wr_sel <= 1'b0;

        dram_rd_sel <= 1'b0;
        dram_wr_sel <= 1'b0;

        spi_byte_rdy <= 2'b00;

        ram_wr_sel  <= 4'b0000;
        ram_rw_addr <= 32'h0000_0000;
        ram_wr_byte_en <= 4'b0000;
    end else begin
        spi_byte_rdy <= {spi_byte_rdy[0], spi_byte_vld_i};

        if (spi_byte_vld_i) begin
            if (!dc_i) begin  // Command
                ram_rd_en <= 1'b0;
                ram_wr_en <= 1'b0;

                case (spi_byte_data_i)
                    CPU_RST: begin
                        cpu_rst_n <= 1'b0;

                        iram_rd_sel <= 1'b0;
                        iram_wr_sel <= 1'b0;

                        dram_rd_sel <= 1'b0;
                        dram_wr_sel <= 1'b0;

                        ram_wr_sel  <= 4'b0000;
                        ram_rw_addr <= 32'h0000_0000;
                    end
                    CPU_RUN: begin
                        cpu_rst_n <= 1'b1;

                        iram_rd_sel <= 1'b0;
                        iram_wr_sel <= 1'b0;

                        dram_rd_sel <= 1'b0;
                        dram_wr_sel <= 1'b0;

                        ram_wr_sel  <= 4'b0000;
                        ram_rw_addr <= 32'h0000_0000;
                    end
                    IRAM_WR: begin
                        cpu_rst_n <= 1'b0;

                        iram_rd_sel <= 1'b0;
                        iram_wr_sel <= 1'b1;

                        dram_rd_sel <= 1'b0;
                        dram_wr_sel <= 1'b0;

                        ram_wr_sel  <= 4'b0001;
                        ram_rw_addr <= 32'h0000_0000;
                    end
                    IRAM_RD: begin
                        cpu_rst_n <= 1'b0;

                        iram_rd_sel <= 1'b1;
                        iram_wr_sel <= 1'b0;

                        dram_rd_sel <= 1'b0;
                        dram_wr_sel <= 1'b0;

                        ram_wr_sel  <= 4'b0000;
                        ram_rw_addr <= 32'h0000_0000;
                    end
                    DRAM_WR: begin
                        cpu_rst_n <= 1'b0;

                        iram_rd_sel <= 1'b0;
                        iram_wr_sel <= 1'b0;

                        dram_rd_sel <= 1'b0;
                        dram_wr_sel <= 1'b1;

                        ram_wr_sel  <= 4'b0001;
                        ram_rw_addr <= 32'h0002_0000;
                    end
                    DRAM_RD: begin
                        cpu_rst_n <= 1'b0;

                        iram_rd_sel <= 1'b0;
                        iram_wr_sel <= 1'b0;

                        dram_rd_sel <= 1'b1;
                        dram_wr_sel <= 1'b0;

                        ram_wr_sel  <= 4'b0000;
                        ram_rw_addr <= 32'h0002_0000;
                    end
                    default: begin
                        cpu_rst_n <= 1'b0;

                        iram_rd_sel <= 1'b0;
                        iram_wr_sel <= 1'b0;

                        dram_rd_sel <= 1'b0;
                        dram_wr_sel <= 1'b0;

                        ram_wr_sel  <= 4'b0000;
                        ram_rw_addr <= 32'h0000_0000;
                    end
                endcase
            end else begin    // Data
                ram_rd_en <= iram_rd_sel | dram_rd_sel;
                ram_wr_en <= iram_wr_sel | dram_wr_sel;

                cpu_rst_n <= cpu_rst_n;

                iram_rd_sel <= iram_rd_sel;
                iram_wr_sel <= iram_wr_sel;

                dram_rd_sel <= dram_rd_sel;
                dram_wr_sel <= dram_wr_sel;

                ram_wr_sel  <= {ram_wr_sel[2:0], ram_wr_sel[3]};
                ram_rw_addr <= ram_rw_addr + (ram_rd_en | ram_wr_en);
            end
        end

        ram_wr_byte_en <= ram_wr_sel & {4{spi_byte_vld_i & dc_i}};
    end
end

endmodule
