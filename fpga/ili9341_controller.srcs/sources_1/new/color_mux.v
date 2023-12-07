// this module takes in a signal for each color (RGB) and outputs which one should be on the data bus based on the selector (dotclk counter)
module color_mux #(
    parameter BITS_DATA = 6
)
(
    input clk,
    input enable,
    input [1:0] selector,
    input [BITS_DATA-1 : 0] red,
    input [BITS_DATA-1 : 0] green,
    input [BITS_DATA-1 : 0] blue,
    output reg [BITS_DATA-1 : 0] data
);
    always @(posedge clk) begin
        if (enable)
            case (selector)
                2'd0: data = blue;
                2'd1: data = green;
                2'd2: data = red;
                default: data = 0;
            endcase
        else data = 0;     
   end 
endmodule
