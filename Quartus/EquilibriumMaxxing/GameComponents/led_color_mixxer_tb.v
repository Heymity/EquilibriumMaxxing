`timescale 1ns/1ps
`timescale 1ns/1ps
module led_color_mixxer_tb;
    parameter N = 8;

    reg clock;
    reg [N-1:0] contador;
    reg [N-1:0] mid_idx;
    reg [N-1:0] max_idx;
    wire [23:0] cor_led;

    reg [23:0] prev_cor;
    reg counting_up;
    reg phase2_started;

    // Instancia o DUT com N=8 para varrer 0..255
    led_color_mixxer #(.N(N)) uut (
        .clock(clock),
        .contador(contador),
        .mid_idx(mid_idx),
        .max_idx(max_idx),
        .cor_led(cor_led)
    );

    initial begin
        $dumpfile("led_color_mixxer_tb.vcd");
        $dumpvars(0, led_color_mixxer_tb);

        // inicializações
        clock = 0;
        mid_idx = 8'd128; // ponto médio para observar transição
        max_idx = 8'd200;
        contador = mid_idx; // começa no meio
        counting_up = 1'b1;
        prev_cor = 24'hxxxxxx;
        phase2_started = 1'b0;
    end

    // gerador de clock
    always #5 clock = ~clock;

    // lógica de contagem: sobe até max_idx e depois desce até 0
    always @(posedge clock) begin
        if (counting_up) begin
            if (contador < max_idx) begin
                contador = contador + 1;
            end else begin
                counting_up = 1'b0;
            end
        end else begin
            if (contador > 0) begin
                contador = contador - 1;
            end else begin
                if (!phase2_started) begin
                    // primeiro ciclo concluído — altera parâmetros dinamicamente e reinicia
                    $display("time=%0t Primeiro ciclo concluido. Alterando mid/max e reiniciando.", $time);
                    mid_idx = 8'd64;
                    max_idx = 8'd180;
                    contador = mid_idx;
                    counting_up = 1'b1;
                    phase2_started = 1'b1;
                end else begin
                    $display("time=%0t Segundo ciclo concluido. Simulação finalizada.", $time);
                    $finish;
                end
            end
        end

        #0; // espera a lógica combinacional estabilizar
        if (cor_led !== prev_cor) begin
            $display("time=%0t cnt=%0d R=%0h G=%0h B=%0h cor=%06h", $time, contador, cor_led[23:16], cor_led[15:8], cor_led[7:0], cor_led);
            prev_cor = cor_led;
        end
    end

endmodule