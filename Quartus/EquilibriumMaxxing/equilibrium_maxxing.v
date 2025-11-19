module equilibrium_maxxing (
	input  wire clock,

	input	 wire	RX,
	
	output wire serial,
	output wire db_serial,
	output wire step,
	output wire dir,
	output wire [9:0] pontuacao,
	output wire ganhou_ponto,
	output wire perdeu_ponto,
	
	//output wire [31:0] M_eff_db,
	//output wire [31:0] mid_idx_db,
	//output wire [31:0] max_idx_db
	
	input	wire [9:0] SW,
	
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5
);
	
	wire reset;
	assign reset = SW[9];


	wire [1:0] nivel_dificuldade;
	wire gerar_nova_jogada;
	wire conta_nivel;
	wire reset_nivel;
	wire fade_trigger;
	
	wire ponto_evento = ganhou_ponto | perdeu_ponto;
	
	wire [27:0] db_7seg_alavanca1;
	wire [27:0] db_7seg_alavanca2;
	wire [6:0] db_estado_serial2alavanca;
   wire [6:0] db_estado_serialreceiver;
	wire [15:0] db_current_pos;
	wire [27:0] db_current_pos_7seg;
	
	equilibrium_maxxing_uc UC (
		.clock(clock),
		.reset(reset),
	
		.nivel_dificuldade(nivel_dificuldade),
		.ponto_evento(ponto_evento),
	
		.gerar_nova_jogada(gerar_nova_jogada),
		.conta_nivel(conta_nivel),
		.reset_nivel(reset_nivel),
		.fade_trigger(fade_trigger)
	);
	
	EQUILIBRIUM_MAXXING_FD FD (
		.clock(clock),
		.reset(reset),
	
		.RX(RX),
	
		.gerar_nova_jogada(gerar_nova_jogada),
	
		.conta_nivel(conta_nivel),
		.reset_nivel(reset_nivel),
	
		.fade_trigger(fade_trigger),
	
		.nivel_dificuldade(nivel_dificuldade),
	
		.serial(serial),
		.db_serial(db_serial),
	
		.step(step),
		.dir(dir),
	
		.ganhou_ponto(ganhou_ponto),
		.perdeu_ponto(perdeu_ponto),
		.pontuacao(pontuacao),
	
		.db_al1(db_7seg_alavanca1),
		.db_al2(db_7seg_alavanca2),
		
		.db_estado_serial2alavanca	(db_estado_serial2alavanca	),
		.db_estado_serialreceiver	(db_estado_serialreceiver	),
		
		.db_current_pos(db_current_pos)
		
		//.M_eff_db(M_eff_db),
		//.mid_idx_db(mid_idx_db),
		//.max_idx_db(max_idx_db)
	);
	
	assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = 
		SW[1:0] == 2'b00 ? 	{db_estado_serial2alavanca, db_estado_serialreceiver, db_7seg_alavanca1} :
		SW[1:0] == 2'b01 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, db_7seg_alavanca2} :
		SW[1:0] == 2'b10 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, db_current_pos_7seg} : 42'd0;

	hexa7seg CURRENT_POS_HEX0 (
		.hexa		(db_current_pos[3:0]),
	   .display	(db_current_pos_7seg[6:0])
	);
	hexa7seg CURRENT_POS_HEX1 (
		.hexa		(db_current_pos[7:4]),
	   .display	(db_current_pos_7seg[13:7])
	);
	hexa7seg CURRENT_POS_HEX2 (
		.hexa		(db_current_pos[11:8]),
	   .display	(db_current_pos_7seg[20:14])
	);
	hexa7seg CURRENT_POS_HEX3 (
		.hexa		(db_current_pos[15:12]),
	   .display	(db_current_pos_7seg[27:21])
	);
		
endmodule
