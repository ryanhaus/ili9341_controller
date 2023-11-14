# ili9341_controller
A controller for a TFT display with a [ILI9341 display controller](https://cdn-shop.adafruit.com/datasheets/ILI9341.pdf), specifically the [MI0283QT-11](https://www.adafruit.com/product/1774). This design uses a Raspberry Pi Pico programmed in C to initialize the display and a Digilent CMOD A7-35T FPGA board programmed in Verilog to control it. Future plans include to remove the Pico and have the FPGA initialize the display as well.

## Photos
Here is the circuit as it is currently on a breadboard, without the display:
![](pictures/ili9341_breadboard.jpg)

Here is the circuit with the display connected & driven to be solid red:
![](pictures/ili9341_breadboard_display.jpg)