module ntt_ctrl (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    output reg         ready,
    output wire [7:0]  addr_a,
    output wire [7:0]  addr_b,
    output wire        mem_we
);

    reg [3:0] stage;
    reg [7:0] j_counter;
    reg [1:0] state;

    reg [3:0] we_pipe;
    reg [7:0] addr_a_delayed [0:3];
    reg [7:0] addr_b_delayed [0:3];

    localparam IDLE = 2'b00, COMP = 2'b01, DONE = 2'b10;

    wire [7:0] step = (8'd1 << stage);
    
    assign addr_a = (state == COMP) ? j_counter : addr_a_delayed[3];
    assign addr_b = (state == COMP) ? (j_counter + step) : addr_b_delayed[3];
    assign mem_we = we_pipe[3];

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; ready <= 1'b1; stage <= 0; j_counter <= 0;
            we_pipe <= 0;
            for (i=0; i<4; i=i+1) begin addr_a_delayed[i] <= 0; addr_b_delayed[i] <= 0; end
        end else begin
            addr_a_delayed[0] <= j_counter;
            addr_b_delayed[0] <= j_counter + step;
            for (i=1; i<4; i=i+1) begin
                addr_a_delayed[i] <= addr_a_delayed[i-1];
                addr_b_delayed[i] <= addr_b_delayed[i-1];
            end

            case (state)
                IDLE: begin
                    if (start) begin state <= COMP; ready <= 0; stage <= 0; j_counter <= 0; end
                    we_pipe <= 0;
                end
                COMP: begin
                    we_pipe <= {we_pipe[2:0], 1'b1};
                    if (j_counter >= (255 - step)) begin
                        if (stage == 7) state <= DONE;
                        else begin stage <= stage + 1; j_counter <= 0; end
                    end else j_counter <= j_counter + 1;
                end
                DONE: begin
                    we_pipe <= {we_pipe[2:0], 1'b0};
                    if (we_pipe == 0) begin ready <= 1; state <= IDLE; end
                end
            endcase
        end
    end
endmodule