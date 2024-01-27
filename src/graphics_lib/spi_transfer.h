#pragma once

#include <stdint.h>


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







extern void spi_transfer_data_blocking(uint32_t data);