module level_register (
    input  wire clock,
    input  wire reset,

    input  wire signed [15:0] alavanca1,
    input  wire signed [15:0] alavanca2,

    input wire start_game,

    output wire start_game_db,
    output reg  [1:0] nivel_reg,
    output wire nivel_locked_db
);

    assign start_game_db = start_game;
    reg nivel_locked;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            nivel_locked <= 1'b0;
            nivel_reg    <= 2'd0;
        end else begin
            if (!nivel_locked && start_game) begin

                case ({alavanca1[15], alavanca2[15]})
                    2'b11: nivel_reg <= 2'd0;
                    2'b10: nivel_reg <= 2'd1;
                    2'b01: nivel_reg <= 2'd2;
                    2'b00: nivel_reg <= 2'd3;
                endcase

                nivel_locked <= 1'b1;
            end
        end
    end

    assign nivel_locked_db = nivel_locked;

endmodule
