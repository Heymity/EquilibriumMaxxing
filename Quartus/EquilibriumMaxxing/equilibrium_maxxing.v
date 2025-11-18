module equilibrium_maxxing (
	input  wire clock,
	input  wire reset,

	input	 wire	RX,
	
	output wire serial,
	output wire db_serial,
	output wire step,
	output wire dir,
	output wire [9:0] pontuacao,
	output wire ganhou_ponto,
	output wire perdeu_ponto,
	
	output wire [31:0] M_eff_db,
	output wire [31:0] mid_idx_db,
	output wire [31:0] max_idx_db
);

	wire [1:0] nivel_dificuldade;
	wire gerar_nova_jogada;
	wire conta_nivel;
	wire reset_nivel;
	wire fade_trigger;
	
	wire ponto_evento = ganhou_ponto | perdeu_ponto;
	
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
	
		.M_eff_db(M_eff_db),
		.mid_idx_db(mid_idx_db),
		.max_idx_db(max_idx_db)
	);

endmodule
