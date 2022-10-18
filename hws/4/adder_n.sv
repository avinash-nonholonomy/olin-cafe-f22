`timescale 1ns/1ps
`default_nettype none

// You may find it useful to have a way to build an n-bit adder, 
// or you can manually create them. 

// This module shows how to use a generate statement to connect
// n 1-bit adders with carries to make a ripple carry adder.

module adder_n(a, b, Cin, S, Cout);

parameter N = 32;

input  wire [N-1:0] a, b;
input wire Cin;
output logic [N-1:0] S;
output wire Cout;

wire [N:0] carries;
assign carries[0] = Cin;
assign Cout = carries[N];
generate
  genvar i;
  for(i = 0; i < N; i++) begin : ripple_carry
    adder_1 ADDER (
      .a(a[i]),
      .b(b[i]),
      .Cin(carries[i]),
      .S(S[i]),
      .Cout(carries[i+1])
    );
  end
endgenerate

endmodule
// to instantiate
// adder_n #(.N(32)) adder_32bit_a ( port list );
