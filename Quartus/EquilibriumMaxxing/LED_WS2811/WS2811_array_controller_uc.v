module WS2811_array_controller_uc (
	input 			clock,
	input 			reset,
	
	// Control Inputs
	input 			enable,
	input				last_led,
	input				serial_reset_done,
	input				word_sent,
	

	// Condition Outputs
	output reg 		send_data,
	output reg		next_led,
	output reg		serial_reset,
	
	// Depuracao
	output wire [1:0]		db_estado
);

	localparam Idle 			= 2'b00;
	localparam SendSerial 	= 2'b01;
	localparam NextLed 		= 2'b10;
	localparam SendReset		= 2'b11;
	
	reg [1:0] Eatual, Eprox;
	
	assign db_estado = Eatual;

	
	always @(posedge clock, posedge reset) begin
		if (reset)
			Eatual <= Idle;
		else
			Eatual <= Eprox;
	end
	
	
	always @(*) begin
		case(Eatual)
			Idle:			Eprox <= enable ? SendSerial : Idle;
			SendSerial:	Eprox <= word_sent ? NextLed : SendSerial;	
			NextLed: 	Eprox <= last_led ? SendReset : SendSerial;
			SendReset:	Eprox <= enable ? (serial_reset_done ? SendSerial : SendReset) : Idle;
			default:		Eprox <= Idle;
		endcase
	end

	always @(*) begin
		send_data		<= Eatual == SendSerial;
		next_led			<= Eatual == NextLed;
	   serial_reset	<= Eatual == SendReset;
	end


endmodule