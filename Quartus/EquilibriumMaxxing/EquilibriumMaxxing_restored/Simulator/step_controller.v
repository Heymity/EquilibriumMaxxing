module step_controller #(
	parameter 			stepTime = 2000,
	parameter			stepWindow = 500_000 // 10ms
) (
	input 				clock,
	input					reset,
	
	input							send_steps,
	input	signed [15:0]		num_steps,
	
	output wire			step,
	output reg			dir
);


	reg								send_steps_prev;
	reg	[15:0]					stepsCounter;
	reg	[15:0]					stepsToSend;
	reg 	[31:0]					counter;
	localparam period = 10000;
	
	assign step = (counter < stepTime) & (stepsCounter <= stepsToSend);
	
	always @(posedge clock) begin
		if (reset) begin
			counter 	<= 0;
			stepsCounter <= 0;
			stepsToSend <= 0;
			send_steps_prev <= 0;
		end else begin
			if (stepsCounter <= stepsToSend) begin
				if (counter >= period) begin
					counter <= 0;
					stepsCounter <= stepsCounter + 1'b1;
				end else begin
					counter <= counter + 1'b1;
				end
			end
			
			send_steps_prev <= send_steps;
			if (send_steps & !send_steps_prev) begin
				stepsCounter <= 0;
				if (num_steps < 0) begin
					dir <= 0;
					stepsToSend <= -num_steps;
				end else begin
					dir <= 1;
					stepsToSend <= num_steps;
				end
				counter <= period/2;
			end
		end
	end


endmodule


/*module step_controller #(
	parameter 			stepTime = 1400,
	parameter			stepWindow = 500_000 // 10ms
) (
	input 				clock,
	input					reset,
	
	input							send_steps,
	input	signed [15:0]		num_steps,
	
	output wire			step,
	output reg			dir
);


	reg								send_steps_prev;
	reg	[31:0]					windowCounter;
	reg 	[31:0]					counter;
	reg 	[31:0]					period;
	
	assign step = counter < stepTime;
	
	always @(posedge clock) begin
		if (reset) begin
			counter 	<= 0;
			period 	<= 32'hFFFFFFFF;
		end else begin
			if (windowCounter < stepWindow - stepTime) begin
				windowCounter <= windowCounter + 1'b1;
				
				if (counter >= period) begin
					counter <= 0;
				end else begin
					counter <= counter + 1'b1;
				end
			end
			
			send_steps_prev <= send_steps;
			if (send_steps & !send_steps_prev) begin
				windowCounter <= 1'b1;
				if (num_steps == 32'd0) begin
					period <= 32'hFFFFFFFF;
				end else begin
					if (num_steps < 0) begin
						period <= (stepWindow - stepTime)/ (-num_steps);
						dir <= 0;
					end else begin
						period <= (stepWindow - stepTime)/ num_steps;
						dir <= 1;
					end
					counter <= 0;
				end
			end
		end
	end


endmodule*/