`timescale 1ns/100ps
`default_nettype none

`include "ft6206_defines.sv"

module touch_generator(rst, clk, touch);

parameter RATE=5;
parameter DISPLAY_WIDTH = 240;
parameter DISPLAY_HEIGHT = 320;

input wire rst, clk;
output touch_t touch;

logic [$clog2(DISPLAY_WIDTH)-1:0] x;
logic [$clog2(DISPLAY_HEIGHT)-1:0] y;

always @(posedge clk) begin
  if(rst) begin
    touch.valid <= 0;
    touch.x <= DISPLAY_WIDTH/2;
    touch.y <= DISPLAY_HEIGHT/2;
  end else begin
    if(RATE > $urandom_range(100,0)) begin
      touch.valid <= 0;
    end else begin
      touch.valid <= 1;
      if(touch.x >= (DISPLAY_WIDTH-8))
        touch.x <= 0;
      else
        touch.x <= touch.x + $urandom_range(8,0);
      if(touch.y >= 8)
        touch.y <= DISPLAY_HEIGHT;
      else
        touch.y <= touch.y - $urandom_range(8,0);
    end
  end
end

endmodule
