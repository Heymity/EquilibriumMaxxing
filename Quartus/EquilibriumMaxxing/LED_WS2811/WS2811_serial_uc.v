module WS2811_serial_uc (
	input clock,
	input reset,
	
	// Input Condicoes
	input					send_data,
	input					fim_data,
	input					fim_bit,
	
	
	// Output Controle
	output reg			shift_data,
	output reg			load_data,
	output reg			send_serial,
	output reg			word_sent,
	
	// Depuracao
	output wire [2:0]	db_estado
);

	localparam Init 		= 3'b000;
	localparam LoadData 	= 3'b001;
	localparam SendBit 		= 3'b010;
	localparam ShiftBit 	= 3'b011;
	localparam WordSent 	= 3'b100;
	
	reg [2:0] Eatual, Eprox;

	
	assign db_estado = Eatual;
	
	always @(posedge clock, posedge reset) begin
		if (reset)
			Eatual <= Init;
		else
			Eatual <= Eprox;
	end
	
	
	always @(*) begin
		case(Eatual)
			Init:			Eprox <= send_data ? LoadData : Init;
			LoadData:	Eprox <= SendBit;	
			SendBit: 	Eprox <= fim_bit ? ShiftBit : SendBit;
			ShiftBit:	Eprox <= fim_data ? WordSent : SendBit;
			WordSent:	Eprox <= Init;
			default:		Eprox <= Init;
		endcase
	end

	always @(*) begin
		shift_data	<= Eatual == ShiftBit;
		load_data	<= Eatual == LoadData;
	   send_serial	<= Eatual == SendBit;
		word_sent 	<= Eatual == WordSent;
	end

	
endmodule