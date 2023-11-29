// this module takes in a SPI signal and writes to the memory (designed for IS61WV5128), also allows for reading during display periods
module spi_video_memory_controller #(
    parameter DISPLAY_WIDTH = 240,
    parameter DISPLAY_HEIGHT = 320,
    
    parameter WIDTH_BITS = $clog2(DISPLAY_WIDTH),
    parameter HEIGHT_BITS = $clog2(DISPLAY_HEIGHT)
) (
    input spi_sck,
    input spi_sda,

    input [WIDTH_BITS-1 : 0] display_x,
    input [HEIGHT_BITS-1 : 0] display_y,

    input memory_read,
    
    output reg [15:0] memory_addr,
    inout [7:0] memory_data,
    output reg memory_write
);
    // NOTE: currently, this relies on the memory being written when the memory is not in use (i.e., not in an active frame period)
    // TODO: use a FIFO system to allow SPI data to be transferred during a reading period and written after that period is done    
    reg [7:0] memory_data_reg;
    assign memory_data = memory_write ? memory_data_reg : 8'hz;
    
    wire [23:0] spi_data;
    wire spi_data_ready;
    
    spi_input #(
        .DATA_BITS(24)
    ) spi_color_input_inst (
        .sck(spi_sck),
        .sda(spi_sda),
        .data(spi_data),
        .data_ready(spi_data_ready)
    );
    
    
    
    // split up the spi data into a 16-bit memory address and an 8-bit data to write
    wire [15:0] write_addr;
    wire [7:0] write_data;
    
    assign write_addr = spi_data[23:8];
    assign write_data = spi_data[7:0];
    
    
    
    // write that data when it's ready, ignore if currently in a reading period
    always @(*) begin
        memory_write = 0;
        
        if (memory_read) begin
            memory_addr = display_x + display_y * DISPLAY_WIDTH;
        end else
            if (spi_data_ready) begin
                memory_addr = write_addr;
                memory_data_reg = write_data;
                memory_write = 1;
            end
    end
endmodule
