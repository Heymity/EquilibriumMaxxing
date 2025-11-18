module WS2811_serial (
	input 			clock,
	input 			reset,
	
	input [23:0] 	rgb_data,
	input 			send,
	
	output			serial,
	output 			word_sent,
	
	output 			db_serial
);
	
	
	wire shift_data;
	wire load_data;
	wire send_serial;
	
	wire fim_data;
	wire fim_bit;


	WS2811_serial_uc UC (
		.clock				(clock	),
		.reset				(reset	),
	
		// Input Condicoes
		.send_data			(send			),
		.fim_data			(fim_data	),
		.fim_bit				(fim_bit		),
	
	
		// Output Controle
		.shift_data			(shift_data	),
		.load_data			(load_data	),
		.send_serial		(send_serial),
		.word_sent			(word_sent	)
	);
	
	WS2811_serial_fd #(
		.T0H( 12),	//  12	24
		.T1H( 30),   //  30   60
		.T0L( 50),  //  50   100
		.T1L( 32)    //  32   64
	) FD (
		.clock				(clock		),
		.reset				(reset		),
	
		// Data Inputs
		.rgb_data			(rgb_data	),
	
		// Control Inputs
		.shift_data			(shift_data	),
		.load_data			(load_data	),
		.send_serial		(send_serial),
	
	
		// Condition Outputs
		.fim_data			(fim_data	),
		.fim_bit				(fim_bit		),
	
		// Data Outputs
		.serial				(serial		),
		
		.db_serial			(db_serial	)
	);
	



endmodule