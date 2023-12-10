// this module handles outputting data through UART
module uart_out #(
    parameter CLOCKS_PER_BIT = 10
) (
    input reset,
    input enable,

    input clk,
    
    input [7:0] data_in,
    input start_transfer,
  
  	output bit_clk,
  
    output reg uart_out = 1,
    output reg transfer_active = 0
);
    // set up a counter to determine when to send a new bit
   	counter #(
        .MODULUS(CLOCKS_PER_BIT)
    ) bit_clk_counter_inst (
        .reset(reset),
        .enable(enable),
        .clk(clk),
        .out(),
        .overflow(bit_clk)
    );

    // set up a counter to count which bit of the frame we are currently sending
    wire [3:0] uart_bit_count;
    wire uart_bit_counter_overflow;

    counter #(
        .MODULUS(10)
    ) uart_bit_counter_inst (
        .reset(reset),
        .enable(enable && transfer_active),
        .clk(bit_clk),
        .out(uart_bit_count),
        .overflow(uart_bit_counter_overflow)  
    );
    
    // to keep track of when to start the transfer
    reg prev_start_transfer = 0;
    
  	always @(posedge bit_clk) begin
        // determine when to start a transfer
        if (start_transfer == 1 && prev_start_transfer == 0)
            transfer_active = 1;
             
        prev_start_transfer = start_transfer;
        
        // handle the transfer if there's currently one active
        if (transfer_active) begin
            case (uart_bit_count)
                // start bit
                4'd0: uart_out = 0;
                
                // stop bit
                4'd9: begin
                    uart_out = 1;
                    transfer_active = 0;
                end             
                
                // any of the data bits
                default: begin
                    uart_out = data_in[uart_bit_count - 1];
                end
            endcase
        end
    end
endmodule