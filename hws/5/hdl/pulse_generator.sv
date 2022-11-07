/*
  Outputs a pulse generator with a period of "ticks".
  out should go high for one cycle ever "ticks" clocks.
*/
module pulse_generator(clk, rst, ena, ticks, out);

parameter N = 8;
input wire clk, rst, ena;
input wire [N-1:0] ticks;
output logic out;


logic counter_comparator;
wire [N-1:0] counter_pp;

adder_n #(.N(N)) ADDER(
  .a(counter), .b(1), .c_in(1'b0),
  .sum(counter_pp)
);

// Reset or gate
logic local_reset;
always_comb local_reset = rst | counter_comparator;

// Create a Register
logic [N-1:0] counter; // our q
always_ff @(posedge clk) begin
  if(local_reset) begin
    counter <= 0;
  end else if(ena) begin
    counter <= counter_pp;
  end
  // this always exists:
  // else counter <= counter;
end

comparator_eq #(.N(N)) COMPARATOR_EQ (
  .a(counter_pp), .b(ticks), .out(counter_comparator)
);

endmodule
