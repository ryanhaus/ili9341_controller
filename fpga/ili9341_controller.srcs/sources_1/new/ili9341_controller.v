// this module uses a display_handler instance to drive sync signals, and also generates the video output
module ili9341_controller(
    input reset,
    input enable,
    
    input spi_sck,
    input spi_sda,
    output spi_ready,
    
    input tft_dotclk,
    
    output tft_hsync,
    output tft_vsync,
    output tft_data_enable,
    output [5:0] tft_data,
    
    output [15:0] memory_addr,
    inout [7:0] memory_data,
    output memory_read,
    output memory_write
);
    // determine sync signals & where we are on the display
    wire [$clog2(240)-1 : 0] tft_display_x;
    wire [$clog2(320)-1 : 0] tft_display_y;
    wire [1:0] dotclk_count;
    wire dotclk_overflow;
    wire [$clog2(240)-1 : 0] tft_next_display_x;
    wire tft_next_display_x_on_screen;
    
    display_handler display_handler_inst (
        .reset(reset),
        .enable(enable),
        .dotclk(tft_dotclk),
        .dotclk_count(dotclk_count),
        .dotclk_overflow(dotclk_overflow),
        .hsync(tft_hsync),
        .vsync(tft_vsync),
        .data_enable(tft_data_enable),
        .display_x(tft_display_x),
        .display_y(tft_display_y),
        .next_display_x(tft_next_display_x),
        .next_display_x_on_screen(tft_next_display_x_on_screen)
    );
    
    
    
    // test: spi memory writing, memory reading for display 
    assign memory_read = tft_data_enable;
    wire memory_write_allowed = !(tft_data_enable || tft_next_display_x_on_screen);
    
    spi_video_memory_controller memory_controller_inst(
        .read_clk(tft_dotclk),
        .write_clk(tft_dotclk),
        .reset(reset),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .spi_ready(spi_ready),
        .display_x(tft_display_x),
        .display_y(tft_display_y),
        .memory_read(memory_read),
        .memory_write_allowed(memory_write_allowed),
        .memory_addr(memory_addr),
        .memory_data(memory_data),
        .memory_write(memory_write)
    );
    
    
    
    // for outputting colors to the data bus
    reg [5:0] red;
    reg [5:0] green;
    reg [5:0] blue;
    
    always @(*) begin
        red = memory_data;
        green = 0;
        blue = 0;
    end
    
    color_mux color_mux_inst(
        .enable(tft_data_enable),
        .selector(dotclk_count),
        .red(red),
        .green(green),
        .blue(blue),
        .data(tft_data)
    );
endmodule