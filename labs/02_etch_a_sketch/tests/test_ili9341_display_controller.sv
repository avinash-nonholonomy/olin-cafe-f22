`timescale 1ns/100ps

`define SIMULATION
// `define VERBOSE

`include "ili9341_defines.sv"
`include "spi_types.sv"

module test_ili9341_display_controller();
parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter MAX_CYCLES = 2_000_000;

//Module I/O and parameters
logic clk, rst, ena;
wire display_rstb;
// SPI Interface
wire spi_csb, spi_clk, spi_mosi;
logic spi_miso;
// Sets the mode (many parallel and serial options, see page 10 of the datasheet).
wire [3:0] interface_mode;
wire data_commandb; // Set to 1 to send data, 0 to send commands. Read as Data/Command_Bar
wire hsync, vsync;
ILI9341_color_t vram_rd_data;
wire [31:0] vram_rd_addr;

// Simulate a smaller display to check our logic
ili9341_display_controller #(
  .DISPLAY_WIDTH(32), .DISPLAY_HEIGHT(32), .CFG_CMD_DELAY(37)
) UUT (
  .clk(clk), .rst(rst), .ena(ena), .interface_mode(interface_mode),
  .spi_csb(spi_csb), .spi_clk(spi_clk), .spi_mosi(spi_mosi), .spi_miso(spi_miso),.enable_test_pattern(1'b1), .touch(51'd0), .vram_rd_data(vram_rd_data), .vram_rd_addr(vram_rd_addr),
  .data_commandb(data_commandb), .vsync(vsync), .hsync(hsync)
);

// Run our main clock.
always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  $dumpfile("ili9341_display_controller.fst");
  $dumpvars(0,UUT);

  // Initialize module inputs.
  clk = 0;
  rst = 1;
  ena = 1;
  spi_miso = 0;
  vram_rd_data = BLUE;

  // Assert reset for long enough.
  repeat(2) @(negedge clk);
  rst = 0;

  repeat (2) @(posedge vsync);
  repeat(100) @(negedge clk);

  $display("Test finished successfully. Check the waveforms!");
  $finish;

end

always @(UUT.cfg_bytes_remaining) begin
  if(UUT.state == 0 && (UUT.cfg_bytes_remaining > 8'd127)) begin
    $display("ERROR - bytes remaining > 127!!! ");
    repeat (5) @(negedge clk);
    $finish;
  end
end

always @(UUT.rom_addr) begin
  if(UUT.state == 0 && (UUT.rom_addr > UUT.ROM_LENGTH)) begin
    $display("ERROR - rom_addr incremented past length!!! ");
    repeat (5) @(negedge clk);
    $finish;
  end
end


`ifdef VERBOSE
always @(posedge clk) begin
  if(UUT.i_ready && UUT.i_valid && UUT.state == 0) begin
    $display("CFG: Sending 0x%h over SPI", UUT.i_data[7:0]);
  end
  if(UUT.i_ready && UUT.i_valid && UUT.state > 0) begin
      $display("CFG: Sending command 0x%h over SPI, data_commandb = %b", UUT.i_data[7:0], data_commandb);
  end

end

`endif

// Put a timeout to make sure the simulation doesn't run forever.
initial begin
  repeat (MAX_CYCLES) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule

