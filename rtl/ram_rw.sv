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

    input logic cpu_fault_i,

    input logic [7:0] uart_rx_data_i,
    input logic       uart_rx_data_vld_i,
    input logic       uart_tx_data_rdy_i,

    input logic [XLEN-1:0] iram_rd_data_i,
    input logic [XLEN-1:0] dram_rd_data_i,

    output logic cpu_rst_n_o,

    output logic [7:0] uart_tx_data_o,
    output logic       uart_tx_data_vld_o,
    output logic       uart_rx_data_rdy_o,

    inout wire [XLEN-1:0] iram_rd_addr_io,
    inout wire [XLEN-1:0] iram_wr_addr_io,
    inout wire [XLEN-1:0] iram_wr_data_io,
    inout wire      [3:0] iram_wr_byte_en_io,

    inout wire [XLEN-1:0] dram_rd_addr_io,
    inout wire [XLEN-1:0] dram_wr_addr_io,
    inout wire [XLEN-1:0] dram_wr_data_io,
    inout wire      [3:0] dram_wr_byte_en_io
);

typedef enum logic [7:0] {
    CPU_RST = 8'h2a,
    CPU_RUN = 8'h2b,
    CONF_WR = 8'h2c,
    CONF_RD = 8'h2d,
    DATA_WR = 8'h2e,
    DATA_RD = 8'h2f
} cmd_en_t;

logic cpu_rst_n;
logic cpu_fault;

logic cfg_rd_en;
logic cfg_wr_en;

logic ram_rd_en;
logic ram_wr_en;

logic rx_data_vld;
logic rx_data_rdy;

logic [7:0] tx_data;
logic       tx_data_vld;
logic       tx_data_rdy;

logic            cmd_en;
logic [XLEN-1:0] cmd_cnt;

logic [XLEN-1:0] ram_rw_addr;
logic [XLEN-1:0] ram_rw_size;

logic [XLEN-1:0] ram_rd_cnt;
logic [XLEN-1:0] ram_rd_addr;

logic [XLEN-1:0] ram_wr_cnt;
logic [XLEN-1:0] ram_wr_addr;

assign cpu_rst_n_o = cpu_rst_n;

assign uart_tx_data_o     = tx_data;
assign uart_tx_data_vld_o = tx_data_vld;
assign uart_rx_data_rdy_o = rx_data_rdy;

