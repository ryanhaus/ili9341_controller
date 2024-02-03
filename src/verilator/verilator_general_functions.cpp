#include "../graphics_lib/general_functions.h"
#include <chrono>
#include <thread>
#include <queue>
#include <mutex>



// sleep_ms
void sleep_ms(uint32_t ms) {
    std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}



// spi_transfer_u32_blocking
std::queue<uint32_t> spi_queue;
std::mutex spi_queue_mutex;

void spi_transfer_u32_blocking(uint32_t data) {
    spi_queue_mutex.lock();
    spi_queue.push(data);
    spi_queue_mutex.unlock();
    
    // NOTE: have to find new solution for this part, but it should work the same without the blocking for simulation
    // while (!spi_queue.empty()) {
    //     asm("NOP");
    // }
}