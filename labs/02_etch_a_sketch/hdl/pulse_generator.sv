`default_nettype none
/*
  Outputs a pulse generator with a period of "ticks".
  out should go high for one cycle ever "ticks" clocks.
*/
module pulse_generator(clk, rst, ena, ticks, out);

parameter N = 8;
input wire clk, rst, ena;
input wire [N-1:0] ticks;
output logic out;
logic [N-1:0] counter;

logic local_reset;
always_comb out = counter == ticks;


always_ff @(posedge clk) begin
  if(rst) begin
    counter <= 0;
  end else if(ena) begin
    counter <= out ? 0 : counter + 1;

  end
  // this always exists:
  // else counter <= counter;
end

endmodule

// module pulse_generator(clk, rst, ena, ticks, out);

// parameter N = 8;
// input wire clk, rst, ena;
// input wire [N-1:0] ticks;
// output logic out;

// logic [N-1:0] counter;
// logic counter_comparator;

// logic [N-1:0] counter;
// logic counter_comparator;

// always_comb begin : comparing_logic
//   counter_comparator = (counter >= ticks);
// end

// always_ff @(posedge clk) begin : pulse_generator
// // reset condition
//   if (rst) begin 
//     counter <= 0;
//   end
// // ena condition
//   else if (ena) begin
//     if (counter_comparator) begin
//       counter <= 0;
//     end
//     else begin 
//       counter <= counter + 1;
//     end
//   end
// end

// always_comb begin : tick_logic // creating pulses until counter has passed until # of ticks
//   out = counter_comparator & ena;
// end

// endmodule
