/*
 * iram_loader.sv
 *
 *  Created on: 2020-07-19 18:00
 *      Author: Jack Chen <redchenjs@live.com>
 */

module iram_loader(
    input logic clk_i,
    input logic rst_n_i,

    input logic dc_i,

    input logic       byte_rdy_i,
    input logic [7:0] byte_data_i,

    output logic        wr_en_o,
    output logic        wr_done_o,
    output logic [12:0] wr_addr_o,
    output logic [ 3:0] wr_byte_en_o
);

localparam [7:0] RAM_WR_ST = 8'h2a;
localparam [7:0] RAM_WR_SP = 8'h2b;

logic ram_wr;
logic ram_done;

logic        wr_en;
logic [12:0] wr_addr;
logic [ 3:0] wr_byte_en;

assign wr_en_o   = byte_rdy_i & ram_wr;
assign wr_done_o = ram_done;

assign wr_addr_o    = wr_addr;
assign wr_byte_en_o = wr_byte_en;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        ram_wr   <= 1'b0;
        ram_done <= 1'b0;

        wr_byte_en <= 4'b0000;

        wr_addr <= 13'h0000;
    end else begin
        if (byte_rdy_i) begin
            if (!dc_i) begin  // Command
                case (byte_data_i)
                    RAM_WR_ST: begin    // Write RAM Start
                        ram_wr   <= 1'b1;
                        ram_done <= 1'b0;
                        
                        wr_byte_en <= 4'b1000;
                    end
                    RAM_WR_SP: begin    // Write RAM Stop
                        ram_wr   <= 1'b0;
                        ram_done <= 1'b1;
                    
                        wr_byte_en <= 4'b0000;
                    end
                    default: begin
                        ram_wr   <= 1'b0;
                        ram_done <= 1'b0;
                
                        wr_byte_en <= 4'b0000;
                    end
                endcase
                
                wr_addr <= 13'h0000;
            end else begin    // Data
                ram_wr   <= ram_wr;
                ram_done <= 1'b0;

                wr_byte_en <= {wr_byte_en[0], wr_byte_en[3:1]};

                wr_addr <= wr_addr + 1'b1;
            end
        end
    end
end

endmodule
