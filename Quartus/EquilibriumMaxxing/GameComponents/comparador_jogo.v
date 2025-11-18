module comparador_jogo #(
    parameter TOTAL_RANGE_STEPS16 = 3200  // equivalente a 180° em step/16
)(
    input  wire clock,
    input  wire [2:0] position_led,      // valor 0–4 vindo do random_led_controller
    input  wire signed [15:0] current_position, // posição do pêndulo em step/16
    output reg  isInPosition
);

    // 5 setores → cada um cobre 3200/5 = 640 step/16
    localparam integer SETOR_SIZE = TOTAL_RANGE_STEPS16 / 5;

    // Calcular limites inferior e superior
    reg signed [15:0] limite_inferior;
    reg signed [15:0] limite_superior;

    always @(*) begin
        limite_inferior = position_led * SETOR_SIZE;
        limite_superior = limite_inferior + SETOR_SIZE;
    end

    // Comparação
    always @(*) begin
        if (current_position >= limite_inferior &&
            current_position <  limite_superior)
            isInPosition = 1'b1;
        else
            isInPosition = 1'b0;
    end

endmodule