// this module takes in an SPI input and converts it into usable data of width DATA_BITS
module spi_input #(
    parameter DATA_BITS = 8
) (
    input clk, // clk frequency must be greater than sck frequency
    input sck,
    input sda,
    
    output reg [DATA_BITS-1 : 0] data = 0,
    output reg data_ready = 0
);
    localparam COUNTER_BITS = $clog2(DATA_BITS); // number of bits required to store DATA_BITS (for counters)
    reg [COUNTER_BITS : 0] bit_counter = 0; // counts through the bits, increments each positive SCK, is used for data_ready, extra bit for overflow detection
    reg [COUNTER_BITS-1 : 0] i; // counts through the bits, but is used internally for the shift register

    reg transfer_has_occured = 0; // flag indicating if at least one transfer has occured

    always @(posedge sck) begin
        // shift data left 1 bit, insert new SDA data into LSB
        for (i = DATA_BITS - 1; i > 0; i = i - 1) begin
            data[i] = data[i - 1];
        end
        
        data[0] = sda;

        // increase bit counter or reset
        bit_counter = bit_counter + 1;

        if (bit_counter == DATA_BITS) begin
            bit_counter = 0;
            transfer_has_occured = 1;
        end
    end


    reg [COUNTER_BITS : 0] last_bit_counter = 0; // stores the value of bit_counter from the previous clock cycle
    always @(posedge clk) begin
        // set data_ready when bit_counter has recently become 0, but only when at least 1 transfer has already occured
        if (transfer_has_occured)
            data_ready = data_ready ? 0 : (last_bit_counter != 0 && bit_counter == 0);

        // store the current bit_counter value for use in the next clock cycle
        last_bit_counter = bit_counter;
    end
endmodule