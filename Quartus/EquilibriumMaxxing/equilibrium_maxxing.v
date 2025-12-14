module equilibrium_maxxing (
	input  wire clock,

	input  wire start_game,
	input  wire	RX,
	input  wire end_left,
	input  wire end_right,
	
	output wire serial,
	output wire db_serial,
	output wire step,
	output wire dir,
	output wire [7:0] pontuacao,
	
	output wire LED0,
	output wire LED1,
	output wire LED2,
	output wire LED3,
	output wire LED4,

	input	wire [9:0] SW,
	
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5
);
	
	assign LED2 = end_left;
	assign LED3 = end_right;
	assign LED4 = calib_done;
	
	assign reset = SW[9];
	
	wire reset;
	wire [31:0] db_speed;
   wire [31:0] db_acc;
	wire gerar_nova_jogada;
	wire conta_nivel;
	wire reset_nivel;
	wire fade_trigger;
	wire prep_done;
	wire trava_servo;
	wire calib;
	wire reset_prep_cnt;
	wire reset_nivel_locked;
	wire external;
	wire ganhou_ponto;
	wire perdeu_ponto;
	wire start_game_db;
	wire calib_done;
	
	wire ponto_evento = ganhou_ponto | perdeu_ponto;
	
	wire [27:0] db_7seg_alavanca1;
	wire [27:0] db_7seg_alavanca2;
	wire [6:0] db_estado_serial2alavanca;
   wire [6:0] db_estado_serialreceiver;
	wire [6:0] db_estado_uc_geral_7seg;
	wire [2:0] db_estado_uc_geral;
	wire [15:0] db_current_pos;
	wire [27:0] db_current_pos_7seg;
	wire [23:0] cor_led_db;
	wire [41:0] cor_led_db_7seg;
	
	wire [27:0] db_acc_7seg;
	
	wire [28:0] contador_jogo_db;
	wire [27:0] contador_jogo_db_7seg;
	
	wire [27:0] db_speed_7seg;
	
	equilibrium_maxxing_uc UC (
		.clock(clock),
		.reset(reset),
	
		.start_game(!start_game),
		.ponto_evento(ponto_evento),
		.prep_done(prep_done),
		.sensorFimCurso(calib_done),
	
		.gerar_nova_jogada(gerar_nova_jogada),
		.conta_nivel(conta_nivel),
		.reset_nivel(reset_nivel),
		.fade_trigger(fade_trigger),
		.trava_servo(trava_servo),
		.calib(calib),
		.reset_prep_cnt(reset_prep_cnt),
		.reset_nivel_locked(reset_nivel_locked),
		.external(external),
		.db_estado(db_estado_uc_geral)
	);
	
	EQUILIBRIUM_MAXXING_FD FD (
		.clock(clock),
		.reset(reset),
	
		.RX(RX),
	
		.start_game(!start_game),
		.gerar_nova_jogada(gerar_nova_jogada),
	
		.conta_nivel(conta_nivel),
		.reset_nivel(reset_nivel),
	
		.fade_trigger(fade_trigger),

		.calib(calib),

		.end_left(end_left),
		.end_right(end_right),
		.trava_servo(trava_servo),

		.nivel_dificuldade(),
		.prep_done(prep_done),
		.reset_prep_cnt(reset_prep_cnt),
		.reset_nivel_locked(reset_nivel_locked),
		.external(external),
	
		.serial(serial),
		.db_serial(db_serial),
	
		.step(step),
		.dir(dir),
	
		.calib_done(calib_done),
	
		.ganhou_ponto(ganhou_ponto),
		.perdeu_ponto(perdeu_ponto),
		.pontuacao(pontuacao),
	
		.db_al1(db_7seg_alavanca1),
		.db_al2(db_7seg_alavanca2),
		
		.db_estado_serial2alavanca	(db_estado_serial2alavanca	),
		.db_estado_serialreceiver	(db_estado_serialreceiver	),
		
		.db_current_pos(db_current_pos),
		.nivel_dificuldade_locked_db(),
		.start_game_db(start_game_db),
		.contador_jogo_db(contador_jogo_db),
		.cor_led_db(cor_led_db),
		
		.db_speed			(db_speed),
		.db_acc				(db_acc),
		
		.db_isInPostition(LED1)
	);
	
	assign LED0 = calib;
	
	assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = 
		SW[2:0] == 3'b000 ? 	{db_estado_serial2alavanca, db_estado_serialreceiver, db_7seg_alavanca1} :
		SW[2:0] == 3'b001 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, db_7seg_alavanca2} :
		SW[2:0] == 3'b010 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, db_current_pos_7seg} : 
		SW[2:0] == 3'b011 ?	{db_estado_uc_geral_7seg, {35{1'b1}}} :
		SW[2:0] == 3'b100 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, db_acc_7seg} : 
		SW[2:0] == 3'b101 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, db_speed_7seg} :
		SW[2:0] == 3'b110 ?	{db_estado_serial2alavanca, db_estado_serialreceiver, contador_jogo_db_7seg} :
		SW[2:0] == 3'b111 ?	{cor_led_db_7seg}
		: 42'd0;

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

	hexa7seg UC_GERAL (
		.hexa		({1'b0, db_estado_uc_geral}),
	   .display	(db_estado_uc_geral_7seg)
	);
	
	hexa7seg ACC0 (
		.hexa		(db_acc[3:0]),
	   .display	(db_acc_7seg[6:0])
	);
	hexa7seg ACC1 (
		.hexa		(db_acc[7:4]),
	   .display	(db_acc_7seg[13:7])
	);
	hexa7seg ACC2 (
		.hexa		(db_acc[11:8]),
	   .display	(db_acc_7seg[20:14])
	);
	hexa7seg ACC3 (
		.hexa		(db_acc[15:12]),
	   .display	(db_acc_7seg[27:21])
	);
	
	hexa7seg SPEED0 (
		.hexa		(db_speed[3:0]),
	   .display	(db_speed_7seg[6:0])
	);
	hexa7seg SPEED1 (
		.hexa		(db_speed[7:4]),
	   .display	(db_speed_7seg[13:7])
	);
	hexa7seg SPEED2 (
		.hexa		(db_speed[11:8]),
	   .display	(db_speed_7seg[20:14])
	);
	hexa7seg SPEED3 (
		.hexa		(db_speed[15:12]),
	   .display	(db_speed_7seg[27:21])
	);
	
	hexa7seg CONT_JOGO_0 (
		.hexa		(contador_jogo_db[19:16]),
	   .display	(contador_jogo_db_7seg[6:0])
	);
	hexa7seg CONT_JOGO_1 (
		.hexa		(contador_jogo_db[23:20]),
	   .display	(contador_jogo_db_7seg[13:7])
	);
	hexa7seg CONT_JOGO_2 (
		.hexa		(contador_jogo_db[27:24]),
	   .display	(contador_jogo_db_7seg[20:14])
	);
	hexa7seg CONT_JOGO_3 (
		.hexa		(contador_jogo_db[28]),
	   .display	(contador_jogo_db_7seg[27:21])
	);
	hexa7seg RGB_0 (
		.hexa		(cor_led_db[3:0]),
	   .display	(cor_led_db_7seg[6:0])
	);
	hexa7seg RGB_1 (
		.hexa		(cor_led_db[7:4]),
	   .display	(cor_led_db_7seg[13:7])
	);
	hexa7seg RGB_2 (
		.hexa		(cor_led_db[11:8]),
	   .display	(cor_led_db_7seg[20:14])
	);
	hexa7seg RGB_3 (
		.hexa		(cor_led_db[15:12]),
	   .display	(cor_led_db_7seg[27:21])
	);
	hexa7seg RGB_4 (
		.hexa		(cor_led_db[19:16]),
	   .display	(cor_led_db_7seg[34:28])
	);
	hexa7seg RGB_5 (
		.hexa		(cor_led_db[23:20]),
	   .display	(cor_led_db_7seg[41:35])
	);

endmodule
