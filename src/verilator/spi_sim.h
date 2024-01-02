#pragma once

#include <queue>
#include <stdint.h>



typedef struct {
    std::queue<uint32_t> data_queue;

    size_t data_index;
    uint8_t bit_index;
} spi_inst;



typedef struct {
    union {
        uint32_t transfer_data;

        struct {
            uint32_t
                data : 16,
                addr : 15,
                ram_select : 1;
        };
    };
} spi_transfer;



spi_inst spi_init() {
    spi_inst inst;
    inst.data_queue = std::queue<uint32_t>();

    inst.data_index = 0;
    inst.bit_index = 0;

    return inst;
}



bool spi_next_bit(spi_inst* inst) {
    bool bit = inst->data_queue.front() & (0x80000000 >> inst->bit_index);

    inst->bit_index++;
    
    if (inst->bit_index == 32) {
        inst->data_queue.pop();
        inst->bit_index = 0;
    }

    return bit;
}