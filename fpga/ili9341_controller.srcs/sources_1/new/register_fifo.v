// this module acts as a customizable FIFO. in the future, switching to the Xilinx IP may be better, but this is more portable
module register_fifo #(
    parameter BITS = 8,
    parameter DEPTH = 32 // must be a power of 2
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
    // read/write addresses
    reg [$clog2(DEPTH)-1 : 0] read_addr = 0;
    reg [$clog2(DEPTH)-1 : 0] write_addr = 0;
    
    wire [$clog2(DEPTH)-1 : 0] next_write_addr = write_addr + 1;
    wire [$clog2(DEPTH)-1 : 0] next_next_write_addr = write_addr + 2;
    
    // the actual memory stored by the FIFO
    reg [BITS-1 : 0] memory [DEPTH-1 : 0];
 
    // status flags   
    assign empty = (write_addr == read_addr);
    assign full = (next_write_addr == read_addr);
    assign almost_full = (next_next_write_addr == read_addr);
    
    // when requested to read, read if not empty
    always @(posedge read_clk) begin
        if (read_enable) begin
            read_data = memory[read_addr];
            
            if (!empty) begin            
                read_addr = read_addr + 1;
            end
        end
    end

    // when requested to write, write if not full
    always @(posedge write_clk) begin
        if (write_enable) begin
            if (!full) begin
                memory[write_addr] = write_data;
                write_addr = write_addr + 1;
            end
        end
    end
endmodule