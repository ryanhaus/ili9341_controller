#pragma once

#include <stdint.h>
#include "tft_sim.h"
#include "spi_sim.h"



typedef struct {
    uint16_t colors[4];
    uint16_t data[8];
} tft_sprite;



tft_sprite bitmap_to_sprite(uint8_t bitmap[8], uint16_t off_color = 0x0000, uint16_t on_color = 0xFFFF) {
    tft_sprite sprite;

    sprite.colors[0] = off_color;
    sprite.colors[1] = on_color;


    for (int col = 0; col < 8; col++) {
        for (int row = 0; row < 8; row++) {
            uint8_t current_pixel = (bitmap[col] >> row) & 0b1;

            sprite.data[col] |= current_pixel << (2 * row);
        }
    }
    

    return sprite;
}


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