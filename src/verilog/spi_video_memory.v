// this module takes in a SPI signal and writes to the memory, also allows for reading during display periods
module spi_video_memory # (
    parameter DISPLAY_WIDTH = 240,
    parameter DISPLAY_HEIGHT = 320,
    
    parameter WIDTH_BITS = $clog2(DISPLAY_WIDTH),
    parameter HEIGHT_BITS = $clog2(DISPLAY_HEIGHT)
) (
    input reset,
    input clk,

    output reg dotclk = 0,
    output reg posclk = 0,

    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    input [WIDTH_BITS-1 : 0] display_x,
    input [HEIGHT_BITS-1 : 0] display_y,
    input in_display_region,

    output [15:0] current_pixel
);
    // SPI FIFO
    wire [31:0] spi_data;
    wire spi_fifo_empty;
    wire spi_fifo_full;
    reg spi_fifo_read = 0;

    assign spi_ready = !spi_fifo_full;

    spi_fifo #(
        .BITS(32),
        .FIFO_DEPTH(32)
    ) spi_fifo_inst (
        .clk(clk),
        .sck(spi_sck),
        .sda(spi_sda),
        .read_clk(clk),
        .read_enable(spi_fifo_read),
        .read_data(spi_data),
        .fifo_empty(spi_fifo_empty),
        .fifo_almost_full(),
        .fifo_full(spi_fifo_full)
    );  
    
    

    // split up the spi data into usable memory controlling data
    wire ram_select = spi_data[31]; // 0 for sprite ram, 1 for tile ram
    wire [14:0] write_addr = spi_data[30:16];
    wire [15:0] write_data = spi_data[15:0];



    // memory primitives
    reg mem_wr_en = 0;

    // tile ram
    reg [10:0] tile_ram_addr = 0;
    wire [15:0] tile_ram_data_16;

    wire [7:0] tile_ram_data = (tile_ram_addr[0] == 1 ? tile_ram_data_16[15:8] : tile_ram_data_16[7:0]);

    addr_chained_bram #(
        .BRAM_COUNT(3)
    ) tile_ram_inst(
        .wdata(write_data),
        .waddr(write_addr),
        .wen(mem_wr_en && ram_select),
        .wclk(~clk), // write on falling edge of clk
        .rdata(tile_ram_data_16),
        .raddr(tile_ram_addr[10:1]),
        .ren(in_display_region),
        .rclk(~clk) // read on falling edge of clk
    );

    // sprite ram
    reg [15:0] sprite_ram_addr = 0;
    wire [15:0] sprite_ram_data;

    ice40_spram sprite_ram_inst (
        .clk(~clk), // read/write on falling edge of clk
        .address(mem_wr_en ? write_addr : sprite_ram_addr),
        .data_in(write_data),
        .write_enable(mem_wr_en && ~ram_select),
        .data_out(sprite_ram_data)
    );



    assign current_pixel = sprite_ram_data;



    // for splitting the sprite ram into 8x 2-bit values, 1 for each pixel
    wire [1:0] pixels [7:0];

    genvar i;
    for (i = 0; i < 8; i = i + 1)
        assign pixels[i] = sprite_ram_data[(i * 2 + 1) : (i * 2)];


    // handle memory
    reg [1:0] state = 0;

    always @(posedge clk) begin
        state = state + 1;

        if (in_display_region) begin // we must read from memory
            // set addresses of appropriate memory
            case (state)
                1: tile_ram_addr = (display_x / 8) + ((display_y / 8) * 30);
                2: sprite_ram_addr = (12 * tile_ram_data) + 4 + (display_y % 8);
                3: sprite_ram_addr = (12 * tile_ram_data) + pixels[display_x % 8];
            endcase
        end else begin // we are able to write to memory
            // on posedge of clk, change the memory write enable to reflect if we just read from the fifo
            mem_wr_en = spi_fifo_read;
        end

        // determine when to set dotclk
        if (state == 0)
            dotclk = 1;

        if (state == 2)
            dotclk = 0;
    end

    always @(negedge clk) begin
        if (in_display_region) begin // we must read from memory
            // reading from memory is already handled on negedge
        end else begin // we are able to write to memory
            // on negedge of clk, change the fifo read enable if we can read from fifo
            spi_fifo_read = !spi_fifo_empty;
        end

        // determine when to set posclk
        if (state == 0)
            posclk = 1;

        if (state == 1)
            posclk = 0;
    end
endmodule
