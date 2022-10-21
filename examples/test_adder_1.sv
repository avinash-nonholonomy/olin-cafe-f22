module test_adder_1;

logic a, b, c_in;
wire sum, c_out;

adder_1 UUT(.a(a), .b(b), .c_in(c_in), .sum(sum), .c_out(c_out));

initial begin
  $dumpvars(0, UUT);
  $dumpfile("adder_1.fst");

  $display("abc | sc");
  for (int i = 0; i < 8; i = i + 1) begin
    c_in = i[2];
    b = i[1];
    a = i[0];

    #1 $display("%b%b%b | %b%b", a, b, c_in, sum, c_out);
  end
end


endmodule
