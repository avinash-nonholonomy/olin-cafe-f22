`timescale 1ns/1ps
`default_nettype none
`include "alu_types.sv"

module test_alu;

parameter N = 32; // Don't need to support other numbers, just using this as a constant.
parameter N_TEST_VECTOR = 9; // Change this number based on how many cases you implement in alu_testcases.memh
parameter N_RANDOM_TESTS = 25;
parameter MAX_ERRORS = 10; // You can change this number to have the test fail earlier or later if too many errors are encounterd. Can make it easier to sift through waveforms.

logic [N-1:0] a, b; // Inputs to the ALU.
alu_control_t control; // Sets the current operation.

wire [N-1:0] result; // Result of the selected operation.
wire overflow; // Is high if the result of an ADD or SUB wraps around the 32 bit boundary.
wire zero;  // Is high if the result is ever all zeros.
wire equal; // is high if a == b.

wire [N-1:0] correct_result; // Result of the selected operation.
wire correct_overflow; // Is high if the result of an ADD or SUB wraps around the 32 bit boundary.
wire correct_zero;  // Is high if the result is ever all zeros.
wire correct_equal; // is high if a == b.

alu #(N) ALU(.a(a), .b(b), .control(control), .result(result), .overflow(overflow), .zero(zero), .equal(equal));
alu_behavioural #(N) ALU_B(.a(a), .b(b), .control(control), .result(correct_result), .overflow(correct_overflow), .zero(correct_zero), .equal(correct_equal));

int errors;
int errors_by_op[0:10];

logic [31:0] test_vector[0:N_TEST_VECTOR-1];
logic loop ;
initial begin
  $dumpfile("alu.fst");
  $dumpvars(0, ALU);
  $dumpvars(0, ALU_B);
  
  a = 0; b = 0; control = control.first;
  errors = 0;
  // Edit the alu_testcases.memh file to add more test cases!
  $readmemh("alu_testcases.memh", test_vector);
  loop = 1;
  while (loop) begin
    $display("Testing alu control = %b (%s)", control, alu_control_name(control));
    for(int j = 0; j < N_TEST_VECTOR; j = j + 1) begin
      for(int k = 0; k < N_TEST_VECTOR; k = k + 1) begin
        a = test_vector[j][N-1:0];
        b = test_vector[k][N-1:0];
        #10;
      end
    end
    for(int i = 0; i < N_RANDOM_TESTS; i = i + 1) begin
      a = $random;
      b = $random;
      #10;
    end
    #10;
    if(control == control.last) loop = 0;;
    control = control.next;
  end
  #10;
  if(errors > 0) begin
    $display("\nTest completed with %d errors.", errors);
  end
  else begin
    $display("\nTest completed with 0 errors!");
  end

  $finish;
end

//checker
always @(a or b or control) begin
  #1;  //this delay makes sure that all values are stable from last change
  
  if(zero !== correct_zero) begin
    $display("@%t: Error: ZERO  : a = %h, b = %h, result = %h, zero = %b, should be %b", $time, a, b, result, zero, correct_zero);
    errors = errors + 1;
  end

  if(equal !== correct_equal) begin
    $display("@%t: Error: EQUAL  : a = %h, b = %h, result = %h, equal = %b, should be %b", $time, a, b, result, equal, correct_equal);
    errors = errors + 1;
  end

  // Comment out this check if you didn't have time to do the overflow logic.
  if(overflow !== correct_overflow) begin
    $display("@%t: Error: OVERFLOW  : a = %h, b = %h, result = %h, overflow = %b, should be %b", $time, a, b, result, overflow, correct_overflow);
    errors = errors + 1;
  end
  
  if(result !== correct_result) begin
    $display("@%t: Error: %s  : a = %h, b = %h, result = %h, should be %h", $time, alu_control_name(control), a, b, result, correct_result);
    errors = errors + 1;
    errors_by_op[control] = errors_by_op[control] + 1;
  end

  if(errors > MAX_ERRORS) begin
    $display("Found too many errors, quitting.");
    $finish;
  end
end

endmodule

`default_nettype wire