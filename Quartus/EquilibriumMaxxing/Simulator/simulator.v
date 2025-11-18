module simulator #(
	parameter simPeriod = 500_000, // 10ms
	parameter fixedPointBaseBits = 16,
	parameter precision = 16
) (
	input 																	clock,
	input																		reset,
	input signed 		[fixedPointBaseBits+precision-1:0]	 	alavanca1,
	input signed 		[fixedPointBaseBits+precision-1:0] 		alavanca2,
	input signed 		[fixedPointBaseBits+precision-1:0]		gravity,
	
	output reg signed [fixedPointBaseBits-1:0]					delta_steps, 			// step/16
	output reg signed [fixedPointBaseBits-1:0]					current_pos,			// step/16

	output wire																sync_sim_clock
);

	reg signed 			[fixedPointBaseBits+   precision-1:0]	total_acc; 				// step/16(2^precision) clk2
	reg signed 			[fixedPointBaseBits+24+precision-1:0]	integrated_speed;		// step/16(2^precision) clk	
	reg signed 			[fixedPointBaseBits+47+precision-1:0]	integrated_pos;		// step/16(2^precision)   
	
	reg [31:0] sim_clock_counter;
	reg sim_clock;
	
	assign sync_sim_clock = sim_clock;
	

	always @(posedge clock or posedge reset) begin
		if (reset) begin
			sim_clock		 		<= 1'b0;
			sim_clock_counter 	<= 32'd0;
		end else begin
			if (sim_clock_counter >= simPeriod/2) begin
				sim_clock_counter <= 32'd0;
				sim_clock <= ~sim_clock;
			end else begin
				sim_clock_counter <= sim_clock_counter + 1'b1;
			end			
		end
	end
	
	always @(posedge sim_clock or posedge reset) begin
		if (reset) begin
			total_acc			<= {(precision + fixedPointBaseBits     ){1'b0}};
			integrated_speed	<= {(precision + fixedPointBaseBits + 24){1'b0}};
			integrated_pos		<= {(precision + fixedPointBaseBits + 47){1'b0}};
			current_pos		 	<= {fixedPointBaseBits{1'b0}};
			delta_steps		 	<= {fixedPointBaseBits{1'b0}};
		end else begin
			total_acc			=	(alavanca1 + alavanca2 + gravity);
			
			integrated_speed 	= integrated_speed + (total_acc * simPeriod);
			integrated_pos 	= integrated_pos + (integrated_speed * simPeriod);
			
			delta_steps 		= integrated_pos[fixedPointBaseBits+47+precision-1:47+precision] - current_pos; 

			current_pos 		= integrated_pos[fixedPointBaseBits+47+precision-1:47+precision];
		end
	end
	

endmodule