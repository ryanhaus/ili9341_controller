#include "../graphics_lib/general_functions.h"
#include "hardware/spi.h"


// sleep_ms defined by pico stdlib



void spi_transfer_u32_blocking(uint32_t data) {
    spi_write_blocking(spi0, (uint8_t*)&data, 4);
}
