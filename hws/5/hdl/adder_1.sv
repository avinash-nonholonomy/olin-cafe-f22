/*
  a 1 bit addder that we can daisy chain for 
  ripple carry adders
*/

module adder_1(a, b, c_in, sum, c_out);

input wire a, b, c_in;
output logic sum, c_out;

logic half_sum;
logic a_and_b;

always_comb begin : adder_gates
  // See Example 4.7 (p. 182) in your textbook for an explanation.
  a_and_b = a & b;
  half_sum = a ^ b;
  c_out = a_and_b | (half_sum & c_in);
  sum = half_sum ^ c_in;
end

endmodule
