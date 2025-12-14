module decoder_5 (
    input  wire        clock,
    input  wire        reset,
    input  wire        carrega_frame,
    input  wire [4:0]  led_select,
    input  wire [23:0] cor_led,

    output reg [2:0]  led_index,
    output reg [23:0] led0,
    output reg [23:0] led1,
    output reg [23:0] led2,
    output reg [23:0] led3,
    output reg [23:0] led4
);

    integer i;
    reg [23:0] leds_int [0:4];

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 5; i=i+1)
                leds_int[i] <= 24'h000000;
        end
        else if (carrega_frame) begin
            for (i = 0; i < 5; i=i+1)
                leds_int[i] <= led_select[i] ? cor_led : 24'h000000;
        end
    end

    // Saídas
    always @(*) begin
        led_index = 3'd0;
        for (i = 4; i >= 0; i=i-1) begin
            if (leds_int[i] != 24'h000000) begin
                led_index = i[2:0];
            end
        end
        {led0, led1, led2, led3, led4} = {
            leds_int[0],
            leds_int[1],
            leds_int[2],
            leds_int[3],
            leds_int[4]
        };
    end
endmodule