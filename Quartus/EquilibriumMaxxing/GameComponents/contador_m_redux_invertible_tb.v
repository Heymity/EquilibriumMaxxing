`timescale 1ns/1ps

module contador_m_redux_invertible_tb;

    reg clock;
    reg zera_as;
    reg zera_s;
    reg conta;
    reg [3:0] score; // SCORE_N=4 in this TB
    reg       count_up; // 1 = count up, 0 = count down
    wire [6:0] Q;
    wire fim;
    wire inicio;

    // Instantiate: M=64, N=7, SCORE_N=4, MIN_M=8
    contador_m_redux_invertible #(.M(64), .N(7), .SCORE_N(4), .MIN_M(8)) uut (
        .clock(clock),
        .zera_as(zera_as),
        .zera_s(zera_s),
        .conta(conta),
        .score(score),
        .count_up(count_up),
        .Q(Q),
        .fim(fim),
        .inicio(inicio)
    );

    initial begin
        $dumpfile("contador_m_redux_invertible_tb.vcd");
        $dumpvars(0, contador_m_redux_invertible_tb);

        clock = 0;
        zera_as = 1;
        zera_s = 0;
        conta = 0;
        score = 0;
        count_up = 1; // start counting up


        #10; // allow initial reset
        zera_as = 0;

        // Start counting with score = 0, counting up
        conta = 1;
        $display("--- Running: score=0, count_up=1 ---");
        repeat (40) @(posedge clock);

        // Switch to counting down (should wrap properly)
        count_up = 0;
        $display("--- Now count_up=0 (counting down) ---");
        repeat (40) @(posedge clock);

        // Increase score to speed up (count down)
        score = 3;
        $display("--- score=3, count_up=0 ---");
        repeat (40) @(posedge clock);

        // Back to counting up and max score
        count_up = 1;
        score = 15; // max for SCORE_N=4
        $display("--- score=15, count_up=1 (fast) ---");
        repeat (80) @(posedge clock);

        $display("--- Simulation finished ---");
        $finish;
    end

    // 10 ns clock period
    always #5 clock = ~clock;

    // Log when fim/inicio assert
    always @(posedge clock) begin
        if (inicio) $display("%0t: inicio=1, Q=%0d, score=%0d", $time, Q, score);
        if (fim)    $display("%0t: fim=1,    Q=%0d, score=%0d", $time, Q, score);
    end

endmodule
