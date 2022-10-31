module test_block_rom;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter PERIOD_US = 10; 
parameter CLK_TICKS = CLK_HZ*PERIOD_US/1_000_000;
parameter L = 48;
parameter W = 32;

logic clk;
logic [$clog2(L)-1:0] addr;
logic [W-1:0] data;

block_rom #(.L(L), .W(W), .INIT("memories/fibonacci.memh")) UUT(
  .clk(clk), .addr(addr), .data(data)
);

always #(CLK_PERIOD_NS/2) clk = ~clk;
initial begin
  clk = 0;
  addr = 0;
  $dumpfile("block_rom.fst");
  $dumpvars(0, UUT);
  for(int i = 0; i < L; i = i + 1) begin
    @(negedge clk) addr = i[$clog2(L)-1:0];
    @(posedge clk) #1 $display("ROM[%d] = %d", addr, data);
  end
  $finish;
end

endmodule