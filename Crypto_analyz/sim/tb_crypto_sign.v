`timescale 1ns/1ps

module tb_crypto_sign;
    reg         clk;
    reg         rst_n;
    reg         cmd_start;
    wire        status_ready;
    reg  [7:0]  ext_addr;
    reg  [11:0] ext_data_in;
    reg         ext_we;
    wire [11:0] ext_data_out;

    crypto_sign dut (
        .clk(clk),
        .rst_n(rst_n),
        .cmd_start(cmd_start),
        .status_ready(status_ready),
        .ext_addr(ext_addr),
        .ext_data_in(ext_data_in),
        .ext_we(ext_we),
        .ext_data_out(ext_data_out)
    );

    always #10 clk = ~clk;
    
    integer i;
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, tb_crypto_sign);

        clk = 0; rst_n = 0; cmd_start = 0; ext_we = 0;
        #50 rst_n = 1;
        #20;

        $display("--- STEP 1: Loading 256 elements into RAM ---");
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            ext_addr = i[7:0]; 
            ext_data_in = i[11:0];
            ext_we = 1;
        end
        @(posedge clk);
        ext_we = 0;

        #40;
        $display("--- STEP 2: NTT Pipeline Start ---");
        cmd_start = 1;
        @(posedge clk);
        cmd_start = 0;

        wait(status_ready == 1);
        #100;

        $display("--- STEP 3: Verifying Results ---");
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            ext_addr = i[7:0];
            #5;
            $display("RAM[%d] = %d (0x%h)", i, ext_data_out, ext_data_out);
        end

        $finish;
    end
endmodule