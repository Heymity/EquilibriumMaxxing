module random_led_controller_fd (
    input  wire        clock,
    input  wire        reset,
    input  wire        gerar_jogada,    // pulso para gerar novo frame
    input  wire [23:0] cor_led,         // cor usada para o LED diferente

    // controle da UC
    input  wire        carrega_frame,

    output wire  [2:0] led_select,
    output wire  [23:0] led0,
    output wire  [23:0] led1,
    output wire  [23:0] led2,
    output wire  [23:0] led3,
    output wire  [23:0] led4
);

    wire [2:0] led_index_internal;
    wire [2:0] contador_q;
    contador_m #(.M(5), .N(3)) CONT (
        .clock(clock),
        .zera_as(reset),
        .zera_s(1'b0),
        .conta(1'b1),
        .Q(contador_q)
    );


    wire [4:0] led_select_onehot;
    random_number RNG (
        .gerar(gerar_jogada),
        .seed(contador_q),
        .numero(led_select_onehot)
    );

    wire [23:0] d0, d1, d2, d3, d4;
    decoder_5 DEC (
        .clock(clock),
        .reset(reset),
        .carrega_frame(carrega_frame),
        .led_select(led_select_onehot),
        .cor_led(cor_led),
        .led_index(led_index),
        .led0(led0),
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4)
    );

    assign led_select = led_index_internal;

endmodule