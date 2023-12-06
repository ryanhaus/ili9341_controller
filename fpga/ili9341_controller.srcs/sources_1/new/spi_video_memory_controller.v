// this module takes in a SPI signal and writes to the memory (designed for IS61WV5128), also allows for reading during display periods
module spi_video_memory_controller #(
    parameter DISPLAY_WIDTH = 240,
    parameter DISPLAY_HEIGHT = 320,
    
    parameter WIDTH_BITS = $clog2(DISPLAY_WIDTH),
    parameter HEIGHT_BITS = $clog2(DISPLAY_HEIGHT)
) (
    input clk,
    input reset,

    input spi_sck,
    input spi_sda,
    output spi_ready,

    input [WIDTH_BITS-1 : 0] display_x,
    input [HEIGHT_BITS-1 : 0] display_y,

    input memory_read,
    input memory_write_allowed,
    
    output [15:0] memory_addr,
    inout [7:0] memory_data,
    output memory_write
);
    reg memory_write_en = 0;
    assign memory_write = memory_write_en && clk;
    
    reg [7:0] memory_data_reg;
    assign memory_data = memory_write_en ? memory_data_reg : 8'hz;
    
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
    
    
    
    // pixel FIFO--allows SPI transfer during read period
    wire fifo_empty;
    wire [23:0] fifo_dout;
    reg fifo_rd_en = 0;
    wire fifo_full;
    wire fifo_almost_full;
    assign spi_ready = ~(fifo_almost_full || fifo_full); // tells the microprocessor when data is ready
    
    register_fifo #(
        .BITS(24),
        .DEPTH(256)
    ) pixel_fifo_inst (
        .read_clk(clk && fifo_rd_en),
        .read_data(fifo_dout),
        .write_clk(spi_data_ready),
        .write_data(spi_data),
        .empty(fifo_empty),
        .full(fifo_full),
        .almost_full(fifo_almost_full)
    );
    
    
    
    // split up the spi data into a 16-bit memory address and an 8-bit data to write
    wire [15:0] write_addr;
    wire [7:0] write_data;
    
    assign write_addr = spi_data[23:8];
    assign write_data = spi_data[7:0];
    
    
    
    // memory control
    reg [15:0] memory_addr_read;
    reg [15:0] memory_addr_write;
    assign memory_addr = memory_read ? memory_addr_read : memory_addr_write;
    
    always @(*) begin
        // if we're reading, then set the memory address to the appropriate value
        if (memory_read)
            memory_addr_read = display_x + display_y * DISPLAY_WIDTH;
    end
    
    
    
    always @(posedge clk) begin
        // by default, we don't want to read from the FIFO or write to the memory
        fifo_rd_en = 0;
        memory_write_en = 0;
    
        // unless if there's data in the FIFO, then process it by reading from the FIFO and writing to memory
        if (!fifo_empty) begin
            if (memory_write_allowed) begin
                fifo_rd_en = 1;
                memory_addr_write = fifo_dout[23:8];
                memory_data_reg = fifo_dout[7:0];
                memory_write_en = 1;
            end
        end
    end
endmodule
