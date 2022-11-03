`timescale 1ns/1ps
`default_nettype none
// python: print(", ".join([f"in{i:02d}" for i in range(16)]))
module mux16(
  in00, in01, in02, in03, in04, in05, in06, in07, in08,
  in09, in10, in11, in12, in13, in14, in15,
  select,out
);

//parameter definitions
parameter N = 1;
//port definitions
input wire [N-1:0] in00, in01, in02, in03, in04, in05, in06, in07, in08, 
  in09, in10, in11, in12, in13, in14, in15;

input  wire [3:0] select;
output logic [N-1:0] out;

wire [N-1:0] mux0, mux1;
//make 4:1 out of 2 8:1 muxes and a 2:1 mux
mux8 #(.N(N)) MUX_0 (
  // python: print(", ".join([f".in{i:01d}(in{i:02d})" for i in range(8)]))
  .in0(in00), .in1(in01), .in2(in02), .in3(in03),
   .in4(in04), .in5(in05), .in6(in06), .in7(in07),
   .select(select[2:0]), .out(mux0)
);

mux8 #(.N(N)) MUX_1 (
  // python: print(", ".join([f".in{i:01d}(in{8+i:02d})" for i in range(8)]))
  .in0(in08), .in1(in09), .in2(in10), .in3(in11), 
  .in4(in12), .in5(in13), .in6(in14), .in7(in15),
  .select(select[2:0]), .out(mux1));
always_comb out = select[3] ? mux1 : mux0;

endmodule
