/*
 * ram_rw.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ram_rw(
    input logic clk_i,
    input logic rst_n_i,

    input logic dc_i,

    input logic       spi_byte_vld_i,
    input logic [7:0] spi_byte_data_i,

    output logic iram_rw_sel_o,
    output logic dram_rd_sel_o,

    output logic        iram_wr_en_o,
    output logic [15:0] iram_wr_addr_o,
    output logic [15:0] iram_wr_data_o,

    output logic [15:0] dram_rd_addr_o
);

localparam [7:0] RAM_WR_ST = 8'h2a;
localparam [7:0] RAM_WR_SP = 8'h2b;

logic ram_wr;
logic ram_done;

logic        wr_en;
logic [12:0] wr_addr;

assign cpu_rst_n_o = ram_done;
assign iram_wr_en_o = spi_byte_vld_i & ram_wr;

assign iram_wr_addr_o = wr_addr;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        ram_wr   <= 1'b0;
        ram_done <= 1'b0;

//        wr_byte_en <= 4'b0000;

        wr_addr <= 13'h0000;
    end else begin
        if (spi_byte_vld_i) begin
            if (!dc_i) begin  // Command
                case (spi_byte_data_i)
                    RAM_WR_ST: begin    // Write RAM Start
                        ram_wr   <= 1'b1;
                        ram_done <= 1'b0;
                        
//                        wr_byte_en <= 4'b1000;
                    end
                    RAM_WR_SP: begin    // Write RAM Stop
                        ram_wr   <= 1'b0;
                        ram_done <= 1'b1;
                    
//                        wr_byte_en <= 4'b0000;
                    end
                    default: begin
                        ram_wr   <= 1'b0;
                        ram_done <= 1'b0;
                
//                        wr_byte_en <= 4'b0000;
                    end
                endcase
                
                wr_addr <= 13'h0000;
            end else begin    // Data
                ram_wr   <= ram_wr;
                ram_done <= 1'b0;

//                wr_byte_en <= {wr_byte_en[0], wr_byte_en[3:1]};

                wr_addr <= wr_addr + 1'b1;
            end
        end
    end
end

endmodule
