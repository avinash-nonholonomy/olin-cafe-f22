`default_nettype none
`timescale 1ns / 100ps

`include "ft6206_defines.sv"
`include "ili9341_defines.sv"

// Etch-a-sketch lab main module.
module main(
  // On board signals
  sysclk, buttons, leds, rgb, pmod,
  // Display signals
  interface_mode,
  touch_i2c_scl, touch_i2c_sda, touch_irq,
  backlight, display_rstb, data_commandb,
  display_csb, spi_mosi, spi_miso, spi_clk
);
parameter SYS_CLK_HZ = 12_000_000; // aka ticks per second
parameter SYS_CLK_PERIOD_NS = (1_000_000_000/SYS_CLK_HZ);
parameter CLK_HZ = 10*SYS_CLK_HZ; // aka ticks per second
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter PWM_PERIOD_US = 100; 
parameter PWM_WIDTH = $clog2(320);
parameter PERIOD_MS_FADE = 100;
parameter DISPLAY_WIDTH = 240;
parameter DISPLAY_HEIGHT = 320;
localparam VRAM_L = DISPLAY_HEIGHT*DISPLAY_WIDTH;
parameter VRAM_W = 16;

//Module I/O and parameters
input wire sysclk;
wire clk;
input wire [1:0] buttons;
logic rst; always_comb rst = buttons[0]; // Use button 0 as a reset signal.
output logic [1:0] leds;
output logic [2:0] rgb;
output logic [7:0] pmod;  always_comb pmod = {6'b0, sysclk, clk}; // You can use the pmod port for debugging, add more signals here if you want to scope them.

// Display driver signals
output wire [3:0] interface_mode;
output wire touch_i2c_scl;
inout wire touch_i2c_sda;
input wire touch_irq;
output wire backlight, display_rstb, data_commandb;
output wire display_csb, spi_clk, spi_mosi;
input wire spi_miso;

`ifdef SIMULATION
assign clk = sysclk;
`else 
// This project wants a faster clock. The MMCME2 module is built in to the FPGA can can generate higher clock frequencies from a base clock. Check out [UG953](https://docs.xilinx.com/r/2021.2-English/ug953-vivado-7series-libraries/MMCME2_BASE) if you want to learn more about how this works.
wire clk_feedback;
MMCME2_BASE #(
  .BANDWIDTH("OPTIMIZED"),
  .CLKFBOUT_MULT_F(64.0), //2.0 to 64.0 in increments of 0.125
  .CLKIN1_PERIOD(SYS_CLK_PERIOD_NS),
  .CLKOUT0_DIVIDE_F(12.5), // Divide amount for CLKOUT0 (1.000-128.000).
  .DIVCLK_DIVIDE(1), // Master division value (1-106)
  .CLKOUT0_DUTY_CYCLE(0.5),.CLKOUT0_PHASE(0.0),
  .STARTUP_WAIT("FALSE") // Delays DONE until MMCM is locked (FALSE, TRUE)
)
MMCME2_BASE_inst (
.CLKOUT0(clk),
.CLKIN1(sysclk),
.PWRDWN(0),
.RST(buttons[1]),
.CLKFBOUT(clk_feedback),
.CLKFBIN(clk_feedback)
);

`endif // SIMULATION

// Touch signals
touch_t touch0, touch1;

`define LAB_PART_1 // Uncomment once you start working on the next parts.

/* ------------------------------------------------------------------------- */
/* -- Part 1 - Intro to Sequential Logic on FPGAs                         -- */
/* ------------------------------------------------------------------------- */
// Some useful timing signals.
wire pulse_1Hz;
pulse_generator #(.N($clog2(CLK_HZ/1))) PULSE_1Hz (
  .clk(clk), .rst(rst), .ena(1'b1), .out(pulse_1Hz),
  .ticks(CLK_HZ/1)
);

wire pulse_10Hz;
pulse_generator #(.N($clog2(CLK_HZ/10))) PULSE_10Hz (
  .clk(clk), .rst(rst), .ena(1'b1), .out(pulse_10Hz),
  .ticks(CLK_HZ/10)
);

