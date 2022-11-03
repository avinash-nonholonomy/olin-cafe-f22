`timescale 1ns/1ps
`default_nettype none
// python: print(", ".join([f"in{i:02d}" for i in range(32)]))
module mux32(
	in00, in01, in02, in03, in04, in05, in06, in07, 
	in08, in09, in10, in11, in12, in13, in14, in15, 
	in16, in17, in18, in19, in20, in21, in22, in23, 
	in24, in25, in26, in27, in28, in29, in30, in31,
	select, out
);

//parameter definitions
parameter N = 1;
//port definitions
input  wire [N-1:0] 
	in00, in01, in02, in03, in04, in05, in06, in07, 
	in08, in09, in10, in11, in12, in13, in14, in15, 
	in16, in17, in18, in19, in20, in21, in22, in23, 
	in24, in25, in26, in27, in28, in29, in30, in31;
input  wire [4:0] select;
output logic [N-1:0] out;

wire [N-1:0] mux0, mux1;
//make 32:1 out of 2 16:1 muxes and a 2:1 mux
mux16 #(.N(N)) MUX_0 (
	// python: print(", ".join([f".in{i:02d}(in{i:02d})" for i in range(16)]))
	.in00(in00), .in01(in01), .in02(in02), .in03(in03), 
	.in04(in04), .in05(in05), .in06(in06), .in07(in07), 
	.in08(in08), .in09(in09), .in10(in10), .in11(in11), 
	.in12(in12), .in13(in13), .in14(in14), .in15(in15),
	.select(select[3:0]), .out(mux0)
);
mux16 #(.N(N)) MUX_1 (
	// python: print(", ".join([f".in{i:02d}(in{16+i:02d})" for i in range(16)]))
	.in00(in16), .in01(in17), .in02(in18), .in03(in19), 
	.in04(in20), .in05(in21), .in06(in22), .in07(in23), 
	.in08(in24), .in09(in25), .in10(in26), .in11(in27), 
	.in12(in28), .in13(in29), .in14(in30), .in15(in31),
	.select(select[3:0]), .out(mux1)
);
always_comb out = select[4] ? mux1 : mux0;

// Here's the behavioral way of doing this:
`ifdef BEHAVIORAL_MUX
always_comb begin : behavioral_mux
  case(select)
    // python:  print("\n".join(["5'd%02d : out = in%02d;"%(i,i) for i in range(0,32)]))
    5'd00 : out = in00;
		5'd01 : out = in01;
		5'd02 : out = in02;
		5'd03 : out = in03;
		5'd04 : out = in04;
		5'd05 : out = in05;
		5'd06 : out = in06;
		5'd07 : out = in07;
		5'd08 : out = in08;
		5'd09 : out = in09;
		5'd10 : out = in10;
		5'd11 : out = in11;
		5'd12 : out = in12;
		5'd13 : out = in13;
		5'd14 : out = in14;
		5'd15 : out = in15;
		5'd16 : out = in16;
		5'd17 : out = in17;
		5'd18 : out = in18;
		5'd19 : out = in19;
		5'd20 : out = in20;
		5'd21 : out = in21;
		5'd22 : out = in22;
		5'd23 : out = in23;
		5'd24 : out = in24;
		5'd25 : out = in25;
		5'd26 : out = in26;
		5'd27 : out = in27;
		5'd28 : out = in28;
		5'd29 : out = in29;
		5'd30 : out = in30;
		5'd31 : out = in31;
  endcase
end
`endif // BEHAVIORAL_MUX

endmodule
`default_nettype wire
