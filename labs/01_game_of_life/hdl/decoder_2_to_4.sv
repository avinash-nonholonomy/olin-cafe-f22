`timescale 1ns/1ps
module decoder_2_to_4(ena, in, out);

input wire ena;
input wire [1:0] in;
output logic [3:0] out;

wire ena0, ena1;
// wire [1:0] decoder_enables;

decoder_1_to_2 DEC0(
  .ena(ena0),
  .in(in[0]),
  .out(out[1:0])
);

decoder_1_to_2 DEC1(
  .ena(ena1),
  .in(in[0]),
  .out(out[3:2])
);

decoder_1_to_2 DEC_ENA(
  .ena(ena),
  .in(in[1]),
  .out({ena1, ena0})
);

endmodule