assign iram_rd_addr_io    = ~cpu_rst_n ? ram_rd_addr : {XLEN{1'bz}};
assign iram_wr_addr_io    = ~cpu_rst_n ? ram_wr_addr : {XLEN{1'bz}};
assign iram_wr_data_io    = ~cpu_rst_n ? uart_rx_data_i : {XLEN{1'bz}};
assign iram_wr_byte_en_io = ~cpu_rst_n ? ram_wr_en & rx_data_vld & ~cmd_en : {4{1'bz}};

assign dram_rd_addr_io    = ~cpu_rst_n ? ram_rd_addr : {XLEN{1'bz}};
assign dram_wr_addr_io    = ~cpu_rst_n ? ram_wr_addr : {XLEN{1'bz}};
assign dram_wr_data_io    = ~cpu_rst_n ? uart_rx_data_i : {XLEN{1'bz}};
assign dram_wr_byte_en_io = ~cpu_rst_n ? ram_wr_en & rx_data_vld & ~cmd_en : {4{1'bz}};

edge2en rx_data_vld_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(uart_rx_data_vld_i),
    .pos_edge_o(rx_data_vld)
);

edge2en cpu_fault_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(cpu_fault_i),
    .pos_edge_o(cpu_fault)
);

edge2en tx_data_rdy_en(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i((cfg_rd_en | ram_rd_en | cpu_fault) & uart_tx_data_rdy_i),
    .pos_edge_o(tx_data_rdy)
);

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        rx_data_rdy <= 1'b0;
    end else begin
        rx_data_rdy <= rx_data_vld ? 1'b1 : (~uart_rx_data_vld_i ? 1'b0 : rx_data_rdy);
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        tx_data     <= 8'h00;
        tx_data_vld <= 1'b0;

        ram_rd_cnt  <= {XLEN{1'b0}};
        ram_rd_addr <= {XLEN{1'b0}};
    end else begin
        if (tx_data_rdy) begin
            if (cfg_rd_en) begin
                case (ram_rd_cnt[2:0])
                    3'h0:
                        tx_data <= ram_rw_addr[7:0];
                    3'h1:
                        tx_data <= ram_rw_addr[15:8];
                    3'h2:
                        tx_data <= ram_rw_addr[23:16];
                    3'h3:
                        tx_data <= ram_rw_addr[31:24];
                    3'h4:
                        tx_data <= ram_rw_size[7:0];
                    3'h5:
                        tx_data <= ram_rw_size[15:8];
                    3'h6:
                        tx_data <= ram_rw_size[23:16];
                    3'h7:
                        tx_data <= ram_rw_size[31:24];
                endcase
            end else if (ram_rd_en) begin
                tx_data <= (ram_rd_addr[31:24] == 8'h00) ? iram_rd_data_i : dram_rd_data_i;
            end else begin
                tx_data <= 8'hef;
            end

            ram_rd_cnt <= (ram_rd_cnt == cmd_cnt) ? {XLEN{1'b0}} : ram_rd_cnt + 1'b1;

            tx_data_vld <= 1'b1;
        end else begin
            tx_data_vld <= uart_tx_data_rdy_i ? 1'b0 : tx_data_vld;
        end

        ram_rd_addr <= ram_rw_addr + ram_rd_cnt;
    end
end

always_ff @(posedge clk_i or negedge rst_n_i)
begin
    if (!rst_n_i) begin
        cmd_en  <= 1'b1;
        cmd_cnt <= {XLEN{1'b0}};

        cpu_rst_n <= 1'b0;

        cfg_wr_en <= 1'b0;
        cfg_rd_en <= 1'b0;

        ram_wr_en <= 1'b0;
        ram_rd_en <= 1'b0;

        ram_rw_addr <= {XLEN{1'b0}};
        ram_rw_size <= {XLEN{1'b0}};

        ram_wr_cnt  <= {XLEN{1'b0}};
        ram_wr_addr <= {XLEN{1'b0}};
    end else begin
        if (rx_data_vld) begin
            if (cmd_en) begin  // Command
                case (uart_rx_data_i)
                    CPU_RST: begin
                        cmd_en <= 1'b1;

                        cpu_rst_n <= 1'b0;

                        cfg_wr_en <= 1'b0;
                        cfg_rd_en <= 1'b0;

                        ram_wr_en <= 1'b0;
                        ram_rd_en <= 1'b0;
                    end
                    CPU_RUN: begin
                        cmd_en <= 1'b1;

                        cpu_rst_n <= 1'b1;

                        cfg_wr_en <= 1'b0;
                        cfg_rd_en <= 1'b0;

                        ram_wr_en <= 1'b0;
                        ram_rd_en <= 1'b0;
                    end
                    CONF_WR: begin
                        cmd_en <= 1'b0;

                        cpu_rst_n <= 1'b0;

                        cfg_wr_en <= 1'b1;
                        cfg_rd_en <= 1'b0;

                        ram_wr_en <= 1'b0;
                        ram_rd_en <= 1'b0;
                    end
                    CONF_RD: begin
                        cmd_en <= 1'b0;

                        cpu_rst_n <= 1'b0;

                        cfg_wr_en <= 1'b0;
                        cfg_rd_en <= 1'b1;

                        ram_wr_en <= 1'b0;
                        ram_rd_en <= 1'b0;
                    end
                    DATA_WR: begin
                        cmd_en <= 1'b0;

                        cpu_rst_n <= 1'b0;

                        cfg_wr_en <= 1'b0;
                        cfg_rd_en <= 1'b0;

                        ram_wr_en <= 1'b1;
                        ram_rd_en <= 1'b0;
                    end
                    DATA_RD: begin
                        cmd_en <= 1'b0;

                        cpu_rst_n <= 1'b0;

                        cfg_wr_en <= 1'b0;
                        cfg_rd_en <= 1'b0;

                        ram_wr_en <= 1'b0;
                        ram_rd_en <= 1'b1;
                    end
                endcase

                ram_wr_cnt  <= {XLEN{1'b0}};
                ram_wr_addr <= ram_rw_addr;
            end else begin    // Data
                cmd_en <= (ram_wr_cnt == cmd_cnt) ? 1'b1 : cmd_en;

                cfg_wr_en <= (ram_wr_cnt == cmd_cnt) ? 1'b0 : cfg_wr_en;
                ram_wr_en <= (ram_wr_cnt == cmd_cnt) ? 1'b0 : ram_wr_en;

                if (cfg_wr_en) begin
                    case (ram_wr_cnt[2:0])
                        3'h0:
                            ram_rw_addr[7:0] <= uart_rx_data_i;
                        3'h1:
                            ram_rw_addr[15:8] <= uart_rx_data_i;
                        3'h2:
                            ram_rw_addr[23:16] <= uart_rx_data_i;
                        3'h3:
                            ram_rw_addr[31:24] <= uart_rx_data_i;
                        3'h4:
                            ram_rw_size[7:0] <= uart_rx_data_i;
                        3'h5:
                            ram_rw_size[15:8] <= uart_rx_data_i;
                        3'h6:
                            ram_rw_size[23:16] <= uart_rx_data_i;
                        3'h7:
                            ram_rw_size[31:24] <= uart_rx_data_i;
                    endcase
                end

                ram_wr_cnt <= (ram_wr_cnt == cmd_cnt) ? {XLEN{1'b0}} : ram_wr_cnt + $unsigned(cfg_wr_en | ram_wr_en);
            end
        end else begin
            cmd_en  <= (ram_rd_cnt == cmd_cnt) & tx_data_rdy ? 1'b1 : cmd_en;
            cmd_cnt <= (cfg_wr_en | cfg_rd_en) ? 3'h7 : (cpu_fault_i ? {XLEN{1'b0}} : ram_rw_size);

            cfg_rd_en <= (ram_rd_cnt == cmd_cnt) & tx_data_rdy ? 1'b0 : cfg_rd_en;
            ram_rd_en <= (ram_rd_cnt == cmd_cnt) & tx_data_rdy ? 1'b0 : ram_rd_en;

            ram_wr_addr <= ram_rw_addr + ram_wr_cnt;
        end
    end
end

endmodule
