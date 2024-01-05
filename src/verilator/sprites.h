#pragma once

#include <stdint.h>
#include "tft_sim.h"
#include "spi_sim.h"



typedef struct {
    uint16_t colors[4];
    uint16_t data[8];
} tft_sprite;



std::array<spi_transfer, 12> sprite_to_spi_transfer(tft_sprite sprite, uint8_t sprite_id) {
    std::array<spi_transfer, 12> transfers;

    // color palette
    for (int i = 0; i < 4; i++) {
        spi_transfer transfer;
        transfer.ram_select = 0;
        transfer.addr = (12 * sprite_id) + i;
        transfer.data = sprite.colors[i];

        transfers[i] = transfer;
    };

    // data
    for (int i = 0; i < 8; i++) {
        spi_transfer transfer;
        transfer.ram_select = 0;
        transfer.addr = (12 * sprite_id) + 4 + i;
        transfer.data = sprite.data[i];

        transfers[4 + i] = transfer;
    }

    return transfers;
}