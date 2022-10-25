`timescale 1ns/1ps
`default_nettype none

module test_multiplier;

parameter N = 3;
parameter MAX_CYCLES=10_000;
parameter N_RANDOM_TESTS=100;

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

int main_unit_busy_cycles = 0;
task wait_till_done;
  ready_o = 0;
  main_unit_busy_cycles = $urandom_range(0,10);
  while(valid_o !== 1'b1) begin
    @(negedge clk);
    if(main_unit_busy_cycles >= 0) begin
      ready_o = 1;
      main_unit_busy_cycles = 0;
    end else begin
      main_unit_busy_cycles = main_unit_busy_cycles - 1;
    end
    @(posedge clk);
  end
  while(ready_o !== 1'b1) begin
    @(negedge clk);
    if(main_unit_busy_cycles >= 0) begin
      ready_o = 1;
      main_unit_busy_cycles = 0;
    end else begin
      main_unit_busy_cycles = main_unit_busy_cycles - 1;
    end
  end
endtask

task wait_till_ready;
  while(ready_i !== 1'b1) @(posedge clk);
endtask

initial begin
  a = 0;
  b = 0;
  clk = 0;
  rst = 1;
  valid_i = 0;
  ready_o = 1;
  
  $dumpfile("multiplier.fst");
  $dumpvars;

  repeat(2) @(negedge clk);
  rst = 0;
  
  $display("Random testing.");
  for (int i = 0; i < N_RANDOM_TESTS; i = i + 1) begin : random_testing
    $display("Random test %d/%d", i+1, N_RANDOM_TESTS);
    wait_till_ready();
    @(negedge clk);
    valid_i = 1;
    a = $random();
    b = $random();
    $display("\nTesting %d * %d ... ", a, b);
    @(negedge clk); 
    valid_i = 0;
    wait_till_done();
    
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

always #5 clk = ~clk;

// Note: the triple === (corresponding !==) check 4-state (e.g. 0,1,x,z) values.
//       It's best practice to use these for checkers!
always @(posedge(valid_o)) begin
  if(valid_o) begin 
    print_io;
    assert(product === correct_product) else begin
      $display("%10t ERROR: product should be %d, is %d",$time, correct_product, product);
      errors = errors + 1;
    end
  end
  if (errors > 10) begin
    $display(" Too many errors found, quitting " );
    $finish;
  end
end

// An overal timeout:
initial begin
  repeat (MAX_CYCLES) @(negedge clk);
  $display("TIMEOUT: Exceeded %d iterations, quitting.", MAX_CYCLES);
  $finish;
end

endmodule
