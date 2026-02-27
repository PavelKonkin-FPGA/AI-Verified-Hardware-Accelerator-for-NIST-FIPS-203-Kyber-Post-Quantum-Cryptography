module twiddle_rom (
    input  wire        clock,
    input  wire [7:0]  address,
    output wire [11:0] q
);

    twiddle_rom_ip u_rom (
        .address (address),
        .clock   (clock),
        .q       (q)
    );

endmodule