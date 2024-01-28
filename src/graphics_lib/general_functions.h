#pragma once
#include <stdint.h>

// all functions below must have a definition for the platform being compiled to
// i.e., one definition specifically for verilator simulation and one definition for hardware
extern void sleep_ms(uint32_t ms);
extern void spi_transfer_u32_blocking(uint32_t data);