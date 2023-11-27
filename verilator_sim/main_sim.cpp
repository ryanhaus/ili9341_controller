#include <iostream>
#include <verilated.h>
#include <SDL.h>
#include "Vili9341_controller.h"

#define WINDOW_SCALE 2

using namespace std;

#pragma pack(push, 1)
struct Pixel {
    union {
        struct { uint8_t a, b, g, r; };
        struct { uint8_t brightness, colors[3]; };
    };
};

Pixel framebuffer[320 * 240];

int main() {
    // initialize SDL for video
    if(SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cout << "Could not initialize SDL: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create SDL window
    SDL_Window* window = SDL_CreateWindow("ILI9341 Controller", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 240 * WINDOW_SCALE, 320 * WINDOW_SCALE, SDL_WINDOW_SHOWN);

    if (!window) {
        std::cout << "Could not create window: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create SDL renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if (!renderer) {
        std::cout << "Could not create renderer: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create SDL texture for video output
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 240, 320);

    if (!texture) {
        std::cout << "Could not create texture: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create verilator instance of the ILI9341 controller
    Vili9341_controller *top = new Vili9341_controller;

    top->reset = 0;
    top->enable = 1;



    // main loop
    while (true) {
        // close window if X is pressed
        SDL_Event e;
        if (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                break;
            }
        }


        // loop through vsync until it is high
        while (!top->tft_vsync) {
            // cycle clock
            top->tft_dotclk = 0;
            top->eval();
            top->tft_dotclk = 1;
            top->eval();
        }

        unsigned int transfer_count = 0;
        unsigned int pixel = 0;

        // loop through vsync until it is low (frame end)
        while (top->tft_vsync) {
            // cycle clock
            top->tft_dotclk = 0;
            top->eval();
            top->tft_dotclk = 1;
            top->eval();

            // if data enable is high, start sending data to the framebuffer
            if (top->tft_data_enable) {
                int current_color = transfer_count % 3;

                framebuffer[pixel].brightness = 0xFF;
                framebuffer[pixel].colors[current_color] = top->tft_data << 2;

                // if all three colors have been sent, advance to next pixel
                if (transfer_count % 3 == 2) {
                    pixel++;
                }

                transfer_count++;
            }
        }
        

        // at this point, the frame is complete and the texture and screen can be updated
        SDL_UpdateTexture(texture, NULL, framebuffer, 240 * sizeof(Pixel));
        SDL_RenderClear(renderer);
        SDL_RenderCopyEx(renderer, texture, NULL, NULL, 0, NULL, SDL_FLIP_HORIZONTAL);
        SDL_RenderPresent(renderer);
    }

    // free resources
    top->final();
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
