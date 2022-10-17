module test_edge_detectors;

logic clk, rst, in;
wire  positive_edge, negative_edge, positive_edge_moore, negative_edge_moore;

edge_detector UUT_MEALY (clk, rst, in, positive_edge, negative_edge);
edge_detector_moore UUT_MOORE (clk, rst, in, positive_edge_moore, negative_edge_moore);

logic [6:0] delay;

initial begin
  clk = 0; 
  rst = 1;
  in = 0;
  $dumpfile("edge_detectors.fst");
  $dumpvars(0, UUT_MEALY);
  $dumpvars(0, UUT_MOORE);

  repeat (2) @(negedge clk);
  rst = 0;

  for(int i = 0; i < 10; i = i + 1) begin
    delay = $random + 1;
    repeat (delay) @(negedge clk);
    in = ~in; // toggle input
  end

  $finish;

end

always #5 clk = ~clk; // clock signal

endmodule