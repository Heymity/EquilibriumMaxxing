module contador_m_half #(parameter M=100, N=7)
(
	input  wire          clock,
	input  wire          zera_as,
	input  wire          zera_s,
	input  wire          conta,
	output reg  [N-1:0]  Q,
	output reg           fim,
	output reg           meio
);

	always @(posedge clock or posedge zera_as) begin
		if (zera_as) begin
			Q <= M/2-1'b1;
		end else if (clock) begin
			if (zera_s) begin
				Q <= M/2-1'b1;
			end else if (conta) begin
				if (Q == M-1'b1) begin
				Q <= M/2-1'b1;
				end else begin
				Q <= Q + 1'b1;
				end
			end
		end
	end
	
	always @ (Q)
		if (Q == M-1)   fim = 1;
		else            fim = 0;
	
	always @ (Q)
		if (Q == M/2-1) meio = 1;
		else            meio = 0;
	
endmodule
