module display_region_handler #(
    parameter SYNC_SIZE = 1,
    parameter BP_SIZE = 1,
    parameter DISPLAY_SIZE = 1,
    parameter FP_SIZE = 1,
    
    localparam TOTAL_SIZE = SYNC_SIZE + BP_SIZE + DISPLAY_SIZE + FP_SIZE,
    localparam SIZE_BITS = $clog2(TOTAL_SIZE)
) (
    input clk,
    input [SIZE_BITS-1 : 0] position,
    
    output reg sync = 0,
    output reg back_porch = 0,
    output reg display = 0,
    output reg front_porch = 0
);
    always @(*) begin
        sync <=          (position >= 0 && position < SYNC_SIZE);
        back_porch <=    (position >= SYNC_SIZE && position < SYNC_SIZE + BP_SIZE);
        display <=       (position >= SYNC_SIZE + BP_SIZE && position < SYNC_SIZE + BP_SIZE + DISPLAY_SIZE);
        front_porch <=   (position >= SYNC_SIZE + BP_SIZE + DISPLAY_SIZE && position < TOTAL_SIZE);
    end
endmodule
