// manually inferring spram, since yosys was trying to infer everything as bram
module ice40_spram (
    input clk,
    input [13:0] address,
    input [15:0] data_in,
    input write_enable,
    output reg [15:0] data_out
);
`ifdef VERILATOR // for simulation
    reg [15:0] mem [0:16383];

    always @(posedge clk) begin
        if (write_enable) begin
            mem[address] <= data_in;
        end

        data_out <= mem[address];
    end
`else // for synthesis
    SB_SPRAM256KA spram_inst (
        .ADDRESS(address),
        .DATAIN(data_in),
        .MASKWREN(16'hffff),
        .WREN(write_enable),
        .CHIPSELECT(1),
        .CLOCK(clk),
        .STANDBY(0),
        .SLEEP(0),
        .POWEROFF(0),
        .DATAOUT(data_out)
    );
`endif 
endmodule