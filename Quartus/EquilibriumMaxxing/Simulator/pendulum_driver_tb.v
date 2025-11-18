`timescale 1ns/1ns

module pendulum_driver_tb ();
	
	reg								clock;
	reg								reset;
	
	reg signed [15:0]	 			al1;
	reg signed [15:0] 			al2;
	
	wire 								step;
	wire								dir;
	
	localparam precision = 16;
	
	pendulum_driver #(
		.simPeriod	(500_000), // 10ms
		.leverADCBits(16)
	) DUT (
		.clock		(clock	),
		.reset		(reset	),
		
	   .al1Bits		(al1		),
	   .al2Bits		(al2		),
	   
	   .step			(step		),
		.dir			(dir		)
	);
	
	integer testCase;
	integer i, s, j, st;
	real angle;
	real speed;
	real g;
	
	parameter clock_period = 20; // clock 50Mhz
	always #(clock_period/2) clock = ~clock;
	
	initial begin
		$timeformat(-3, 3, " ms", 15); 
		$display("Simulation Start");
		i = 0;
		clock = 0;
		reset = 0;
		
		al1 = 0;
		al2 = 0;
		
		testCase = 0;
		
		#(2*clock_period);
		reset = 1;
		#(2000);
		reset = 0;
		DUT.SIMULATION_UNIT.integrated_pos[16+47+16-1:47+16] = 16'd0;
		//al1 <= -16'h0010; // 89_7074 = 180°/s2 em ponto fixo 16 bits
		
		
		
		$display("Time           │ Total Acc          │ Speed              │ Pos                │ Delta    │ Gravity  │ Steps/16 │ angle° │ Speed (°/s2)");
		$display("───────────────┼────────────────────┼────────────────────┼────────────────────┼──────────┼──────────┼──────────┼────────┼─────────────");
		for (i = 0; i < 5000; i = i + 1) begin
			
			@(posedge DUT.sim_clock_sync);
			
			g = ((DUT.SIMULATION_UNIT.gravity) * 0.1125 * 50_000_000 * 50_000_000 / (1 << precision)) / 64'd140737488355328;
			angle = DUT.SIMULATION_UNIT.current_pos * 0.1125;
			speed = ((DUT.SIMULATION_UNIT.integrated_speed / (1 << precision)) * 0.1125 * 50_000_000) / 64'd140737488355328;
			$display("%t│%20h│%20h│%20h│%10d│%10d│%10d│%8.4f│ %f", $realtime, DUT.SIMULATION_UNIT.total_acc, DUT.SIMULATION_UNIT.integrated_speed, DUT.SIMULATION_UNIT.integrated_pos, DUT.delta_steps, g, DUT.SIMULATION_UNIT.current_pos, angle, speed);
		
			
		end
		
		$finish;
		
	end
	
	




endmodule
