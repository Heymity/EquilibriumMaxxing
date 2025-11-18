module contador_m_redux_invertible #(
	parameter M = 100,
	parameter N = 7,
	parameter SCORE_N = 8,
	parameter MIN_M = 10
)
(
	input  wire                 clock,
	input  wire                 zera_as,
	input  wire                 zera_s,
	input  wire                 conta,
	input  wire [SCORE_N-1:0]   score,
	input  wire                 count_up,
	output reg  [N-1:0]         Q,
	output reg                  fim,
	output reg                  inicio,

	//saídas para mixxer de cor
    output wire [31:0]          M_eff_out,
    output wire [31:0]          mid_idx_out,
    output wire [31:0]          max_idx_out
);

localparam integer SCORE_MAX = (1<<SCORE_N) - 1;
wire [31:0] reduction = (SCORE_MAX == 0) ? 0 : ((M - MIN_M) * score) / SCORE_MAX;
wire [31:0] M_eff = M - reduction;
wire [31:0] M_eff_minus1 = (M_eff > 0) ? (M_eff - 1) : 0;
wire [31:0] mid_idx = (M_eff > 0) ? (M_eff/2) : 0;

assign M_eff_out   = M_eff;
assign mid_idx_out = mid_idx;
assign max_idx_out = M_eff_minus1;

always @(posedge clock or posedge zera_as) begin
	if (zera_as) begin
		Q <= mid_idx[N-1:0];
	end else begin
		if (zera_s) begin
			Q <= mid_idx[N-1:0];
		end else if (conta) begin
			if (count_up) begin
				// counting up
				if (Q == M_eff_minus1[N-1:0]) begin
					Q <= 0;
				end else begin
					Q <= Q + 1'b1;
				end
			end else begin
				if (Q == 0) begin
					Q <= M_eff_minus1[N-1:0];
				end else begin
					Q <= Q - 1'b1;
				end
			end
		end
	end
end

always @(*) begin
	fim = (Q == M_eff_minus1[N-1:0]);
	inicio = (Q == 0);
end
	
endmodule
