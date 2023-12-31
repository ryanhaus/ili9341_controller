// this module takes in an SPI input and stores it in a FIFO for later use
module spi_fifo #(
    parameter BITS = 8,
    parameter FIFO_DEPTH = 32,
    parameter FIFO_ALMOST_FULL_RANGE = 2
) (
    input clk, // clock frequency must be greater than sck frequency
    input sck,
    input sda,

    input read_clk,
    input read_enable,
    output [BITS-1 : 0] read_data,

    output fifo_empty,
    output fifo_almost_full,
    output fifo_full
);
    // SPI input
    wire [BITS-1 : 0] spi_data;
    wire spi_data_ready;

    spi_input #(
        .DATA_BITS(BITS)
    ) spi_input_inst (
        .clk(clk),
        .sck(sck),
        .sda(sda),
        .data(spi_data),
        .data_ready(spi_data_ready)
    );



    // FIFO instance
    register_fifo #(
        .BITS(BITS),
        .DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_RANGE(FIFO_ALMOST_FULL_RANGE)
    ) register_fifo_inst (
        .read_clk(read_clk),
        .read_enable(read_enable),
        .read_data(read_data),
        .write_clk(spi_data_ready),
        .write_enable(1),
        .write_data(spi_data),
        .empty(fifo_empty),
        .almost_full(fifo_almost_full),
        .full(fifo_full)
    );
endmodule