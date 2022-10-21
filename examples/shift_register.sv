`default_nettype none

/*
A synchronous register (batch of flip flops) with rst > ena.
*/

module shift_register(clk, ena, rst, data_in, d, q);

parameter N = 4;

input wire clk, ena, rst, data_in;
output logic [N-1:0] d;
output logic [N-1:0] q;

always_comb begin 
  d[0] = data_in;
  d[N-1:1] = q[N-2:0];
end

always_ff @(posedge clk) begin
  if(rst) begin
    q <= 0;
  end else begin
    if (ena) begin
      q[0] <= data_in;
      q[N-1:1] <= q[N-2:0]; // See lecture notes for diagram.
    end
  end
end

endmodule
