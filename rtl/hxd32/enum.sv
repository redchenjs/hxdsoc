/*
 * enum.sv
 *
 *  Created on: 2021-05-20 15:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

package opcode_enum;
    typedef enum logic [4:0] {
        OPCODE_G_LOAD      = 5'b00_000,
        OPCODE_G_LOAD_FP   = 5'b00_001,
        OPCODE_G_MISC_MEM  = 5'b00_011,
        OPCODE_G_OP_IMM    = 5'b00_100,
        OPCODE_G_AUIPC     = 5'b00_101,
        OPCODE_G_OP_IMM_32 = 5'b00_110,

        OPCODE_G_STORE     = 5'b01_000,
        OPCODE_G_STORE_FP  = 5'b01_001,
        OPCODE_G_AMO       = 5'b01_011,
        OPCODE_G_OP        = 5'b01_100,
        OPCODE_G_LUI       = 5'b01_101,
        OPCODE_G_OP_32     = 5'b01_110,

        OPCODE_G_MADD      = 5'b10_000,
        OPCODE_G_MSUB      = 5'b10_001,
        OPCODE_G_NMSUB     = 5'b10_010,
        OPCODE_G_NMADD     = 5'b10_011,
        OPCODE_G_OP_FP     = 5'b10_100,

        OPCODE_G_BRANCH    = 5'b11_000,
        OPCODE_G_JALR      = 5'b11_001,
        OPCODE_G_JAL       = 5'b11_011,
        OPCODE_G_SYSTEM    = 5'b11_100
    } opcode_g_t;

    typedef enum logic [4:0] {
        OPCODE_C_ADDI4SPN     = 5'b00_000,
        OPCODE_C_FLD          = 5'b00_001,
        OPCODE_C_LW           = 5'b00_010,
        OPCODE_C_FLW          = 5'b00_011,
        OPCODE_C_FSD          = 5'b00_101,
        OPCODE_C_SW           = 5'b00_110,
        OPCODE_C_FSW          = 5'b00_111,

        OPCODE_C_ADDI         = 5'b01_000,
        OPCODE_C_JAL          = 5'b01_001,
        OPCODE_C_LI           = 5'b01_010,
        OPCODE_C_LUI_ADDI16SP = 5'b01_011,
        OPCODE_C_MISC_ALU     = 5'b01_100,
        OPCODE_C_J            = 5'b01_101,
        OPCODE_C_BEQZ         = 5'b01_110,
        OPCODE_C_BNEZ         = 5'b01_111,

        OPCODE_C_SLLI         = 5'b10_000,
        OPCODE_C_FLDSP        = 5'b10_001,
        OPCODE_C_LWSP         = 5'b10_010,
        OPCODE_C_FLWSP        = 5'b10_011,
        OPCODE_C_JR_MV_ADD    = 5'b10_100,
        OPCODE_C_FSDSP        = 5'b10_101,
        OPCODE_C_SWSP         = 5'b10_110,
        OPCODE_C_FSWSP        = 5'b10_111
    } opcode_c_t;

    typedef enum logic [1:0] {
        OPCODE_C_EXT0_JR   = 2'b00,
        OPCODE_C_EXT0_MV   = 2'b01,
        OPCODE_C_EXT0_JALR = 2'b10,
        OPCODE_C_EXT0_ADD  = 2'b11
    } opcode_c_ext0_t;

    typedef enum logic {
        OPCODE_C_EXT1_LUI      = 1'b0,
        OPCODE_C_EXT1_ADDI16SP = 1'b1
    } opcode_c_ext1_t;

    typedef enum logic [1:0] {
        OPCODE_C_ALU_SRLI = 2'b00,
        OPCODE_C_ALU_SRAI = 2'b01,
        OPCODE_C_ALU_ANDI = 2'b10,
        OPCODE_C_ALU_MISC = 2'b11
    } opcode_c_alu_t;

    typedef enum logic [1:0] {
        OPCODE_C_ALU_EXT_SUB = 2'b00,
        OPCODE_C_ALU_EXT_XOR = 2'b01,
        OPCODE_C_ALU_EXT_OR  = 2'b10,
        OPCODE_C_ALU_EXT_AND = 2'b11
    } opcode_c_alu_ext_t;
endpackage

package pc_op_enum;
    typedef enum logic [1:0] {
        PC_WR_NEXT = 2'b00,
        PC_WR_JALR = 2'b01,
        PC_WR_ALU  = 2'b10
    } pc_wr_sel_t;

    typedef enum logic [1:0] {
        PC_INC_4  = 2'b00,
        PC_INC_2  = 2'b01,
        PC_INC_4P = 2'b10,
        PC_INC_2P = 2'b11
    } pc_inc_sel_t;
endpackage

package reg_op_enum;
    typedef enum logic [1:0] {
        RD_WR_ALU      = 2'b00,
        RD_WR_DRAM     = 2'b01,
        RD_WR_PC_INC_4 = 2'b10,
        RD_WR_PC_INC_2 = 2'b11
    } rd_wr_sel_t;
endpackage

package ram_op_enum;
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
endpackage

package alu_op_enum;
    typedef enum logic [1:0] {
        ALU_A_ZERO = 2'b00,
        ALU_A_RS1  = 2'b01,
        ALU_A_PC   = 2'b10
    } alu_a_sel_t;

    typedef enum logic [1:0] {
        ALU_B_ZERO = 2'b00,
        ALU_B_RS2  = 2'b01,
        ALU_B_IMM  = 2'b10
    } alu_b_sel_t;

    typedef enum logic [2:0] {
        ALU_COMP_BEQ  = 3'b000,
        ALU_COMP_BNE  = 3'b001,
        ALU_COMP_BLT  = 3'b100,
        ALU_COMP_BGE  = 3'b101,
        ALU_COMP_BLTU = 3'b110,
        ALU_COMP_BGEU = 3'b111
    } alu_comp_sel_t;

    typedef enum logic {
        ALU_OP_0_ADD_SRL = 1'b0,
        ALU_OP_0_SUB_SRA = 1'b1
    } alu_op_0_sel_t;

    typedef enum logic [2:0] {
        ALU_OP_1_ADD  = 3'b000,
        ALU_OP_1_SLL  = 3'b001,
        ALU_OP_1_SLT  = 3'b010,
        ALU_OP_1_SLTU = 3'b011,
        ALU_OP_1_XOR  = 3'b100,
        ALU_OP_1_SRL  = 3'b101,
        ALU_OP_1_OR   = 3'b110,
        ALU_OP_1_AND  = 3'b111
    } alu_op_1_sel_t;
endpackage
