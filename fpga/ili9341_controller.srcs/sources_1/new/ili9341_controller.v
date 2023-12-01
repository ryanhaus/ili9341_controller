// this module uses a display_handler instance to drive sync signals, and also generates the video output
module ili9341_controller(
    input reset,
    input enable,
    
    input spi_sck,
    input spi_sda,
    
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
    wire [$clog2(240)-1 : 0] tft_next_display_x;
    wire tft_next_display_x_on_screen;
    
    display_handler display_handler_inst (
        .reset(reset),
        .enable(enable),
        .dotclk(tft_dotclk),
        .dotclk_count(dotclk_count),
        .hsync(tft_hsync),
        .vsync(tft_vsync),
        .data_enable(tft_data_enable),
        .display_x(tft_display_x),
        .display_y(tft_display_y),
        .next_display_x(tft_next_display_x),
        .next_display_x_on_screen(tft_next_display_x_on_screen)
    );
    
    
    
    // test: spi memory writing, memory reading for display 
    assign memory_read = tft_next_display_x_on_screen;
    
    spi_video_memory_controller memory_controller_inst(
        .clk(tft_dotclk),
        .reset(reset),
        .spi_sck(spi_sck),
        .spi_sda(spi_sda),
        .display_x(tft_next_display_x),
        .display_y(tft_display_y),
        .memory_read(tft_next_display_x_on_screen),
        .memory_addr(memory_addr),
        .memory_data(memory_data),
        .memory_write(memory_write)
    );
    
    
    
    // for outputting colors to the data bus
    reg [5:0] red;
    reg [5:0] green;
    reg [5:0] blue;
    
    reg [5:0] next_red;
    reg [5:0] next_green;
    reg [5:0] next_blue;
    
    always @(posedge tft_dotclk) begin
        if (dotclk_count == 0) begin
            red = next_red;
            green = next_green;
            blue = next_blue;
        
            next_red = memory_read ? memory_data : 0;
            next_green = 0;
            next_blue = 0;
        end
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