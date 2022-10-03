`default_nettype none

module mystery(a,b,c, out);	
	//port definitions
	input wire a, b, c;
	output logic out[3:0];
	
	always_comb begin
		out[0] = b ? a : c;
		out[1] = (~a & b) | (~b & a);
		out[2] = c | ( b & c);
	end

	logic d;
	always_comb d = b ? a : 1'b0;
	always_ff @(posedge c) begin
		out[3] <= d;
	end

endmodule
