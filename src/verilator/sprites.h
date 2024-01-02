#pragma once

#include <stdint.h>
#include "tft_sim.h"
#include "spi_sim.h"



typedef struct {
    union {
        tft_pixel pixels[8][8];
        uint16_t data[64];
    };
} tft_sprite;



tft_sprite bitmap_to_sprite(uint8_t data[8]) {
    tft_sprite sprite;

    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            bool white = (data[i] & (0x80 >> j));
            sprite.data[8 * i + j] = (white ? 0xFFFF : 0x0000);
        }
    }

    return sprite;
}



std::array<spi_transfer, 64> sprite_to_spi_transfer(tft_sprite sprite, uint8_t sprite_id) {
    std::array<spi_transfer, 64> transfers;

    for (int i = 0; i < 64; i++) {
        spi_transfer transfer;
        transfer.ram_select = 0;
        transfer.addr = sprite_id * 64 + i;
        transfer.data = sprite.data[i];

        transfers[i] = transfer;
    }

    return transfers;
}