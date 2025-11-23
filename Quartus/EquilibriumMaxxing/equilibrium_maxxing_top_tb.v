`timescale 1ns/1ps

module equilibrium_maxxing_top_tb;

    // Clock
    reg clock = 0;
    always #5 clock = ~clock; // 100 MHz (10 ns period)

    // UC inputs
    reg reset;
    reg start_game;
    reg ponto_evento;
    reg prep_done;
    reg sensorFimCurso;

    // UC outputs (we'll monitor these)
    wire gerar_nova_jogada;
    wire conta_nivel;
    wire reset_nivel;
    wire fade_trigger;
    wire trava_servo;
    wire calib_start;
    wire reset_prep_cnt;
    wire reset_nivel_locked;
    wire [2:0] uc_state;

    // Simulated LED array (11 LEDs). When a new play is generated, one LED will light.
    reg [10:0] leds;
    reg [10:0] prev_leds;
    integer led_counter = 0;
    reg fake_gerar = 1'b0;
    reg prev_gen_play = 1'b0;

    // Level register signals (standalone instance to force level selection)
    reg reset_lr;
    reg start_game_lr;
    reg signed [15:0] alavanca1;
    reg signed [15:0] alavanca2;
    wire [1:0] nivel_reg;

    // Instantiate the control unit (UUT)
    equilibrium_maxxing_uc UC (
        .clock(clock),
        .reset(reset),
        .start_game(start_game),
        .ponto_evento(ponto_evento),
        .prep_done(prep_done),
        .sensorFimCurso(sensorFimCurso),
        .gerar_nova_jogada(gerar_nova_jogada),
        .conta_nivel(conta_nivel),
        .reset_nivel(reset_nivel),
        .fade_trigger(fade_trigger),
        .trava_servo(trava_servo),
        .calib_start(calib_start),
        .reset_prep_cnt(reset_prep_cnt),
        .reset_nivel_locked(reset_nivel_locked),
        .db_estado(uc_state)
    );

    // Instantiate the level selector to show selection behavior
    level_register LR (
        .clock(clock),
        .reset(reset_lr),
        .alavanca1(alavanca1),
        .alavanca2(alavanca2),
        .start_game(start_game_lr),
        .nivel_reg(nivel_reg)
    );

    // Monitor UC state changes and print
    reg [2:0] prev_uc_state = 3'bxxx;
    always @(posedge clock) begin
        if (uc_state !== prev_uc_state) begin
            case (uc_state)
                3'b000: $display("%0t ns: UC state -> Calibra (000)", $time);
                3'b001: $display("%0t ns: UC state -> SelNivel (001)", $time);
                3'b010: $display("%0t ns: UC state -> Prep (010)", $time);
                3'b011: $display("%0t ns: UC state -> genNext (011)", $time);
                3'b100: $display("%0t ns: UC state -> Joga (100)", $time);
                default: $display("%0t ns: UC state -> UNKNOWN (%b)", $time, uc_state);
            endcase
            prev_uc_state <= uc_state;
        end
    end

    // Simulate LEDs: light one LED when `gerar_nova_jogada` or `fake_gerar` rises
    always @(posedge clock) begin
        reg gen_play;
        gen_play = gerar_nova_jogada | fake_gerar;
        if (gen_play && !prev_gen_play) begin
            // choose next LED (round-robin)
            leds = 11'b0;
            leds[led_counter % 11] = 1'b1;
            $display("%0t ns: LED %0d lit (leds vector = %b)", $time, led_counter % 11, leds);
            led_counter = led_counter + 1;
        end
        prev_gen_play <= gen_play;
    end

    // Monitor LED changes and print when any LED turns on/off
    always @(posedge clock) begin
        if (leds !== prev_leds) begin
            $display("%0t ns: leds changed: %b -> %b", $time, prev_leds, leds);
            prev_leds <= leds;
        end
    end

    // Task to select a level using level_register
    task select_level(input [1:0] lvl);
        integer timeout;
        begin
            // Set alavanca sign bits according to level_register mapping
            case (lvl)
                2'd0: begin alavanca1 = 16'h8000; alavanca2 = 16'h8000; end
                2'd1: begin alavanca1 = 16'h8000; alavanca2 = 16'h0000; end
                2'd2: begin alavanca1 = 16'h0000; alavanca2 = 16'h8000; end
                2'd3: begin alavanca1 = 16'h0000; alavanca2 = 16'h0000; end
            endcase

            // Pulse reset_lr briefly to ensure nivel_locked is cleared
            reset_lr = 1'b1;
            @(posedge clock);
            reset_lr = 1'b0;

            // Wait until UC is in SelNivel (with timeout)
            timeout = 0;
            while (uc_state != 3'b001 && timeout < 200) begin
                @(posedge clock);
                timeout = timeout + 1;
            end

            if (uc_state != 3'b001) begin
                $display("%0t ns: Warning - UC did not enter SelNivel before selecting level (timeout)", $time);
            end

            // Pulse start on both UC and LR to lock the level
            start_game = 1'b1;
            start_game_lr = 1'b1;
            @(posedge clock);
            start_game = 1'b0;
            start_game_lr = 1'b0;

            // Allow one cycle for nivel_reg to update
            @(posedge clock);

            // simulate FD prep finishing: pulse prep_done so UC will move to genNext
            prep_done = 1'b1;
            @(posedge clock);
            prep_done = 1'b0;

            // If UC didn't actually generate gerar_nova_jogada (FD absent), pulse fake_gerar
            fake_gerar = 1'b1;
            @(posedge clock);
            fake_gerar = 1'b0;

            $display("%0t ns: Requested select level %0d -> nivel_reg = %0d", $time, lvl, nivel_reg);
        end
    endtask

    initial begin
        // Initial values
        reset = 1'b1;
        start_game = 1'b0;
        ponto_evento = 1'b0;
        prep_done = 1'b0;
        sensorFimCurso = 1'b0;

        // initialize LEDs
        leds = 11'b0;
        prev_leds = 11'b0;
        prev_gen_play = 1'b0;

        reset_lr = 1'b1;
        start_game_lr = 1'b0;
        alavanca1 = 16'h0000;
        alavanca2 = 16'h0000;

        // Hold reset for a few cycles
        repeat (4) @(posedge clock);
        reset = 1'b0;
        reset_lr = 1'b0;

        // Simulate calibration finished so UC can progress to SelNivel
        sensorFimCurso = 1'b1;

        // Wait some cycles for state changes
        repeat (20) @(posedge clock);

        // Select levels 0..3 one by one
        select_level(2'd0);
        repeat (20) @(posedge clock);

        select_level(2'd1);
        repeat (20) @(posedge clock);

        select_level(2'd2);
        repeat (20) @(posedge clock);

        select_level(2'd3);
        repeat (50) @(posedge clock);

        $display("Testbench finished.");
        $finish;
    end

endmodule
