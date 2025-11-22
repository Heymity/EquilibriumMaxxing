module pendulum_driver#(
	parameter simPeriod = 500_000, 		// 10ms
	parameter leverADCBits = 16
) (
	input 	clock,
	input		reset,
	
	input 	signed	[leverADCBits-1:0]	al1Bits, // Ponto Fixo 14.2
	input		signed	[leverADCBits-1:0]	al2Bits, // Ponto Fixo 14.2
	input   wire calib_done,
	
	output									step,
	output									dir,

	output	wire	signed 	[15:0] 	current_pos,
	
	output									db_sim_clock_sync
);

	
	
	//wire signed	[leverADCBits-1:0]	al1Bits; // Ponto Fixo 14.2
	//wire signed	[leverADCBits-1:0]	al2Bits; // Ponto Fixo 14.2
	
	//assign al1Bits = 16'd0;
	//assign al2Bits = 16'd0;
	
	
	// Estao como localparam pois se mudar precisa mudar a rom da gravidade ou fazer um shift no valor armazenado.
 	localparam fixedPointBaseBits = 16;
	localparam precision = 16;
 
 
	// alBits PF 14.2 (°/s^2) -> (alDPS) PF 16.24 °/s^2 -> (alSPC) PF 16.16 8,88*2^p/2500MM Step/(16s)
	// 3,55...*2^(47-(14*log_2(10))) = 0,5003999585967217777777777777262 = 0,801A36 base 2
	// Ponto Fixo .24; Precisa ser 64 bits para que a multiplicação seja feita com 64bits e não resulte em overflow
	localparam signed DPS2SPC = 64'sh0000_0000_0080_1A36; 
	
	wire signed	[39:0] 	al1DPS, al2DPS, gDPS;  	// Degree Per Second
	wire signed	[fixedPointBaseBits+precision-1:0] 	al1SPC, al2SPC, gSPC;	// Step Per Clock	
	
	// Sign Extend, Ponto Fixo 14.2 para Ponto fixo 16.24
	assign al1DPS = {{(18-leverADCBits){al1Bits[leverADCBits-1]}}, al1Bits, 22'h000}; 
	// Note que o resultado da multiplição tem 64 bits e está em PF .48, fazemos >> 32 para transformar em PF 16.16
	assign al1SPC = ((al1DPS * DPS2SPC) >> (48 - precision));
	assign al2DPS = {{(18-leverADCBits){al2Bits[leverADCBits-1]}}, al2Bits, 22'h000}; // Idem aos comentarios acima
	assign al2SPC = ((al2DPS * DPS2SPC) >> (48 - precision));						
	
	
	wire										sim_clock_sync;
	wire signed	[fixedPointBaseBits-1:0]	delta_steps;
	
	wire 			[31:0]	gravity;	// PF 16.16
 	wire 			[11:0]	gravity_rom_addr;
	//wire signed	[15:0]	current_pos;
	
	assign db_sim_clock_sync = sim_clock_sync;
	
	wire [11:0]	current_pos_add_when_negative;
	assign current_pos_add_when_negative = 3200+current_pos[11:0];
	assign gravity_rom_addr = current_pos >= 0 ? current_pos[11:0] : current_pos_add_when_negative;
	
	step_controller #(
		.stepTime				(1400				),
		.stepWindow 			(simPeriod		)		
	) STEP_MOTOR_CONTROLLER (
		.clock					(clock			),
		.reset					(reset			),
				
		.send_steps 			(sim_clock_sync),
		.num_steps				(delta_steps	),			//[15:0]
				
		.step						(step				),
		.dir						(dir				)
	);

	simulator #(
		.simPeriod				(simPeriod		), 	
		.fixedPointBaseBits	(fixedPointBaseBits),
		.precision				(precision)
	) SIMULATION_UNIT (
		.clock					(clock			),
		.reset					(reset			),
				
		.alavanca1				(al1SPC			),			//[fixedPointBaseBits+precision-1:0]
		.alavanca2				(al2SPC			),			//[fixedPointBaseBits+precision-1:0]
		.gravity					(gravity			),			//[fixedPointBaseBits+precision-1:0]
				
		.delta_steps			(delta_steps	), 		// step/16 [fixedPointBaseBits-1:0]
		.current_pos			(current_pos	),			// step/16 [fixedPointBaseBits-1:0]
	
		.sync_sim_clock		(sim_clock_sync),
		.calib_done				(calib_done)
	);	
	
	gravity_rom ROM_GRAVIDADE (
		.addr						(gravity_rom_addr	),
		.data_out				(gravity				)
	);
	
endmodule