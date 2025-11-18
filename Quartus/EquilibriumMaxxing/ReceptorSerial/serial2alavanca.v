module serial2alavanca(
	input clock,
	input reset,
	input RX,
	
	output reg signed	[15:0]	al1Bits,
	output reg signed	[15:0]	al2Bits,
	
	output [6:0] db_estado,
	output [6:0] db_estado_serial
);

	localparam preambleD = 3'b000;
	localparam preambleA1 = 3'b001;
	localparam preambleT = 3'b010;
	localparam preambleA2 = 3'b011;
	localparam al1LSB 	= 3'b100;
	localparam al1MSB 	= 3'b101;
	localparam al2LSB 	= 3'b110;
	localparam al2MSB 	= 3'b111;
	
	wire receiver_data_ready;
	wire [7:0] dados_ascii;
	
	reg [2:0] Eatual;
	
	reg signed	[15:0]	al1Bits_internal;
	reg signed	[15:0]	al2Bits_internal;	
	
	rx_serial_8N1 SERIAL (
		 .clock      (clock),
		 .reset      (reset),
		 .RX         (RX),
		 
		 .pronto     (receiver_data_ready),
		 .dados_ascii(dados_ascii), 
		 .db_estado		(db_estado_serial)
	);
	
	
	always @(posedge clock) begin
		if (reset) begin
			Eatual <= preambleA1;
			al1Bits_internal <= 0;
			al2Bits_internal <= 0;
		end else begin
				
			if (receiver_data_ready) begin
				case (Eatual) 
					preambleD: 	begin
						Eatual <= dados_ascii == 8'h44 ? preambleA1 		:preambleD;
						al1Bits <= al1Bits_internal;
						al2Bits <= al2Bits_internal;
					end
					preambleA1:	Eatual <= dados_ascii == 8'h41 ? preambleT		:preambleD;
					preambleT: 	Eatual <= dados_ascii == 8'h54 ? preambleA2		:preambleD;
					preambleA2:	Eatual <= dados_ascii == 8'h41 ? al1LSB			:preambleD;
					al1LSB 	:	begin
						Eatual <= al1MSB;
						al1Bits_internal[7:0] <= dados_ascii;
					end
					al1MSB 	:	begin
						Eatual <= al2LSB;
						al1Bits_internal[15:8] <= dados_ascii;
					end
					al2LSB 	:	begin
						Eatual <= al2MSB;
						al2Bits_internal[7:0] <= dados_ascii;
					end
					al2MSB 	:	begin
						Eatual <= preambleD;
						al2Bits_internal[15:8] <= dados_ascii;
					end
				endcase
			end
		end
	end
	
	hexa7seg HEX (
		.hexa		(Eatual),
		.display (db_estado)
	);
 

endmodule