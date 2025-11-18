module contador_m_updown_limitado #(parameter M=1000, N=10) (
    input  wire        clock,
    input  wire        zera_as,
    input  wire        zera_s,

    input  wire        inc,
    input  wire        dec,

    output reg  [N-1:0] Q
);

    always @(posedge clock or posedge zera_as) begin
        if (zera_as) begin
            Q <= 0;
        end else begin
            if (zera_s) begin
                Q <= 0;

            end else begin
                if (inc && !dec) begin
                    if (Q < M-1)
                        Q <= Q + 1'b1;

                end else if (dec && !inc) begin
                    if (Q > 0)
                        Q <= Q - 1'b1;
                end
            end
        end
    end
endmodule