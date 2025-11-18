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

    integer mid;
    integer maxv;
    integer cnt;
    integer prod;
    integer prod2;
    integer val;
    integer dist;
    integer delta;
    
    // tabela de recíprocos pré-calculados: recip[i] ~= floor(255<<RECP_SHIFT / i)
    localparam integer TABLE_SIZE = (1<<N);
    reg [RECP_WIDTH-1:0] recip_table [0:TABLE_SIZE-1];
    integer i;

    initial begin
        recip_table[0] = 0;
        for (i = 1; i < TABLE_SIZE; i = i + 1) begin
            recip_table[i] = (255 << RECP_SHIFT) / i;
        end
    end

    reg [7:0] R, G, B;

    always @(*) begin
        mid = mid_idx;
        maxv = max_idx;
        cnt = contador;

        // default
        R = 8'd0;
        G = 8'd0;
        B = 8'd0;

        if (cnt == mid) begin
            // Amarelo puro
            R = 8'd255;
            G = 8'd255;
            B = 8'd0;
        end else if (cnt < mid) begin
            // vermelho -> amarelo: G cresce de 0..255 conforme cnt/mid
            R = 8'd255;
            if (mid > 0) begin
                // G = (cnt * 255) / mid  => use recip_table[mid]
                // produto largura: cnt (<=TABLE_SIZE-1) * recip (RECP_WIDTH)
                prod = cnt * recip_table[mid];
                G = ((prod >> RECP_SHIFT) & 8'hFF);
            end else begin
                G = 8'd255;
            end
            B = 8'd0;
        end else begin
            // amarelo -> verde: R decresce de 255..0 conforme (cnt-mid)/(max-mid)
            G = 8'd255;
            dist = (maxv > mid) ? (maxv - mid) : 1;
            delta = cnt - mid;
            if (dist > 0) begin
                prod2 = delta * recip_table[dist];
                // value = (delta * 255) / dist
                val = (prod2 >> RECP_SHIFT);
                if (val > 255) val = 255;
                R = 8'd255 - (val & 8'hFF);
            end else begin
                R = 8'd0;
            end
            B = 8'd0;
        end

        cor_led = {R, G, B};
    end

endmodule
