`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_decoders;
  logic ena;
  logic [2:0] in;
  wire [7:0] out;

  decoder_3_to_8 UUT(
    .ena(ena),
    .in(in[2:0]),
    .out(out[7:0])
  );

  initial begin // initial block means that only works in simulation, can't do this in real files
    // Collect waveforms - allows you to see timing diagrams
    $dumpfile("decoder_3_8.fst");
    $dumpvars(0, UUT);
    
    ena = 1;  // check output for enable high
    $display("ena in | out");
    for (int i = 0; i < 8; i = i + 1) begin
      in = i[2:0];
      #1 $display("%1b %2b | %4b", ena, in, out);
    end

    ena = 0;  // check output for enable 0
    for (int i = 0; i < 8; i = i + 1) begin
      in = i[2:0];
      #1 $display("%1b %2b | %4b", ena, in, out);
    end
        
    $finish;      
	end

endmodule
