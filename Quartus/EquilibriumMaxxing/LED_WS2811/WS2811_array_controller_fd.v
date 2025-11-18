// WS2811_array_controller_fd.v (modificado)
module WS2811_array_controller_fd (
    input           clock,
    input           reset,

    // Data Inputs
    input   [7:0]   led_count,

    input           use_external_rgb,
    input  [23:0]   external_led0,
    input  [23:0]   external_led1,
    input  [23:0]   external_led2,
    input  [23:0]   external_led3,
    input  [23:0]   external_led4,

    // Control Inputs
    input           send_data,
    input           next_led,
    input           serial_reset,

    // Condition Outputs
    output wire     last_led,
    output wire     serial_reset_done,
    output wire     word_sent,

    // Data Outputs
    output wire     serial,

    // Depuracao
    output wire     db_serial
);

    wire [23:0] rgb_wave;
    wire [23:0] rgb_source;

    WS2811_serial LED_SERIAL_TRANSMITER (
        .clock(clock),
        .reset(reset),
        .rgb_data(rgb_source),
        .send(send_data),
        .serial(serial),
        .word_sent(word_sent),
        .db_serial(db_serial)
    );

    wire [15:0] curr_led;
    contador_m #(.M(1000), .N(16)) LED_COUNTER (
        .clock(clock),
        .zera_as(reset),
        .zera_s(serial_reset),
        .conta(next_led),
        .Q(curr_led),
        .fim(),
        .meio()
    );

    contador_m #(.M(80000), .N(32)) SERIAL_RESET_TIMER (
        .clock(clock),
        .zera_as(reset),
        .zera_s(1'b0),
        .conta(serial_reset),
        .Q(),
        .fim(serial_reset_done),
        .meio()
    );

    // antigo
    WS2811_rgb_wave_provider RGB_PROVIDER (
        .clock(clock),
        .reset(reset),
        .advance(next_led),
        .serial_reset(serial_reset),
        .rgb(rgb_wave)
    );

    // novo
    wire [23:0] rgb_ext;
    assign rgb_ext = (curr_led == 0) ? external_led0 :
                     (curr_led == 1) ? external_led1 :
                     (curr_led == 2) ? external_led2 :
                     (curr_led == 3) ? external_led3 :
                     (curr_led == 4) ? external_led4 :
                     24'h000000;

    // escolher entre antigo e novo
    assign rgb_source = use_external_rgb ? rgb_ext : rgb_wave;

    // last_led condition
    assign last_led = (curr_led >= led_count);

endmodule