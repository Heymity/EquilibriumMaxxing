module decoder_11 (
    input  wire        clock,
    input  wire        reset,
    input  wire        carrega_frame,
    input  wire [10:0] led_select,
    input  wire [23:0] cor_led,

    output reg [3:0]  led_index,
    output reg [23:0] led0,
    output reg [23:0] led1,
    output reg [23:0] led2,
    output reg [23:0] led3,
    output reg [23:0] led4,
    output reg [23:0] led5,
    output reg [23:0] led6,
    output reg [23:0] led7,
    output reg [23:0] led8,
    output reg [23:0] led9,
    output reg [23:0] led10
);

    integer i;
    reg [23:0] leds_int [0:10];

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 11; i=i+1)
                leds_int[i] <= 24'h000000;
        end
        else if (carrega_frame) begin
            for (i = 0; i < 11; i=i+1)
                leds_int[i] <= led_select[i] ? cor_led : 24'h000000;
        end
    end

    // Saídas
    always @(*) begin
        led_index = 4'd0;
        for (i = 10; i >= 0; i=i-1) begin
            if (leds_int[i] != 24'h000000) begin
                led_index = i[3:0];
            end
        end
        {led0, led1, led2, led3, led4, led5, led6, led7, led8, led9, led10} = {
            leds_int[0],
            leds_int[1],
            leds_int[2],
            leds_int[3],
            leds_int[4],
            leds_int[5],
            leds_int[6],
            leds_int[7],
            leds_int[8],
            leds_int[9],
            leds_int[10]
        };
    end
endmodule
