module WS2811_rgb_wave_provider (
	input 				clock,
	input 				reset,
	input 				advance,
	input 				serial_reset,
	
	output wire [23:0] rgb
);

	/*
	
	HSV -> RGB	S = 1, V = 1, 0<=H<360
	X = 1*(1-|H/60°%2 - 1|)*255 = (255-|(H*0,016667 % 2)*255 - 255|)
	
	(r',g',b') 	= (255	,X		,0),  0<H<60        	+
					= (X		,255	,0),  60<H<120		  	-
					= (0		,255	,X),  120<H<180		+
					= (0		,X		,255),  180<H<240		-
					= (X		,0		,255),  240<H<300		+
					= (255	,0		,X),  300<H<360		-
	
	((r'), (g'), (b'))
	
	Vê-se que R,G e B são tres ondas trapezoidais
	*/
	
	reg 	[7:0] r, g, b; 
	reg 	[2:0]	selector;
	
	reg	[31:0] clk_div;
	
	wire 	[7:0] sum_source;
	
	wire 	[7:0] sum_out;
	
	wire			sum_255;
	wire			sum_0;
	
	assign 	rgb			= {r,g,b};
	
	assign 	sum_source 	= 	selector == 3'b000 ?
										g : selector == 3'b001 ?
										r : selector == 3'b010 ?
										b : selector == 3'b011 ?
										g : selector == 3'b100 ?
										r : selector == 3'b101 ?
										b : 8'h00;
								
	assign 	sum_out 		= 	selector[0] == 1'b0 ? sum_source + 1'b1 : sum_source - 1'b1;
	
	assign	sum_255		= 	&sum_out;
	assign	sum_0			=	&(~sum_out);
	

	always @(posedge clock) begin
		if (reset) begin
			r	 				<= 8'hFF;	
			g	 				<= 8'h00;	
			b	 				<= 8'h00;	
			selector 		<= 3'b000;	
			clk_div			<= 32'd0;
		end else begin
			if(advance) begin
				clk_div <= clk_div + 1'b1;
			end
			if (clk_div >= 1000) begin
				clk_div <= 0;
				case (selector) 
					3'b000: begin
						g <= sum_out;
						if (sum_255) selector <= 3'b001;
					end 
					3'b011: begin
						g <= sum_out;
						if (sum_0) selector <= 3'b100;
					end 
						
					3'b001: begin
						r <= sum_out;
						if (sum_0) selector <= 3'b010;
					end
					3'b100: begin
						r <= sum_out;
						if (sum_255) selector <= 3'b101;
					end
						
					3'b010: begin
						b <= sum_out;
						if (sum_255) selector <= 3'b011;
					end
					3'b101: begin
						b <= sum_out;
						if (sum_0) selector <= 3'b000;
					end 
						
					default: selector <= 3'b000;
				endcase
			end
		end
	end


endmodule