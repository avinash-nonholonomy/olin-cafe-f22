`timescale 1ns / 1ps
`default_nettype none

module test_main;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter MAX_CYCLES=10_000;

logic clk, rst;
logic [1:0] buttons;
wire [2:0] rgb;

main UUT(.clk(clk), .buttons(buttons), .rgb(rgb));

always #(CLK_PERIOD_NS/2) clk = ~clk;

int bounces, delay;
task bounce_button();
  bounces = ($urandom % 20) + 10;
  $display("starting a bounce sequence %d", bounces);
  for(int i = 0; i < bounces; i = i + 1) begin
    delay = ($urandom % 15) + 1;
    $display("bouncing with delay %d", delay);
    #(delay) buttons[1] = $urandom;
  end
endtask


initial begin
  $dumpfile("main.fst");
  $dumpvars(0, UUT);

  // Initialize all of our variables
  clk = 0;
  rst = 1;

  buttons[0] = 1;
  buttons[1] = 0;

  // Reset over
  repeat (2) @(negedge clk);
  buttons[0] = 0;

  for(int i = 0; i < 5; i = i + 1) begin
    $display("On test number %2d", i);
    bounce_button();
    buttons[1] = 1;

    repeat (250) @(posedge clk);

    bounce_button();
    buttons[1] = 0;

    repeat (250) @(posedge clk);
  end

  $finish;

end

// Put a timeout to make sure the simulation doesn't run forever.
initial begin
  repeat (MAX_CYCLES) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule