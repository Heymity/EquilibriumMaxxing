module equilibrium_maxxing_uc (
    input  wire clock,
    input  wire reset,

    input  wire [1:0] nivel_dificuldade,
    input  wire ponto_evento,

    output reg gerar_nova_jogada,
    output reg conta_nivel,
    output reg reset_nivel,
    output reg fade_trigger
);

endmodule
