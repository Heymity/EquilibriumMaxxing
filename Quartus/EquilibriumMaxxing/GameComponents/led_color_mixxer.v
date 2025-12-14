module led_color_mixxer #(
    parameter N = 10,
    // precisão do multiplicador de recíprocos (número de bits fracionários)
    parameter RECP_SHIFT = 12,
    parameter RECP_WIDTH = 24
) (
    input  wire                clock,
    input  wire [N-1:0]        contador,
    input  wire [N-1:0]        mid_idx,
    input  wire [N-1:0]        max_idx,
    output reg  [23:0]         cor_led
);

    // Use wide regs for intermediate arithmetic (to support N up to 29)
    reg [63:0] midv;
    reg [63:0] maxv;
    reg [63:0] cntv;
    reg [63:0] prod;
    reg [63:0] prod2;
    reg [63:0] val64;
    reg [63:0] distancia;
    reg [63:0] delta;

    reg [7:0] R, G, B;

    always @(*) begin
        // widen inputs to 64-bit temporaries to avoid overflow in multiplications
        midv = mid_idx;
        maxv = max_idx;
        cntv = contador;

        // default
        R = 8'd0;
        G = 8'd0;
        B = 8'd0;
        prod = 64'd0;
        prod2 = 64'd0;
        distancia = 64'd0;
        delta = 64'd0;
        val64 = 64'd0;

        if (cntv == midv) begin
            // Amarelo puro
            R = 8'd255;
            G = 8'd255;
            B = 8'd0;
        end else if (cntv < midv) begin
            // vermelho -> amarelo: G cresce de 0..255 conforme cnt/mid
            R = 8'd255;
            if (midv > 0) begin
                // G = (cnt * 255) / mid
                prod = cntv * 64'd255;
                val64 = prod / midv;
                if (val64 > 255) val64 = 255;
                G = val64[7:0];
            end else begin
                G = 8'd255;
            end
            B = 8'd0;
        end else begin
            // amarelo -> verde: R decresce de 255..0 conforme (cnt-mid)/(max-mid)
            G = 8'd255;
            distancia = (maxv > midv) ? (maxv - midv) : 64'd1;
            delta = cntv - midv;
            if (distancia > 0) begin
                prod2 = delta * 64'd255;
                val64 = prod2 / distancia;
                if (val64 > 255) val64 = 255;
                R = 8'd255 - val64[7:0];
            end else begin
                R = 8'd0;
            end
            B = 8'd0;
        end

        cor_led = {R, G, B};
    end

endmodule
