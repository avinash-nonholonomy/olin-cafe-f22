`timescale 1ns/1ps
`default_nettype none

module test_practice;

logic rst, clk, ena, seed;
wire out;

practice UUT(
  .rst(rst), 
  .clk(clk),
  .ena(ena),
  .seed(seed),
  .out(out)
);

initial begin
  $dumpfile("practice.fst");
  $dumpvars(0, UUT);

  clk = 0;
  rst = 1;
  ena = 0;
  seed = 1;

  $display("Running simulation...");
  @(negedge clk) rst = 0;
  repeat (2) @(negedge clk) ena = 1;
  repeat (64) @(posedge clk);
  $display("... done. Use gtkwave to see what this does!");
  $finish;
end


// Clock generation:
always #5 clk = ~clk;

endmodule
