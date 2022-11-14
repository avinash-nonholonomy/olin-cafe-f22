`timescale 1ns/1ps
`default_nettype none
`define SIMULATION


module test_rv32i_system;

localparam MAX_CYCLES = 100_000;

logic sysclk;
logic [1:0] buttons;
wire [1:0] leds;
wire [2:0] rgb;
wire [3:0] interface_mode;
wire backlight, display_rstb, data_commandb;
wire display_csb, spi_clk, spi_mosi;
logic spi_miso;

rv32i_system UUT(
  .sysclk(sysclk), .buttons(buttons), .leds(leds), .rgb(rgb),
  .interface_mode(interface_mode), .backlight(backlight), 
  .display_rstb(display_rstb), .data_commandb(data_commandb), 
  .display_csb(display_csb), 
  .spi_mosi(spi_mosi), .spi_miso(spi_miso), .spi_clk(spi_clk)
);


initial begin
  $dumpfile("rv32i_system.fst");
  $dumpvars(0, UUT);

  sysclk = 0;
  buttons = 2'b01;
  spi_miso = 0;
  repeat (2) @(negedge sysclk);
  buttons = 2'b00;
  repeat (MAX_CYCLES) @(posedge sysclk);
  @(negedge sysclk);
  
  $display("Ran %d cycles, finishing.", MAX_CYCLES);

  UUT.MMU.dump_memory("mmu");

  $finish;
end

always #5 sysclk = ~sysclk;

endmodule
