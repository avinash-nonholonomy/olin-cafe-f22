`timescale 1ns / 1ps

module test_triangle_generator;
parameter N = 4;
logic clk, rst, ena;
wire [N-1:0] out;

triangle_generator #(.N(N)) UUT(
  .clk(clk), .rst(rst), .ena(ena), .out(out)
);

always #5 clk = ~clk;

initial begin
  $dumpfile("triangle_generator.fst");
  $dumpvars(0, UUT);

  rst = 1;
  ena = 1;
  clk = 0;
  
  repeat (1) @(negedge clk);
  rst = 0;
  repeat (2 << (N + 4)) @(posedge clk);
  $finish;
end

endmodule
