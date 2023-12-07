// this module just counts over a certain range determined by MODULUUS, also outputs when the last tick is occuring
module counter #(
    parameter MODULUS = 10,
    localparam MODULUS_BITS = $clog2(MODULUS)
) (
    input reset,
    input enable,
    
    input clk,
    
    output reg [MODULUS_BITS : 0] out, // note that an extra bit is included to account for counters that are 
    output reg overflow = 0
);
    initial out = 0;

    always @(posedge clk) begin 
        if (reset)
            out = 0;
        else if (enable) begin
            // start off with the overflow flag being low, and increase the couter
            overflow = 0;
            out = out + 1;
            
            // if our counter has reached the modulus, then set the overflow flag and reset counter back to zero
            if (out == MODULUS) begin
                overflow = 1;
                out = 0;    
            end
        end  
    end
endmodule
