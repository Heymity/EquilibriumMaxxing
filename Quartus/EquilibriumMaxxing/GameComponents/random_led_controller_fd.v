module random_led_controller_fd (
    input  wire        clock,
    input  wire        reset,
    input  wire        gerar_jogada,    // pulso para gerar novo frame
    input  wire [23:0] cor_led,         // cor usada para o LED diferente

    // controle da UC
    input  wire        carrega_frame,

    output wire  [3:0] led_select,
    output wire  [23:0] led0,
    output wire  [23:0] led1,
    output wire  [23:0] led2,
    output wire  [23:0] led3,
    output wire  [23:0] led4,
    output wire  [23:0] led5,
    output wire  [23:0] led6,
    output wire  [23:0] led7,
    output wire  [23:0] led8,
    output wire  [23:0] led9,
    output wire  [23:0] led10
);

    wire [3:0] led_index_internal;
    wire [3:0] contador_q;
    contador_m #(.M(11), .N(4)) CONT (
        .clock(clock),
        .zera_as(reset),
        .zera_s(1'b0),
        .conta(1'b1),
        .Q(contador_q)
    );


    wire [10:0] led_select_onehot;
    random_number RNG (
        .gerar(gerar_jogada),
        .seed(contador_q),
        .numero(led_select_onehot)
    );

    wire [23:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10;
    decoder_11 DEC (
        .clock(clock),
        .reset(reset),
        .carrega_frame(carrega_frame),
        .led_select(led_select_onehot),
        .cor_led(cor_led),
        .led_index(led_index_internal),
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

    assign led_select = led_index_internal;

endmodule