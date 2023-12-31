// uses 2 counters to count along a 2D rectangle (the display)
module counter_2d #(
    parameter X_MODULUS = 10,
    localparam X_MODULUS_BITS = $clog2(X_MODULUS),
    
    parameter Y_MODULUS = 10,
    localparam Y_MODULUS_BITS = $clog2(Y_MODULUS)
) (
    input clk,
    input enable,
    input reset,
    
    output reg [X_MODULUS_BITS : 0] out_x, // note that the extra bit is for moduli of powers of two
    output reg [Y_MODULUS_BITS : 0] out_y // same as above
);
    always @(posedge clk) begin 
        if (reset) begin
            out_x = 0;
            out_y = 0;
        end else if (enable) begin
            if (out_x + 1 == X_MODULUS) begin
                out_x = 0;
                
                if (out_y + 1 == Y_MODULUS)
                    out_y = 0;
                else
                    out_y = out_y + 1;
            end else begin
                out_x = out_x + 1;
            end
        end  
    end
endmodule
