module crypto_sign (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        cmd_start,
    output wire        status_ready,
    input  wire [7:0]  ext_addr,
    input  wire [11:0] ext_data_in,
    input  wire        ext_we,
    output wire [11:0] ext_data_out
);

    wire [11:0] bfly_u, bfly_v, bfly_tw;
    wire [11:0] bfly_res_u, bfly_res_v;
    wire [7:0]  addr_a, addr_b;
    wire        ctrl_mem_we;

    ntt_ctrl u_ntt_ctrl (
        .clk    (clk),
        .rst_n  (rst_n),
        .start  (cmd_start),
        .ready  (status_ready),
        .addr_a (addr_a),
        .addr_b (addr_b),
        .mem_we (ctrl_mem_we)
    );

    ntt_butterfly u_ntt_bfly (
        .clk     (clk),
        .rst_n   (rst_n),
        .u       (bfly_u),
        .v       (bfly_v),
        .twiddle (bfly_tw),
        .res_u   (bfly_res_u),
        .res_v   (bfly_res_v)
    );

    mem_array_256 u_coeffs_mem (
        .clock     (clk),
        .address_a (status_ready ? ext_addr    : addr_a),
        .data_a    (status_ready ? ext_data_in : bfly_res_u),
        .wren_a    (status_ready ? ext_we      : ctrl_mem_we),
        .q_a       (bfly_u),
        .address_b (status_ready ? 8'h00       : addr_b),
        .data_b    (bfly_res_v),
        .wren_b    (status_ready ? 1'b0        : ctrl_mem_we),
        .q_b       (bfly_v)
    );

    twiddle_rom u_twiddle_rom (
        .clock   (clk),
        .address (addr_b),
        .q       (bfly_tw)
    );

    assign ext_data_out = bfly_u;

endmodule