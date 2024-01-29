#pragma once
#include "spi_transfer.h"
#include <stdint.h>
#include <array>



#define RGB565_TO_U16(r, g, b) (uint16_t)((((r & 0xF8) >> 3) << 11) | (((g & 0xFC) >> 2) << 5) | ((b & 0xF8) >> 3))
#define INDEX8_TO_U16(i0, i1, i2, i3, i4, i5, i6, i7) (uint16_t)((i0 << 14) | (i1 << 12) | (i2 << 10) | (i3 << 8) | (i4 << 6) | (i5 << 4) | (i6 << 2) | i7)



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