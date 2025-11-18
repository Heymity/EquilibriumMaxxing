`timescale 1ns/1ns

module simulator_tb ();
	
	reg												clock;
	reg												reset;
	
	reg signed [15+precision:0]	 			al1;
	reg signed [15+precision:0] 				al2;
	reg signed [15+precision:0]				g;
	
	wire signed [15:0]							ds;
	wire signed [15:0]							cp;

	localparam precision = 16;
	
	simulator #(
		.simPeriod	(500_000), // 10ms
		.precision	(precision)
	) DUT (
		.clock		(clock	),
		.reset		(reset	),
	   .alavanca1	(al1		),
	   .alavanca2	(al2		),
	   .gravity		(g			),
	   
	   .delta_steps(ds		),
	   .current_pos(cp		)
	);
	
	integer testCase;
	integer i;
	real angle;
	real speed;
	
	parameter clock_period = 20; // clock 50Mhz
	always #(clock_period/2) clock = ~clock;
	
	initial begin
		$display("Simulation Start");
		i = 0;
		clock = 0;
		reset = 0;
		
		al1 = 0;
		al2 = 0;
		g	= 0;
		
		testCase = 0;
		
		#(2*clock_period);
		reset = 1;
		#(2000);
		reset = 0;
		@(negedge clock);
		
		#(20000);
		
		@(negedge DUT.sim_clock);
		g <= 32'h005A_127B; // 90,0721893310546875 ~= 180°/s2 em ponto fixo 16 bits
		
		
		@(posedge DUT.sim_clock);
		
		
		$display("Total Acc           │ Speed              │ Pos                │ Steps/16 │ angle° │ Speed (°/s2)");
		$display("────────────────────┼────────────────────┼────────────────────┼──────────┼────────┼─────────────");
		for (i = 0; i < 50; i = i + 1) begin
			//#(2_500_000*clock_period); //50ms
			#(500_000*clock_period); //10ms
			angle = cp * 0.1125;
			speed = ((DUT.integrated_speed >> precision) * 0.1125 * 50_000_000) / 140737488355328;
			$display("%20h│%20h│%20h│%10d│%8.4f│ %f", DUT.total_acc, DUT.integrated_speed, DUT.integrated_pos, cp, angle, speed);
		end
		
		g <= 32'h0000_0000;
		
		@(posedge DUT.sim_clock);
		
		for (i = 0; i < 50; i = i + 1) begin
			//#(2_500_000*clock_period); //50ms
			#(500_000*clock_period); //10ms
			angle = cp * 0.1125;
			speed = ((DUT.integrated_speed >> precision) * 0.1125 * 50_000_000) / 140737488355328;
			$display("%20h│%20h│%20h│%10d│%8.4f│ %f", DUT.total_acc, DUT.integrated_speed, DUT.integrated_pos, cp, angle, speed);
		end
		
		g <= -32'h005A_127B; // 89_7074 = 180°/s2 em ponto fixo 16 bits
		
		@(posedge DUT.sim_clock);
		
		for (i = 0; i < 50; i = i + 1) begin
			//#(2_500_000*clock_period); //50ms
			#(500_000*clock_period); //10ms
			angle = cp * 0.1125;
			speed = ((DUT.integrated_speed >> precision) * 0.1125 * 50_000_000) / 140737488355328;
			$display("%20h│%20h│%20h│%10d│%8.4f│ %f", DUT.total_acc, DUT.integrated_speed, DUT.integrated_pos, cp, angle, speed);
		end
		
		g <= 32'h00000_000;
		#(500_000*clock_period); //10ms
			angle = cp * 0.1125;
			speed = ((DUT.integrated_speed >> precision) * 0.1125 * 50_000_000) / 140737488355328;
			$display("%20h│%20h│%20h│%10d│%8.4f│ %f", DUT.total_acc, DUT.integrated_speed, DUT.integrated_pos, cp, angle, speed);
		
		@(posedge DUT.sim_clock);
		
		for (i = 0; i < 2; i = i + 1) begin
			#(2_500_000*clock_period); //50ms
			angle = cp * 0.1125;
			speed = ((DUT.integrated_speed >> precision) * 0.1125 * 50_000_000) / 140737488355328;	
			$display("%20h│%20h│%20h│%10d│%8.4f│ %f", DUT.total_acc, DUT.integrated_speed, DUT.integrated_pos, cp, angle, speed);
		end
		
		$finish;
		
	end
	
	



endmodule
