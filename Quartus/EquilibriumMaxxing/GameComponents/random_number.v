module random_number (
    input gerar,
    input [2:0] seed,
    output reg [4:0] numero
);


always @(posedge gerar) begin
    case (seed)
        3'b000: numero <= 5'b00001;
        3'b001: numero <= 5'b00010;
        3'b010: numero <= 5'b00100;
        3'b011: numero <= 5'b01000;
        3'b100: numero <= 5'b10000;
        default: numero <= 5'b00001;
    endcase
end

endmodule