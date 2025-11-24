module EQUILIBRIUM_MAXXING_FD (
	input	wire clock,
	input	wire reset,
		
	input	wire RX,
	
	input	wire start_game,
	input	wire gerar_nova_jogada,
		
	input	wire conta_nivel,
	input	wire reset_nivel,
		
	input	wire fade_trigger,
	
	input   wire calib_start,
    
    input  wire sensorFimCurso,
    input  wire trava_servo,
    input  wire reset_prep_cnt,
    input  wire reset_nivel_locked,
    
    // Test override for alavanca values (when high, FD will use `test_al1/test_al2`)
    input  wire test_override_al,
    input  wire signed [15:0] test_al1,
    input  wire signed [15:0] test_al2,

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
	
	output wire [15:0] db_current_pos
);
	wire signed [15:0] alavanca1_from_serial;
	wire signed [15:0] alavanca2_from_serial;

	serial2alavanca SERIAL (
		.clock			(clock),
		.reset			(reset),
		.RX				(RX),
        
		.al1Bits			(alavanca1_from_serial),
		.al2Bits			(alavanca2_from_serial),
		.db_estado			(db_estado_serial2alavanca),
		.db_estado_serial	(db_estado_serialreceiver)
	);

	// Final alavanca signals: choose serial values or test override values
	wire signed [15:0] alavanca1 = test_override_al ? test_al1 : alavanca1_from_serial;
	wire signed [15:0] alavanca2 = test_override_al ? test_al2 : alavanca2_from_serial;

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
		.nivel_reg(nivel_dificuldade_interno)
	);
	
	wire signed [15:0] current_pos;
	wire [9:0] mid_idx, max_idx;
	
	assign db_current_pos = current_pos;
	
	wire signed [15:0] al1_drive;
	wire signed [15:0] al2_drive;
	wire calib_done;

	pendulum_input_mux INPUT_MUX (
		.alavanca1(alavanca1),
		.alavanca2(alavanca2),
		.calib_start(calib_start),
		.sensorFimCurso(sensorFimCurso),
		.trava_servo(trava_servo),
		.al1_drive(al1_drive),
		.al2_drive(al2_drive),
		.calib_done(calib_done)
	);

	pendulum_driver PEND (
		.clock(clock),
		.reset(reset),
		.al1Bits(al1_drive),
		.al2Bits(al2_drive),
		.step(step),
		.dir(dir),
		.current_pos(current_pos),
		.calib_done(calib_done),
		.calib_start(calib_start)
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
	
	contador_m #(.M(10_000_000), .N(24)) PREP_COUNTER (
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
