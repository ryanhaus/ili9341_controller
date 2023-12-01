// this module acts as a customizable FIFO. in the future, switching to the Xilinx IP may be better, but this is more portable
module register_fifo #(
    parameter BITS = 8,
    parameter DEPTH = 32 // must be a power of 2
) (
    input read_clk,
    output reg [BITS-1 : 0] read_data,
    
    input write_clk,
    input [BITS-1 : 0] write_data,
    
    output empty,
    output almost_full,
    output full
);
    // read/write addresses
    reg [$clog2(DEPTH)-1 : 0] read_addr = 0;
    reg [$clog2(DEPTH)-1 : 0] write_addr = 0;
    
    // teh actual memory stored by the FIFO
    reg [BITS-1 : 0] memory [DEPTH-1 : 0];
 
    // status flags   
    assign empty = (write_addr == read_addr);
    assign full = (write_addr + 1 == read_addr);
    assign almost_full = (write_addr + 2 == read_addr);
    
    always @(*) begin
        // reading data is asynchronous 
        read_data = memory[read_addr];
    end
    
    // when requested to read, read if not empty
    always @(posedge read_clk) begin
        if (!empty) begin            
            read_addr = read_addr + 1;
        end
    end

    // when requested to write, write if not empty
    always @(posedge write_clk) begin
        if (!full) begin
            memory[write_addr] = write_data;
            write_addr = write_addr + 1;
        end
    end
endmodule