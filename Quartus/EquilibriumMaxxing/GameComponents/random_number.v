module random_number (
    input gerar,
    input [3:0] seed,
    output reg [10:0] numero
);


always @(posedge gerar) begin
    case (seed)
        4'b0000: numero <= 11'b00000000001;
        4'b0001: numero <= 11'b00000000010;
        4'b0010: numero <= 11'b00000000100;
        4'b0011: numero <= 11'b00000001000;
        4'b0100: numero <= 11'b00000010000;
        4'b0101: numero <= 11'b00000100000;
        4'b0110: numero <= 11'b00001000000;
        4'b0111: numero <= 11'b00010000000;
        4'b1000: numero <= 11'b00100000000;
        4'b1001: numero <= 11'b01000000000;
        4'b1010: numero <= 11'b10000000000;
        default: numero <= 11'b00000000001;
    endcase
end

endmodule