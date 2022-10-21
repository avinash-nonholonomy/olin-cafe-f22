module main(clk, buttons, rgb);

input wire clk;
input wire [1:0] buttons;
output logic [2:0] rgb;

logic rst; always_comb rst = buttons[0];

wire debounced;
debouncer #(.BOUNCE_TICKS(250)) DEBOUNCE(
  .clk(clk), .rst(rst),
  .bouncy_in(buttons[1]),
  .debounced_out(debounced)
);

wire positive_edge;
edge_detector_moore EDGE_DETECTOR(
  .clk(clk), .rst(rst),
  .in(debounced), 
  .positive_edge(positive_edge)
);


endmodule