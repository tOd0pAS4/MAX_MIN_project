module poly_min_max_v2 #(
    parameter Q = 16,
    parameter WIDTH = 32 
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              start,
    
    input  logic signed [WIDTH-1:0] coeff_a, coeff_b, coeff_c,
    input  logic signed [WIDTH-1:0] start_x,
    input  logic signed [WIDTH-1:0] stop_x,      
    input  logic signed [WIDTH-1:0] step_size,

    output logic signed [WIDTH-1:0] min_y, max_y,
    output logic              done
);

    typedef enum logic [2:0] {IDLE, INIT, CALC_1, CALC_2, CALC_3, COMPARE, FINISH} state_t;
    state_t state;

    logic signed [WIDTH-1:0] curr_x;
    logic signed [63:0]      mult_temp; 
    logic signed [WIDTH-1:0] acc_prev;
    logic signed [WIDTH-1:0] y_val;
    logic signed [WIDTH-1:0] min_y_reg, max_y_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            done       <= 0;
            curr_x     <= 0;
            mult_temp  <= 0;
            acc_prev   <= 0;
            y_val      <= 0;
            min_y      <= 32'sh7FFF_FFFF; 
            max_y      <= 32'sh8000_0000; 
            min_y_reg  <= 32'sh7FFF_FFFF; 
            max_y_reg  <= 32'sh8000_0000; 
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) state <= INIT;
                end

                INIT: begin
                    curr_x    <= start_x;
                    min_y_reg <= 32'sh7FFF_FFFF; 
                    max_y_reg <= 32'sh8000_0000;
                    state     <= CALC_1;
                end

                CALC_1: begin
                    mult_temp <= coeff_a * curr_x;
                    state     <= CALC_2;
                end

                CALC_2: begin
                    acc_prev <= mult_temp[Q +: WIDTH] + coeff_b;
                    state    <= CALC_3;
                end

                CALC_3: begin
                    mult_temp <= acc_prev * curr_x;
                    state     <= COMPARE;
                end

                COMPARE: begin
                    y_val = mult_temp[Q +: WIDTH] + coeff_c;
                    
                    if (y_val < min_y_reg) min_y_reg <= y_val;
                    if (y_val > max_y_reg) max_y_reg <= y_val;

                    if (curr_x >= stop_x) begin
                        state <= FINISH;
                    end else begin
                        curr_x <= curr_x + step_size;
                        state  <= CALC_1;
                    end
                end

                FINISH: begin
                    done  <= 1;
                    min_y <= min_y_reg;
                    max_y <= max_y_reg;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule