// manually inferred address-chained bram
module addr_chained_bram #(
    parameter BRAM_COUNT = 1,
    parameter EXTRA_ADDR_BITS = $clog2(BRAM_COUNT),
    parameter ADDR_BITS = 8 + EXTRA_ADDR_BITS
) (
    input [15:0] wdata,
    input [ADDR_BITS-1 : 0] waddr,
    input wen,
    input wclk,
    
    output reg [15:0] rdata,
    input [ADDR_BITS-1 : 0] raddr,
    input ren,
    input rclk
);
    reg [15:0] rdatas [BRAM_COUNT-1 : 0];

    // NOTE: this is a workaround for yosys complaining about a combinatorial loop, may have to be fixed since ren is not considered
    assign rdata = rdatas[raddr[ADDR_BITS-1 : 8]];
    /*always @(*) begin
        if (ren) begin
            rdata <= rdatas[raddr[ADDR_BITS-1 : 8]];
        end
    end*/

    genvar i;

    generate
        for (i = 0; i < BRAM_COUNT; i = i + 1) begin : bram
            ice40_bram bram_inst (
                .wdata(wdata),
                .waddr(waddr[7:0]),
                .wen(wen && (waddr[ADDR_BITS-1 : 8] == i)),
                .wclk(wclk),
                
                .rdata(rdatas[i]),
                .raddr(raddr[7:0]),
                .ren(ren && (raddr[ADDR_BITS-1 : 8] == i)),
                .rclk(rclk)
            );
        end
    endgenerate
endmodule