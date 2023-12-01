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

    while (1) {
        while (!fpga_read_vsync()) {
            asm("nop");
        }
        while(fpga_read_vsync()) {
            asm("nop");
        }

        for (int a = 0; a < 100; a++)
            fpga_write_data((uint8_t[]) { rand(), rand(), rand() }, 3);
        //fpga_write_data((uint8_t[]) { i >> 8, i & 0xFF, i % 240 }, 3);
        //i++;
    }
}