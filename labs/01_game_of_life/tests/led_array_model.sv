/*
A "physics" based model for the LED array.

*/

module led_array_model(rows, cols);

parameter N = 5;
input wire [N-1:0] rows;
input wire [N-1:0] cols;

logic [N-1:0] leds [N-1:0];

int voltage = 0;
always @(rows[N-1:0], cols[N-1:0]) begin
  for (int i = 0; i < N; i = i +1) begin
    for (int j = 0; j < N; j = j + 1) begin
      voltage = int'(cols[j]) - int'(rows[i]);
      leds[j][i] = (voltage > 0) ? 1'b1 : 1'b0;
    end
  end
end

task print_bars();
  for (int i = 0; i < N; i = i + 1) $write("-");
  $write("\n");
endtask

task print_status();
  print_bars();
  for (int i = N-1; i >=0;  i = i - 1) begin
    $display("%b", leds[i][N-1:0]);
  end
  print_bars();
endtask

endmodule