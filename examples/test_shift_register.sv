`timescale 1ns/1ps
`default_nettype none

module test_shift_register;
parameter N = 4;

logic clk, ena, rst, data_in;
wire [N-1:0] d;
wire [N-1:0] q;

shift_register #(.N(N)) UUT (
  .clk(clk), .ena(ena), .rst(rst), .data_in(data_in), .d(d), .q(q)
);

task print_state;
  $display("q = %b", q);
endtask

always #5 clk = ~clk;

logic [N-1:0] goal = 4'b1010;

initial begin
  $dumpfile("shift_register.fst");
  $dumpvars(0, UUT);
  clk = 0;
  ena = 1;
  rst = 1;
  data_in = 0;
  $display("Goal = %b", goal);

  repeat (1) @(posedge clk);
  print_state();
  rst = 0;
  for (int i = 0; i < N; i = i + 1) begin
    @(negedge clk);
    data_in = goal[N-1-i];
    $display("setting data_in to %b", data_in);
    @(posedge clk) print_state();
  end
  @(negedge clk) ena = 0;

  repeat (N) @(posedge clk);
  $display("q = %b, goal = %b", q, goal);

  if(q !== goal) begin
    $display("---------------------------------------------------------------");
    $display("-- FAILURE                                                   --");
    $display("---------------------------------------------------------------");
  end else begin
    $display("---------------------------------------------------------------");
    $display("-- SUCCESS                                                   --");
    $display("---------------------------------------------------------------");
  end

  $finish;
end



endmodule