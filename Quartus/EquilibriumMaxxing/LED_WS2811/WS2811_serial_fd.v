module WS2811_serial_fd #(
	parameter T0H = 12,
	parameter T1H = 30,
	parameter T0L = 50,
	parameter T1L = 32
)(
	input 				clock,
	input					reset,
	
	// Data Inputs
	input 	[23:0] 	rgb_data,
	
	// Control Inputs
	input					shift_data,
	input					load_data,
	input					send_serial,
	
	
	// Condition Outputs
	output wire			fim_data,
	output wire			fim_bit,
	
	// Data Outputs
	output wire			serial,
	
	// Depuracao
	output wire			db_serial,
	output wire			db_currBit
);

	reg [23:0] 	rgb_data_sr;
	reg [4:0]	shift_counter;
	reg [7:0] 	pulse_counter;
	
	assign fim_data 	= 	shift_counter == 5'd23;
	assign fim_bit 	=	rgb_data_sr[23] ? (pulse_counter == T1H + T1L - 1) : (pulse_counter == T0H + T0L - 1);
	assign serial 		= 	send_serial ? 
									(rgb_data_sr[23] ? 
										(pulse_counter > T1H ? 1'b0 : 1'b1) : 
										(pulse_counter > T0H ? 1'b0 : 1'b1)) : 
									1'b0;
	
	
	// mudar para componentes descretos
	always @(posedge clock, posedge reset) begin
		if (reset) begin
			rgb_data_sr		<= 24'h000000;
			shift_counter	<=	5'b00000;
			pulse_counter	<= 8'h00;
		end else begin 
		
			if (shift_data) begin
				rgb_data_sr 	<= {rgb_data_sr[22:0], 1'b0};
				shift_counter 	<= shift_counter + 1'b1;
				pulse_counter 	<= 0;
			end
			
			if (load_data) begin
				rgb_data_sr 	<= rgb_data;
				shift_counter 	<= 0;
			end
			
			if (send_serial) begin
				pulse_counter 	<= pulse_counter + 1'b1;
			end
			
		end
	end
	
	assign db_serial = serial;
	assign db_currBit = rgb_data_sr[23];

endmodule