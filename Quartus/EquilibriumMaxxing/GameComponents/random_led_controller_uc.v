module random_led_controller_uc(
    input  wire clock,
    input  wire reset,
    input  wire gerar_jogada,       // pulso externo

    output reg  carrega_frame       // pulso para FD
);

    localparam Idle 		= 1'b0;
	localparam Load_frame 	= 1'b1;
	
	reg Eatual, Eprox;

	always @(posedge clock, posedge reset) begin
		if (reset)
			Eatual <= Idle;
		else
			Eatual <= Eprox;
	end

    always @(*) begin
		case(Eatual)
			Idle:		Eprox <= gerar_jogada ? Load_frame : Idle;
			Load_frame:	Eprox <= Idle;	
			default:	Eprox <= Idle;
		endcase
	end

	always @(*) begin
		carrega_frame   <= Eatual == Load_frame;
	end

endmodule