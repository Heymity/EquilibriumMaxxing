`timescale 1ns/1ps

module random_led_controller_tb;

    reg clock = 0;
    reg reset = 1;
    reg gerar_jogada = 0;

    wire serial;
    wire db_serial;

    // Parâmetros do teste
    localparam COR_TESTE = 24'hFF0000; // vermelho para facilitar visualização

    wire [23:0] db_led0;
    wire [23:0] db_led1;
    wire [23:0] db_led2;
    wire [23:0] db_led3;
    wire [23:0] db_led4;

    // TOPLEVEL (random + WS2811)
    random_led_controller DUT (
        .clock(clock),
        .reset(reset),
        .gerar_jogada(gerar_jogada),
        .cor_led(COR_TESTE),
        .serial(serial),
        .db_serial(db_serial),
        .db_led0(db_led0),
        .db_led1(db_led1),
        .db_led2(db_led2),
        .db_led3(db_led3),
        .db_led4(db_led4)
    );

    // Clock 50 MHz
    always #10 clock = ~clock;

    // ---- Função auxiliar: descobre qual LED acendeu ----
    function integer detect_led;
        input [23:0] L0, L1, L2, L3, L4;

        begin
            if (L0 != 24'h0) detect_led = 0;
            else if (L1 != 24'h0) detect_led = 1;
            else if (L2 != 24'h0) detect_led = 2;
            else if (L3 != 24'h0) detect_led = 3;
            else if (L4 != 24'h0) detect_led = 4;
            else detect_led = -1; // erro
        end
    endfunction

    // ---- Acesso interno aos LEDS da FD ----
    wire [23:0] L0 = db_led0;
    wire [23:0] L1 = db_led1;
    wire [23:0] L2 = db_led2;
    wire [23:0] L3 = db_led3;
    wire [23:0] L4 = db_led4;

    integer escolhido;

    // TESTE PRINCIPAL
    initial begin
        $display("===== INICIANDO TESTE DE RANDOMIZAÇÃO =====");

        #50 reset = 0;

        repeat (3) begin : cada_teste
            @(posedge clock);
            gerar_jogada = 1;
            @(posedge clock);
            gerar_jogada = 0;

            // Espera a UC carregar o frame
            repeat(10) @(posedge clock);

            // Descobre LED escolhido
            escolhido = detect_led(L0, L1, L2, L3, L4);

            $display("[%0t] Jogada -> LED sorteado = %0d", $time, escolhido);
            $display("      RGBs = %06h %06h %06h %06h %06h",
                L0, L1, L2, L3, L4);
            $display("");
        end

        $display("===== FIM DO TESTE =====");
        $finish;
    end

endmodule
