module contador_m_invertible #(
    parameter M = 100,
    parameter N = 7
)
(
    input  wire         clock,
    input  wire         zera_as,
    input  wire         zera_s,
    input  wire         conta,
    input  wire         count_up,   // 1 = sobe, 0 = desce

    output reg  [N-1:0] Q,
    output reg          fim,
    output reg          inicio
);

localparam integer MID = M/2;
localparam integer MAX = M-1;

    always @(posedge clock or posedge zera_as) begin
        if (zera_as) begin
            Q <= MID[N-1:0];
        end else begin
            if (zera_s) begin
                Q <= MID[N-1:0];
            end else if (conta) begin

                if (count_up) begin
                    if (Q == MAX[N-1:0])
                        Q <= MID[N-1:0];
                    else
                        Q <= Q + 1'b1;

                end else begin
                    if (Q == 0)
                        Q <= MID[N-1:0];
                    else
                        Q <= Q - 1'b1;
                end

            end
        end
    end

    // Fim quando Q == M-1
    always @(*) begin
        fim  = (Q == MAX[N-1:0]);
        inicio = (Q == 0);
    end

endmodule