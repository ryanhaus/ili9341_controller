// this module takes in an SPI input and converts it into usable data of width DATA_BITS
module spi_input #(
    parameter DATA_BITS = 8
) (
    input sck,
    input sda,
    
    output reg [DATA_BITS-1 : 0] data = 0,
    output reg data_ready
);
    localparam COUNTER_BITS = $clog2(DATA_BITS); // number of bits required to store DATA_BITS (for counters)
    reg [COUNTER_BITS-1 : 0] bit_counter = 0; // counts through the bits, increments each positive SCK, is used for data_ready
    reg [COUNTER_BITS-1 : 0] i; // counts through the bits, but is used internally for the shift register

    always @(posedge sck) begin
        data_ready = 0; // initially set the data as not ready
    
        // shift data right 1 bit, insert new SDA data into MSB
        for (i = DATA_BITS - 1; i > 0; i = i - 1) begin
            data[i] = data[i - 1];
        end
        
        data[0] = sda;
        
        // increase bit counter. if it hits DATA_BITS, then the data is ready and it can be reset
        bit_counter = bit_counter + 1;
        
        if (bit_counter == DATA_BITS) begin
            bit_counter = 0;
            data_ready = 1;
        end
    end
endmodule
