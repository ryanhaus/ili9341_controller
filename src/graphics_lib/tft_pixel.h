#pragma once


// data structure for a single pixel in RGB565 format
#pragma pack(push, 1)
struct tft_pixel {
    uint16_t
        b5 : 5,
        g6 : 6,
        r5 : 5;
};
#pragma pack(pop)