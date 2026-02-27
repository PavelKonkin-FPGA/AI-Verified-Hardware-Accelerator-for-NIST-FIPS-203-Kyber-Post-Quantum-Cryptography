module ntt_butterfly (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [11:0] u,
    input  wire [11:0] v,
    input  wire [11:0] twiddle,
    output reg  [11:0] res_u,
    output reg  [11:0] res_v
);

    localparam [11:0] Q  = 12'd3329;
    localparam [13:0] MU = 14'd5041; 

    reg [23:0] s1_mul;
    reg [11:0] s1_u;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_mul <= 24'd0; s1_u <= 12'd0;
        end else begin
            s1_mul <= v * twiddle;
            s1_u   <= u;
        end
    end

    reg [37:0] s2_barrett;
    reg [11:0] s2_u;
    reg [23:0] s2_v_tw;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_barrett <= 38'd0; s2_u <= 12'd0; s2_v_tw <= 24'd0;
        end else begin
            s2_barrett <= s1_mul * MU;
            s2_u       <= s1_u;
            s2_v_tw    <= s1_mul;
        end
    end

    reg [11:0] s3_t_red;
    reg [11:0] s3_u;

    wire [13:0] q_approx = s2_barrett[37:24];
    wire [25:0] sub_val  = q_approx * Q;
    wire [25:0] r_init   = s2_v_tw - sub_val;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s3_t_red <= 12'd0; s3_u <= 12'd0;
        end else begin
            s3_t_red <= (r_init >= Q) ? (r_init - Q) : r_init[11:0];
            s3_u     <= s2_u;
        end
    end

    wire [12:0] sum = s3_u + s3_t_red;
    wire [12:0] sub = (s3_u >= s3_t_red) ? (s3_u - s3_t_red) : (s3_u + Q - s3_t_red);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            res_u <= 12'd0; res_v <= 12'd0;
        end else begin
            res_u <= (sum >= Q) ? (sum - Q) : sum[11:0];
            res_v <= (sub >= Q) ? (sub - Q) : sub[11:0];
        end
    end
endmodule