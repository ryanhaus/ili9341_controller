// this module acts as a customizable FIFO. in the future, switching to the IP may be better, but this is more portable
module register_fifo #(
    parameter BITS = 8,
    parameter DEPTH = 32,
    parameter ALMOST_FULL_RANGE = 2,

    parameter ADDR_BITS = $clog2(DEPTH)
) (
    input read_clk,
    input read_enable,
    output reg [BITS-1 : 0] read_data,
    
    input write_clk,
    input write_enable,
    input [BITS-1 : 0] write_data,
    
    output empty,
    output almost_full,
    output full
);
    // memory for storing FIFO data
    reg [ADDR_BITS-1 : 0] read_addr = 0;
    reg [ADDR_BITS-1 : 0] write_addr = 0;

    reg [BITS-1 : 0] memory [DEPTH-1 : 0];

    // generate full/empty signals
    assign empty = (read_addr == write_addr);
    assign full = (read_addr == write_addr + 1);
    assign almost_full = (read_addr == write_addr + ALMOST_FULL_RANGE);



    // handle FIFO addresses and reading/writing
    always @(posedge write_clk) begin
        if (write_enable && !full) begin
            memory[write_addr] = write_data;
            write_addr = write_addr + 1;
        end
    end

    always @(posedge read_clk) begin
        if (read_enable && !empty) begin
            read_data = memory[read_addr];
            read_addr = read_addr + 1;
        end
    end
endmodule
