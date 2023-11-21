// this module keeps track of the current position in the display and also drives the synchronization signals
module display_handler #(
    // information about number of clocks per pixel
    parameter CLKS_PER_PIXEL = 3,
    
    // information about the sync periods along the horizontal axis
    parameter HSYNC_WIDTH = 10,
    parameter HBP_WIDTH = 20,
    parameter DISPLAY_WIDTH = 240,
    parameter HFP_WIDTH = 10,
    
    // information about the syn periods along the vertical axis
    parameter VSYNC_HEIGHT = 2,
    parameter VBP_HEIGHT = 2,
    parameter DISPLAY_HEIGHT = 320,
    parameter VFP_HEIGHT = 4,
    
    // number of bits required to store the x and y positions relative to the displayed region, bit widths of display_x and display_y respectively
    // note that tft_x and tft_y are used internally to count the position relative to the whole sync region
    parameter DISPLAY_WIDTH_BITS = $clog2(DISPLAY_WIDTH),
    parameter DISPLAY_HEIGHT_BITS = $clog2(DISPLAY_HEIGHT)
) (
    input reset,
    input enable,
    
    input dotclk,
    
    output [$clog2(CLKS_PER_PIXEL)-1 : 0] dotclk_count,
    
    output hsync,
    output vsync,
    output data_enable,
    
    output [DISPLAY_WIDTH_BITS-1 : 0] display_x,
    output [DISPLAY_HEIGHT_BITS-1 : 0] display_y
);
    // calculate total scan width and heights, including sync periods, front/back porches, and display areas
    localparam TOTAL_WIDTH = HSYNC_WIDTH + HBP_WIDTH + DISPLAY_WIDTH + HFP_WIDTH;
    localparam TOTAL_HEIGHT = VSYNC_HEIGHT + VBP_HEIGHT + DISPLAY_HEIGHT + VFP_HEIGHT;
    
    // calculate number of bits required to store total width/height
    localparam WIDTH_BITS = $clog2(TOTAL_WIDTH);
    localparam HEIGHT_BITS = $clog2(TOTAL_HEIGHT);



    // counter to keep track of when to advance the pixel counter
    wire dotclk_last_tick;
    
    counter #(
        .MODULUS(CLKS_PER_PIXEL)
    ) dotclk_counter (
        .reset(reset),
        .enable(enable),
        .clk(dotclk),
        .out(dotclk_count),
        .last_tick(dotclk_last_tick)
    );



    // counters to hold the current pixel position on the screen
    wire [WIDTH_BITS-1 : 0] tft_x;
    wire [HEIGHT_BITS-1 : 0] tft_y;

    counter_2d #(
        .X_MODULUS(TOTAL_WIDTH),
        .Y_MODULUS(TOTAL_HEIGHT)
    ) lcd_counter (
        .clk(dotclk),
        .enable(enable && dotclk_last_tick),
        .reset(reset),
        .out_x(tft_x),
        .out_y(tft_y)
    );
    
    // to determine sync signals and if we're in the display region
    wire in_horiz_display;
    wire in_vert_display;
    assign data_enable = (in_horiz_display && in_vert_display); // data is enabled when we're in the display region, active high signal
    
    
    
    // for determining horizontal sync signals
    wire in_hsync;
    assign hsync = ~in_hsync; // the display is active low for hsync
    
    display_region_handler #(
        .SYNC_SIZE(HSYNC_WIDTH),
        .BP_SIZE(HBP_WIDTH),
        .DISPLAY_SIZE(DISPLAY_WIDTH),
        .FP_SIZE(HFP_WIDTH)
    ) horiz_display_region_handler_inst (
        .clk(dotclk),
        .position(tft_x),
        .sync(in_hsync),
        .back_porch(),
        .display(in_horiz_display),
        .front_porch()
    );
    
    
    
    // for determining vertical sync signals
    wire in_vsync;
    assign vsync = ~in_vsync; // the display is active low for vsync
    
    display_region_handler #(
        .SYNC_SIZE(VSYNC_HEIGHT),
        .BP_SIZE(VBP_HEIGHT),
        .DISPLAY_SIZE(DISPLAY_HEIGHT),
        .FP_SIZE(VFP_HEIGHT)
    ) vert_display_region_handler_inst (
        .clk(dotclk),
        .position(tft_y),
        .sync(in_vsync),
        .back_porch(),
        .display(in_vert_display),
        .front_porch()
    );
    
    
    
    // determine where we are relative to the display
    assign display_x = tft_x - (HSYNC_WIDTH + HBP_WIDTH);
    assign display_y = tft_y - (VSYNC_HEIGHT + VBP_HEIGHT);
endmodule
