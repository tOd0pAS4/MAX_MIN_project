`timescale 1ns / 1ps

module tb_poly_min_max_v2;

    parameter Q = 16;
    parameter WIDTH = 32;

    logic              clk;
    logic              rst_n;
    logic              start;
    logic signed [WIDTH-1:0] coeff_a, coeff_b, coeff_c;
    logic signed [WIDTH-1:0] start_x;
    logic signed [WIDTH-1:0] stop_x;    
    logic signed [WIDTH-1:0] step_size;

    logic signed [WIDTH-1:0] min_y;
    logic signed [WIDTH-1:0] max_y;
    logic              done;

    // Instancja testowanego modułu (DUT)
    poly_min_max_v2 #(
        .Q(Q),
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .start_x(start_x),
        .stop_x(stop_x),       
        .step_size(step_size),
        .min_y(min_y),
        .max_y(max_y),
        .done(done)
    );

    always #5 clk = (clk === 1'b0) ? 1'b1 : 1'b0;

    function integer float_to_fixed;
        input real val;
        begin
            float_to_fixed = integer'(val * 2**Q); 
        end
    endfunction

    function real fixed_to_float;
        input integer val;
        begin
            fixed_to_float = real'(val) / 2**Q;
        end
    endfunction

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        coeff_a = 0; coeff_b = 0; coeff_c = 0;
        start_x = 0; stop_x = 0; step_size = 0;

        $display("--------------------------------------------------");
        $display("Rozpoczecie symulacji (Format Q%0d.%0d)...", WIDTH-Q, Q);
        
        #20;
        rst_n = 1;
        #20;

        coeff_a   = float_to_fixed(2.0);
        coeff_b   = float_to_fixed(-3.0);
        coeff_c   = float_to_fixed(-12.0);
        
        start_x   = float_to_fixed(-3.0);
        stop_x    = float_to_fixed(4.0);
        step_size = float_to_fixed(0.1); 

        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        $display("Wyslano sygnal start (stop_x = %f). Czekam na done...", fixed_to_float(stop_x));

        wait(done == 1'b1);
        
        repeat(2) @(posedge clk); 

        $display("--------------------------------------------------");
        $display("WYNIKI OSTATECZNE:");
        $display("Minimum y  = %f (RAW: %d)", fixed_to_float(min_y), min_y);
        $display("Maksimum y = %f (RAW: %d)", fixed_to_float(max_y), max_y);
        $display("--------------------------------------------------");

        #100;
        $finish;
    end

endmodule