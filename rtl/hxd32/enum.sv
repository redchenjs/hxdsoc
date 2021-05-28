/*
 * enum.sv
 *
 *  Created on: 2021-05-20 15:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

typedef enum logic {
    PC_WR_PC_NEXT = 1'h0,
    PC_WR_ALU     = 1'h1
} pc_wr_sel_t;

typedef enum logic {
    PC_INC_4 = 1'h0,
    PC_INC_2 = 1'h1
} pc_inc_sel_t;

typedef enum logic [1:0] {
    RD_WR_ALU     = 2'h0,
    RD_WR_DRAM    = 2'h1,
    RD_WR_PC_NEXT = 2'h2
} rd_wr_sel_t;

typedef enum logic [2:0] {
    DRAM_WR_B = 3'b000,
    DRAM_WR_H = 3'b001,
    DRAM_WR_W = 3'b010
} dram_wr_sel_t;

typedef enum logic [2:0] {
    DRAM_RD_B  = 3'b000,
    DRAM_RD_H  = 3'b001,
    DRAM_RD_W  = 3'b010,
    DRAM_RD_BU = 3'b100,
    DRAM_RD_HU = 3'b101
} dram_rd_sel_t;

typedef enum logic [1:0] {
    ALU_A_ZERO = 2'h0,
    ALU_A_RS1  = 2'h1,
    ALU_A_PC   = 2'h2
} alu_a_sel_t;

typedef enum logic [1:0] {
    ALU_B_ZERO = 2'h0,
    ALU_B_RS2  = 2'h1,
    ALU_B_IMM  = 2'h2
} alu_b_sel_t;

typedef enum logic [2:0] {
    ALU_COMP_BEQ  = 3'b000,
    ALU_COMP_BNE  = 3'b001,
    ALU_COMP_BLT  = 3'b100,
    ALU_COMP_BGE  = 3'b101,
    ALU_COMP_BLTU = 3'b110,
    ALU_COMP_BGEU = 3'b111
} alu_comp_sel_t;

typedef enum logic [2:0] {
    ALU_OP_1_ADD  = 3'b000,
    ALU_OP_1_AND  = 3'b111,
    ALU_OP_1_OR   = 3'b110,
    ALU_OP_1_XOR  = 3'b100,
    ALU_OP_1_SLL  = 3'b001,
    ALU_OP_1_SRL  = 3'b101,
    ALU_OP_1_SLT  = 3'b010,
    ALU_OP_1_SLTU = 3'b011
} alu_op_1_sel_t;
