#include "../graphics_lib/sprites.h"
tft_sprite smiley_sprite = {
	{ RGB565_TO_U16(0, 0, 0), RGB565_TO_U16(255, 233, 127), RGB565_TO_U16(255, 216, 0), RGB565_TO_U16(0, 0, 0) },
	{ INDEX8_TO_U16(0, 0, 2, 2,2, 2, 0, 0), INDEX8_TO_U16(0, 2, 1, 1,1, 1, 2, 0), INDEX8_TO_U16(2, 1, 0, 1,1, 0, 1, 2), INDEX8_TO_U16(2, 1, 1, 1,1, 1, 1, 2), INDEX8_TO_U16(2, 1, 0, 0,0, 0, 1, 2), INDEX8_TO_U16(2, 1, 1, 0,0, 1, 1, 2), INDEX8_TO_U16(0, 2, 1, 1,1, 1, 2, 0), INDEX8_TO_U16(0, 0, 2, 2,2, 2, 0, 0),  }
};
