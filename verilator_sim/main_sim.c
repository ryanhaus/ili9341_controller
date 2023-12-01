#include <stdio.h>
#include <stdlib.h>
#include <verilated.h>
#include <SDL.h>
#include "Vili9341_verilator.h"
#include "verilated_vcd_c.h"

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

uint8_t VERILATOR_TRACE = 0;

// for tracing
void tick(Vili9341_verilator* top, VerilatedVcdC* m_trace, uint64_t* tick_counter) {
    top->eval();
    
    if (VERILATOR_TRACE)
        m_trace->dump((*tick_counter)++);
}

int main(int argc, char** argv) {
    VERILATOR_TRACE = (argc > 1 && strcmp("--trace", argv[1]) == 0);

    // initialize SDL for video
    if(SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("Could not initialize SDL: %s\n", SDL_GetError());
        return 1;
    }



    // create SDL window
    SDL_Window* window = SDL_CreateWindow("ILI9341 Controller", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 240 * WINDOW_SCALE, 320 * WINDOW_SCALE, SDL_WINDOW_SHOWN);

    if (!window) {
        printf("Could not craete window: %s\n", SDL_GetError());
        return 1;
    }



    // create SDL renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if (!renderer) {
        printf("Could not craete renderer: %s\n", SDL_GetError());
        return 1;
    }



    // create SDL texture for video output
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 240, 320);

    if (!texture) {
        printf("Could not craete texture: %s\n", SDL_GetError());
        return 1;
    }



    // create verilator instance of the ILI9341 controller
    Vili9341_verilator *top = new Vili9341_verilator;
    
    // for tracing
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    Verilated::traceEverOn(1);
    uint64_t tick_counter = 0;

    top->trace(m_trace, 99);
    m_trace->open("trace.vcd");

    uint8_t red = 0;

    srand(time(NULL));

    // main loop
    int frame_counter = 0;

    for (int x = 0; x < 1023; x++) {
        for (int i = 0; i < 24; i++) {
            top->spi_sck = 0;
            top->spi_sda = rand() & 1;
            tick(top, m_trace, &tick_counter);


            
            top->spi_sck = 1;
            tick(top, m_trace, &tick_counter);
        }
    }

    do {
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
            tick(top, m_trace, &tick_counter);
            top->tft_dotclk = 1;
            tick(top, m_trace, &tick_counter);
        }

        unsigned int transfer_count = 0;
        unsigned int pixel = 0;

        // loop through vsync until it is low (frame end)
        while (top->tft_vsync) {
            // cycle clock
            top->tft_dotclk = 0;
            tick(top, m_trace, &tick_counter);
            top->tft_dotclk = 1;
            tick(top, m_trace, &tick_counter);

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
    } while(!VERILATOR_TRACE);

    // free resources
    top->final();
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    // for tracing
    m_trace->close();

    return 0;
}
