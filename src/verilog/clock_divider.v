// this module divides an input clock by an integer divisor
module clock_divider #(
    parameter DIVISOR = 2,
    localparam COUNTER_BITS = $clog2(DIVISOR)
) (
    input reset,
    input clkin,
    output clkout
);
    reg [COUNTER_BITS-1 : 0] counter = 0;
    assign clkout = (counter >= DIVISOR / 2);

    always @(posedge clkin) begin
        if (reset) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule