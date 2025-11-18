module WS2811_array_controller (
	input 		clock,
	input 		reset,
	
	input [7:0] led_count,
	input 		enable,
	
    input       use_external_rgb,
    input [23:0] external_led0,
    input [23:0] external_led1,
    input [23:0] external_led2,
    input [23:0] external_led3,
    input [23:0] external_led4,

	output 		serial,
	
	output		db_serial
);

	wire last_led;			
	wire serial_reset_done;
	wire word_sent;				    
	wire send_data;			
	wire next_led;			
	wire serial_reset;		
	
	
	WS2811_array_controller_uc UC (
		.clock					(clock),
		.reset					(reset),
	
		// Control Inputs
		.enable					(enable				),
		.last_led				(last_led			),
		.serial_reset_done		(serial_reset_done),
		.word_sent				(word_sent			),
	

		// Condition Outputs
		.send_data				(send_data			),
		.next_led				(next_led			),
		.serial_reset			(serial_reset		)
	);

	WS2811_array_controller_fd FD (
		.clock					(clock),
		.reset					(reset),
	
		// Data Inputs
		.led_count				(led_count),

		.use_external_rgb(use_external_rgb),
        .external_led0(external_led0),
        .external_led1(external_led1),
        .external_led2(external_led2),
        .external_led3(external_led3),
        .external_led4(external_led4),
	
		// Control Inputs
		.send_data				(send_data			),
		.next_led				(next_led			),
		.serial_reset			(serial_reset		),
	
	
		// Condition Outputs
		.last_led				(last_led			),
		.serial_reset_done	(serial_reset_done),
		.word_sent				(word_sent			),
	
		// Data Outputs
		.serial					(serial				),
		
		
		.db_serial				(db_serial			)
	);

endmodule