module gravity_rom #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12
) (
    input wire [ADDR_WIDTH-1:0] addr,
    output wire [DATA_WIDTH-1:0] data_out
);
    reg [DATA_WIDTH-1:0] rom_array [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemh("rom_gravidade_30cm_PF4bits.hex", rom_array, 0, (1<<ADDR_WIDTH)-1); 
    end

	 assign data_out = rom_array[addr];

endmodule