#pragma once

#include "../graphics_lib/spi_transfer.h"
#include <queue>
#include <stdint.h>



uint8_t bit_index = 0;
extern std::queue<uint32_t> spi_queue;



bool spi_next_bit() {
    bool bit = spi_queue.front() & (0x80000000 >> bit_index);

    bit_index++;
    
    if (bit_index == 32) {
        spi_queue.pop();
        bit_index = 0;
    }

    return bit;
}