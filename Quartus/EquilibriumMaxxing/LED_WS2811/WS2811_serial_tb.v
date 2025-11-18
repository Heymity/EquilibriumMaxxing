`timescale 1ns/1ns


module WS2811_serial_tb ();

	reg	 [23:0] 	rgb_data;
	reg				clock;
	reg				reset;
	reg				send;
	
	wire				serial;
	wire				word_sent;

	WS2811_serial DUT (
		.clock		(clock	),
		.reset		(reset	),
	
		// Input
		.rgb_data	(rgb_data),
		.send			(send		),
	
		// Output
		.serial		(serial	),
		.word_sent	(word_sent)
	);
	
	integer testCase;
	
	parameter clock_period = 20; // clock 50Mhz
	always #(clock_period/2) clock = ~clock;
	
	reg [31:0] casos [0:7];
	
	
	initial begin
		$display("Simulation Start");
		
		casos[0] = 24'hFF0000; // Red
		casos[1] = 24'h00FF00; // Green
		casos[2] = 24'h0000FF; // Blue
		casos[3] = 24'hF0F0F0;
		casos[4] = 24'h000000;
		casos[5] = 24'hFFFFFF; 
		casos[6] = 24'h81AB01; 
		casos[7] = 24'h010000; 
		
		
		clock = 0;
		reset = 0;
		send = 0;
		
		testCase = 0;
		
		#(2*clock_period);
		reset = 1;
		#(2000);
		reset = 0;
		@(negedge clock);
		
		#(20000);
		
		for (testCase = 0; testCase < 8; testCase = testCase + 1) begin
			$display("Caso %0d", testCase);
					
			rgb_data = casos[testCase];
			@(negedge clock);
			send = 1;
			
			
			wait (word_sent == 1'b1);
			
			send = 0;
			#(1000);
	
		end
		
		$stop;
		
	end
	
	

endmodule