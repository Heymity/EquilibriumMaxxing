module jogo_controller (
    input  wire clock,
    input  wire reset,

    input  wire [3:0] position_led,
    input  signed [15:0] current_position,

    input  wire [1:0] nivel_dificuldade,

    // sinais de controle dos contadores
    input  wire conta_nivel,

    input  wire reset_ponto,
    input  wire reset_nivel,

    output wire ganhou_ponto,
    output wire perdeu_ponto,
    output wire [7:0] pontuacao,

    output wire [9:0] M_eff,
    output wire [9:0] mid_idx,
    output wire [9:0] max_idx,

    output wire [9:0] contador_jogo
);

    wire isInPosition;
    wire [7:0] pontuacao_interna;

    comparador_jogo CJ (
        .clock(clock),
        .position_led(position_led),
        .current_position(current_position),
        
        .isInPosition(isInPosition)
    );

    contador_m_updown_limitado #(
        .M(1000),
        .N(8)
    ) contador_pontos (
        .clock(clock),
        .zera_as(reset),
        .zera_s(reset_ponto),
        .inc(ganhou_ponto),
        .dec(perdeu_ponto),
        .Q(pontuacao_interna)
    );

    wire [9:0] contador_jogo_lvl0;
    wire ganhou_ponto_lvl0;

    contador_m_half #(
        .M(1000),
        .N(10)
    ) contador_jogo_nivel_0 (
        .clock(clock),
        .zera_as(reset),
        .zera_s(reset_nivel),
        .conta(conta_nivel),
        .Q(contador_jogo_lvl0),
        .fim(ganhou_ponto_lvl0),
        .meio()
    );

    wire [9:0] contador_jogo_lvl1;
    wire ganhou_ponto_lvl1;
    wire perdeu_ponto_lvl1;

    contador_m_invertible #(
        .M(1000),
        .N(10)
    ) contador_jogo_nivel_1 (
        .clock(clock),
        .zera_as(reset),
        .zera_s(reset_nivel),
        .conta(conta_nivel),
        .count_up(isInPosition),
        .Q(contador_jogo_lvl1),
        .fim(ganhou_ponto_lvl1),
        .inicio(perdeu_ponto_lvl1)
    );

    wire [9:0] contador_jogo_lvl23;
    wire ganhou_ponto_lvl23;
    wire perdeu_ponto_lvl23;
    wire [9:0] M_eff_nivel23;
    wire [9:0] mid_idx_nivel23;
    wire [9:0] max_idx_nivel23;

    contador_m_redux_invertible #(
        .M(1000),
        .N(10),
        .SCORE_N(8),
        .MIN_M(300)
    ) contador_jogo_nivel_2_3 (
        .clock(clock),
        .zera_as(reset),
        .zera_s(reset_nivel),
        .conta(conta_nivel),
        .score(pontuacao_interna),
        .count_up(isInPosition),
        .Q(contador_jogo_lvl23),
        .fim(ganhou_ponto_lvl23),
        .inicio(perdeu_ponto_lvl23),
        .M_eff_out(M_eff_nivel23),
        .mid_idx_out(mid_idx_nivel23),
        .max_idx_out(max_idx_nivel23)
    );

    assign M_eff =
        (nivel_dificuldade == 2'b00) ? 10'd1000 :
        (nivel_dificuldade == 2'b01) ? 10'd1000 :
                                       M_eff_nivel23;

    assign mid_idx =
        (nivel_dificuldade == 2'b00) ? 10'd500 :
        (nivel_dificuldade == 2'b01) ? 10'd500 :
                                       mid_idx_nivel23;

    assign max_idx =
        (nivel_dificuldade == 2'b00) ? 10'd999 :
        (nivel_dificuldade == 2'b01) ? 10'd999 :
                                       max_idx_nivel23;

    assign contador_jogo =
        (nivel_dificuldade == 2'b00) ? contador_jogo_lvl0 :
        (nivel_dificuldade == 2'b01) ? contador_jogo_lvl1 :
                                       contador_jogo_lvl23;

    assign ganhou_ponto =
        (nivel_dificuldade == 2'b00) ? ganhou_ponto_lvl0 :
        (nivel_dificuldade == 2'b01) ? ganhou_ponto_lvl1 :
                                       ganhou_ponto_lvl23;

    assign perdeu_ponto =
        (nivel_dificuldade == 2'b00) ? 1'b0 :
        (nivel_dificuldade == 2'b01) ? perdeu_ponto_lvl1 :
                                       perdeu_ponto_lvl23;

    assign pontuacao = pontuacao_interna;

endmodule
