#include "../graphics_lib/general_functions.h"
#include <chrono>
#include <thread>
#include <queue>



// sleep_ms
void sleep_ms(uint32_t ms) {
    std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}



// spi_transfer_u32_blocking
std::queue<uint32_t> spi_queue;

void spi_transfer_u32_blocking(uint32_t data) {
    spi_queue.push(data);
    
    while (!spi_queue.empty()) {
        asm("NOP");
    }
}