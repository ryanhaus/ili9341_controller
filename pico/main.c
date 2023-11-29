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
    
    while (1) {
        fpga_write_data((uint8_t[]) { rand(), rand(),  rand() }, 3);
    }
}