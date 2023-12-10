// this module just counts over a certain range determined by MODULUUS, also outputs when the last tick is occuring
module counter #(
    parameter MODULUS = 10,
    localparam MODULUS_BITS = $clog2(MODULUS)
) (
    input reset,
    input enable,
    
    input clk,
    
    output reg [MODULUS_BITS : 0] out = 0, // note that an extra bit is included to account for counters that are powers of 2
    output reg overflow = 0
);
    always @(posedge clk) begin 
        if (reset)
            out = 0;
        else if (enable) begin
            if (out + 1 == MODULUS) begin
                out <= 0;    
                overflow <= 1;
            end else begin
                out <= out + 1;
                overflow <= 0;
            end
        end  
    end
endmodule