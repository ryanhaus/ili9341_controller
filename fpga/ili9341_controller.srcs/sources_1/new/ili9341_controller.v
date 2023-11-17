module ili9341_controller #(
    parameter HSYNC_WIDTH = 10,
    parameter HBP_WIDTH = 20,
    parameter DISPLAY_WIDTH = 240,
    parameter HFP_WIDTH = 10,
    
    parameter VSYNC_HEIGHT = 2,
    parameter VBP_HEIGHT = 2,
    parameter DISPLAY_HEIGHT = 320,
    parameter VFP_HEIGHT = 4
) (
    input dotclk,
    
    output hsync,
    output vsync,
    output data_enable,
    output [17:0] data
);
    // calculate total scan width and heights, including sync periods, front/back porches, and display areas
    localparam TOTAL_WIDTH = HSYNC_WIDTH + HBP_WIDTH + DISPLAY_WIDTH + HFP_WIDTH;
    localparam TOTAL_HEIGHT = VSYNC_HEIGHT + VBP_HEIGHT + DISPLAY_HEIGHT + VFP_HEIGHT;
    
    // calculate number of bits required to store total width/height
    localparam WIDTH_BITS = $clog2(TOTAL_WIDTH);
    localparam HEIGHT_BITS = $clog2(TOTAL_HEIGHT);

    // counters to hold the current pixel position on the screen
    wire [WIDTH_BITS-1 : 0] tft_x;
    wire [HEIGHT_BITS-1 : 0] tft_y;

    counter_2d #(
        .X_MODULUS(TOTAL_WIDTH),
        .Y_MODULUS(TOTAL_HEIGHT)
    ) lcd_counter (
        .clk(dotclk),
        .enable(1'b1),
        .reset(1'b0),
        .out_x(tft_x),
        .out_y(tft_y)
    );
    
    // to determine sync signals and if we're in the display region
    wire in_horiz_display;
    wire in_vert_display;
    assign data_enable = (in_horiz_display && in_vert_display);
    
    
    
    wire in_hsync;
    assign hsync = ~in_hsync;
    
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
    
    
    
    wire in_vsync;
    assign vsync = ~in_vsync;
    
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
    
    
    
    // test: color gradients
    reg [5:0] red;
    reg [5:0] green;
    reg [5:0] blue;
    
    always @(*) begin
        red = (tft_x - (HSYNC_WIDTH + HBP_WIDTH));
        green = (tft_y - (VSYNC_HEIGHT + VBP_HEIGHT));
        blue = 6'b0;
    end
    
    assign data = { red, green, blue };
endmodule
