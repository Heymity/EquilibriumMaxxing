`timescale 1ns / 1ps

module equilibrium_maxxing_tb;

    // Sinais de clock e controle
    reg clock;
    reg [9:0] SW;
    
    // Entradas
    reg start_game;
    reg RX;
    reg end_left;
    reg end_right;
    // Fast simulation mode: forces internal events so long-running counters don't block
    reg SIM_FAST = 1'b1;
    
    // Saídas
    wire serial;
    wire db_serial;
    wire step;
    wire dir;
    wire [7:0] pontuacao;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire start_game_db;
    wire [23:0] cor_led_db;
    
    // Instância do módulo
    equilibrium_maxxing DUT (
        .clock(clock),
        .start_game(start_game),
        .RX(RX),
        .end_left(end_left),
        .end_right(end_right),
        .serial(serial),
        .db_serial(db_serial),
        .step(step),
        .dir(dir),
        .pontuacao(pontuacao),
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
    wire [15:0] db_current_pos = DUT.FD.db_current_pos;
    wire [3:0] position_led = DUT.FD.RAND.position_led;
    wire [9:0] contador_jogo_db = DUT.FD.JOGO.contador_jogo;
    
    // Task para aguardar N ciclos
    task wait_cycles(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clock);
            end
        end
    endtask
    
    integer k;

    // Simulação principal
    initial begin
        $dumpfile("equilibrium_maxxing_tb.vcd");
        $dumpvars(0, equilibrium_maxxing_tb);
        
        // Inicialização
        SW = 10'b0000000000;  // reset = 0
        start_game = 1'b1;
        RX = 1'b1;           // UART idle
        end_left = 1'b0;
        end_right = 1'b0;
        
        $display("=== TESTE: CALIBRAÇÃO ===");
        
        // 1. Aplicar reset
        $display("[%0t] Reset ON", $time);
        SW[9] = 1'b1;
        wait_cycles(10);
        
        // 2. Tirar reset
        $display("[%0t] Reset OFF", $time);
        SW[9] = 1'b0;
        wait_cycles(10);
        
        // 3. Aguardar e sair do estado Calibra (acionando sensor de fim de curso)
        $display("[%0t] Estado após reset: %b", $time, db_estado);
        wait_cycles(20);
        
        // Se estiver em Calibra (3'b000), aciona sensor de fim de curso
        if (db_estado == 3'b000) begin  // Estado Calibra
            $display("[%0t] Sistema em estado Calibra. Acionando end_left...", $time);
            end_left = 1'b1;
            wait_cycles(10);
            end_left = 1'b0;
            wait_cycles(20);
            $display("[%0t] Saiu de Calibra. Estado atual: %b", $time, db_estado);
        end
        
        // ===== TESTE DE SELEÇÃO DE NÍVEL =====
        $display("\n=== TESTE: SELEÇÃO DE NÍVEL ===");
        $display("[%0t] Selecionando nível 1...", $time);
        
        // Forçar valores das alavancas no módulo serial2alavanca
        // Para seleção de nível 1: alavanca1[15] = 1, alavanca2[15] = 0
        force DUT.FD.SERIAL.al1Bits = 16'h8000;
        force DUT.FD.SERIAL.al2Bits = 16'h0000;
        wait_cycles(50);
        
        // Pressionar start_game
        $display("[%0t] start_game = 1", $time);
        start_game = 1'b0;
        wait_cycles(1);
        start_game = 1'b1;
        
        // Liberar as forças após o latch do nível
        release DUT.FD.SERIAL.al1Bits;
        release DUT.FD.SERIAL.al2Bits;
        
        // Aguardar transição para Prep (or force it in fast-sim)
        if (SIM_FAST) begin
            // prep_done is produced inside FD; force it briefly to simulate the prep finishing
            $display("[%0t] SIM_FAST: forçando prep_done para acelerar transição", $time);
            force DUT.FD.prep_done = 1'b1;
            wait_cycles(2);
            release DUT.FD.prep_done;
            wait_cycles(2);
        end else begin
            wait_cycles(50);
        end
        $display("[%0t] Estado: %b (esperado Prep=010)", $time, db_estado);
        
        // ===== TESTE DE GERAÇÃO DE JOGADA =====
        $display("\n=== TESTE: GERAÇÃO DE JOGADA ===");

        if (SIM_FAST) begin
            // Simule algumas jogadas forçando ganho de ponto para transitar Joga->Prep
            for (k = 0; k < 3; k = k + 1) begin
                $display("[%0t] SIM_FAST: forçando geracao de jogada/prep (iter %0d)", $time, k);
                // Garante que há uma nova jogada pronta
                force DUT.FD.prep_done = 1'b1;
                wait_cycles(1);
                release DUT.FD.prep_done;
                wait_cycles(2);

                // Agora force um ponto ganho para voltar a PREP
                force DUT.FD.ganhou_ponto = 1'b1;
                wait_cycles(1);
                release DUT.FD.ganhou_ponto;
                wait_cycles(5);

                $display("[%0t] Estado: %b, position_led: %d, current_pos: %d", $time, db_estado, position_led, db_current_pos);
            end
        end else begin
            repeat(10) begin
                wait_cycles(50);
                $display("[%0t] Estado: %b, position_led: %d, current_pos: %d", 
                         $time, db_estado, position_led, db_current_pos);
            end
        end
        
        // ===== TESTE DE CALIBRAÇÃO (MANUAL) =====
        $display("\n=== TESTE: CALIBRAÇÃO MANUAL ===");
        $display("[%0t] Acionando sensor de fim de curso", $time);
        end_left = 1'b1;
        wait_cycles(10);
        $display("[%0t] end_left = %b, current_pos = %d", $time, end_left, db_current_pos);
        
        end_left = 1'b0;
        wait_cycles(50);
        
        $display("\n=== FIM DA SIMULAÇÃO ===");
        $finish;
    end
    
    // Variáveis para rastrear mudanças (evitar impressão duplicada)
    reg [2:0] prev_db_estado = 3'b000;
    reg prev_serial = 1'b0;
    reg [7:0] prev_pontuacao = 8'b0;
    reg prev_ganhou_ponto = 1'b0;
    reg prev_perdeu_ponto = 1'b0;
    reg [9:0] prev_contador_jogo_db = 10'b0;
    reg [23:0] prev_cor_led_db = 24'b0;
    
    // Monitor detalhado para cor_led_db
    initial begin
        #10;  // Aguarda um pouco para sincronizar
        $display("[%0t] TESTE: Começando monitor de cor_led_db", $time);
    end
    
    always @(posedge clock) begin
        // Força printagem simples
        if ($time > 1000 && $time < 200000) begin
            // Apenas a cada 1000 unidades de tempo para não spammar
            if (($time % 1000) == 0) begin
                $display("[%0t] cor_led_db=%024b", $time, cor_led_db);
            end
        end
    end
    
    // Monitor adicional para eventos importantes
    always @(posedge clock) begin
        if (DUT.FD.ganhou_ponto) begin
            $display("[%0t] *** PONTO GANHO! Pontuação: %d ***", $time, pontuacao);
        end
        if (DUT.FD.perdeu_ponto) begin
            $display("[%0t] *** PONTO PERDIDO! Pontuação: %d ***", $time, pontuacao);
        end
        
        // Imprime apenas quando há mudança real
        if ((db_estado != prev_db_estado) || 
            (serial != prev_serial) || 
            (pontuacao != prev_pontuacao) || 
            (DUT.FD.ganhou_ponto != prev_ganhou_ponto) ||
            (DUT.FD.perdeu_ponto != prev_perdeu_ponto) ||
            (contador_jogo_db != prev_contador_jogo_db) ||
            (cor_led_db != prev_cor_led_db)) begin
            $display("[%0t] MUDANÇA DETECTADA | db_estado=%b | serial=%b | pontuacao=%d | ganhou_ponto=%b | perdeu_ponto=%b | contador_jogo=%d | cor_led_db=%024b | nivel_dificuldade=%b",
                     $time, db_estado, serial, pontuacao, DUT.FD.ganhou_ponto, DUT.FD.perdeu_ponto, contador_jogo_db, DUT.FD.cor_led_db, DUT.FD.nivel_dificuldade);
        end
        
        // Atualiza valores anteriores
        prev_db_estado <= db_estado;
        prev_serial <= serial;
        prev_pontuacao <= pontuacao;
        prev_ganhou_ponto <= DUT.FD.ganhou_ponto;
        prev_perdeu_ponto <= DUT.FD.perdeu_ponto;
        prev_contador_jogo_db <= contador_jogo_db;
        prev_cor_led_db <= cor_led_db;
    end

endmodule