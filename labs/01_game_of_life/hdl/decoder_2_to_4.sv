`timescale 1ns/1ps

module decoder_2_to_4(ena, in, out);

    input wire ena;
    input wire [1:0] in;
    output logic [3:0] out;
    wire [1:0] ena_wire;

<<<<<<< HEAD
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
=======
    decoder_1_to_2 in_to_ena(
        .ena (ena),
        .in (in[1]),
        .out (ena_wire[1:0])
    );
>>>>>>> 504d6e3 (Lab 1 Code)

    decoder_1_to_2 in_to_out0(
        .ena (ena_wire[0]),
        .in (in[0]),
        .out (out[1:0])
    );

    decoder_1_to_2 in_to_out1(
        .ena (ena_wire[1]),
        .in (in[0]),
        .out (out[3:2])
    );
endmodule