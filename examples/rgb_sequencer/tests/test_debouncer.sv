`timescale 1ns / 1ps
`default_nettype none

module test_debouncer;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.

logic clk, rst;
logic bouncy_in;

wire debounced_out;

debouncer #(.BOUNCE_TICKS(100)) UUT (
  .clk(clk), .rst(rst), .bouncy_in(bouncy_in), 
  .debounced_out(debounced_out)
);

always #(CLK_PERIOD_NS/2) clk = ~clk;

int bounces, delay;
initial begin
  $dumpfile("debouncer.fst");
  $dumpvars(0, UUT);

  // Initialize all of our variables
  clk = 0;
  rst = 1;

  bouncy_in = 0;

  repeat (2) @(negedge clk);
  rst = 0;

  // simulation of a bounce up
  bounces = ($urandom % 20) + 10;
  $display("starting a bounce sequence %d", bounces);
  for(int i = 0; i < bounces; i = i + 1) begin
    delay = ($urandom % 15) + 1;
    $display("bouncing with delay %d", delay);
    #(delay) bouncy_in = $urandom;
  end
  bouncy_in = 1;

  repeat (250) @(posedge clk);

  if( debounced_out !== 1) $display("ERROR!");

  // simulation of a bounce down
  bounces = ($urandom % 20) + 10;
  $display("starting a bounce sequence %d", bounces);
  for(int i = 0; i < bounces; i = i + 1) begin
    delay = ($urandom % 15) + 1;
    $display("bouncing with delay %d", delay);
    #(delay) bouncy_in = $urandom;
  end
  bouncy_in = 0;

  repeat (250) @(posedge clk);
  if( debounced_out !== 0) $display("ERROR!");

  $finish;

end

// Put a timeout to make sure the simulation doesn't run forever.
initial begin
  repeat (1000) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule