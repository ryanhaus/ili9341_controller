// this module just counts over a certain range determined by MODULUUS, also outputs when the last tick is occuring
module counter #(
    parameter MODULUS = 10,
    localparam MODULUS_BITS = $clog2(MODULUS)
) (
    input reset,
    input enable,
    
    input clk,
    
    output reg [MODULUS_BITS-1 : 0] out,
    output reg last_tick = 0
);
    initial out = 0;

    always @(posedge clk) begin 
        if (reset)
            out = 0;
        else if (enable) begin
            if (last_tick) begin
                out = 0;
                last_tick <= 0;
            end else begin
                out = out + 1;
                
                if (out + 1 == MODULUS)
                    last_tick <= 1;
            end             
        end  
    end
endmodule
