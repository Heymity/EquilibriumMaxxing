module led_color_fader (
    input  wire        clock,
    input  wire        reset,
    input  wire        trigger,           // pulso: início da jogada
    input  wire [23:0] cor_in,
    input  wire [9:0] max_idx,
    output reg  [23:0] cor_out
);

    // separa canais
    reg [7:0] R_in, G_in, B_in;
    reg [7:0] R_out, G_out, B_out;

    // contadores e flags
    reg [31:0] fade_length; // duração do fade em ciclos
    reg [31:0] fade_counter; // contador decrescente durante fade
    reg fading;

    // registrar entrada quando trigger ocorrer
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            R_in <= 0; G_in <= 0; B_in <= 0;
            R_out <= 0; G_out <= 0; B_out <= 0;
            cor_out <= 24'd0;
            fade_length <= 0;
            fade_counter <= 0;
            fading <= 1'b0;
        end else begin
            if (trigger) begin
                // armar e iniciar fade IMEDIATAMENTE
                R_in <= cor_in[23:16];
                G_in <= cor_in[15:8];
                B_in <= cor_in[7:0];
                // duração do fade = max(1, max_idx/2)
                fade_length <= (max_idx >> 1) > 0 ? (max_idx >> 1) : 1;
                fade_counter <= (max_idx >> 1) > 0 ? (max_idx >> 1) : 1;
                fading <= 1'b1;
                // inicializa saída com cor de entrada (fade_counter == fade_length)
                R_out <= cor_in[23:16];
                G_out <= cor_in[15:8];
                B_out <= cor_in[7:0];
                cor_out <= cor_in;
            end else begin
                if (fading) begin
                    if (fade_counter > 0) begin
                        // cálculo linear: out = in * fade_counter / fade_length
                        R_out <= (R_in * fade_counter) / fade_length;
                        G_out <= (G_in * fade_counter) / fade_length;
                        B_out <= (B_in * fade_counter) / fade_length;
                        cor_out <= {R_out, G_out, B_out};
                        fade_counter <= fade_counter - 1;
                    end else begin
                        // fade concluído
                        R_out <= 8'd0; G_out <= 8'd0; B_out <= 8'd0;
                        cor_out <= 24'd0;
                        fading <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
