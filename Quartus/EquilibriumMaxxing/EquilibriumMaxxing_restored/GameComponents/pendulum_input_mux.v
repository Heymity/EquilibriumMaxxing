module pendulum_input_mux (
    input  wire signed [15:0] alavanca1,
    input  wire signed [15:0] alavanca2,
    input  wire calib_start,
    input  wire sensorFimCurso,
    input  wire trava_servo,

    output reg signed [15:0] al1_drive,
    output reg signed [15:0] al2_drive,
    output wire calib_done
);

    localparam signed [15:0] CALIB_SPEED = 16'sd1000;

    assign calib_done = sensorFimCurso;

    always @(*) begin
        if (calib_start && !sensorFimCurso) begin
            al1_drive = -CALIB_SPEED;
            al2_drive = 0;
        end else if (trava_servo) begin
            al1_drive = 0;
            al2_drive = 0;
        end else begin
            al1_drive = alavanca1;
            al2_drive = alavanca2;
        end
    end

endmodule
