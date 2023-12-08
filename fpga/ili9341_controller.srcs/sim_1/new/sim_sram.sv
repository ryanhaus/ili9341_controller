// this module simulates the IS61WV5128 chip found on the CMOD A7-35T board
module sim_sram #(
    parameter ADDR_BITS = 19,
    parameter DATA_BITS = 8,
    localparam MEM_SIZE = 2 ** ADDR_BITS
) (
    input clk,

    // address and data buses
    input [ADDR_BITS-1 : 0] mem_addr,
    inout [DATA_BITS-1 : 0] mem_data,
    
    // control signals, active high (NOTE: on the actual chip, these are active low. this is handled in the top.v module)
    input mem_read,
    input mem_write
);
    // the actual memory contents of the chip
    reg [DATA_BITS-1 : 0] memory [MEM_SIZE-1 : 0];    
    
    // handle what the data bus is being used for
    reg [DATA_BITS-1 : 0] mem_data_reg;
    assign mem_data = mem_read ? mem_data_reg : { DATA_BITS { 1'bz }};
    
    
    
    // handle reading
    always @(*) begin
        mem_data_reg = memory[mem_addr];
    end
    
    
    
    // handle writing
    always @(posedge mem_write) begin
        memory[mem_addr] = mem_data;
    end
endmodule
