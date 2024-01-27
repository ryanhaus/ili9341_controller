#pragma once

#include "../graphics_lib/spi_transfer.h"



bool spi_next_bit(spi_inst* inst) {
    bool bit = inst->data_queue.front() & (0x80000000 >> inst->bit_index);

    inst->bit_index++;
    
    if (inst->bit_index == 32) {
        inst->data_queue.pop();
        inst->bit_index = 0;
    }

    return bit;
}