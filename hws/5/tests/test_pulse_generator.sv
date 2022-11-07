`timescale 1ns / 1ps

module test_pulse_generator;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter PERIOD_US = 10; 
parameter CLK_TICKS = 6; // CLK_HZ*PERIOD_US/1_000_000;

logic clk, rst, ena;
logic [$clog2(CLK_TICKS)-1:0] ticks;
wire out;

pulse_generator #(.N($clog2(CLK_TICKS))) UUT (
  .clk(clk), .rst(rst), .ena(ena), .ticks(ticks),
  .out(out)
);


always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  $dumpfile("pulse_generator.fst");
  $dumpvars(0, UUT);

  rst = 1;
  ena = 1;
  clk = 0;
  ticks = CLK_TICKS;
  $display("Output a pulse ever %d (%d) ticks...", ticks, CLK_TICKS);
  
  repeat (2) @(negedge clk);
  rst = 0;

  repeat (10*CLK_TICKS) @(posedge clk);
  
  @(negedge clk);
  ena = 0;
  repeat (2*CLK_TICKS) @(posedge clk);
  $finish;
end


endmodule