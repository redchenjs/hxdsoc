/*
 * reg_file.sv
 *
 *  Created on: 2020-08-02 16:55
 *      Author: Jack Chen <redchenjs@live.com>
 */

module reg_file #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic            pc_wr_en_i,
    input logic [XLEN-1:0] pc_wr_data_i,

    input logic            rd_wr_en_i,
    input logic      [4:0] rd_wr_addr_i,
    input logic [XLEN-1:0] rd_wr_data_i,

    input logic [4:0] rs1_rd_addr_i,
    input logic [4:0] rs2_rd_addr_i,

    output logic [XLEN-1:0] pc_rd_data_o,

    output logic [XLEN-1:0] rs1_rd_data_o,
    output logic [XLEN-1:0] rs2_rd_data_o
);

logic [XLEN-1:0] pc;
logic [XLEN-1:0] x_reg [31:1];

logic [XLEN-1:0] rs1_rd_data;
logic [XLEN-1:0] rs2_rd_data;

wire [XLEN-1:0] x0_zero  = {XLEN{1'b0}}; // Hard-wired zero
wire [XLEN-1:0] x1_ra    = x_reg[1];     // Return address
wire [XLEN-1:0] x2_sp    = x_reg[2];     // Stack pointer
wire [XLEN-1:0] x3_gp    = x_reg[3];     // Global pointer
wire [XLEN-1:0] x4_tp    = x_reg[4];     // Thread pointer
wire [XLEN-1:0] x5_t0    = x_reg[5];     // Temporary / alternate link register
wire [XLEN-1:0] x6_t1    = x_reg[6];     // Temporary
wire [XLEN-1:0] x7_t2    = x_reg[7];     // Temporary
wire [XLEN-1:0] x8_s0_fp = x_reg[8];     // Saved register / frame pointer
wire [XLEN-1:0] x9_s1    = x_reg[9];     // Saved register
wire [XLEN-1:0] x10_a0   = x_reg[10];    // Function argument / return value
wire [XLEN-1:0] x11_a1   = x_reg[11];    // Function argument / return value
wire [XLEN-1:0] x12_a2   = x_reg[12];    // Function argument
wire [XLEN-1:0] x13_a3   = x_reg[13];    // Function argument
wire [XLEN-1:0] x14_a4   = x_reg[14];    // Function argument
wire [XLEN-1:0] x15_a5   = x_reg[15];    // Function argument
wire [XLEN-1:0] x16_a6   = x_reg[16];    // Function argument
wire [XLEN-1:0] x17_a7   = x_reg[17];    // Function argument
wire [XLEN-1:0] x18_s2   = x_reg[18];    // Saved register
wire [XLEN-1:0] x19_s3   = x_reg[19];    // Saved register
wire [XLEN-1:0] x20_s4   = x_reg[20];    // Saved register
wire [XLEN-1:0] x21_s5   = x_reg[21];    // Saved register
wire [XLEN-1:0] x22_s6   = x_reg[22];    // Saved register
wire [XLEN-1:0] x23_s7   = x_reg[23];    // Saved register
wire [XLEN-1:0] x24_s8   = x_reg[24];    // Saved register
wire [XLEN-1:0] x25_s9   = x_reg[25];    // Saved register
wire [XLEN-1:0] x26_s10  = x_reg[26];    // Saved register
wire [XLEN-1:0] x27_s11  = x_reg[27];    // Saved register
wire [XLEN-1:0] x28_t3   = x_reg[28];    // Temporary
wire [XLEN-1:0] x29_t4   = x_reg[29];    // Temporary
wire [XLEN-1:0] x30_t5   = x_reg[30];    // Temporary
wire [XLEN-1:0] x31_t6   = x_reg[31];    // Temporary

assign pc_rd_data_o = pc;

assign rs1_rd_data_o = rs1_rd_data;
assign rs2_rd_data_o = rs2_rd_data;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        pc <= {XLEN{1'b0}};

        for (integer i=1; i<32; i++) begin
            x_reg[i] <= {XLEN{1'b0}};
        end
        
        rs1_rd_data = {XLEN{1'b0}};
        rs2_rd_data = {XLEN{1'b0}};
    end else begin
        if (pc_wr_en_i) begin
            pc <= pc_wr_data_i;
        end

        if (rd_wr_en_i) begin
            x_reg[rd_wr_addr_i] <= rd_wr_data_i;
        end

        rs1_rd_data = x_reg[rs1_rd_addr_i];
        rs2_rd_data = x_reg[rs2_rd_addr_i];
    end
end

endmodule
