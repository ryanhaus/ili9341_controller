// takes in a one-dimensional position and outputs which 'region' that position is in based on the parameters
module display_region_handler #(
    parameter SYNC_SIZE = 1,
    parameter BP_SIZE = 1,
    parameter DISPLAY_SIZE = 1,
    parameter FP_SIZE = 1,
    
    localparam TOTAL_SIZE = SYNC_SIZE + BP_SIZE + DISPLAY_SIZE + FP_SIZE,
    localparam SIZE_BITS = $clog2(TOTAL_SIZE)
) (
    input enable,
    input [SIZE_BITS-1 : 0] position,
    
    output reg sync,
    output reg back_porch,
    output reg display,
    output reg front_porch
);
    always @(*) begin
        if (enable) begin
            /* verilator lint_off UNSIGNED */
            sync =          (position >= 0 && position < SYNC_SIZE);
            back_porch =    (position >= SYNC_SIZE && position < SYNC_SIZE + BP_SIZE);
            display =       (position >= SYNC_SIZE + BP_SIZE && position < SYNC_SIZE + BP_SIZE + DISPLAY_SIZE);
            front_porch =   (position >= SYNC_SIZE + BP_SIZE + DISPLAY_SIZE && position < TOTAL_SIZE);
        end
    end
endmodule
