`timescale 1ns/1ps
`default_nettype none
module test_multiplier;

parameter N = 3;

int errors = 0;
logic clk, rst;
logic [N-1:0] a, b;
logic valid_i;
wire ready_i, valid_o;
logic ready_o;
wire [2*N-1:0] product;

multiplier #(.N(N)) UUT(
  .clk(clk), .rst(rst),
  .valid_i(valid_i), .ready_i(ready_i),
  .valid_o(valid_o), .ready_o(ready_o),
  .a(a), .b(b), .product(product)
);

logic [2*N-1:0] correct_product;

always_comb begin : behavioural_solution_logic
  correct_product = a*b;
end

task print_io;
  $display("%d * %d = %d (%d)", a, b, product, correct_product);
endtask

task wait_till_done;
  while(~valid_o) @(posedge clk);
endtask

task wait_till_ready;
  while(~ready_i) @(posedge clk);
endtask

always #5 clk = ~clk;

initial begin
  $dumpfile("multiplier.fst");
  $dumpvars(0, UUT);
  a = 0;
  b = 0;
  clk = 0;
  rst = 1;
  valid_i = 0;
  ready_o = 1;

  repeat(2) @(posedge clk);
  rst = 0;
  
  $display("Random testing.");
  for (int i = 0; i < 1000; i = i + 1) begin : random_testing
    wait_till_ready();
    @(negedge clk);
    valid_i = 1;
    a = $random();
    b = $random();
    $display("\nTesting %d * %d ... ", a, b);
    @(negedge clk); 
    valid_i = 0;
    wait_till_done();

    if (errors > 10) begin
      $display(" Too many errors found, quitting " );
      i = 100000000;
    end
  end
  if (errors !== 0) begin
    $display("---------------------------------------------------------------");
    $display("-- FAILURE                                                   --");
    $display("---------------------------------------------------------------");
    $display(" %d failures found, try again!", errors);
  end else begin
    $display("---------------------------------------------------------------");
    $display("-- SUCCESS                                                   --");
    $display("---------------------------------------------------------------");
  end
  $finish;
end

// Note: the triple === (corresponding !==) check 4-state (e.g. 0,1,x,z) values.
//       It's best practice to use these for checkers!
always @(a,b, valid_o) begin
  if(valid_o) begin 
    print_io;
    assert(product === correct_product) else begin
      $display("%10t ERROR: product should be %d, is %d",$time, correct_product, product);
      errors = errors + 1;
    end
  end
end

endmodule
