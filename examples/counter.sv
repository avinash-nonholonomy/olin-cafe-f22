`default_nettype none


module counter(clk, ena, rst, count);
parameter N = 8;

input wire clk, ena, rst;
logic [N-1:0] next_state, state;
output logic [N-1:0] q;

always_ff @(posedge clk) begin
  if (rst) begin
    count <= 0;
  end
  else begin
    if (ena) begin
      state <= next_state;
      // another option - what you will see in most real examples.
      // state <= state + 1;
    end
  end
end

// Structural option:
/*
adder_n #(.N(N)) ADDER(
  .a(state), .b(1), .out(next_state), .carry_in(0)
);
*/

// Behavioral Option:
always_comb next_state = state + 1;

endmodule
