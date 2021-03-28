/*
 * idu.sv
 *
 *  Created on: 2020-08-02 16:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

module idu #(
    parameter XLEN = 32
) (
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN-1:0] ir_rd_data_i,

    output logic [4:0] rd_wr_addr_o,
    output logic [4:0] rs1_rd_addr_o,
    output logic [4:0] rs2_rd_addr_o,

    output logic [XLEN-1:0] imm_rd_data_o,

    output logic inst_lui_o,
    output logic inst_auipc_o,

    output logic inst_jal_o,
    output logic inst_jalr_o,

    output logic inst_beq_o,
    output logic inst_bne_o,
    output logic inst_blt_o,
    output logic inst_bge_o,
    output logic inst_bltu_o,
    output logic inst_bgeu_o,

    output logic inst_lb_o,
    output logic inst_lh_o,
    output logic inst_lw_o,
    output logic inst_lbu_o,
    output logic inst_lhu_o,
    output logic inst_sb_o,
    output logic inst_sh_o,
    output logic inst_sw_o,

    output logic inst_addi_o,
    output logic inst_slti_o,
    output logic inst_sltiu_o,
    output logic inst_xori_o,
    output logic inst_ori_o,
    output logic inst_andi_o,
    output logic inst_slli_o,
    output logic inst_srli_o,
    output logic inst_srai_o,

    output logic inst_add_o,
    output logic inst_sub_o,
    output logic inst_sll_o,
    output logic inst_slt_o,
    output logic inst_sltu_o,
    output logic inst_xor_o,
    output logic inst_srl_o,
    output logic inst_sra_o,
    output logic inst_or_o,
    output logic inst_and_o,

    output logic inst_fence_o,

    output logic inst_ecall_o,
    output logic inst_ebreak_o
);

localparam [4:0] OPCODE_LOAD      = 5'b00_000;
localparam [4:0] OPCODE_STORE     = 5'b01_000;
localparam [4:0] OPCODE_MADD      = 5'b10_000;
localparam [4:0] OPCODE_BRANCH    = 5'b11_000;

localparam [4:0] OPCODE_LOAD_FP   = 5'b00_001;
localparam [4:0] OPCODE_STORE_FP  = 5'b01_001;
localparam [4:0] OPCODE_MSUB      = 5'b10_001;
localparam [4:0] OPCODE_JALR      = 5'b11_001;

localparam [4:0] OPCODE_NMSUB     = 5'b10_010;

localparam [4:0] OPCODE_MISC_MEM  = 5'b00_011;
localparam [4:0] OPCODE_AMO       = 5'b01_011;
localparam [4:0] OPCODE_NMADD     = 5'b10_011;
localparam [4:0] OPCODE_JAL       = 5'b11_011;

localparam [4:0] OPCODE_OP_IMM    = 5'b00_100;
localparam [4:0] OPCODE_OP        = 5'b01_100;
localparam [4:0] OPCODE_OP_FP     = 5'b10_100;
localparam [4:0] OPCODE_SYSTEM    = 5'b11_100;

localparam [4:0] OPCODE_AUIPC     = 5'b00_101;
localparam [4:0] OPCODE_LUI       = 5'b01_101;

localparam [4:0] OPCODE_OP_IMM_32 = 5'b00_110;
localparam [4:0] OPCODE_OP_32     = 5'b01_110;

wire [4:0] opcode = ir_rd_data_i[6:2];

wire opcode_load     = (opcode == OPCODE_LOAD);
wire opcode_store    = (opcode == OPCODE_STORE);
wire opcode_branch   = (opcode == OPCODE_BRANCH);
wire opcode_jalr     = (opcode == OPCODE_JALR);
wire opcode_misc_mem = (opcode == OPCODE_MISC_MEM);
wire opcode_jal      = (opcode == OPCODE_JAL);
wire opcode_op_imm   = (opcode == OPCODE_OP_IMM);
wire opcode_op       = (opcode == OPCODE_OP);
wire opcode_system   = (opcode == OPCODE_SYSTEM);
wire opcode_auipc    = (opcode == OPCODE_AUIPC);
wire opcode_lui      = (opcode == OPCODE_LUI);

wire [4:0] rd  = ir_rd_data_i[11: 7];
wire [4:0] rs1 = ir_rd_data_i[19:15];
wire [4:0] rs2 = ir_rd_data_i[24:20];

wire [2:0] funct3 = ir_rd_data_i[14:12];
wire [6:0] funct7 = ir_rd_data_i[31:25];

wire [11:0] imm_i = {ir_rd_data_i[31:20]};
wire [11:0] imm_s = {ir_rd_data_i[31:25], ir_rd_data_i[11:7]};
wire [11:0] imm_b = {ir_rd_data_i[31], ir_rd_data_i[7], ir_rd_data_i[30:25], ir_rd_data_i[11:8]};
wire [19:0] imm_u = {ir_rd_data_i[31:12]};
wire [19:0] imm_j = {ir_rd_data_i[31], ir_rd_data_i[19:12], ir_rd_data_i[20], ir_rd_data_i[30:21]};

wire inst_lui    = opcode_lui;
wire inst_auipc  = opcode_auipc;
wire inst_jal    = opcode_jal;
wire inst_jalr   = opcode_jalr;

wire inst_beq    = opcode_branch & (funct3 == 3'b000);
wire inst_bne    = opcode_branch & (funct3 == 3'b001);
wire inst_blt    = opcode_branch & (funct3 == 3'b100);
wire inst_bge    = opcode_branch & (funct3 == 3'b101);
wire inst_bltu   = opcode_branch & (funct3 == 3'b110);
wire inst_bgeu   = opcode_branch & (funct3 == 3'b111);

wire inst_lb     = opcode_load & (funct3 == 3'b000);
wire inst_lh     = opcode_load & (funct3 == 3'b001);
wire inst_lw     = opcode_load & (funct3 == 3'b010);
wire inst_lbu    = opcode_load & (funct3 == 3'b100);
wire inst_lhu    = opcode_load & (funct3 == 3'b101);
wire inst_sb     = opcode_store & (funct3 == 3'b000);
wire inst_sh     = opcode_store & (funct3 == 3'b001);
wire inst_sw     = opcode_store & (funct3 == 3'b010);

wire inst_addi   = opcode_op_imm & (funct3 == 3'b000);
wire inst_slti   = opcode_op_imm & (funct3 == 3'b010);
wire inst_sltiu  = opcode_op_imm & (funct3 == 3'b011);
wire inst_xori   = opcode_op_imm & (funct3 == 3'b100);
wire inst_ori    = opcode_op_imm & (funct3 == 3'b110);
wire inst_andi   = opcode_op_imm & (funct3 == 3'b111);
wire inst_slli   = opcode_op_imm & (funct3 == 3'b001);
wire inst_srli   = opcode_op_imm & (funct3 == 3'b101) &~ ir_rd_data_i[30];
wire inst_srai   = opcode_op_imm & (funct3 == 3'b101) &  ir_rd_data_i[30];
wire inst_add    = opcode_op & (funct3 == 3'b000) &~ ir_rd_data_i[30];
wire inst_sub    = opcode_op & (funct3 == 3'b000) &  ir_rd_data_i[30];
wire inst_sll    = opcode_op & (funct3 == 3'b001);
wire inst_slt    = opcode_op & (funct3 == 3'b010);
wire inst_sltu   = opcode_op & (funct3 == 3'b011);
wire inst_xor    = opcode_op & (funct3 == 3'b100);
wire inst_srl    = opcode_op & (funct3 == 3'b101) &~ ir_rd_data_i[30];
wire inst_sra    = opcode_op & (funct3 == 3'b101) &  ir_rd_data_i[30];
wire inst_or     = opcode_op & (funct3 == 3'b110);
wire inst_and    = opcode_op & (funct3 == 3'b111);

wire inst_fence  = opcode_misc_mem & (funct3 == 3'b000);

wire inst_ecall  = opcode_system &~ ir_rd_data_i[20];
wire inst_ebreak = opcode_system &  ir_rd_data_i[20];

logic [XLEN-1:0] imm;

always_comb begin
    case (opcode)
        OPCODE_LOAD:
            imm = {{20{imm_i[11] &~ funct3[2]}}, imm_i};
        OPCODE_JALR:
            imm = {{20{imm_i[11]}}, imm_i};
        OPCODE_OP_IMM:
            imm = {{20{imm_i[11] &~ (funct3 == 3'b011)}}, imm_i};
        OPCODE_STORE:
            imm = {{20{imm_s[11]}}, imm_s};
        OPCODE_JAL:
            imm = {{11{imm_j[19]}}, imm_j, 1'b0};
        OPCODE_BRANCH:
            imm = {{19{imm_b[11] &~ funct3[1]}}, imm_b, 1'b0};
        OPCODE_AUIPC,
        OPCODE_LUI:
            imm = {imm_u, 12'h000};
        default:
            imm = 32'h0000_0000;
    endcase
end

assign rs1_rd_addr_o = rs1;
assign rs2_rd_addr_o = rs2;

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rd_wr_addr_o <= 5'h00;

        imm_rd_data_o <= {XLEN{1'b0}};

        inst_lui_o    <= 1'b0;
        inst_auipc_o  <= 1'b0;

        inst_jal_o    <= 1'b0;
        inst_jalr_o   <= 1'b0;

        inst_beq_o    <= 1'b0;
        inst_bne_o    <= 1'b0;
        inst_blt_o    <= 1'b0;
        inst_bge_o    <= 1'b0;
        inst_bltu_o   <= 1'b0;
        inst_bgeu_o   <= 1'b0;

        inst_lb_o     <= 1'b0;
        inst_lh_o     <= 1'b0;
        inst_lw_o     <= 1'b0;
        inst_lbu_o    <= 1'b0;
        inst_lhu_o    <= 1'b0;
        inst_sb_o     <= 1'b0;
        inst_sh_o     <= 1'b0;
        inst_sw_o     <= 1'b0;

        inst_addi_o   <= 1'b0;
        inst_slti_o   <= 1'b0;
        inst_sltiu_o  <= 1'b0;
        inst_xori_o   <= 1'b0;
        inst_ori_o    <= 1'b0;
        inst_andi_o   <= 1'b0;
        inst_slli_o   <= 1'b0;
        inst_srli_o   <= 1'b0;
        inst_srai_o   <= 1'b0;

        inst_add_o    <= 1'b0;
        inst_sub_o    <= 1'b0;
        inst_sll_o    <= 1'b0;
        inst_slt_o    <= 1'b0;
        inst_sltu_o   <= 1'b0;
        inst_xor_o    <= 1'b0;
        inst_srl_o    <= 1'b0;
        inst_sra_o    <= 1'b0;
        inst_or_o     <= 1'b0;
        inst_and_o    <= 1'b0;

        inst_fence_o  <= 1'b0;

        inst_ecall_o  <= 1'b0;
        inst_ebreak_o <= 1'b0;
    end else begin
        rd_wr_addr_o <= rd;

        imm_rd_data_o <= imm;

        inst_lui_o    <= inst_lui;
        inst_auipc_o  <= inst_auipc;

        inst_jal_o    <= inst_jal;
        inst_jalr_o   <= inst_jalr;

        inst_beq_o    <= inst_beq;
        inst_bne_o    <= inst_bne;
        inst_blt_o    <= inst_blt;
        inst_bge_o    <= inst_bge;
        inst_bltu_o   <= inst_bltu;
        inst_bgeu_o   <= inst_bgeu;

        inst_lb_o     <= inst_lb;
        inst_lh_o     <= inst_lh;
        inst_lw_o     <= inst_lw;
        inst_lbu_o    <= inst_lbu;
        inst_lhu_o    <= inst_lhu;
        inst_sb_o     <= inst_sb;
        inst_sh_o     <= inst_sh;
        inst_sw_o     <= inst_sw;

        inst_addi_o   <= inst_addi;
        inst_slti_o   <= inst_slti;
        inst_sltiu_o  <= inst_sltiu;
        inst_xori_o   <= inst_xori;
        inst_ori_o    <= inst_ori;
        inst_andi_o   <= inst_andi;
        inst_slli_o   <= inst_slli;
        inst_srli_o   <= inst_srli;
        inst_srai_o   <= inst_srai;

        inst_add_o    <= inst_add;
        inst_sub_o    <= inst_sub;
        inst_sll_o    <= inst_sll;
        inst_slt_o    <= inst_slt;
        inst_sltu_o   <= inst_sltu;
        inst_xor_o    <= inst_xor;
        inst_srl_o    <= inst_srl;
        inst_sra_o    <= inst_sra;
        inst_or_o     <= inst_or;
        inst_and_o    <= inst_and;

        inst_fence_o  <= inst_fence;

        inst_ecall_o  <= inst_ecall;
        inst_ebreak_o <= inst_ebreak;
    end
end

endmodule
