module multishot(clk, rst, in, out);

/*

A multishot outputs a pulse train while the the input is high. You can set the
frequency of the pulse train (in powers of 2) by having a shift register instead of
usig a single flip flop.

The circuit we drew in lecture is the N = 1 case.

*/

parameter N = 1; 

input wire clk, rst, in;
output logic out;

// Make a shift register that goes lsb to msb
logic [N-1:0] shift_register;
always @(posedge clk) begin : shift_register_logic
  if(rst) shift_register <= 0;
  else begin
    shift_register[0] <= in;
    if (N > 1) begin
      shift_register[N-1:1] <= shift_register[N-2:0];
    end
  end
end

endmodule
