// this module takes in a SPI signal and writes to the memory, also allows for reading during display periods
module spi_video_memory # (
    parameter DISPLAY_WIDTH = 240,
    parameter DISPLAY_HEIGHT = 320,
    parameter SPRITE_SIZE = 8, // must be a power of 2 and a common factor of both DISPLAY_WIDTH and DISPLAY_HEIGHT
    
    parameter WIDTH_BITS = $clog2(DISPLAY_WIDTH),
    parameter HEIGHT_BITS = $clog2(DISPLAY_HEIGHT)
) (
    input reset,
    input clk,

    output reg dotclk = 0,
    output reg advance_pixel = 0,

    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    input [WIDTH_BITS-1 : 0] display_x,
    input [HEIGHT_BITS-1 : 0] display_y,
    input in_display_region,

    output reg [15:0] current_pixel
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
        .read_clk(spi_fifo_read),
        .read_enable(~in_display_region),
        .read_data(spi_data),
        .fifo_empty(spi_fifo_empty),
        .fifo_almost_full(),
        .fifo_full(spi_fifo_full)
    );  
    
    

    // split up the spi data into usable memory controlling data
    wire ram_select = spi_data[31]; // 0 for sprite ram, 1 for tile ram
    wire [14:0] write_addr = spi_data[30:16];
    wire [15:0] write_data = spi_data[15:0];



    // memory for storing sprite and tile data
    localparam SPRITE_MEM_SIZE = 256 * SPRITE_SIZE * SPRITE_SIZE;
    localparam SPRITE_MEM_ADDR_BITS = $clog2(SPRITE_MEM_SIZE);
    localparam TILE_MEM_SIZE = (DISPLAY_WIDTH / SPRITE_SIZE) * (DISPLAY_HEIGHT / SPRITE_SIZE);
    localparam TILE_MEM_ADDR_BITS = $clog2(TILE_MEM_SIZE);

    reg [SPRITE_MEM_ADDR_BITS-1 : 0] sprite_addr;
    reg [TILE_MEM_ADDR_BITS-1 : 0] tile_addr;
    wire [15:0] sprite_data;
    reg [7:0] tile_data;

    reg [7:0] tile_mem [0 : TILE_MEM_SIZE-1];

    reg sprite_mem_wr_en = 0;

    ice40_spram sprite_mem_inst (
        .clk(clk),
        .address(sprite_addr),
        .data_in(write_data),
        .write_enable(~ram_select && sprite_mem_wr_en),
        .data_out(sprite_data)
    );



    // handle memory accessing
    reg [1:0] state = 0;

    always @(posedge clk) begin
        if (in_display_region)
            case (state)
                0: tile_data = tile_mem[tile_addr];
                // sprite data writing is handled already
            endcase

        case (state)
            0: dotclk = 0;
            2: dotclk = 1;
        endcase

        state = state + 1;

        advance_pixel = (state == 0);
    end

    always @(negedge clk) begin
        sprite_mem_wr_en = 0;

        if (in_display_region)
            case (state)
                0: tile_addr = ((display_x / SPRITE_SIZE) + (display_y / SPRITE_SIZE) * (DISPLAY_WIDTH / SPRITE_SIZE));
                1: sprite_addr = tile_data * SPRITE_SIZE * SPRITE_SIZE + (display_x % SPRITE_SIZE) + (display_y % SPRITE_SIZE) * SPRITE_SIZE;
                2: current_pixel = sprite_data;
            endcase
        else
            if (!spi_fifo_empty)
                case (state)
                    0, 2: begin
                        spi_fifo_read = 1;
                    end
                    1, 3: begin
                        if (spi_fifo_read)
                            if (ram_select)
                                tile_mem[write_addr] = write_data;
                            else begin
                                sprite_addr = write_addr;
                                sprite_mem_wr_en = 1;
                            end

                        spi_fifo_read = 0;
                    end
                endcase
    end
endmodule
