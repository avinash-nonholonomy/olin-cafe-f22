module decoder_1_to_2(ena, in, out);

input wire ena;
input wire in;
output logic [1:0] out;


logic in_bar;
always_comb begin
  out[1] = in & ena;
  in_bar = ~ in;
  out[0] = in_bar & ena;
end

// Alternate:
// always_comb out[0] = ~in & ena;


endmodule