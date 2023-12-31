#include <stdint.h>



typedef struct {
    uint32_t* data;
    size_t data_size;

    size_t data_index;
    uint8_t bit_index;

    bool done;
} spi_inst;



spi_inst spi_init(uint32_t* data, size_t data_size) {
    spi_inst inst;
    inst.data = data;
    inst.data_size = data_size;

    inst.data_index = 0;
    inst.bit_index = 0;

    inst.done = false;

    return inst;
}



bool spi_next_bit(spi_inst* inst) {
    bool bit = inst->data[inst->data_index] & (0x80000000 >> inst->bit_index);

    inst->bit_index++;
    
    if (inst->bit_index == 32) {
        inst->bit_index = 0;
        inst->data_index++;

        if (inst->data_index == inst->data_size) {
            inst->done = true;
        }
    }

    return bit;
}