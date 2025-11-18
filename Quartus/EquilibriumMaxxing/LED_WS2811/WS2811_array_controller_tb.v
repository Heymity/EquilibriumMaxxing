`timescale 1ns/1ns


module WS2811_array_controller_tb ();


	reg				clock;
	reg				reset;
	reg				enable;
	reg [7:0]		led_count;
	
	wire				serial;

	WS2811_array_controller DUT(
		.clock			(clock),
		.reset			(reset),
	
		.led_count		(led_count),
		.enable			(enable),
	
		.serial			(serial)
	);
	
	integer testCase;
	
	parameter clock_period = 20; // clock 50Mhz
	always #(clock_period/2) clock = ~clock;
	
	
	initial begin
		$display("Simulation Start");
		
		clock = 0;
		reset = 0;
		enable = 0;
		led_count = 8'd200;
		
		testCase = 0;
		
		#(2*clock_period);
		reset = 1;
		#(2000);
		reset = 0;
		@(negedge clock);
		
		#(20000);
		enable = 1;
		#(100_000_000); 
		
		
		$stop;
		
	end


endmodule