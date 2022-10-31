`timescale 1ns/1ps

`define SIMULATION
`define VERBOSE

`include "ft6206_defines.sv"
`include "i2c_types.sv"

module test_ft6206_controller();
parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter MAX_CYCLES = 1_000_000;

//Module I/O and parameters
logic clk, rst, ena;
wire scl;
wire sda;
wire [7:0] weight;
wire [3:0] area;
touch_t touch0, touch1;


ft6206_controller UUT (clk, rst, ena, scl, sda, touch0, touch1);

ft6206_model MODEL (rst, scl, sda);


// Run our main clock.
always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  $dumpfile("ft6206_controller.fst");
  $dumpvars(0, UUT);
  $dumpvars(0, MODEL);
  
  clk = 0;
  rst = 1;
  ena = 1;

  repeat (2) @(negedge clk);

  rst = 0;

  @(posedge touch0.valid);
  print_touch(touch0);

  repeat (100) @(negedge clk);
  ena = 0;
  repeat (100) @(negedge clk);

  $finish;  

end



// Put a timeout to make sure the simulation doesn't run forever.
initial begin
  repeat (MAX_CYCLES) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule

