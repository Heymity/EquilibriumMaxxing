module EQUILIBRIUM_MAXXING_FD (
	input	wire clock,
	input	wire reset,
		
	input	wire RX,
	
	input	wire start_game,
	input	wire gerar_nova_jogada,
		
	input	wire conta_nivel,
	input	wire reset_nivel,
		
	input	wire fade_trigger,
	
	input   wire calib,
    
    input  wire end_left,
    input  wire end_right,
    input  wire trava_servo,
    input  wire reset_prep_cnt,
    input  wire reset_nivel_locked,
	input  wire external,

	output wire [1:0] nivel_dificuldade,
	output wire prep_done,
	
	output wire serial,
	output wire db_serial,
	
	output wire step,
	output wire dir,
	
	output wire ganhou_ponto,
	output wire perdeu_ponto,
	output wire [7:0] pontuacao,
	
	output wire [9:0] M_eff_db,
	output wire [9:0] mid_idx_db,
	output wire [9:0] max_idx_db,
	
	output wire [27:0] db_al1,
	output wire [27:0] db_al2,
	
	output wire	[6:0] db_estado_serial2alavanca,
	output wire	[6:0] db_estado_serialreceiver,
	
	output wire [15:0] db_current_pos,
	output wire start_game_db,

	output wire [9:0] contador_jogo_db,
	output wire nivel_dificuldade_locked_db,
	output wire [23:0] cor_led_db
);

	wire signed [15:0] alavanca1;
   wire signed [15:0] alavanca2;
	
	assign contador_jogo_db = contador_jogo;
	
	serial2alavanca SERIAL (
		.clock				(clock),
		.reset				(reset),
		.RX					(RX),
			
		.al1Bits				(alavanca1),
		.al2Bits				(alavanca2),
		.db_estado			(db_estado_serial2alavanca),
		.db_estado_serial	(db_estado_serialreceiver)
	);

	hexa7seg HEX1 (
		.hexa		(alavanca1[3:0]),
	   .display	(db_al1[6:0])
	);
	hexa7seg HEX2 (
		.hexa		(alavanca1[7:4]),
	   .display	(db_al1[13:7])
	);
	hexa7seg HEX3 (
		.hexa		(alavanca1[11:8]),
	   .display	(db_al1[20:14])
	);
	hexa7seg HEX4 (
		.hexa		(alavanca1[15:12]),
	   .display	(db_al1[27:21])
	);
	
	hexa7seg HEX12 (
		.hexa		(alavanca2[3:0]),
	   .display	(db_al2[6:0])
	);
	hexa7seg HEX22 (
		.hexa		(alavanca2[7:4]),
	   .display	(db_al2[13:7])
	);
	hexa7seg HEX32 (
		.hexa		(alavanca2[11:8]),
	   .display	(db_al2[20:14])
	);
	hexa7seg HEX42 (
		.hexa		(alavanca2[15:12]),
	   .display	(db_al2[27:21])
	);

	

	wire [1:0] nivel_dificuldade_interno;
	
	level_register LEVEL_SEL (
		.clock(clock),
		.reset(reset_nivel_locked),
		.alavanca1(alavanca1),
		.alavanca2(alavanca2),
		.start_game(start_game),
		.start_game_db(start_game_db),
		.nivel_reg(nivel_dificuldade_interno),
		.nivel_locked_db(nivel_dificuldade_locked_db)
	);
	
	wire signed [15:0] current_pos;
	wire [9:0] mid_idx, max_idx;
	
	assign db_current_pos = current_pos;
	
	wire signed [15:0] al1_drive;
	wire signed [15:0] al2_drive;
	wire calib_done;
	assign calib_done = end_left || end_right;

	pendulum_driver PEND (
		.clock(clock),
		.reset(reset),
		.al1Bits(al1_drive),
		.al2Bits(al2_drive),
		.step(step),
		.dir(dir),
		.current_pos(current_pos),
		.end_left(end_left),
		.end_right(end_right),
		.calib(calib)
	);
	
	wire [3:0] led_alvo;
	
	random_led_controller RAND (
		.clock(clock),
		.reset(reset),
		.gerar_jogada(gerar_nova_jogada),
		.trigger(fade_trigger),
		.contador_jogo(contador_jogo),
		.mid_idx(mid_idx),
		.max_idx(max_idx),
		.nivel_dificuldade(nivel_dificuldade_interno),
		.external(external),
	
		.serial(serial),
		.db_serial(db_serial),
	
		.position_led(led_alvo),
		.cor_led_db(cor_led_db)
	);
	
	wire [9:0] contador_jogo;
	
	jogo_controller JOGO (
		.clock(clock),
		.reset(reset),
	
		.position_led(led_alvo),
		.current_position(current_pos),
	
		.nivel_dificuldade(nivel_dificuldade_interno),
	
		.conta_nivel(conta_nivel),

		.reset_ponto(reset_nivel),
		.reset_nivel(reset_nivel),
	
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

	wire prep_cnt_fim;
	
	contador_m #(.M(500), .N(24)) PREP_COUNTER (
		.clock(clock),
		.zera_as(reset),
		.zera_s(reset_prep_cnt),
		.conta(1'b1),
		.Q(),
		.fim(prep_cnt_fim),
		.meio()
	);
	
	assign prep_done = prep_cnt_fim;

endmodule
