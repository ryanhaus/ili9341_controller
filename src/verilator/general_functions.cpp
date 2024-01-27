#include "../graphics_lib/general_functions.h"
#include <chrono>
#include <thread>

void wait_ms(uint32_t ms) {
    std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}