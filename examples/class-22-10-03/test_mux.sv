`timescale 1ns/1ps
`default_nettype none
module test_mux;

int errors = 0;

logic in0, in1, select;
wire out;

glitch_mux UUT(.in0(in0), .in1(in1), .select(select), .out(out));


// Some behavioural comb. logic that computes correct values.
logic correct_out;

always_comb begin : behavioural_solution_logic
  correct_out = select ? in1 : in0;
end

// You can make "tasks" in testbenches. Think of them like methods of a class, 
// they have access to the member variables.
task print_io;
  $display("%b %b %b | %b (%b)", select, in0, in1, out, correct_out);
endtask

integer i;
// 2) the test cases - initial blocks are like programming, not hardware
initial begin
  $dumpfile("glitch.fst");
  $dumpvars(0, UUT);
  
  $display("Checking all inputs.");
  $display("S in0 in1 | out (correct out)");
  for (i = 0; i < 8; i = i + 1) begin
    select = i[0];
    in1 = i[1];
    in0 = i[2];
    
    // Wait at least 100 time units to let logic propagate.
    #100 print_io();
  end

  // Show the glitch
  $display("Check out time %t for the glitch.", $time);
  select = 0;
  #100 print_io();
  select = 1;
  #100 print_io();
  $display("Glitch should have happened before %t.", $time);

  # 100;
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
always @(in0 or in1 or select) begin
  #50;
  assert(out === correct_out) else begin
    // $display("  ERROR: mux out should be %b, is %b", out, correct_out);
    errors = errors + 1;
  end
end

endmodule
