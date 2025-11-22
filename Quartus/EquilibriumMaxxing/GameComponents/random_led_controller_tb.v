`timescale 1ns/1ps

module random_led_controller_tb;

    reg clock = 0;
    reg reset = 1;
    reg gerar_jogada = 0;

    wire serial;
    wire db_serial;

    // Parâmetros do teste
    localparam COR_TESTE = 24'hFF0000; // vermelho para facilitar visualização

    // Acessa os LEDs internos do FD via hierarquia (DUT -> FD_RAND)
    wire [23:0] db_led0 = DUT.FD_RAND.led0;
    wire [23:0] db_led1 = DUT.FD_RAND.led1;
    wire [23:0] db_led2 = DUT.FD_RAND.led2;
    wire [23:0] db_led3 = DUT.FD_RAND.led3;
    wire [23:0] db_led4 = DUT.FD_RAND.led4;
    wire [23:0] db_led5 = DUT.FD_RAND.led5;
    wire [23:0] db_led6 = DUT.FD_RAND.led6;
    wire [23:0] db_led7 = DUT.FD_RAND.led7;
    wire [23:0] db_led8 = DUT.FD_RAND.led8;
    wire [23:0] db_led9 = DUT.FD_RAND.led9;
    wire [23:0] db_led10 = DUT.FD_RAND.led10;

    // TOPLEVEL (random + WS2811)
    random_led_controller DUT (
        .clock(clock),
        .reset(reset),
        .gerar_jogada(gerar_jogada),
        .serial(serial),
        .db_serial(db_serial)
    );

    // Clock 50 MHz
    always #10 clock = ~clock;

    // ---- Função auxiliar: descobre qual LED acendeu ----
    function integer detect_led;
        input [23:0] L0, L1, L2, L3, L4, L5, L6, L7, L8, L9, L10;

        begin
            if (L0 != 24'h0) detect_led = 0;
            else if (L1 != 24'h0) detect_led = 1;
            else if (L2 != 24'h0) detect_led = 2;
            else if (L3 != 24'h0) detect_led = 3;
            else if (L4 != 24'h0) detect_led = 4;
            else if (L5 != 24'h0) detect_led = 5;
            else if (L6 != 24'h0) detect_led = 6;
            else if (L7 != 24'h0) detect_led = 7;
            else if (L8 != 24'h0) detect_led = 8;
            else if (L9 != 24'h0) detect_led = 9;
            else if (L10 != 24'h0) detect_led = 10;
            else detect_led = -1; // erro
        end
    endfunction

    // ---- Acesso interno aos LEDS da FD (aliases) ----
    wire [23:0] L0 = db_led0;
    wire [23:0] L1 = db_led1;
    wire [23:0] L2 = db_led2;
    wire [23:0] L3 = db_led3;
    wire [23:0] L4 = db_led4;
    wire [23:0] L5 = db_led5;
    wire [23:0] L6 = db_led6;
    wire [23:0] L7 = db_led7;
    wire [23:0] L8 = db_led8;
    wire [23:0] L9 = db_led9;
    wire [23:0] L10 = db_led10;

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
            escolhido = detect_led(L0, L1, L2, L3, L4, L5, L6, L7, L8, L9, L10);

            $display("[%0t] Jogada -> LED sorteado = %0d", $time, escolhido);
            $display("      RGBs = %06h %06h %06h %06h %06h %06h %06h %06h %06h %06h %06h",
                L0, L1, L2, L3, L4, L5, L6, L7, L8, L9, L10);
            $display("");
        end

        $display("===== FIM DO TESTE =====");
        $finish;
    end

endmodule
