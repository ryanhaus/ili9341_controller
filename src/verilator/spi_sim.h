#pragma once

#include "../graphics_lib/spi_transfer.h"
#include <queue>
#include <mutex>
#include <stdint.h>



uint8_t bit_index = 0;
extern std::queue<uint32_t> spi_queue;
extern std::mutex spi_queue_mutex;



bool spi_next_bit() {
    spi_queue_mutex.lock();
    
    bool bit = spi_queue.front() & (0x80000000 >> bit_index);

    bit_index++;
    
    if (bit_index == 32) {
        spi_queue.pop();
        bit_index = 0;
    }

    spi_queue_mutex.unlock();

    return bit;
}