module random_led_controller (
    input  wire clock,
    input  wire reset,
    input  wire gerar_jogada,
    input  wire trigger,
    input  wire external,
    input  wire [9:0] contador_jogo,
    input  wire [9:0] mid_idx,
    input  wire [9:0] max_idx,
    input  wire [1:0] nivel_dificuldade,

    output wire serial,
    output wire db_serial,
    output wire [3:0] position_led,
    output wire [23:0] cor_led_db
);

    assign cor_led_db = cor_led;
    wire carrega_frame;
    wire [23:0] cor_led, cor_led_normal, cor_led_faded, led0, led1, led2, led3, led4, led5, led6, led7, led8, led9, led10;

    led_color_mixxer #(.N(10)) COLOR_MIXX (
        .clock(clock),
        .contador(contador_jogo),
        .mid_idx(mid_idx),
        .max_idx(max_idx),
        .cor_led(cor_led_normal)
    );

    led_color_fader COLOR_FADER (
        .clock(clock),
        .reset(reset),
        .trigger(trigger),
        .cor_in(cor_led_normal),
        .max_idx(max_idx),
        .cor_out(cor_led_faded)
    );

    assign cor_led = nivel_dificuldade == 2'b11 ? cor_led_faded : cor_led_normal;

    random_led_controller_uc UC_RAND (
        .clock(clock),
        .reset(reset),
        .gerar_jogada(gerar_jogada),
        .carrega_frame(carrega_frame)
    );

    random_led_controller_fd FD_RAND (
        .clock(clock),
        .reset(reset),
        .gerar_jogada(gerar_jogada),
        .cor_led(cor_led),
        .carrega_frame(carrega_frame),

        .led_select(position_led),
        .led0(led0),
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4),
        .led5(led5),
        .led6(led6),
        .led7(led7),
        .led8(led8),
        .led9(led9),
        .led10(led10)
    );

    WS2811_array_controller DRIVER (
        .clock(clock),
        .reset(reset),

        .led_count(8'd11),
        .enable(1'b1),             // sempre enviando
        .use_external_rgb(external),   // usa os LEDs gerados

        .external_led0(led0),
        .external_led1(led1),
        .external_led2(led2),
        .external_led3(led3),
        .external_led4(led4),
        .external_led5(led5),
        .external_led6(led6),
        .external_led7(led7),
        .external_led8(led8),
        .external_led9(led9),
        .external_led10(led10),

        .serial(serial),
        .db_serial(db_serial)
    );

endmodule
