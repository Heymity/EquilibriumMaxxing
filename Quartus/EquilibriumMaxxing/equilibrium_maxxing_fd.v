module EQUILIBRIUM_MAXXING_FD (
	input	wire clock,
	input	wire reset,
		
	input	wire RX,
		
	input	wire gerar_nova_jogada,
		
	input	wire conta_nivel,
	input	wire reset_nivel,
		
	input	wire fade_trigger,
	
	output wire [1:0] nivel_dificuldade,
	
	output wire serial,
	output wire db_serial,
	
	output wire step,
	output wire dir,
	
	output wire ganhou_ponto,
	output wire perdeu_ponto,
	output wire [9:0] pontuacao,
	
	output wire [31:0] M_eff_db,
	output wire [31:0] mid_idx_db,
	output wire [31:0] max_idx_db
);

	wire signed [15:0] alavanca1;
   wire signed [15:0] alavanca2;
	
	serial2alavanca SERIAL (
		.clock				(clock),
		.reset				(reset),
		.RX					(RX),
			
		.al1Bits				(alavanca1),
		.al2Bits				(alavanca2),
		.db_estado			(),
		.db_estado_serial	()
	);

	hexa7seg HEX1 (
		.hexa		(alavanca1[3:0]),
	   .display	(db_al1_1)
	);
	hexa7seg HEX2 (
		.hexa		(alavanca1[7:4]),
	   .display	(db_al1_2)
	);
	hexa7seg HEX3 (
		.hexa		(alavanca1[11:8]),
	   .display	(db_al1_3)
	);
	hexa7seg HEX4 (
		.hexa		(alavanca1[15:12]),
	   .display	(db_al1_4)
	);

	

	wire [1:0] nivel_dificuldade_interno;
	
	level_register LEVEL_SEL (
		.clock(clock),
		.reset(reset),
		.alavanca1(alavanca1),
		.alavanca2(alavanca2),
		.start_game(gerar_nova_jogada),
		.nivel_reg(nivel_dificuldade_interno)
	);
	
	wire signed [15:0] current_pos;
	wire [31:0] mid_idx, max_idx;
	
	pendulum_driver PEND (
		.clock(clock),
		.reset(reset),
		.al1Bits(alavanca1),
		.al2Bits(alavanca2),
		.step(step),
		.dir(dir),
		.current_pos(current_pos)
	);
	
	wire [2:0] led_alvo;
	
	random_led_controller RAND (
		.clock(clock),
		.reset(reset),
		.gerar_jogada(gerar_nova_jogada),
		.trigger(fade_trigger),
		.contador_jogo(contador_jogo),
		.mid_idx(mid_idx),
		.max_idx(max_idx),
		.nivel_dificuldade(nivel_dificuldade_interno),
	
		.serial(serial),
		.db_serial(db_serial),
	
		.position_led(led_alvo)
	);
	
	wire [9:0] contador_jogo;
	
	jogo_controller JOGO (
		.clock(clock),
		.reset(reset),
	
		.position_led(led_alvo),
		.current_position(current_pos),
	
		.nivel_dificuldade(nivel_dificuldade_interno),
	
		.conta_nivel0(conta_nivel),
		.conta_nivel1(conta_nivel),
		.conta_nivel23(conta_nivel),
	
		.reset_ponto(reset_nivel),
		.reset_nivel0(reset_nivel),
		.reset_nivel1(reset_nivel),
		.reset_nivel23(reset_nivel),
	
		.ganhou_ponto(ganhou_ponto),
		.perdeu_ponto(perdeu_ponto),
		.pontuacao(pontuacao),
	
		.M_eff(M_eff_db),
		.mid_idx(mid_idx),
		.max_idx(max_idx),
		.contador_jogo(contador_jogo)
	);
	
	assign nivel_dificuldade = nivel_dificuldade_interno;
	assign mid_idx_db = mid_idx;
	assign max_idx_db = max_idx;

endmodule
