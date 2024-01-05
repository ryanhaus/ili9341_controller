// manually inferring bram
module ice40_bram (
    input [15:0] wdata,
    input [7:0] waddr,
    input wen,
    input wclk,
    
    output reg [15:0] rdata,
    input [7:0] raddr,
    input ren,
    input rclk
);

    `ifdef VERILATOR // for simulation
        reg [15:0] mem [0:255];

        always @(posedge wclk) begin
            if (wen) begin
                mem[waddr] <= wdata;
            end
        end

        always @(posedge rclk) begin
            if (ren) begin
                rdata <= mem[raddr];
            end
        end
    `else // for synthesis
        SB_RAM40_4K bram_inst (
            .RDATA(rdata),
            .RADDR(raddr),
            .RCLK(rclk),
            .RE(ren),
            .WADDR(waddr),
            .WCLK(wclk),
            .WE(wen),
            .MASK(16'hffff),
            .WDATA(wdata)
        );
    `endif

endmodule