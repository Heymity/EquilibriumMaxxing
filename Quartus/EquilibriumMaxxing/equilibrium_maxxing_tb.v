`timescale 1ns / 1ps

module equilibrium_maxxing_tb;

    // Sinais de clock e controle
    reg clock;
    reg [9:0] SW;
    
    // Entradas
    reg start_game;
    reg RX;
    reg sensorFimCurso;
    
    // Saídas
    wire serial;
    wire db_serial;
    wire step;
    wire dir;
    wire [9:0] pontuacao;
    wire ganhou_ponto;
    wire perdeu_ponto;
    wire [2:0] nivel_dificuldade;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    // Instância do módulo
    equilibrium_maxxing DUT (
        .clock(clock),
        .start_game(start_game),
        .RX(RX),
        .sensorFimCurso(sensorFimCurso),
        .serial(serial),
        .db_serial(db_serial),
        .step(step),
        .dir(dir),
        .pontuacao(pontuacao),
        .ganhou_ponto(ganhou_ponto),
        .perdeu_ponto(perdeu_ponto),
        .nivel_dificuldade(nivel_dificuldade),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
    
    // Gerador de clock 50 MHz
    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;  // período 20ns
    end
    
    // Monitor de estados
    wire [2:0] db_estado = DUT.UC.db_estado;
    wire [15:0] db_current_pos = DUT.db_current_pos;
    wire [15:0] alavanca1 = DUT.FD.alavanca1;
    wire [15:0] alavanca2 = DUT.FD.alavanca2;
    wire [3:0] position_led = DUT.FD.led_alvo;
    wire trava_servo = DUT.UC.trava_servo;
    wire calib_start = DUT.UC.calib_start;
    wire calib_done = DUT.FD.INPUT_MUX.calib_done;
    wire conta_nivel = DUT.UC.conta_nivel;
    
    // Task para aguardar N ciclos
    task wait_cycles(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clock);
            end
        end
    endtask
    
    // Simulação principal
    initial begin
        $dumpfile("equilibrium_maxxing_tb.vcd");
        $dumpvars(0, equilibrium_maxxing_tb);
        
        // Inicialização
        SW = 10'b0000000000;  // reset = 0
        start_game = 1'b0;
        RX = 1'b1;           // UART idle
        sensorFimCurso = 1'b0;
        
        $display("=== TESTE: CALIBRAÇÃO ===");
        
        // 1. Aplicar reset
        $display("[%0t] Reset ON", $time);
        SW[9] = 1'b1;
        wait_cycles(10);
        
        // 2. Tirar reset
        $display("[%0t] Reset OFF", $time);
        SW[9] = 1'b0;
        wait_cycles(10);
        
        // Estado esperado: Calibra (3'b001 = SelNivel é o padrão pós-reset, mas UC inicia em SelNivel)
        // Obs: o reset leva para SelNivel, não Calibra. Ajuste conforme necessário.
        
        // 3. Forçar calibração enviando sensorFimCurso
        // Nota: A UC só entra em Calibra se o reset levar lá, ou por lógica externa
        // Por enquanto, vamos simular que o sistema inicia em SelNivel
        
        $display("[%0t] Estado após reset: %b (SelNivel=001 ou outro)", $time, db_estado);
        wait_cycles(20);
        
        // ===== TESTE DE SELEÇÃO DE NÍVEL =====
        $display("\n=== TESTE: SELEÇÃO DE NÍVEL ===");
        $display("[%0t] Aguardando start_game...", $time);
        
        // Simular leitura de alavancas para seleção (nível 0)
        // O level_register lê alavanca1/alavanca2, mas não simulamos UART aqui
        wait_cycles(100);
        
        // Pressionar start_game
        $display("[%0t] start_game = 1", $time);
        start_game = 1'b1;
        wait_cycles(1);
        start_game = 1'b0;
        
        // Aguardar transição para Prep
        wait_cycles(50);
        $display("[%0t] Estado: %b (esperado Prep=010)", $time, db_estado);
        
        // ===== TESTE DE GERAÇÃO DE JOGADA =====
        $display("\n=== TESTE: GERAÇÃO DE JOGADA ===");
        
        // Simular prep_done (da lógica de preparação)
        // Nota: prep_done é gerado internamente pela FD, não é entrada
        // Vamos aguardar que a UC transite naturalmente
        
        repeat(10) begin
            wait_cycles(50);
            $display("[%0t] Estado: %b, conta_nivel: %b, position_led: %d, current_pos: %d", 
                     $time, db_estado, conta_nivel, position_led, db_current_pos);
        end
        
        // ===== TESTE DE DINÂMICA DO PÊNDULO =====
        $display("\n=== TESTE: DINÂMICA DO PÊNDULO ===");
        $display("[%0t] Simulando movimento do pêndulo...", $time);
        
        // A dinâmica vem do simulator dentro do pendulum_driver
        // Apenas monitoramos current_pos
        repeat(100) begin
            wait_cycles(100);
            if (conta_nivel) begin
                $display("[%0t] JOGA: current_pos=%d, position_led=%d, ganhou=%b, perdeu=%b, pontuacao=%d",
                         $time, db_current_pos, position_led, ganhou_ponto, perdeu_ponto, pontuacao);
            end
        end
        
        // ===== TESTE DE CALIBRAÇÃO (MANUAL) =====
        $display("\n=== TESTE: CALIBRAÇÃO MANUAL ===");
        $display("[%0t] Acionando sensor de fim de curso", $time);
        sensorFimCurso = 1'b1;
        wait_cycles(10);
        $display("[%0t] calib_done = %b, current_pos = %d", $time, calib_done, db_current_pos);
        
        sensorFimCurso = 1'b0;
        wait_cycles(50);
        
        $display("\n=== FIM DA SIMULAÇÃO ===");
        $finish;
    end
    
    // Monitor adicional para eventos importantes
    always @(posedge clock) begin
        if (ganhou_ponto) begin
            $display("[%0t] *** PONTO GANHO! Pontuação: %d ***", $time, pontuacao);
        end
        if (perdeu_ponto) begin
            $display("[%0t] *** PONTO PERDIDO! Pontuação: %d ***", $time, pontuacao);
        end
        if (db_estado != 3'b100) begin  // Qualquer transição de estado
            $display("[%0t] Transição de estado detectada: novo_estado=%b", $time, db_estado);
        end
    end

endmodule
