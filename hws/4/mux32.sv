	
`timescale 1ns/1ps
`default_nettype none
/*
  Making 32 different inputs is annoying, so I use python:
  print(", ".join([f"in{i:02}" for i in range(32)]))
  The solutions will include comments for where I use python-generated HDL.
*/

module mux2(in0, in1, select, out);
  input wire in0, in1, select;
  output logic out;
  always_comb out = select ? in1 : in0;
endmodule

module mux4(in0, in1, in2, in3, select, out);
  input wire in0, in1, in2, in3;
  input wire [1:0] select;
  output logic out;
  wire [1:0] internal;

  mux2 mux0(
    .in0 (in0),
    .in1 (in1),
    .select (select[0]),
    .out (internal[0])
  );

  mux2 mux1(
    .in0 (in2),
    .in1 (in3),
    .select (select[0]),
    .out (internal[1])
  );  

  mux2 mux2(
    .in0 (internal[0]),
    .in1 (internal[1]),
    .select (select[1]),
    .out (out)
  );

endmodule

module mux8(in0, in1, in2, in3, in4, in5, in6, in7, select, out);
  input wire in0, in1, in2, in3, in4, in5, in6, in7;
  input wire [2:0] select;
  output logic out;
  wire [1:0] internal;

  mux4 mux0(
    .in0 (in0),
    .in1 (in1),
    .in2 (in2),
    .in3 (in3),
    .select (select[1:0]),
    .out (internal[0])
  );

  mux4 mux1(
    .in0 (in4),
    .in1 (in5),
    .in2 (in6),
    .in3 (in7),
    .select (select[1:0]),
    .out (internal[1])
  );

  mux2 mux2_0(
    .in0 (internal[0]),
    .in1 (internal[1]),
    .select (select[2]),
    .out (out)
  );
endmodule

module mux16(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15, select, out);
  input wire in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
  input wire [3:0] select;
  output logic out;
  wire [1:0] internal;

  mux8 mux0(
    .in0 (in0),
    .in1 (in1),
    .in2 (in2),
    .in3 (in3),
    .in4 (in4),
    .in5 (in5),
    .in6 (in6),
    .in7 (in7),
    .select (select[2:0]),
    .out (internal[0])
  );

  mux8 mux1(
    .in0 (in8),
    .in1 (in9),
    .in2 (in10),
    .in3 (in11),
    .in4 (in12),
    .in5 (in13),
    .in6 (in14),
    .in7 (in15),
    .select (select[2:0]),
    .out (internal[1])
  );

  mux2 mux2_0(
    .in0 (internal[0]),
    .in1 (internal[1]),
    .select (select[3]),
    .out (out)
  );
endmodule

module mux32(
  in00, in01, in02, in03, in04, in05, in06, in07, in08, in09, in10, 
  in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, in21, 
  in22, in23, in24, in25, in26, in27, in28, in29, in30, in31,
  select,out
);
	//parameter definitions
	parameter N = 1;
	//port definitions
  // python: print(", ".join([f"in{i:02}" for i in range(32)]))
	input  wire [(N-1):0] in00, in01, in02, in03, in04, in05, in06, in07, in08, 
    in09, in10, in11, in12, in13, in14, in15, in16, in17, in18, in19, in20, 
    in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31;
	input  wire [4:0] select;
  wire [1:0] internal;
	output logic [(N-1):0] out;

mux16 mux0(
    .in0 (in00),
    .in1 (in01),
    .in2 (in02),
    .in3 (in03),
    .in4 (in04),
    .in5 (in05),
    .in6 (in06),
    .in7 (in07),
    .in8 (in08),
    .in9 (in09),
    .in10 (in10),
    .in11 (in11),
    .in12 (in12),
    .in13 (in13),
    .in14 (in14),
    .in15 (in15),
    .select (select[3:0]),
    .out (internal[0])
  );

mux16 mux1(
    .in0 (in16),
    .in1 (in17),
    .in2 (in18),
    .in3 (in19),
    .in4 (in20),
    .in5 (in21),
    .in6 (in22),
    .in7 (in23),
    .in8 (in24),
    .in9 (in25),
    .in10 (in26),
    .in11 (in27),
    .in12 (in28),
    .in13 (in29),
    .in14 (in30),
    .in15 (in31),
    .select (select[3:0]),
    .out (internal[1])
  );

  mux2 mux2_0(
    .in0 (internal[0]),
    .in1 (internal[1]),
    .select (select[4]),
    .out (out)
  );

endmodule
