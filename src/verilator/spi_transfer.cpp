#include "../graphics_lib/spi_transfer.h"
#include <stdio.h>
#include <queue>



std::queue<uint32_t> spi_queue;



void spi_transfer_data_blocking(uint32_t data) {
    printf("spi_transfer_data_blocking: %08x\n", data);
    spi_queue.push(data);
    
    while (!spi_queue.empty()) {
        asm("NOP");
    }
}