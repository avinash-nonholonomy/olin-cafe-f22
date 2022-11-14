`timescale 1ns/1ps
`default_nettype none

`include "memmap.sv"

module mmu(
  clk, rst, 
  core_addr, core_rd_data, core_wr_ena, core_wr_data,
  leds, rgb,
  interface_mode, backlight, display_rstb, data_commandb,
  display_csb, spi_mosi, spi_miso, spi_clk
);

parameter INST_L = 256;
parameter DATA_L = 256;
parameter VRAM_L = 320*240;
parameter INIT_INST = "mem/zeros.memh";
parameter INIT_DATA = "mem/zeros.memh";
parameter INIT_VRAM = "mem/zeros.memh";

input wire  clk, rst;
input wire core_wr_ena;
input wire [31:0] core_wr_data, core_addr;
output logic [31:0] core_rd_data;
// LEDs
output wire [1:0] leds;
output wire [2:0] rgb;
// Display driver signals
output wire [3:0] interface_mode;
output wire backlight, display_rstb, data_commandb;
output wire display_csb, spi_clk, spi_mosi;
input wire spi_miso;

logic inst_wr_ena, data_wr_ena, vram_wr_ena;
wire [31:0] inst_rd_data, data_rd_data;
wire [31:0] periph_vram_addr;
wire [15:0] core_vram_rd_data, periph_vram_rd_data;

logic gpio_mode_wr_ena, gpio_state_wr_ena;
logic [31:0] gpio_mode, gpio_state_i, gpio_state_o;

// Instruction Memory
distributed_ram #(.W(32), .L(INST_L), .INIT(INIT_INST)) INST_RAM(
  .clk(clk), .wr_ena(inst_wr_ena), .addr(core_addr[$clog2(INST_L)+1:2]), .wr_data(core_wr_data), .rd_data(inst_rd_data)
);

// Data Memory
distributed_ram #(.W(32), .L(DATA_L), .INIT(INIT_DATA)) DATA_RAM(
  .clk(clk), .wr_ena(data_wr_ena), .addr(core_addr[$clog2(DATA_L)+1:2]), .wr_data(core_wr_data), .rd_data(data_rd_data)
);

// Video Memory - DMA (Direct Memory Access) Example
// dual_port_distributed_ram 
// #(.W(16), .L(VRAM_L), .INIT(INIT_VRAM)) VRAM(
dual_port_ram 
#(.W(8), .L(VRAM_L), .INIT(INIT_VRAM)) VRAM(
  .clk(clk),
  .wr_ena0(vram_wr_ena), .addr0(core_addr[$clog2(VRAM_L)-1:0]), .wr_data0(core_wr_data[15:0]), .rd_data0(core_vram_rd_data[15:0]),
  .wr_ena1(1'b0), .addr1(periph_vram_addr[$clog2(VRAM_L)-1:0]), .wr_data1(16'd0), .rd_data1(periph_vram_rd_data)
);

// Display controller
assign backlight = 1;
ili9341_display_controller #(.VRAM_START_ADDRESS(32'h0000_1000)) ILI9341 (
  .clk(clk), .rst(rst), .ena(1'b1), 
  .display_rstb(display_rstb), .interface_mode(interface_mode),
  .spi_csb(display_csb), .spi_clk(spi_clk), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
  .data_commandb(data_commandb),
  .vram_rd_addr(periph_vram_addr),
  .vram_rd_data(periph_vram_rd_data[7:0])
);

// An LED MMR that lets us control duty cycle.
logic led_mmr_wr_ena;
wire [31:0] led_mmr;
logic [3:0] led_pwm0,led_pwm1;
logic [7:0] led_r_pwm, led_g_pwm, led_b_pwm;
register #(.N(32)) LED_MMR(.clk(clk), .rst(rst), .ena(led_mmr_wr_ena), .d(core_wr_data), .q(led_mmr));

wire pwm_step;
localparam CLK_HZ=60_000_000;
pulse_generator #(.N($clog2(CLK_HZ/10000))) PULSE_PWM (
  .clk(clk), .rst(rst), .ena(1'b1), .out(pwm_step),
  .ticks(CLK_HZ/10000)
);

pwm #(.N(4)) PWM_LED0 (
  .clk(clk), .rst(rst), .ena(1'b1), .step(pwm_step), .duty(led_pwm0),
  .out(leds[0])
);

pwm #(.N(4)) PWM_LED1 (
  .clk(clk), .rst(rst), .ena(1'b1), .step(pwm_step), .duty(led_pwm1),
  .out(leds[1])
);
pwm #(.N(8)) PWM_LED_R (
  .clk(clk), .rst(rst), .ena(1'b1), .step(pwm_step), .duty(led_r_pwm),
  .out(rgb[0])
);
pwm #(.N(8)) PWM_LED_G (
  .clk(clk), .rst(rst), .ena(1'b1), .step(pwm_step), .duty(led_g_pwm),
  .out(rgb[1])
);
pwm #(.N(8)) PWM_LED_B (
  .clk(clk), .rst(rst), .ena(1'b1), .step(pwm_step), .duty(led_b_pwm),
  .out(rgb[2])
);
always_comb begin :led_mmr_decode
  led_pwm0 = led_mmr[31:28];
  led_pwm1 = led_mmr[27:24];
  led_r_pwm = 8'd255 - led_mmr[23:16];
  led_g_pwm = 8'd255 - led_mmr[15:8];
  led_b_pwm = 8'd255 - led_mmr[7:0];
end


always_comb begin : MMU_ADDRESS_DECODING
  if (core_addr >= `MEM_INST_START && core_addr <= `MEM_INST_END) begin
    inst_wr_ena = core_wr_ena;
    data_wr_ena = 0;
    gpio_mode_wr_ena = 0;
    gpio_state_wr_ena = 0;
    vram_wr_ena = 0;
    led_mmr_wr_ena = 0;
    
    core_rd_data = inst_rd_data;
  end else if (core_addr >= `MEM_DATA_START && core_addr <= `MEM_DATA_END) begin
    inst_wr_ena = 0;
    vram_wr_ena = 0;
    data_wr_ena = core_wr_ena;
    gpio_mode_wr_ena = 0;
    gpio_state_wr_ena = 0;
    led_mmr_wr_ena = 0;
    
    core_rd_data = data_rd_data;
  end else if (core_addr >= `MEM_VRAM_START && core_addr <= `MEM_VRAM_END) begin 
    inst_wr_ena = 0;
    vram_wr_ena = core_wr_ena;
    data_wr_ena = 0;
    gpio_mode_wr_ena = 0;
    gpio_state_wr_ena = 0;
    led_mmr_wr_ena = 0;
    
    core_rd_data = {16'd0, core_vram_rd_data};
  end else if (core_addr == `MEM_MMR_LEDS) begin
    inst_wr_ena = 0;
    vram_wr_ena = 0;
    data_wr_ena = 0;
    gpio_mode_wr_ena = 0;
    gpio_state_wr_ena = 0;
    led_mmr_wr_ena = core_wr_ena;
    
    core_rd_data = led_mmr;
  end else if (core_addr == `MEM_GPIO_MODE) begin
    inst_wr_ena = 0;
    vram_wr_ena = 0;
    data_wr_ena = 0;
    gpio_mode_wr_ena = core_wr_ena;
    gpio_state_wr_ena = 0;
    led_mmr_wr_ena = 0;
    
    core_rd_data = gpio_mode;
  end else if (core_addr == `MEM_GPIO_STATE) begin
    inst_wr_ena = 0;
    vram_wr_ena = 0;
    data_wr_ena = 0;
    gpio_mode_wr_ena = 0;
    gpio_state_wr_ena = core_wr_ena;
    led_mmr_wr_ena = 0;
    
    core_rd_data = gpio_state_i;
  end else begin
    inst_wr_ena = 0;
    vram_wr_ena = 0;
    data_wr_ena = 0;
    gpio_mode_wr_ena = 0;
    gpio_state_wr_ena = 0;
    led_mmr_wr_ena = 0;
    
    core_rd_data = 32'dx;
  end

end

task dump_memory(string prefix);
  INST_RAM.dump_memory({prefix, "_inst.out"});
  DATA_RAM.dump_memory({prefix, "_data.out"});
  VRAM.dump_memory({prefix, "_vram.out"});
endtask

endmodule