wire pulse_100Hz;
pulse_generator #(.N($clog2(CLK_HZ/100))) PULSE_100Hz (
  .clk(clk), .rst(rst), .ena(1'b1), .out(pulse_100Hz),
  .ticks(CLK_HZ/100)
);
wire [PWM_WIDTH-1:0] triangle0, triangle1;
triangle_generator #(.N(PWM_WIDTH)) LED_FADER0 (
  .clk(clk), .rst(rst), .ena(pulse_10Hz), .out(triangle0)
);

triangle_generator #(.N(PWM_WIDTH)) LED_FADER1 (
  .clk(clk), .rst(rst), .ena(pulse_100Hz), .out(triangle1)
);

logic [PWM_WIDTH-1:0] led_pwm0, led_pwm1;
pwm #(.N(PWM_WIDTH)) PWM_LED0 (
  .clk(clk), .rst(rst), .ena(1'b1), .step(1'b1), .duty(led_pwm0),
  .out(leds[0])
);
pwm #(.N(PWM_WIDTH)) PWM_LED1 (
  .clk(clk), .rst(rst), .ena(1'b1), .step(1'b1), .duty(led_pwm1),
  .out(leds[1])
);

`define LAB_PART_1
always_comb begin: led_pwm_muxes
`ifdef LAB_PART_1
  // For part 1, use the output of the triangle generators.
  led_pwm0 = triangle0;
  led_pwm1 = triangle1;
`else
  // For parts 2+, it's helpful to see the touch signals on the LEDs.
  led_pwm0 = touch0.valid ? touch0.x : 0;
  led_pwm1 = touch0.valid ? touch0.y : 0;
`endif // LAB_PART_1
end

always_comb begin: rgb_leds
  rgb = 3'b110; // RGB leds are active low, so this sets the LEDs to blue.
  // Feel free to add more logic here as a debugging signal!
end


/* ------------------------------------------------------------------------- */
/* -- Part 2 - Option A - SPI control of the ili9341                      -- */
/* ------------------------------------------------------------------------- */

assign backlight = 1; // Note, you can PWM this pin to change the display brightness, but I don't recommend you start with that, I've had students trying to debug working display HDL because the real problem was that the PWM didn't work.

ILI9341_color_t vram_rd_data;

ili9341_display_controller ILI9341(
  .clk(clk), .rst(rst), .ena(1'b1), .display_rstb(display_rstb), .interface_mode(interface_mode),
  .spi_csb(display_csb), .spi_clk(spi_clk), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
  .data_commandb(data_commandb),
  .touch(touch0),
  .vram_rd_addr(vram_rd_addr),
  .vram_rd_data(vram_rd_data),
  // !!! NOTE - change enable_test_pattern to zero once you start implementing the video ram !!!
  .enable_test_pattern(1'b1) 
);

/* ------------------------------------------------------------------------- */
/* -- Part 2 - Option B - i2c reading of the touch screen                 -- */
/* ------------------------------------------------------------------------- */
`ifdef SIMULATION
// Generate cleaner touch signals when simulating main.
touch_generator TOUCH_GENERATOR (.rst(rst), .clk(clk), .touch(touch0));
`endif

// capacitive touch controller
ft6206_controller #(.CLK_HZ(CLK_HZ), .I2C_CLK_HZ(400_000)) FT6206(
  .clk(clk), .rst(rst), .ena(1'b1),
  .scl(touch_i2c_scl), .sda(touch_i2c_sda)
`ifndef SIMULATION
  , .touch0(touch0)
`endif // SIMULATION
);

/* ------------------------------------------------------------------------- */
/* -- Part 3 - Using Video RAM to make an etch a sketch                  --  */
/* ------------------------------------------------------------------------- */
wire [$clog2(VRAM_L)-1:0] vram_rd_addr;
logic [$clog2(VRAM_L)-1:0] vram_wr_addr, vram_clear_counter;
logic vram_wr_ena;
ILI9341_color_t vram_wr_data;

block_ram #(.W(VRAM_W), .L(VRAM_L)) VRAM(
  .clk(clk), .rd_addr(vram_rd_addr), .rd_data(vram_rd_data),
  .wr_ena(vram_wr_ena), .wr_addr(vram_wr_addr), .wr_data(vram_wr_data)
);
// Add your vram control FSM here:

endmodule