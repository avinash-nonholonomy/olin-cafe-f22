`timescale 1ns / 100ps
`default_nettype none

`include "i2c_types.sv"

`define SIMULATION
module test_i2c_controller;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2C_CLK_HZ = 400_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2C_CLK_HZ/2;  // Divide by two necessary since we toggle the signal
parameter MAX_CYCLES_PER_TX = 1000;
parameter MAX_CYCLES = 10000;

//Module I/O and parameters
logic clk, rst;
wire scl;
wire sda_tristate; // Use another triststate to drive the i2c bus when reading data.

i2c_transaction_t mode;
wire i_ready;
logic i_valid;
logic [6:0] i_addr;
logic [7:0] i_data;
logic o_ready;
wire o_valid;
wire [7:0] o_data;

i2c_controller UUT(
  .clk(clk), .rst(rst), 
  .scl(scl), .sda(sda_tristate), 
  .mode(mode), 
  .i_ready(i_ready), .i_valid(i_valid), .i_addr(i_addr), .i_data(i_data),
  .o_ready(o_ready), .o_valid(o_valid), .o_data(o_data)
);

// Run our main clock.
always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  // Collect waveforms
  $dumpfile("i2c_controller.fst");
  $dumpvars(0, UUT);
  
  // Initialize module inputs.
  clk = 0;
  rst = 1;
  i_valid = 0;
  i_addr = 8'h10;
  i_data = $random;
  o_ready = 1;
  mode = WRITE_8BIT_REGISTER;

  // Assert reset for long enough.
  repeat(2) @(negedge clk);
  rst = 0;

  // Test write
  mode = WRITE_8BIT_REGISTER;
  for (int i = 0; i < 4; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    i_data = i_data + 1; 
    $display("\nWriting 0x%h to the i2c device.", );
    i_valid = 1;
    @(negedge clk) i_valid = 0;
    repeat (MAX_CYCLES_PER_TX) @(negedge clk);
    if(~i_ready) begin
      $display("Error, i2c write timed out, quitting.");
      $finish;
    end
  end

  // Test read
  mode = READ_8BIT;
  for (int i = 0; i < 4; i = i + 1) begin
    while(~i_ready) @(posedge clk);
    repeat (2) @(negedge clk);
    $display("\nReading from i2c device.", );
    i_valid = 1;
    @(negedge clk) i_valid = 0;
    repeat (MAX_CYCLES_PER_TX) @(negedge clk);
    if(~i_ready | ~o_valid) begin
      $display("Error, i2c read timed out, quitting.");
      $finish;
    end
  end

  $display("Test completed successfully!");
  $finish;
end

// A very simple secondary device model that drives sda when the UUT isn't.
logic sda_secondary_out;
always @(negedge scl) begin
  if(rst) sda_secondary_out = 1;
  else case(UUT.state)
    S_ACK_ADDR, S_ACK_WR: sda_secondary_out = 0;
    default: sda_secondary_out = $random;
  endcase
end
assign sda_tristate = UUT.sda_oe ? 1'bz : sda_secondary_out; // opposite of tristate internal to UUT.

// Put a timeout to make sure the simulation doesn't run forever;
initial begin
  repeat (MAX_CYCLES) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule
