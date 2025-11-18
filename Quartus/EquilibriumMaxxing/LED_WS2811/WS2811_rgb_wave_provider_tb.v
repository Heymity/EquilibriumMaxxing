`timescale 1ns/1ns


module rgb_wave_provider_tb ();

	reg				clock;
	reg				reset;
	reg				next_led;
	reg				serial_reset;
	
	wire	[23:0]	rgb;

	WS2811_rgb_wave_provider DUT (
		.clock			(clock			),
		.reset			(reset			),
		.advance			(next_led		),
		.serial_reset	(serial_reset	),
		
		.rgb				(rgb				)
	);
	
	integer cLed;
	integer testCase;
	
	parameter clock_period = 20; // clock 50Mhz
	always #(clock_period/2) clock = ~clock;
	
	
	initial begin
		$display("Simulation Start");
		
		
		clock = 0;
		reset = 0;
		next_led = 0;
		serial_reset = 0;
		cLed = 0;
		testCase = 0;
		
		#(2*clock_period);
		reset = 1;
		#(2000);
		reset = 0;
		@(negedge clock);
		
		#(20000);
		
		for (testCase = 0; testCase < 1000; testCase = testCase + 1) begin
			for (cLed = 0; cLed < 200; cLed = cLed + 1) begin
				#(62*clock_period);
				@(negedge clock);
				next_led = 1'b1;
				#(2*clock_period);
				next_led = 1'b0;
			end
			
		
			serial_reset = 1'b1;
			#(2600);
			serial_reset = 1'b0;
		end
		
		$stop;
		
	end
	
	

endmodule