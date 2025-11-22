module equilibrium_maxxing_uc (
    input  wire        clock,
    input  wire        reset,

    // Entradas de controle
    input  wire        start_game,
    input  wire        ponto_evento,
    input  wire        prep_done,
    input  wire        sensorFimCurso,

    // Saídas de controle
    output reg         gerar_nova_jogada,
    output reg         conta_nivel,
    output reg         reset_nivel,
    output reg         fade_trigger,
    output reg         trava_servo,
    output reg         calib_start,
    output reg         reset_prep_cnt,
    output reg         reset_nivel_locked,

    // Depuração
    output wire [2:0]  db_estado
);

    localparam Calibra  = 3'b000;
    localparam SelNivel = 3'b001;
    localparam Prep     = 3'b010;
    localparam genNext  = 3'b011;
    localparam Joga     = 3'b100;

    reg [2:0] Eatual, Eprox;
    reg [2:0] prev_E;

    assign db_estado = Eatual;

    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= Calibra;
        else
            Eatual <= Eprox;
    end

    // guarda estado anterior para detectar transições
    always @(posedge clock or posedge reset) begin
        if (reset)
            prev_E <= Calibra;
        else
            prev_E <= Eatual;
    end

    // Lógica de transição
    always @(*) begin
        case (Eatual)

            Calibra:
                // Aguarda módulo de calibração sinalizar "feito"
                Eprox = sensorFimCurso ? SelNivel : Calibra;

            SelNivel:
                // Aguarda seleção de nível
                Eprox = start_game ? Prep : SelNivel;

            Prep:
                // Prepara para próxima jogada
                Eprox = prep_done ? genNext : Prep;

            genNext:
                // Gera nova jogada                
                Eprox = Joga;

            Joga:
                // ciclo de jogada
                Eprox = ponto_evento ? Prep : Joga;

            default:
                Eprox = Calibra;
        endcase
    end

    // Lógica de saída
    always @(*) begin
        gerar_nova_jogada  <= Eatual == genNext;
        conta_nivel   <= Eatual == Joga;
        reset_nivel   <= Eatual == Calibra || Eatual == SelNivel;
        fade_trigger  <= (Eatual == Joga) && (prev_E != Joga);
        trava_servo   <= Eatual == SelNivel;
        calib_start   <= Eatual == Calibra;
        reset_prep_cnt <= Eatual == ~Prep;
        reset_nivel_locked <= (Eatual == SelNivel);
    end

endmodule
