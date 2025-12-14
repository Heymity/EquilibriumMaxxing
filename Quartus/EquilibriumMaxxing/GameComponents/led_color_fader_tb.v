`timescale 1ns/1ps
module led_color_fader_tb;
    reg clock = 0;
    reg reset;
    reg trigger;
    reg [23:0] cor_in;
    reg [9:0] max_idx;
    wire [23:0] cor_out;

    // instantiate DUT
    led_color_fader UUT (
        .clock(clock),
        .reset(reset),
        .trigger(trigger),
        .cor_in(cor_in),
        .max_idx(max_idx),
        .cor_out(cor_out)
    );

    // clock
    always #5 clock = ~clock;

    reg [23:0] prev_cor;

    initial begin
        $dumpfile("led_color_fader_tb.vcd");
        $dumpvars(0, led_color_fader_tb);

        // initial state
        reset = 1; trigger = 0; cor_in = 24'hFF0000; max_idx = 32'd200; prev_cor = 24'hxxxxxx;
        #20;
        reset = 0;

        // First trigger: red, max_idx=200 (fade length = 100 cycles)
        $display("--- Trigger 1: red, max_idx=200 ---");
        @(posedge clock);
        trigger = 1;
        @(posedge clock);
        trigger = 0;

        // wait until cor_out becomes zero or timeout
        wait_zero_or_timeout(10000);

        // Second trigger: green, shorter max_idx=50 (faster fade)
        cor_in = 24'h00FF00; max_idx = 32'd50;
        $display("--- Trigger 2: green, max_idx=50 ---");
        @(posedge clock);
        trigger = 1;
        @(posedge clock);
        trigger = 0;

        wait_zero_or_timeout(5000);

        $display("Testbench finished");
        $finish;
    end

    // monitor changes on cor_out
    always @(posedge clock) begin
        if (cor_out !== prev_cor) begin
            $display("time=%0t cor_out=%06h R=%0d G=%0d B=%0d", $time, cor_out, cor_out[23:16], cor_out[15:8], cor_out[7:0]);
            prev_cor = cor_out;
        end
    end

    // task: wait until cor_out==0 or timeout cycles
    task wait_zero_or_timeout;
        input integer timeout_cycles;
        integer i;
        begin
            for (i = 0; i < timeout_cycles; i = i + 1) begin
                @(posedge clock);
                if (cor_out == 24'd0) begin
                    $display("cor_out reached zero at time=%0t", $time);
                    disable wait_zero_or_timeout;
                end
            end
            $display("timeout waiting for cor_out==0 (after %0d cycles)", timeout_cycles);
        end
    endtask

endmodule
