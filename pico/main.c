#include <stdlib.h>
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

#include "tft_interface.h"
#include "fpga_interface.h"

uint8_t red = 0;

int main() {
    tft_init();
    fpga_init();
    
    uint16_t i = 0;

    for (int frame = 0; frame < 10; frame++) {
        while (!fpga_read_vsync()) {
            asm("nop");
        }
        while(fpga_read_vsync()) {
            asm("nop");
        }
    }

    while (1) {
        fpga_write_data((uint8_t[]) { i >> 8, i & 0xFF, i % 240 }, 3);
        i++;
    }
}